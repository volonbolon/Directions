//
//  VBCopilot.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBCopilot.h"
#import "VBAPIClient.h"

@interface VBCopilot ()
@property (strong) NSArray *steps; 
@property (strong, readwrite) NSDictionary *currentStep;
- (void)handleRouteNotification:(NSNotification *)notification; 
@end

@implementation VBCopilot
@synthesize currentStep; 
@synthesize steps; 
+ (VBCopilot *)sharedCopilot {
    static dispatch_once_t pred;
    static VBCopilot *copilot = nil;
    
    dispatch_once(&pred, ^{ 
        copilot = [[self alloc] init]; 
        
        [[NSNotificationCenter defaultCenter] addObserver:copilot
                                                 selector:@selector(handleRouteNotification:)
                                                     name:kNewRouteNotificationName 
                                                   object:nil]; 
        
        [[NSNotificationCenter defaultCenter] addObserver:copilot
                                                 selector:@selector(handleRouteNotification:)
                                                     name:kRouteFailNotificationName 
                                                   object:nil];
    });
    return copilot;
}

- (void)handleRouteNotification:(NSNotification *)notification {
    NSDictionary *route = [[[[VBAPIClient sharedClient] route] objectForKey:@"routes"] objectAtIndex:0];
    NSDictionary *leg = [[route objectForKey:@"legs"] objectAtIndex:0]; 
    [self setSteps:[leg objectForKey:@"steps"]]; 
                    
}

@end
