//
//  VBRouteConfigurationViewController.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBRouteConfigurationViewController.h"
#import "VBAPIClient.h"
#import "NSError+CoalesceError.h"
#import "VBProgressHUD.h"
#import "VBCopilot.h"
#import "UIAlertView+VBErrorFeedback.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>

@interface VBRouteConfigurationViewController ()
@property (strong) NSArray *routeModes; 
@property (strong) CLPlacemark *originPlacemark; 
@property (strong) CLPlacemark *destinationPlacemark;

- (BOOL)checkOrigin; 
- (BOOL)checkDestination; 
- (void)retrievePlacemarks; 
- (void)completeRouteConfiguration; 
- (void)handleRouteNotification:(NSNotification *)notification; 
- (void)cleanView;  
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
@synthesize originPlacemark; 
@synthesize destinationPlacemark; 

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
    
    UIBarButtonItem *cancelButtonItem = SYSBARBUTTON(UIBarButtonSystemItemCancel, @selector(cancelButtonTapped)); 
    [cancelButtonItem setAccessibilityHint:@"Cancel"];
    [cancelButtonItem setAccessibilityLabel:@"Cancel"]; 
    [[self navigationItem] setLeftBarButtonItem:cancelButtonItem]; 
    
    UIBarButtonItem *doneButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(doneButtonTapped)); 
    [doneButtonItem setAccessibilityHint:@"Done"];
    [doneButtonItem setAccessibilityLabel:@"Done"]; 
    [[self navigationItem] setRightBarButtonItem:doneButtonItem]; 
    
    [[self scrollView] setContentSize:CGSizeMake(320, 563)];
    [[self scrollView] setCanCancelContentTouches:NO]; 
    [[self scrollView] setDelaysContentTouches:NO]; 
}

- (void)viewDidDisappear:(BOOL)animated {
    [[self originStreetTextField] setText:@""]; 
    [[self originCityTextField] setText:@""]; 
    [[self originStateTextField] setText:@""]; 
    
    [[self destinationStreetTextField] setText:@""]; 
    [[self destinationCityTextField] setText:@""]; 
    [[self destinationStateTextField] setText:@""]; 
    
    [[self avoidTollsSwitch] setOn:NO];
    [[self avoidHighwaysSwitch] setOn:NO];
    
    [[self modePickerView] selectRow:0
                         inComponent:0 
                            animated:NO];
    
    [super viewDidDisappear:animated]; 
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
                                                    completion:^{}]; 
}

- (IBAction)doneButtonTapped {
    if ( ![self checkOrigin] || ![self checkDestination] ) {
        UIAlertView *missingData = [[UIAlertView alloc] initWithTitle:@"Missing Data"
                                                              message:@"Origin and Destination information whould be completed"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Dismiss"
                                                    otherButtonTitles:nil];
        [missingData show]; 
        return; 
    }
    [self cleanView]; 
    [VBProgressHUD showWithStatus:@"Loading Route"
                 networkIndicator:YES]; 
    [self retrievePlacemarks]; 
}

- (IBAction)getCurrentLocation {
    [VBProgressHUD showWithStatus:@"Loading Current Location" 
                 networkIndicator:YES]; 
    [[VBCopilot sharedCopilot] updateLocation:^(CLLocation *newLocation, NSError *error) {
        if ( error != nil ) {
            [UIAlertView presentAlertViewWithError:error]; 
        } else if ( newLocation != nil ){
            CLGeocoder *geocoder = [[CLGeocoder alloc] init]; 
            [geocoder reverseGeocodeLocation:newLocation
                           completionHandler:^(NSArray *placemarks, NSError *error) {
                               if ( error != nil ) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [VBProgressHUD dismissWithError:[error localizedDescription] afterDelay:3.0]; 
                                   }); 
                               } else {
                                   CLPlacemark *op = [placemarks objectAtIndex:0]; 
                                   NSDictionary *addressDictionary = [op addressDictionary]; 
                                   NSString *streetAddress = [addressDictionary objectForKey:(NSString *)kABPersonAddressStreetKey]; 
                                   NSString *city = [addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey]; 
                                   NSString *state = [addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [VBProgressHUD dismissWithSuccess:@"Found Location"]; 
                                       [[self originStreetTextField] setText:streetAddress]; 
                                       [[self originCityTextField] setText:city];
                                       [[self originStateTextField] setText:state]; 
                                       [[self destinationCityTextField] setText:city]; 
                                       [[self destinationStateTextField] setText:state]; 
                                   }); 
                               }
                           }]; 
        }
    }]; 
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView 
numberOfRowsInComponent:(NSInteger)component {
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ( [textField  isEqual:[self originCityTextField]] ) {
        [[self destinationCityTextField] setText:[textField text]]; 
    }
    if ( [textField  isEqual:[self originStateTextField]] ) {
        [[self destinationStateTextField] setText:[textField text]]; 
    }
    return YES; 
}

- (BOOL)checkOrigin {
    return [[[self originStreetTextField] text] length] > 0 && [[[self originCityTextField] text] length] > 0 && [[[self originStateTextField] text] length] > 0; 
}

- (BOOL)checkDestination {
    return [[[self destinationStreetTextField] text] length] > 0 && [[[self destinationCityTextField] text] length] > 0 && [[[self destinationStateTextField] text] length] > 0;
}

- (void)retrievePlacemarks {
    dispatch_queue_t geocode_queue;
    geocode_queue = dispatch_queue_create("vb.directions.geocode_queue", NULL);
    dispatch_group_t group = dispatch_group_create();
    
    __block NSError *originalError = nil; 
    
    NSDictionary *originDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[[self originStreetTextField] text], kABPersonAddressStreetKey, 
                                      [[self originCityTextField] text], kABPersonAddressCityKey, 
                                      [[self originStateTextField] text], kABPersonAddressStateKey, nil]; 
    
    NSDictionary *destinationDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[[self destinationStreetTextField] text], kABPersonAddressStreetKey, 
                                           [[self destinationCityTextField] text], kABPersonAddressCityKey, 
                                           [[self destinationStateTextField] text], kABPersonAddressStateKey, nil]; 
    
    dispatch_group_async(group, geocode_queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        CLGeocoder *geocoder = [[CLGeocoder alloc] init]; 
    
        [geocoder geocodeAddressDictionary:originDictionary 
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             if ( error != nil ) {
                                 originalError = [NSError errorFromOriginalError:originalError
                                                                           error:error]; 
                             } else {
                                 if ( [placemarks count] > 0 ) {
                                     [self setOriginPlacemark:[placemarks objectAtIndex:0]]; 
                                 }
                             }
                             dispatch_semaphore_signal(semaphore);
                         }]; 
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
    });
    
    dispatch_group_async(group, geocode_queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
        CLGeocoder *geocoder = [[CLGeocoder alloc] init]; 
        
        [geocoder geocodeAddressDictionary:destinationDictionary
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             if ( error != nil ) {
                                 originalError = [NSError errorFromOriginalError:originalError
                                                                           error:error]; 
                             } else {
                                 if ( [placemarks count] > 0 ) {
                                     [self setDestinationPlacemark:[placemarks objectAtIndex:0]]; 
                                 }
                             }
                             dispatch_semaphore_signal(semaphore);
                         }]; 
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
    });
    
    dispatch_group_notify(group, geocode_queue, ^{
        if ( originalError != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [VBProgressHUD dismissWithError:@"Unable to found a suitable route" afterDelay:5]; 
            }); 
        } else {
            [self completeRouteConfiguration];
        }
    });
}

- (void)completeRouteConfiguration {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteNotification:)
                                                     name:kNewRouteNotificationName
                                                   object:nil]; 
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRouteNotification:)
                                                     name:kRouteFailNotificationName
                                                   object:nil]; 
    }); 
    CLLocation *originLocation = [originPlacemark location]; 
    CLLocation *destinationLocation = [destinationPlacemark location]; 
    
    NSString *originAsString = [[NSString alloc] initWithFormat:@"%f,%f", [originLocation coordinate].latitude, [originLocation coordinate].longitude];
    NSString *destinationAsString = [[NSString alloc] initWithFormat:@"%f,%f", [destinationLocation coordinate].latitude, [destinationLocation coordinate].longitude]; 
    
    NSMutableArray *avoidBits = [[NSMutableArray alloc] initWithCapacity:2];
    
    if ( [[self avoidTollsSwitch] isOn] ) {
        [avoidBits addObject:@"tolls"]; 
    }
    if ( [[self avoidHighwaysSwitch] isOn] ) {
        [avoidBits addObject:@"highways"]; 
    }
    
    NSDictionary *userInfo = nil; 
    if ( [avoidBits count] > 0 ) {
       userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:originAsString, kOriginKey,
                   destinationAsString, kDestinationKey,
                   [avoidBits componentsJoinedByString:@","], kAvoidKey, 
                   [[self routeModes] objectAtIndex:[[self modePickerView] selectedRowInComponent:0]], kModeKey,
                   @"true", kSensorKey, nil]; 
    } else {
        userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:originAsString, kOriginKey,
                    destinationAsString, kDestinationKey,
                    [[self routeModes] objectAtIndex:[[self modePickerView] selectedRowInComponent:0]], kModeKey, 
                    @"true", kSensorKey, nil]; 
    }
    
    [[VBAPIClient sharedClient] produceRouteWithUserInformation:userInfo]; 
}

- (void)handleRouteNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
    if ( [[notification name] isEqualToString:kNewRouteNotificationName] ) {
        [VBProgressHUD dismissWithSuccess:@"Route found"]; 
        [[self parentViewController] dismissViewControllerAnimated:YES 
                                                        completion:^{}]; 
    } else if ( [[notification name] isEqualToString:kRouteFailNotificationName] ) {
        [VBProgressHUD dismissWithError:@"No route found" 
                             afterDelay:3]; 
    }
}

- (void)cleanView {
    [[self originStreetTextField] resignFirstResponder]; 
    [[self originCityTextField] resignFirstResponder]; 
    [[self originStateTextField] resignFirstResponder]; 
    
    [[self destinationStreetTextField] resignFirstResponder]; 
    [[self destinationCityTextField] resignFirstResponder]; 
    [[self destinationStateTextField] resignFirstResponder]; 
    
    [[self scrollView] setContentOffset:CGPointMake(0, 0) 
                               animated:YES]; 
}

@end
