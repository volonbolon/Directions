//
//  VBCopilot.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface VBCopilot : NSObject <CLLocationManagerDelegate>
+ (VBCopilot *)sharedCopilot; 
@property (strong, readonly) NSDictionary *currentStep; 
@end
