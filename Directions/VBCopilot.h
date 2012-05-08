//
//  VBCopilot.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^VBCopilotGetLocationCompletionBlock)(CLLocation *newLocation, NSError *error);

@interface VBCopilot : NSObject <CLLocationManagerDelegate>
@property (strong, readonly) NSDictionary *currentStep; 
@property (strong, readonly) CLLocation *latestKnownLocation;
@property (readonly) CLLocationDistance distanceToEndPoint; 

+ (VBCopilot *)sharedCopilot; 
- (void)updateLocation:(VBCopilotGetLocationCompletionBlock)cb; 
@end
