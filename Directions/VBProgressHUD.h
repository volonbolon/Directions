//
//  VBProgressHUD.h
//  klroy
//
//  Created by Ariel Rodriguez on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    VBProgressHUDMaskTypeNone = 1, // allow user interactions while HUD is displayed
    VBProgressHUDMaskTypeClear, // don't allow
    VBProgressHUDMaskTypeBlack, // don't allow and dim the UI in the back of the HUD
    VBProgressHUDMaskTypeGradient // don't allow and dim the UI with a a-la-alert-view bg gradient
};

typedef NSUInteger VBProgressHUDMaskType;

@interface VBProgressHUD : UIWindow

+ (void)show;
+ (void)showWithStatus:(NSString *)status;
+ (void)showWithStatus:(NSString *)status 
      networkIndicator:(BOOL)show;
+ (void)showWithStatus:(NSString *)status 
              maskType:(VBProgressHUDMaskType)maskType;
+ (void)showWithStatus:(NSString *)status 
              maskType:(VBProgressHUDMaskType)maskType
      networkIndicator:(BOOL)show;
+ (void)showWithMaskType:(VBProgressHUDMaskType)maskType;
+ (void)showWithMaskType:(VBProgressHUDMaskType)maskType 
        networkIndicator:(BOOL)show;

+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)setStatus:(NSString *)string; // change the HUD loading status while it's showing

+ (void)dismiss; // simply dismiss the HUD with a fade+scale out animation
+ (void)dismissWithSuccess:(NSString *)successString; // also displays the success icon image
+ (void)dismissWithSuccess:(NSString *)successString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString *)errorString; // also displays the error icon image
+ (void)dismissWithError:(NSString *)errorString afterDelay:(NSTimeInterval)seconds;

@end
