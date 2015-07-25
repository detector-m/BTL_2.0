//
//  XMPPManager.h
//  Smartlock
//
//  Created by RivenL on 15/4/27.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "RLDate.h"

#pragma mark -
#import "SoundManager.h"

#pragma mark -
/**
 *  Notification fro xmpp
 */
extern const NSString *kDidConnected;
extern const NSString *kDidDisconnected;
extern const NSString *kReceiveMessage;
extern const NSString *kReceiveLogoutMessage;


@interface XMPPManager : NSObject <XMPPStreamDelegate, XMPPRosterDelegate> {
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSString *jid;
    NSString *password;
    
    BOOL customCertEvaluation;
    
    BOOL isXmppConnected;
    BOOL isXmppConnecting;
}
#pragma mark -
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
//@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStroage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;


#pragma mark -
+ (instancetype)sharedXMPPManager;

#pragma mark -
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

//- (void)setupStream;
- (BOOL)connect;
- (BOOL)connect:(NSString *)_jid password:(NSString *)_password;
- (BOOL)reconnect;
- (void)disconnect;
@end
