//
//  ViewController.m
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 25-02-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import "ViewController.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "NSUserDefaults+JHLASync.h"

#import "JHLGoogleImageNode.h"
#import "GoogleImagesDatasource.h"
#import "GoogleImageInfo.h"
#import "DetailViewController.h"

static NSString * const DETAIL_SEGUE_IDENTIFIER = @"detail";

@interface ViewController () <ASCollectionViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property UISearchBar *searchBar;
@property ASCollectionView *collectionView;
@property GoogleImagesDatasource *imagesDatasource;
@property UITableView *searchHistoryTable;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) {
        return nil;
    }
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectZero];
    _searchBar.delegate = self;
    _searchBar.prompt = NSLocalizedString(@"Enter search term(s)", nil);
    self.navigationItem.titleView = _searchBar;
    
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
    
    [self refreshData];

}

- (void)refreshData {
    NSLog(@"Refresh");

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

    NSArray *searchHistory = [NSUserDefaults standardUserDefaults].searchHistory;

    //Make sure the view fits.
    CGFloat preferredSearchHistoryTableHeigh = MIN(self.searchHistoryTable.rowHeight * searchHistory.count, self.view.frame.size.height - self.topLayoutGuide.length);
    self.searchHistoryTable.frame = CGRectMake(10.0, self.topLayoutGuide.length, self.searchBar.frame.size.width - 20.0, preferredSearchHistoryTableHeigh);
}

- (void)updateSearchText:(NSString *)searchText {
    NSMutableArray *deletedIndexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.imagesDatasource.numberOfImages; i++) {
        [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    self.imagesDatasource.searchString = searchText;
    
    [self.collectionView deleteItemsAtIndexPaths:deletedIndexPaths];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSearchText:searchText];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSArray *searchHistory = [NSUserDefaults standardUserDefaults].searchHistory;

    if (searchHistory.count > 0) {
        self.searchHistoryTable = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.searchHistoryTable.rowHeight = 44.0;
        self.searchHistoryTable.layer.borderWidth = 0.5;
        self.searchHistoryTable.delegate = self;
        self.searchHistoryTable.dataSource = self;
        self.searchHistoryTable.allowsSelection = YES;
    }
    
    [self.view addSubview:self.searchHistoryTable];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"end search edit");
    [self.searchHistoryTable removeFromSuperview];
    self.searchHistoryTable = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length > 0) {
        NSMutableArray *searchHistory = [[NSUserDefaults standardUserDefaults].searchHistory mutableCopy];

        [searchHistory removeObject:searchBar.text];
        [searchHistory insertObject:searchBar.text atIndex:0];

        [NSUserDefaults standardUserDefaults].searchHistory = searchHistory;
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self refreshData];
    [self.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *searchHistory = [NSUserDefaults standardUserDefaults].searchHistory;

    NSString *searchText = [searchHistory objectAtIndex:indexPath.row];
    self.searchBar.text = searchText;
    [self updateSearchText:searchText];
    [self refreshData];
    [self.searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *searchHistory = [NSUserDefaults standardUserDefaults].searchHistory;

    return searchHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *searchHistory = [NSUserDefaults standardUserDefaults].searchHistory;

    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [searchHistory objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(ASCollectionView *)collectionView willBeginBatchFetchWithContext:(ASBatchContext *)context {
    NSLog(@"Fetch batch");
    
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:DETAIL_SEGUE_IDENTIFIER sender:[self.imagesDatasource imageInfoForIndex:indexPath.row]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *detailVC = (DetailViewController *)segue.destinationViewController;
    detailVC.imageInfo = (GoogleImageInfo *)sender;
}

@end
