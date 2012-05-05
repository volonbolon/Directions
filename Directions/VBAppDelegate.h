//
//  VBAppDelegate.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VBSegmentsController;

@interface VBAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) VBSegmentsController *segmentsController;
@property (strong, nonatomic) UIWindow *window;

@end
