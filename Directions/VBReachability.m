//
//  VBReachability.m
//  klroy
//
//  Created by Ariel Rodriguez on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VBReachability.h"

static NSString *reachabilityFlags(SCNetworkReachabilityFlags flags)  {
    return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
#if	TARGET_OS_IPHONE
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
            'X',
#endif
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
}

@interface VBReachability ()
- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags;
- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;
@end

//Start listening for reachability notifications on the current run loop
static void TMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) 
{
#pragma unused (target)
    VBReachability *reachability = ((__bridge VBReachability*)info);
    
    // we probably dont need an autoreleasepool here as GCD docs state each queue has its own autorelease pool
    // but what the heck eh?
    @autoreleasepool 
    {
        [reachability reachabilityChanged:flags];
    }
}

NSString *const kReachabilityChangedNotification = @"kReachabilityChangedNotification";

@implementation VBReachability
@synthesize reachabilityRef;
@synthesize reachabilitySerialQueue;

@synthesize reachableOnWWAN;

@synthesize reachableBlock;
@synthesize unreachableBlock;

@synthesize reachabilityObject;

+ (VBReachability *)reachabilityWithHostname:(NSString *)hostname {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    if (ref) {
        id reachability = [[self alloc] initWithReachabilityRef:ref];
        
#if __has_feature(objc_arc)
        return reachability;
#else
        return [reachability autorelease];
#endif
        
    }
    
    return nil;
}

+ (VBReachability *)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    if (ref) {
        id reachability = [[self alloc] initWithReachabilityRef:ref];
        
#if __has_feature(objc_arc)
        return reachability;
#else
        return [reachability autorelease];
#endif
    }
    return nil;
}

+ (VBReachability *)reachabilityForInternetConnection  {   
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress:&zeroAddress];
}

+ (VBReachability *)reachabilityForLocalWiFi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len            = sizeof(localWifiAddress);
    localWifiAddress.sin_family         = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
    
    return [self reachabilityWithAddress:&localWifiAddress];
}


// initialization methods

- (VBReachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref  {
    self = [super init];
    if (self != nil) 
    {
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;
    }
    
    return self;    
}

- (void)dealloc {
    [self stopNotifier];
    if(self.reachabilityRef) {
        CFRelease(self.reachabilityRef);
        self.reachabilityRef = nil;
    }
#ifdef DEBUG
    NSLog(@"Reachability: dealloc");
#endif
    
#if !(__has_feature(objc_arc))
    [super dealloc];
#endif
}

#pragma mark - notifier methods

// Notifier 
// NOTE: this uses GCD to trigger the blocks - they *WILL NOT* be called on THE MAIN THREAD
// - In other words DO NOT DO ANY UI UPDATES IN THE BLOCKS.
//   INSTEAD USE dispatch_async(dispatch_get_main_queue(), ^{UISTUFF}) (or dispatch_sync if you want)

- (BOOL)startNotifier {
    SCNetworkReachabilityContext    context = { 0, NULL, NULL, NULL, NULL };
    
    // this should do a retain on ourself, so as long as we're in notifier mode we shouldn't disappear out from under ourselves
    // woah
    self.reachabilityObject = self;
    
    context.info = (__bridge void *)self;
    
    if (!SCNetworkReachabilitySetCallback(self.reachabilityRef, TMReachabilityCallback, &context)) {
#ifdef DEBUG
        NSLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
#endif
        return NO;
    }
    
    //create a serial queue
    self.reachabilitySerialQueue = dispatch_queue_create("net.volonbolon.reachability", NULL);        
    
    // set it as our reachability queue which will retain the queue
    if(SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue)) {
        dispatch_release(self.reachabilitySerialQueue);
        // refcount should be ++ from the above function so this -- will mean its still 1
        return YES;
    }
    
    dispatch_release(self.reachabilitySerialQueue);
    self.reachabilitySerialQueue = nil;
    return NO;
}

- (void)stopNotifier {
    // first stop any callbacks!
    SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
    
    // unregister target from the GCD serial dispatch queue
    // this will mean the dispatch queue gets dealloc'ed
    if(self.reachabilitySerialQueue) {
        SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);
        self.reachabilitySerialQueue = nil;
    }
    
    self.reachabilityObject = nil;
}

#pragma mark - reachability tests

// this is for the case where you flick the airplane mode
// you end up getting something like this:
//Reachability: WR ct-----
//Reachability: -- -------
//Reachability: WR ct-----
//Reachability: -- -------
// we treat this as 4 UNREACHABLE triggers - really apple should do better than this

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags {
    BOOL connectionUP = YES;
    
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
        connectionUP = NO;
    
    if( (flags & testcase) == testcase )
        connectionUP = NO;
    
#if	TARGET_OS_IPHONE
    if(flags & kSCNetworkReachabilityFlagsIsWWAN) {
        // we're on 3G
        if(!self.reachableOnWWAN) {
            // we dont want to connect when on 3G
            connectionUP = NO;
        }
    }
#endif
    
    return connectionUP;
}

- (BOOL)isReachable {
    SCNetworkReachabilityFlags flags;  
    
    if( !SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) ) {
        return NO; 
    }
    
    return [self isReachableWithFlags:flags];
}

- (BOOL)isReachableViaWWAN  {
#if	TARGET_OS_IPHONE
    
    SCNetworkReachabilityFlags flags = 0;
    
    if( SCNetworkReachabilityGetFlags(reachabilityRef, &flags) ) {
        // check we're REACHABLE
        if( flags & kSCNetworkReachabilityFlagsReachable ) {
            // now, check we're on WWAN
            if( flags & kSCNetworkReachabilityFlagsIsWWAN ) {
                return YES;
            }
        }
    }
#endif
    
    return NO;
}

- (BOOL)isReachableViaWiFi  {
    SCNetworkReachabilityFlags flags = 0;
    
    if( SCNetworkReachabilityGetFlags(reachabilityRef, &flags) ) {
        // check we're reachable
        if( (flags & kSCNetworkReachabilityFlagsReachable) ) {
#if	TARGET_OS_IPHONE
            // check we're NOT on WWAN
            if((flags & kSCNetworkReachabilityFlagsIsWWAN)) {
                return NO;
            }
#endif
            return YES;
        }
    }
    
    return NO;
}


// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
- (BOOL)isConnectionRequired {
    return [self connectionRequired];
}

- (BOOL)connectionRequired {
    SCNetworkReachabilityFlags flags;
	
	if( SCNetworkReachabilityGetFlags(reachabilityRef, &flags) ) {
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}
    
    return NO;
}

// Dynamic, on demand connection?
- (BOOL)isConnectionOnDemand {
	SCNetworkReachabilityFlags flags;
	
	if ( SCNetworkReachabilityGetFlags(reachabilityRef, &flags) ) {
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
	}
	
	return NO;
}

// Is user intervention required?
- (BOOL)isInterventionRequired {
    SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & kSCNetworkReachabilityFlagsInterventionRequired));
	}
	
	return NO;
}


#pragma mark - reachability status stuff

- (NetworkStatus)currentReachabilityStatus {
    if( [self isReachable] ) {
        if( [self isReachableViaWiFi] ) {
            return ReachableViaWiFi;
        }
        
#if	TARGET_OS_IPHONE
        return ReachableViaWWAN;
#endif
    }
    
    return NotReachable;
}

-(SCNetworkReachabilityFlags)reachabilityFlags {
    SCNetworkReachabilityFlags flags = 0;
    
    if( SCNetworkReachabilityGetFlags(reachabilityRef, &flags) ) {
        return flags;
    }
    
    return 0;
}

- (NSString *)currentReachabilityString {
	NetworkStatus temp = [self currentReachabilityStatus];
	
	if ( temp == reachableOnWWAN ) {
        // updated for the fact we have CDMA phones now!
		return NSLocalizedString(@"Cellular", @"");
	}
	if (temp == ReachableViaWiFi) {
		return NSLocalizedString(@"WiFi", @"");
	}
	
	return NSLocalizedString(@"No Connection", @"");
}

- (NSString *)currentReachabilityFlags {
    return reachabilityFlags([self reachabilityFlags]);
}

#pragma mark - callback function calls this method

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
#ifdef DEBUG
    NSLog(@"Reachability: %@", reachabilityFlags(flags));
#endif
    
    if( [self isReachableWithFlags:flags] ) {
        if(self.reachableBlock) {
#ifdef DEBUG
            NSLog(@"Reachability: blocks are not called on the main thread.\n Use dispatch_async(dispatch_get_main_queue(), ^{}); to update your UI!");
#endif
            self.reachableBlock(self);
        }
    }
    else
    {
        if(self.unreachableBlock)
        {
#ifdef DEBUG
            NSLog(@"Reachability: blocks are not called on the main thread.\n Use dispatch_async(dispatch_get_main_queue(), ^{}); to update your UI!");
#endif
            self.unreachableBlock(self);
        }
    }
    
    // this makes sure the change notification happens on the MAIN THREAD
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification 
                                                            object:self];
    });
}

@end
