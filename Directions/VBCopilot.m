//
//  VBCopilot.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBCopilot.h"
#import "VBAPIClient.h"
#import "VBProgressHUD.h"

@interface VBCopilot ()
@property (strong) NSArray *steps; 
@property (strong, readwrite) NSDictionary *currentStep;
@property (assign) NSUInteger selectedIndex; 
@property (strong) CLLocationManager *locationManager; 
@property (strong) CLLocation *latestKnownLocation;
@property (strong) CLLocation *endLocationForCurrentStep; 

- (void)handleRouteNotification:(NSNotification *)notification; 
- (void)updateStep:(NSUInteger)newIndex; 
@end

@implementation VBCopilot
@synthesize locationManager; 
@synthesize currentStep; 
@synthesize selectedIndex; 
@synthesize steps; 
@synthesize latestKnownLocation;
@synthesize endLocationForCurrentStep; 

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

- (id)init {
    self = [super init]; 
    
    if ( self != nil ) {
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        [lm setDelegate:self]; 
        [lm setDesiredAccuracy:kCLLocationAccuracyBestForNavigation]; 
        [lm setDistanceFilter:10]; 
         
        [self setLocationManager:lm]; 
    }
    
    return self; 
}

- (void)handleRouteNotification:(NSNotification *)notification {
    NSDictionary *route = [[[[VBAPIClient sharedClient] route] objectForKey:@"routes"] objectAtIndex:0];
    NSDictionary *leg = [[route objectForKey:@"legs"] objectAtIndex:0]; 
    [self setSteps:[leg objectForKey:@"steps"]]; 
    
    [self updateStep:0];
        
    [[self locationManager] startUpdatingLocation];
    
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        CLLocationAccuracy horizontalAccuracy = [[self latestKnownLocation] horizontalAccuracy]; 
        if ( horizontalAccuracy > 100.0 || horizontalAccuracy < 0.0 ) {
            [[self locationManager] stopUpdatingLocation]; 
            
            UIAlertView *noAccurateEnoughLocationAlertView = [[UIAlertView alloc] initWithTitle:@"No Accurate Enough Location"
                                                                                        message:nil
                                                                                       delegate:nil
                                                                              cancelButtonTitle:@"Dismiss"
                                                                              otherButtonTitles:nil]; 
            [noAccurateEnoughLocationAlertView show]; 
        }
    });
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if ( abs(howRecent) < 15.0 ) {
        [self setLatestKnownLocation:newLocation];
        
        if ( [newLocation distanceFromLocation:[self endLocationForCurrentStep]] < 10.0 ) {
            NSUInteger newIndex = [self selectedIndex]+1;
            if ( [[self steps] count] > newIndex ) {
                [self updateStep:newIndex]; 
            } else {
                [[self locationManager] stopUpdatingLocation]; 
                [self setSteps:nil]; 
                [self setCurrentStep:nil]; 
                [self setEndLocationForCurrentStep:nil]; 
                
                [VBProgressHUD showSuccessWithStatus:@"We reach the end point"]; 
            }
        }
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
    }
}
  
- (void)updateStep:(NSUInteger)newIndex {
    [self setSelectedIndex:newIndex]; 
    [self setCurrentStep:[[self steps] objectAtIndex:newIndex]]; 
    NSDictionary *endLocation = [[self currentStep] objectForKey:@"end_location"];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[[endLocation objectForKey:@"lat"] doubleValue]
                                                 longitude:[[endLocation objectForKey:@"lng"] doubleValue]];
    [self setEndLocationForCurrentStep:loc]; 
}

@end
