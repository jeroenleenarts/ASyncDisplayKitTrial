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
#import "GoogleImagesDatasource.h"
#import "GoogleImageInfo.h"

@interface ViewController () <ASCollectionViewDelegate>

@property ASCollectionView *collectionView;
@property GoogleImagesDatasource *imagesDatasource;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) {
        return nil;
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    
    _imagesDatasource = [[GoogleImagesDatasource alloc]init];
    
    _collectionView = [[ASCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.asyncDataSource = _imagesDatasource;
    _collectionView.asyncDelegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.collectionView];
    
    //I know this is not very pretty. But considering time constraints and the fact that we're programming against a deprecated API I am not too bothered by this.
    [self.imagesDatasource fetchBatchOnCompletion:^(NSError *error) {
        if (error) {
            [self.collectionView reloadData];
            return;
        }
        [self.imagesDatasource fetchBatchOnCompletion:^(NSError *error) {
            if (error) {
                [self.collectionView reloadData];
                return;
            }
            [self.imagesDatasource fetchBatchOnCompletion:^(NSError *error) {
                if (error) {
                    [self.collectionView reloadData];
                    return;
                }
                [self.imagesDatasource fetchBatchOnCompletion:^(NSError *error) {
                    if (error) {
                        [self.collectionView reloadData];
                        return;
                    }
                    NSLog(@"Fetch finish");
                    
                    [self.collectionView reloadData];
                }];
            }];
        }];
    }];
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = self.view.frame;
}

- (void)collectionView:(ASCollectionView *)collectionView willBeginBatchFetchWithContext:(ASBatchContext *)context {
    NSLog(@"Fetch");
    
    NSInteger currentNumberOfImages = self.imagesDatasource.numberOfImages;
    void (^processResultsBlock)() = ^{
        NSLog(@"Fetch finish");
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSInteger newNumberOfImages = self.imagesDatasource.numberOfImages;
        
        for (NSInteger i = currentNumberOfImages; i < newNumberOfImages; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        
        [context completeBatchFetching:YES];
    };

    //I know this is not very pretty. But considering time constraints and the fact that we're programming against a deprecated API I am not too bothered by this.
    [self.imagesDatasource fetchBatchOnCompletion:^(NSError *error) {
        if (error) {
            processResultsBlock();
            return;
        }
        [self.imagesDatasource fetchBatchOnCompletion:^(NSError *error) {
            if (error) {
                processResultsBlock();
                return;
            }
            [self.imagesDatasource fetchBatchOnCompletion:^(NSError *error) {
                if (error) {
                    processResultsBlock();
                    return;
                }
                [self.imagesDatasource fetchBatchOnCompletion:^(NSError *error) {
                    processResultsBlock();
                }];
            }];
        }];
    }];
}

@end
