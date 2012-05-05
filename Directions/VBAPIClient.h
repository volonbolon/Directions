//
//  VBAPIClient.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPClient.h"

@interface VBAPIClient : AFHTTPClient
@property (strong, readonly) NSArray *routePoints; 
+ (VBAPIClient *)sharedClient;
- (void)produceRouteWithUserInformation:(NSDictionary *)userInfo; 
- (BOOL)shouldAskForNewParams;
@end
