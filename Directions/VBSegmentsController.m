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

@interface VBSegmentsController ()
@property (strong, nonatomic, readwrite) NSArray *viewControllers; 
@property (strong, nonatomic, readwrite) UINavigationController *navigationController; 
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
    }
    return self; 
}

- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)segmentedControl {
    NSUInteger index = [segmentedControl selectedSegmentIndex]; 
    UIViewController *incomingViewController = [[self viewControllers] objectAtIndex:index]; 
    [[self navigationController] setViewControllers:[NSArray arrayWithObject:incomingViewController] animated:NO];
    [[incomingViewController navigationItem] setTitleView:segmentedControl]; 
    [[incomingViewController navigationItem] setRightBarButtonItem:BARBUTTON(@"New Route", @selector(presentNewRouteConfiguration))]; 
}

- (IBAction)presentNewRouteConfiguration {
    VBRouteConfigurationViewController *rcvc = [[VBRouteConfigurationViewController alloc] initWithNibName:@"VBRouteConfigurationViewController"
                                                                                                    bundle:nil];
    UINavigationController *rootController = [[UINavigationController alloc] initWithRootViewController:rcvc]; 
     
    [rootController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal]; 
    [[self navigationController] presentViewController:rootController
                                              animated:YES 
                                            completion:^{}]; 
}

@end
