//
//  VBCopilot.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBCopilot.h"

@interface VBCopilot ()
@property (strong, readwrite) NSDictionary *currentStep;
@end

@implementation VBCopilot
@synthesize currentStep; 
+ (VBCopilot *)sharedCopilot {
    static dispatch_once_t pred;
    static VBCopilot *copilot = nil;
    
    dispatch_once(&pred, ^{ 
        copilot = [[self alloc] init]; 
    });
    return copilot;
}
@end
