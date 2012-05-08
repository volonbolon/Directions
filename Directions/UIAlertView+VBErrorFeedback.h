//
//  UIAlertView+VBErrorFeedback.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (VBErrorFeedback)
+ (void)presentAlertViewWithError:(NSError *)error; 
@end
