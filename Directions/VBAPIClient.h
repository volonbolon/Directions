//
//  VBAPIClient.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPClient.h"

extern NSString *const kOriginKey;
extern NSString *const kDestinationKey;
extern NSString *const kModeKey;
extern NSString *const kAvoidKey;
extern NSString *const kSensorKey;

extern NSString *const kNewRouteNotificationName;
extern NSString *const kRouteFailNotificationName;

@interface VBAPIClient : AFHTTPClient
@property (strong, readonly) NSDictionary *route;  
+ (VBAPIClient *)sharedClient;
- (void)produceRouteWithUserInformation:(NSDictionary *)userInfo; 
- (BOOL)shouldAskForNewParams;
@end
