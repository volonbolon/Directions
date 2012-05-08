//
//  NSString+HTMLStripper.m
//  Directions
//
//  Created by Ariel Rodriguez on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+HTMLStripper.h"

@implementation NSString (HTMLStripper)
- (NSString *)stringByStrippingHTML {
    NSRange range;
    NSString *s = [self copy];
    while ( (range = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound ) {
        s = [s stringByReplacingCharactersInRange:range
                                       withString:@""];
    }
        
    return s; 
}

@end
