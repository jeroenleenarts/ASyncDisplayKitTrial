//
//  GoogleImagesDatasource.m
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 01-03-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import "GoogleImagesDatasource.h"
#import "GoogleImageInfo.h"
#import "JHLGoogleImageNode.h"

#import <MTLJSONAdapter.h>

static NSString  * const BASE_URL = @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&";

@interface GoogleImagesDatasource ()

@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, assign) BOOL locked;

@property (nonatomic, strong) NSMutableArray* pendingChanges;

@end

@implementation GoogleImagesDatasource

-(instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _images = [NSMutableArray array];
    _pendingChanges = [NSMutableArray array];
//    _searchString = @"cocoaheadsnl";
    
    return self;
}

-(NSUInteger)numberOfImages {
    return self.images.count;
}

- (void)fetchBatchOnCompletion:(void(^)(NSError *error))completionBlock {
    
    //Sending an empty search string is an immediate 403 error.
    if (self.searchString.length == 0) {
        NSLog(@"Empty search");
        completionBlock(nil);
        return;
    }
    NSMutableString *queryString = [NSMutableString string];
    [queryString appendString:BASE_URL];
    [queryString appendFormat:@"q=%@&", self.searchString];
    [queryString appendFormat:@"start=%lu", (unsigned long)self.images.count];
    
//    NSLog(@"queryString: %@", queryString);
    
    NSString *escapedString = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *queryUrl = [NSURL URLWithString:escapedString];
    
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession] dataTaskWithURL:queryUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionBlock(error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            completionBlock(error);
            return;
        }
        
        NSNumber *statusCode = [jsonData valueForKey:@"responseStatus"];
        if (statusCode.integerValue != 200) {
            NSError *error = [NSError errorWithDomain:@"This should be fixed" code:statusCode.integerValue userInfo:jsonData];
            completionBlock(error);
            return;
        }
        
        NSError *mtlError;
        NSArray *images = [jsonData valueForKeyPath:@"responseData.results"];
        NSArray* imagesInfo = [MTLJSONAdapter modelsOfClass:[GoogleImageInfo class] fromJSONArray:images error:&mtlError];
        [self.images addObjectsFromArray:imagesInfo];
        
        if (mtlError) {
            completionBlock(mtlError);
            return;
        }
        
        completionBlock(nil);
    }];
    
    [dataTask resume];
}

- (void)setSearchString:(NSString *)searchString {
    for (NSOperation *operation in self.pendingChanges) {
        [operation start];
    }

    _searchString = searchString;
    
    //reset datasource state, new search
    [self.images removeAllObjects];
    [self.pendingChanges removeAllObjects];
}

-(GoogleImageInfo *)imageInfoForIndex:(NSUInteger)index {
    return [self.images objectAtIndex:index];
}

- (ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    GoogleImageInfo *imageInfo = [self.images objectAtIndexedSubscript:indexPath.row];
    
    JHLGoogleImageNode *imageNode = [[JHLGoogleImageNode alloc] initWithNetworkedImageURL:[NSURL URLWithString:imageInfo.tbURL]];
    
    return imageNode;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (void)collectionViewLockDataSource:(ASCollectionView *)collectionView {
    // I have not enabled async loading of data
    NSLog(@"lock");
    self.locked = YES;
}

- (void)collectionViewUnlockDataSource:(ASCollectionView *)collectionView {
    // I have not enabled async loading of data
    NSLog(@"unlock");
    self.locked = NO;
    
    for (NSOperation *operation in self.pendingChanges) {
        [operation start];
    }
    
    [self.pendingChanges removeAllObjects];
}

@end
