//
//  VBSegmentsController.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBSegmentsController : NSObject
// Defined as readonly to prevent edition
@property (strong, nonatomic, readonly) NSArray *viewControllers; 
@property (strong, nonatomic, readonly) UINavigationController *navigationController; 

- (id)initWithNavigationController:(UINavigationController *)theNavigationController
                   viewControllers:(NSArray *)viewControllers;
- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)segmentedControl;
- (IBAction)presentNewRouteConfiguration; 
@end
