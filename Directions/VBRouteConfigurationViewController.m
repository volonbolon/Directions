//
//  VBRouteConfigurationViewController.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBRouteConfigurationViewController.h"

@interface VBRouteConfigurationViewController ()
@property (strong) NSArray *routeModes; 
@end

@implementation VBRouteConfigurationViewController
@synthesize scrollView;
@synthesize originStreetTextField;
@synthesize originCityTextField;
@synthesize originStateTextField;
@synthesize destinationStreetTextField;
@synthesize destinationCityTextField;
@synthesize destinationStateTextField;
@synthesize avoidTollsSwitch;
@synthesize avoidHighwaysSwitch;
@synthesize modePickerView;

@synthesize routeModes; 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSArray *rm = [[NSArray alloc] initWithObjects:@"driving", @"walking", @"bicycling", nil]; 
        [self setRouteModes:rm]; 
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setLeftBarButtonItem:SYSBARBUTTON(UIBarButtonSystemItemCancel, @selector(cancelButtonTapped))]; 
    [[self navigationItem] setRightBarButtonItem:SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(doneButtonTapped))]; 
    
    [[self scrollView] setContentSize:CGSizeMake(320, 563)];
    [[self scrollView] setCanCancelContentTouches:NO]; 
    [[self scrollView] setDelaysContentTouches:NO]; 
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setOriginStreetTextField:nil];
    [self setOriginCityTextField:nil];
    [self setOriginStateTextField:nil];
    [self setDestinationStreetTextField:nil];
    [self setDestinationCityTextField:nil];
    [self setDestinationStateTextField:nil];
    [self setAvoidTollsSwitch:nil];
    [self setAvoidHighwaysSwitch:nil];
    [self setModePickerView:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelButtonTapped {
    [[self parentViewController] dismissViewControllerAnimated:YES
                                                    completion:^{
                                                        
                                                    }]; 
}

- (IBAction)doneButtonTapped {
    
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self routeModes] count]; 
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView 
             titleForRow:(NSInteger)row 
            forComponent:(NSInteger)component {
    return [[self routeModes] objectAtIndex:row]; 
}

#pragma mark - UITextFieldDelegate 
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ( [textField isEqual:[self originStreetTextField]] ) {
        [[self scrollView] setContentOffset:CGPointMake(0, 0)
                                   animated:YES]; 
    }
    
    if ( [textField isEqual:[self originCityTextField]] || [textField isEqual:[self originStateTextField]] ) {
        [[self scrollView] setContentOffset:CGPointMake(0, 40) 
                                   animated:YES]; 
    }
    
    if ( [textField isEqual:[self destinationStreetTextField]] ) {
        [[self scrollView] setContentOffset:CGPointMake(0, 80)
                                   animated:YES]; 
    }
    
    if ( [textField isEqual:[self destinationCityTextField]] || [textField isEqual:[self destinationStateTextField]] ) {
        [[self scrollView] setContentOffset:CGPointMake(0, 120) animated:YES]; 
    }
} 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( [textField isEqual:[self originStreetTextField]] ) {
        [[self originCityTextField] becomeFirstResponder];
    } else if ( [textField isEqual:[self originCityTextField]] ) {
        [[self originStateTextField] becomeFirstResponder];
    } else if ( [textField isEqual:[self originStateTextField]] ) {
        [[self destinationStreetTextField] becomeFirstResponder];
    } else if ( [textField isEqual:[self destinationStreetTextField]] ) {
        [[self destinationCityTextField] becomeFirstResponder];
    } else if ( [textField isEqual:[self destinationCityTextField]] ) {
        [[self destinationStateTextField] becomeFirstResponder];
    } else {
        [textField resignFirstResponder]; 
    }
    
    
    return YES; 
}

@end
