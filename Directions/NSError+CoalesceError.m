//
//  NSError+CoalesceError.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSError+CoalesceError.h"

NSUInteger const VBValidationMultipleErrorsError = 101; 
NSString *const VBDetailedErrorsKey = @"VBDetailedErrorsKey";

@implementation NSError (CoalesceError)
+ (NSError *)errorFromOriginalError:(NSError *)originalError 
                              error:(NSError *)secondError {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary]; 
    NSMutableArray *errors = [NSMutableArray array]; 
    
    if ( originalError != nil && [originalError code] == VBValidationMultipleErrorsError ) {
        [userInfo addEntriesFromDictionary:[originalError userInfo]]; 
        [errors addObjectsFromArray:[userInfo objectForKey:VBDetailedErrorsKey]]; 
    } else {
        [errors addObject:secondError]; 
    }
    [userInfo setObject:errors forKey:VBDetailedErrorsKey]; 
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:VBValidationMultipleErrorsError 
                           userInfo:userInfo];
}
@end
