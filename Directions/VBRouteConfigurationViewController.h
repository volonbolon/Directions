//
//  VBRouteConfigurationViewController.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBRouteConfigurationViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *originStreetTextField;
@property (weak, nonatomic) IBOutlet UITextField *originCityTextField;
@property (weak, nonatomic) IBOutlet UITextField *originStateTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationStreetTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationCityTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationStateTextField;
@property (weak, nonatomic) IBOutlet UISwitch *avoidTollsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *avoidHighwaysSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *modePickerView;

- (IBAction)cancelButtonTapped;
- (IBAction)doneButtonTapped;
- (IBAction)getCurrentLocation;
@end
