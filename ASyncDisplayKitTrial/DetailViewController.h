//
//  DetailViewController.h
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 02-03-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoogleImageInfo;

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) GoogleImageInfo *imageInfo;

@end
