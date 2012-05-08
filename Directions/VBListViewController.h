//
//  VBListViewController.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBRoutePresentation.h"

@interface VBListViewController : UIViewController <VBRoutePresentation>
@property (weak, nonatomic) IBOutlet UILabel *distanceToNextCheckpoint;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@end
