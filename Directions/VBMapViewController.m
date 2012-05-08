//
//  VBMapViewController.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBMapViewController.h"
#import "VBAPIClient.h"
#import "VBCopilot.h"
#import "VBProgressHUD.h"
#import "NSString+HTMLStripper.h"
#import "MKPolyline+GoogleAPIEncodedString.h"

@interface VBMapViewController () 
 
@end

@implementation VBMapViewController
@synthesize mapView;
@synthesize toolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MKUserTrackingBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:[self mapView]]; 
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    NSArray *toolBarItems = [[NSArray alloc] initWithObjects:flexibleSpace, trackingButton, nil]; 
    [[self toolbar] setItems:toolBarItems animated:YES]; 
    
    [[VBCopilot sharedCopilot] addObserver:self
                                forKeyPath:@"currentStep" 
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];
    
    [[self mapView] setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    
    [[VBCopilot sharedCopilot] removeObserver:self
                                   forKeyPath:@"currentStep"];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)showRoute {
    NSDictionary *route = [[[[VBAPIClient sharedClient] route] objectForKey:@"routes"] objectAtIndex:0];
    NSDictionary *bounds = [route objectForKey:@"bounds"];
    NSDictionary *northeastDictionary = [bounds objectForKey:@"northeast"]; 
    NSDictionary *southwestDictionary = [bounds objectForKey:@"southwest"]; 
    CLLocationCoordinate2D northeastCoordinate = CLLocationCoordinate2DMake([[northeastDictionary objectForKey:@"lat"] doubleValue], [[northeastDictionary objectForKey:@"lng"] doubleValue]);
     CLLocationCoordinate2D southwestCoordinate = CLLocationCoordinate2DMake([[southwestDictionary objectForKey:@"lat"] doubleValue], [[southwestDictionary objectForKey:@"lng"] doubleValue]);
    MKMapPoint northeastPoint = MKMapPointForCoordinate(northeastCoordinate); 
    MKMapPoint southwestPoint = MKMapPointForCoordinate(southwestCoordinate); 
    
    MKMapRect mapRect = MKMapRectMake(fmin(northeastPoint.x, southwestPoint.x), fmin(northeastPoint.y, southwestPoint.y), fabs(northeastPoint.x - southwestPoint.x), fabs(northeastPoint.y - southwestPoint.y)); 

    [[self mapView] setVisibleMapRect:mapRect animated:YES]; 
    
    NSString *encodedPolyline = [[route objectForKey:@"overview_polyline"] objectForKey:@"points"]; 
    MKPolyline *polyline = [MKPolyline polylineWithEncodedString:encodedPolyline]; 
    [[self mapView] addOverlay:polyline]; 
}

- (MKOverlayView *)mapView:(MKMapView *)mapView
            viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithOverlay:overlay];
    overlayView.lineWidth = 5;
    overlayView.strokeColor = [UIColor purpleColor];
    overlayView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5f];
    return overlayView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [VBProgressHUD showSuccessWithStatus:[[[[VBCopilot sharedCopilot] currentStep] objectForKey:@"html_instructions"] stringByStrippingHTML]];
}

@end
