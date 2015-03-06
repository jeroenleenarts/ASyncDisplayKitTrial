//
//  NSUserDefaults+JHLASync.m
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 06-03-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import "NSUSerDefaults+JHLASync.h"

@implementation NSUserDefaults(JHLASync)

- (NSArray *)searchHistory {
    NSArray *searchHistory = [self arrayForKey:@"searchHistory"];
    if (searchHistory == nil) {
        searchHistory = [NSArray array];
    }
    return searchHistory;
}

- (void)setSearchHistory:(NSArray *)searchHistory {
    if (searchHistory.count > 12) {
        searchHistory = [searchHistory subarrayWithRange:NSMakeRange(0, 12)];
    }
    [self setObject:searchHistory forKey:@"searchHistory"];
}

@end
