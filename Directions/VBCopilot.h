//
//  VBCopilot.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VBCopilot : NSObject
+ (VBCopilot *)sharedCopilot; 
@property (strong, readonly) NSDictionary *currentStep; 
@end
