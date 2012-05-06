//
//  NSError+CoalesceError.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSUInteger const VBValidationMultipleErrorsError;
extern NSString *const VBDetailedErrorsKey;

@interface NSError (CoalesceError)
+ (NSError *)errorFromOriginalError:(NSError *)originalError 
                              error:(NSError *)secondError;  
@end
