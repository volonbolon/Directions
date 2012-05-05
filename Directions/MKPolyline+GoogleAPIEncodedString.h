//
//  MKPolyline+GoogleAPIEncodedString.h
//  Directions
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (GoogleAPIEncodedString)
+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString; 
@end
