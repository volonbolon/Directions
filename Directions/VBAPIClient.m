//
//  VBAPIClient.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBAPIClient.h"
#import "AFJSONRequestOperation.h"

@interface VBAPIClient ()
@property (strong, readwrite) NSArray *routePoints;
@end

@implementation VBAPIClient
@synthesize routePoints;

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
    }
    
    return self;
}

- (void)produceRouteWithUserInformation:(NSDictionary *)userInfo {
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"-34.630672,-58.434915", @"origin", 
                            @"-34.777428,-58.463057", @"destination", 
                            @"false", @"sensor", nil]; 
    NSURLRequest *request = [self requestWithMethod:@"GET"
                                               path:@"maps/api/directions/json" 
                                         parameters:params]; 
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            NSLog(@"%@", JSON);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"%@", error);
                                                                                        }]; 
    [operation start]; 
}

- (BOOL)shouldAskForNewParams {
    return YES; 
}

@end
