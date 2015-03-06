//
//  GoogleImageInfo.h
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 01-03-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MTLModel.h>
#import <MTLJSONAdapter.h>

@interface GoogleImageInfo : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* tbURLString;
@property (nonatomic, strong) NSString* URLString;

@end
