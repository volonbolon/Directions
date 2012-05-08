//
//  UIAlertView+VBErrorFeedback.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+VBErrorFeedback.h"

@implementation UIAlertView (VBErrorFeedback)
+ (void)presentAlertViewWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedRecoverySuggestion]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil]; 
        [alertView show]; 
    }); 
}
@end
