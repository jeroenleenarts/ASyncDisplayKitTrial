//
//  GoogleImageInfo.m
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 01-03-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import "GoogleImageInfo.h"

@implementation GoogleImageInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"title": @"titleNoFormatting",
             @"tbURLString": @"tbUrl",
             @"URLString": @"url"
             };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"title: %@ | tbUrl: %@", self.title, self.tbURLString];
}


@end
