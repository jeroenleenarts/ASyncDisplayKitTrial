//
//  GoogleImagesDatasource.h
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 01-03-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface GoogleImagesDatasource : NSObject <ASCollectionViewDataSource>

@property (nonatomic, copy) NSString* searchString;
@property (nonatomic, readonly) NSUInteger numberOfImages;

- (void)fetchBatchOnCompletion:(void(^)(NSError *error))completionBlock;

@end
