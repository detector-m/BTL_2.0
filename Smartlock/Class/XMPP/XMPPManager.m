//
//  XMPPManager.m
//  Smartlock
//
//  Created by RivenL on 15/4/27.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "XMPPManager.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>

#pragma mark -
#import "MyCoreDataManager.h"
#import "Message.h"

#import "Login.h"
#import "RLJSON.h"

#pragma mark -
#import "RLNotificationManager.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

#pragma mark -
static NSString *kXMPPHostName = @"dqcc.com.cn";
static const NSInteger kXMPPHostPort = 5222;
static NSString *kXMPPDomain = @"dqcc.com.cn";
static NSString *kXMPPResource = @"bluelock";
static NSString *kXMPPAdmin = @"00000000";

#pragma mark -
const NSString *kDidConnected = @"didConnected";
const NSString *kDidDisconnected = @"didDisconnected";
const NSString *kReceiveMessage = @"didReceiveMessage";
const NSString *kReceiveLogoutMessage = @"didReceiveLogoutMessage";

#pragma mark -
void postNotification(const NSString *notificationName, id object) {
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)notificationName object:object];
}

void postNotificationWithNone(const NSString *notificationName) {
    postNotification(notificationName, nil);
}

@interface XMPPManager ()
- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;
@end

@implementation XMPPManager
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

- (void)dealloc {
    [self teardownStream];
}

+ (instancetype)sharedXMPPManager {
    static XMPPManager *_sharedXMPPManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedXMPPManager = [[XMPPManager alloc] init];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        [_sharedXMPPManager setupStream];
    });
    
    return _sharedXMPPManager;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster {
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities {
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream {
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    //	[xmppStream setHostName:@"talk.google.com"];
    [xmppStream setHostName:kXMPPHostName];
    [xmppStream setHostPort:kXMPPHostPort];
    
    
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
//    if([domain isEqualToString:@"gmail.com"]
//       || [domain isEqualToString:@"gtalk.com"]
//       || [domain isEqualToString:@"talk.google.com"]) {
//        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
//        [presence addChild:priority];
//    }
    if([domain isEqualToString:kXMPPDomain]) {
        NSXMLElement *proiority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:proiority];
    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)connect {
    return [self connect:[User sharedUser].dqID password:[User sharedUser].password];
}
- (BOOL)connect:(NSString *)_jid password:(NSString *)_password {
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSString *myJID = _jid;//[_jid stringByAppendingString:kXMPPDomain.length? kXMPPDomain:@"dqcc.com.cn"];
    NSString *myPassword = _password;
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    XMPPJID *xmppJID = [XMPPJID jidWithUser:myJID domain:kXMPPDomain resource:kXMPPResource];
    [xmppStream setMyJID:xmppJID/*[XMPPJID jidWithString:myJID]*/];
    jid = myJID;
    password = myPassword;
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
#ifdef DEBUG
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting" message:@"See console for error details." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
#endif
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    [self setXmppConnecting:YES];
    
    return YES;
}

- (BOOL)reconnect {
    NSError *error = nil;
    if(isXmppConnected || [self isXmppConnecting])
        return YES;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
#ifdef DEBUG
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting" message:@"See console for error details." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
#endif
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect {
    [self goOffline];
    [xmppStream disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName) {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation) {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    [self setXmppConnecting:NO];
    NSError *error = nil;
    
    if (![self.xmppStream authenticateWithPassword:password error:&error]) {
        DDLogError(@"Error authenticating: %@", error);
        
        postNotification(kDidConnected, error);
        return;
    }
    
    postNotificationWithNone(kDidConnected);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    DDLogVerbose(@"message = %@", message);
    
    if([message.type isEqualToString:@"chat"] || ![message.from.user isEqualToString:kXMPPAdmin] || ![message.from.domain isEqualToString:kXMPPDomain] || ![message.from.resource hasPrefix:kXMPPResource]) {
        return;
    }
    
    if([Message messageTypeWithXMPPMessage:message] == 101) {
//        if(![[User sharedUser].deviceTokenString isEqualToString:[Message messageDeviceTokenWithXMPPMessage:message]]) {
//            postNotification(kReceiveLogoutMessage, @YES);
//            [Login hudAlertLogout];
//            
//            return;
//        }
        
        postNotification(kReceiveLogoutMessage, @NO);
        return;
    }
    else if([Message messageTypeWithXMPPMessage:message] == 105) {
        return;
    }
    else if([Message messageTypeWithXMPPMessage:message] == 106) {
        
    }
//    if([Message messageFlagWithXMPPMessage:message]) {
//    
//    }
    if(![User getVoiceSwitch]) {
        [[SoundManager sharedManager] playSound:@"ReceiveMessage.mp3"];
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    [[MyCoreDataManager sharedManager] insertObjectInObjectTable:messageDictionaryFromXMPPMessage(message) withTablename:NSStringFromClass([Message class])];
#if 0
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from] xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];
    NSString *displayName = [user displayName];
#endif
    
    NSString *body = [[message elementForName:@"body"] stringValue];
    
    if (![[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [RLNotificationManager scheduleMessageNotificationWithAlert:body];
    }

    postNotificationWithNone(kReceiveMessage);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self setXmppConnecting:NO];
    if (!isXmppConnected) {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        postNotification(kDidDisconnected, error);
        return;
    }
    
    postNotificationWithNone(kDidDisconnected);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from] xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare]) {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName message:body delegate:nil cancelButtonTitle:@"Not implemented" otherButtonTitles:nil];
        [alertView show];
    } 
    else {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

#pragma mark - 
- (BOOL)isXmppConnecting {
    @synchronized(self) {
        return isXmppConnecting;
    }
}

- (void)setXmppConnecting:(BOOL)value  {
    @synchronized(self) {
        isXmppConnecting = value;
    }
}
@end