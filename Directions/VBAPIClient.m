//
//  VBAPIClient.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBAPIClient.h"
#import "AFJSONRequestOperation.h"

NSString *const kOriginKey = @"origin";
NSString *const kDestinationKey = @"destination";
NSString *const kModeKey = @"mode";
NSString *const kAvoidKey = @"avoid";
NSString *const kSensorKey = @"sensor";

NSString *const kNewRouteNotificationName = @"newRouteNotificationName";
NSString *const kRouteFailNotificationName = @"routeFailNotificationName";

@interface VBAPIClient ()
@property (strong, readwrite) NSArray *routePoints;
@property (assign) BOOL processing; 
@end

@implementation VBAPIClient
@synthesize routePoints;
@synthesize processing; 

+ (VBAPIClient *)sharedClient {
    static dispatch_once_t pred;
    static VBAPIClient *client = nil;
     
    dispatch_once(&pred, ^{ 
        NSURL *url = [[NSURL alloc] initWithString:@"http://maps.googleapis.com/"]; 
        client = [[self alloc] initWithBaseURL:url]; 
    });
    return client;
}

- (id)initWithBaseURL:(NSURL *)url {
    // maps/api/directions/json?origin=-34.630672,-58.434915&destination=-34.777428,-58.463057&sensor=false
    self = [super initWithBaseURL:url];
    if ( self != nil ) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" 
                         value:@"application/json"];
        
        [self setProcessing:NO]; 
    }
    
    return self;
}

- (void)produceRouteWithUserInformation:(NSDictionary *)userInfo {
    if ( [self processing] ) {
        return; 
    }
    
    NSURLRequest *request = [self requestWithMethod:@"GET"
                                               path:@"maps/api/directions/json" 
                                         parameters:userInfo]; 
    NSLog(@"%@", [[request URL] absoluteString]);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            NSLog(@"%@", JSON);
                                                                                            [self setProcessing:NO]; 
                                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                [[NSNotificationCenter defaultCenter] postNotificationName:kNewRouteNotificationName
                                                                                                                                                    object:nil]; 
                                                                                            }); 
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"%@", error);
                                                                                            [self setProcessing:NO]; 
                                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                [[NSNotificationCenter defaultCenter] postNotificationName:kRouteFailNotificationName
                                                                                                                                                    object:nil]; 
                                                                                            });
                                                                                        }]; 
    [self setProcessing:YES]; 
    [operation start]; 
}

- (BOOL)shouldAskForNewParams {
    return YES; 
}

@end
