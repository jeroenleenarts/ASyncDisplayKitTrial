//
//  JHLGoogleImageNode.m
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 25-02-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import "JHLGoogleImageNode.h"

static const CGFloat kCellInnerPadding = 5.0f;

@interface JHLGoogleImageNode ()
    
@property ASNetworkImageNode* imageNode;
    
@end

@implementation JHLGoogleImageNode

- (instancetype) initWithNetworkedImageURL:(NSURL *)url {
    if (!(self = [super init]))
    {
        return nil;
    }
    
    _imageNode = [[ASNetworkImageNode alloc] init];
    _imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    _imageNode.URL = url;
    [self addSubnode:_imageNode];
    
    return self;
}

- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    CGFloat availableWidth = constrainedSize.width / 3.0;
    
    return CGSizeMake(floorf(availableWidth),
                      floorf(availableWidth));
}

- (void)layout
{
    _imageNode.frame = CGRectMake(kCellInnerPadding, kCellInnerPadding, self.calculatedSize.width - 2.0 * kCellInnerPadding, self.calculatedSize.height - 2.0 * kCellInnerPadding);
}

@end
