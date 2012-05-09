//
//  VBSegmentsController.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBSegmentsController.h"
#import "VBAPIClient.h"
#import "VBRouteConfigurationViewController.h"
#import "VBRoutePresentation.h"

@interface VBSegmentsController ()
@property (strong, nonatomic, readwrite) NSArray *viewControllers; 
@property (strong, nonatomic, readwrite) UINavigationController *navigationController; 
- (void)handleRouteNotification:(NSNotification *)notification; 
- (void)showRoute; 
@end

@implementation VBSegmentsController
@synthesize viewControllers; 
@synthesize navigationController; 

- (id)initWithNavigationController:(UINavigationController *)theNavigationController
                   viewControllers:(NSArray *)vc {
    self = [super init];
    if ( self != nil ) {
        [self setNavigationController:theNavigationController]; 
        [self setViewControllers:vc]; 
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleRouteNotification:)
                                                     name:kNewRouteNotificationName
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleRouteNotification:)
                                                     name:kRouteFailNotificationName
                                                   object:nil];
    }
    return self; 
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
}

- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)segmentedControl {
    NSUInteger index = [segmentedControl selectedSegmentIndex]; 
    UIViewController *incomingViewController = [[self viewControllers] objectAtIndex:index]; 
    [[self navigationController] setViewControllers:[NSArray arrayWithObject:incomingViewController] animated:NO];
    [[incomingViewController navigationItem] setTitleView:segmentedControl]; 
    UIBarButtonItem *newRouteButtonItem = BARBUTTON(@"New Route", @selector(presentNewRouteConfiguration)); 
    [newRouteButtonItem setAccessibilityLabel:@"New Route"]; 
    [newRouteButtonItem setAccessibilityHint:@"New Route"]; 
    [[incomingViewController navigationItem] setRightBarButtonItem:newRouteButtonItem]; 
    
    [self showRoute]; 
}

- (IBAction)presentNewRouteConfiguration {
    VBRouteConfigurationViewController *rcvc = [[VBRouteConfigurationViewController alloc] initWithNibName:@"VBRouteConfigurationViewController"
                                                                                                    bundle:nil];
    UINavigationController *rootController = [[UINavigationController alloc] initWithRootViewController:rcvc]; 
     
    [rootController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal]; 
    [rootController setModalPresentationStyle:UIModalPresentationFullScreen]; 
    [[self navigationController] presentViewController:rootController
                                              animated:YES 
                                            completion:^{}]; 
}

- (void)handleRouteNotification:(NSNotification *)notification {
    [self showRoute]; 
}

- (void)showRoute {
    if ( [[[[self navigationController] viewControllers] objectAtIndex:0] conformsToProtocol:@protocol(VBRoutePresentation)] ) {
        UIViewController <VBRoutePresentation>*vc = (UIViewController <VBRoutePresentation> *)[[[self navigationController] viewControllers] objectAtIndex:0];
        [vc showRoute];
    }
}

@end
