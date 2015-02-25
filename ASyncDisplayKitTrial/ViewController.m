//
//  ViewController.m
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 25-02-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import "ViewController.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "JHLGoogleImageNode.h"

@interface ViewController () <ASCollectionViewDataSource, ASCollectionViewDelegate>

@property ASCollectionView *collectionView;
@property NSUInteger numberOfImages;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) {
        return nil;
    }
    
#pragma mark change me to a higer value
    _numberOfImages = 5;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    
    _collectionView = [[ASCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.asyncDataSource = self;
    _collectionView.asyncDelegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.collectionView];
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = self.view.frame;
}

- (ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath {

    JHLGoogleImageNode *imageNode = [[JHLGoogleImageNode alloc] initWithNetworkedImageURL:[NSURL URLWithString:@"http://dump.leenarts.net/avatar.png"]];
    
    return imageNode;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfImages;
}

- (void)collectionView:(ASCollectionView *)collectionView willBeginBatchFetchWithContext:(ASBatchContext *)context {
    NSLog(@"Fetch");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Fetch finish");
        
        NSUInteger batchSize = 50;
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSInteger currentNumberOfImages = self.numberOfImages;
        self.numberOfImages += batchSize;
        
        for (NSInteger i = 0; i < batchSize; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:currentNumberOfImages + i inSection:0]];
        }
        
        [self.collectionView insertItemsAtIndexPaths:indexPaths];

        [context completeBatchFetching:YES];
    });
}

- (void)collectionViewLockDataSource:(ASCollectionView *)collectionView {
    NSLog(@"Lock");
}

- (void)collectionViewUnlockDataSource:(ASCollectionView *)collectionView {
    NSLog(@"Unlock");
}

@end
