//
//  DetailViewController.m
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 02-03-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import "DetailViewController.h"
#import "GoogleImageInfo.h"

@implementation DetailViewController


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.infoLabel.text = NSLocalizedString(@"Loading detail image", nil);
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[self.imageInfo.URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"Finished downloading detail image");
            dispatch_async(dispatch_get_main_queue(), ^{

                if ([(NSHTTPURLResponse*)response statusCode] != 200) {
                    self.infoLabel.text = NSLocalizedString(@"Detail image unavailable.", nil);
                    return;
                }
                UIImage *image = [UIImage imageWithData:data];
                if (image == nil) {
                    self.infoLabel.text = NSLocalizedString(@"Image data corrupt", nil);
                    return;
                }
                self.imageView.image = image;
                self.infoLabel.hidden = YES;
            });
            NSLog(@"Set image");
        }
    }];
    
    [task resume];
    
}
@end
