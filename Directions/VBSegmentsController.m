//
//  VBSegmentsController.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBSegmentsController.h"

@interface VBSegmentsController ()
@property (strong, nonatomic, readwrite) NSArray *viewControllers; 
@property (strong, nonatomic, readwrite) UINavigationController *navigationController; 
@end

@implementation VBSegmentsController
@synthesize viewControllers; 
@synthesize navigationController; 

- (id)initWithNavigationController:(UINavigationController *)theNavigationController
                   viewControllers:(NSArray *)viewControllers {
    return nil;
}

- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)aSegmentedControl {
    
}
@end
