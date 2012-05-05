//
//  VBReachability.h
//  klroy
//
//  Created by Ariel Rodriguez on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

extern NSString *const kReachabilityChangedNotification;

typedef enum  {
	// Apple NetworkStatus Compatible Names.
	NotReachable     = 0,
	ReachableViaWiFi = 2,
	ReachableViaWWAN = 1
} NetworkStatus;

@class VBReachability;

typedef void (^NetworkReachable)(VBReachability *reachability);
typedef void (^NetworkUnreachable)(VBReachability *reachability);

@interface VBReachability : NSObject
@property (nonatomic, copy) NetworkReachable reachableBlock;
@property (nonatomic, copy) NetworkUnreachable unreachableBlock;

@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, assign) dispatch_queue_t reachabilitySerialQueue;

@property (nonatomic, assign) BOOL reachableOnWWAN;

@property (nonatomic, strong) id reachabilityObject;

+ (VBReachability *)reachabilityWithHostname:(NSString*)hostname;
+ (VBReachability *)reachabilityForInternetConnection;
+ (VBReachability *)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
+ (VBReachability *)reachabilityForLocalWiFi;

- (VBReachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

- (BOOL)startNotifier;
- (void)stopNotifier;

- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
- (BOOL)isConnectionRequired; // Identical DDG variant.
- (BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
- (BOOL)isConnectionOnDemand;
// Is user intervention required?
- (BOOL)isInterventionRequired;

- (NetworkStatus)currentReachabilityStatus;
- (SCNetworkReachabilityFlags)reachabilityFlags;
- (NSString *)currentReachabilityString;
- (NSString *)currentReachabilityFlags;

@end
