//
//  JHLGoogleImageNode.h
//  ASyncDisplayKitTrial
//
//  Created by Jeroen Leenarts on 25-02-15.
//  Copyright (c) 2015 Jeroen Leenarts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface JHLGoogleImageNode : ASCellNode

- (instancetype) initWithNetworkedImageURL:(NSURL *)url;

@end
