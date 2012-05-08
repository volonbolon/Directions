//
//  VBListViewController.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBListViewController.h"
#import "VBCopilot.h"
#import "NSString+HTMLStripper.h"

@interface VBListViewController ()

@end

@implementation VBListViewController
@synthesize distanceToNextCheckpoint;
@synthesize instructionsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *currentStep = [[VBCopilot sharedCopilot] currentStep]; 
    
    if ( currentStep == nil ) {
        UIAlertView *noRouteAlertView = [[UIAlertView alloc] initWithTitle:@"No Route"
                                                                   message:@"Please, select the origin and the destination for your route" 
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Dismiss"
                                                         otherButtonTitles:nil]; 
        [noRouteAlertView show]; 
    } else {
        [[self instructionsLabel] setText:[[currentStep objectForKey:@"html_instructions"] stringByStrippingHTML]];
    }
    
    [[VBCopilot sharedCopilot] addObserver:self
                                forKeyPath:@"distanceToEndPoint" 
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];
    [[VBCopilot sharedCopilot] addObserver:self
                                forKeyPath:@"currentStep" 
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];
}

- (void)viewDidUnload {
    [self setDistanceToNextCheckpoint:nil];
    [self setInstructionsLabel:nil];
    [super viewDidUnload];
    
    [[VBCopilot sharedCopilot] removeObserver:self forKeyPath:@"distanceToEndPoint"]; 
    [[VBCopilot sharedCopilot] removeObserver:self forKeyPath:@"currentStep"]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ( [keyPath isEqualToString:@"distanceToEndPoint"] ) {
        NSString *distanceAsString = [[NSString alloc] initWithFormat:@"%.2f m", ([[VBCopilot sharedCopilot] distanceToEndPoint]*0.000621371192)]; 
        [[self distanceToNextCheckpoint] setText:distanceAsString]; 
    } else if ( [keyPath isEqualToString:@"currentStep"] ) {
        [[self instructionsLabel] setText:[[[[VBCopilot sharedCopilot] currentStep] objectForKey:@"html_instructions"] stringByStrippingHTML]];
    }
}

#pragma mark - VBRoutePresentation
- (void)showRoute {
    NSDictionary *currentStep = [[VBCopilot sharedCopilot] currentStep]; 
    [[self instructionsLabel] setText:[[currentStep objectForKey:@"html_instructions"] stringByStrippingHTML]];
}

@end
