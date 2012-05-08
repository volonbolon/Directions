//
//  DirectionsTests.m
//  DirectionsTests
//
//  Created by Ariel Rodriguez on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DirectionsTests.h"
#import "MKPolyline+GoogleAPIEncodedString.h"
#import "NSString+HTMLStripper.h"

@implementation DirectionsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testPolyline {
    // Test coordinates extrated from 
    // http://maps.googleapis.com/maps/api/directions/json?origin=-34.630672,-58.434915&destination=-34.777428,-58.463057&sensor=false
    MKPolyline *polyline = [MKPolyline polylineWithEncodedString:@"pxjrEfatcJSiCsEl@gG~@eA}Lm@_IhHeAZTFJHl@h@lGXdCf@~DFPlAfO`@zDh@pCr@zBTl@tC|FnDrHdDdGnIjNnBnD^z@d@bB\\dBPlBDhAChHCvFP~CPnAVlANj@~@zBjB|DnAzBxAzBfEpFvC~DhEzGpAtB`@f@j@v@h@h@`ChB`Ah@bAb@dA^nHlBnCz@fBz@~AdAjDlChDzBvF`EjFzDbC~AbE~BnB`A|GfCfGtBzInDnJ~CnA\\dO~EpUdIzGhCzG|B|GrBtXdJdCx@rF|BvCbAdF|AjQvFrAf@~A`A~AhAfAbAfEdEdEnDdAp@~F~EjIrGnE~ClQpNtGzEzHtGtDtDp@fAlCnExAzBzA~BfA`AjAz@l@\\`D~@dEhAfATtA`@bBz@vKvI|HvGrA~@tEpD|GnFnEbDpCrBxExDzMtJrCtBjBjAhFlDjFzC`F|DlFnDtC|A|@|@J\\Dh@PlB`@vAXf@f@`@\\Bd@C|@Wr@]jAkA|@kAd@{@vA{B|A_C`CqEp@yA`@}AfA}D^qAhAoCj@gAjCsDnCaET]hAgArAoAvD{CnA{@lP}KrWuQhTeOzJwGvOwK~N}Jr_@qWbOgKbScNvN}JxLeI|\\yU`CeBdAw@zFiDvIgHb@i@dBoCv@sC`@mC\\aFV_FJq@jCoKdAoC|CuHv@sBzAwEVi@PK^Fp@rAfChG"]; 
    NSInteger pointCount = [polyline pointCount]; 
    CLLocationCoordinate2D *coords = calloc(pointCount, sizeof(CLLocationCoordinate2D));
    NSRange pointsRange = NSMakeRange(0, pointCount);
    [polyline getCoordinates:coords 
                       range:pointsRange]; 
    
    STAssertEqualsWithAccuracy(coords[0].latitude, -34.630672, 1E-4, nil); 
    STAssertEqualsWithAccuracy(coords[0].longitude, -58.434915, 1E-4, nil); 
    
    STAssertEqualsWithAccuracy(coords[pointCount-1].latitude, -34.777428, 1E-4, nil); 
    STAssertEqualsWithAccuracy(coords[pointCount-1].longitude, -58.463057, 1E-4, nil); 
    
    free(coords);
}

- (void)testHTMLStripper {
    NSString *s = [[NSString alloc] initWithString:@"Head <b>southeast</b> on <b>4th St</b> toward <b>Stevenson St</b>"];
    NSString *control = [[NSString alloc] initWithString:@"Head southeast on 4th St toward Stevenson St"];
    STAssertTrue([control isEqualToString:[s stringByStrippingHTML]], @"control and s should be equal");
}

@end
