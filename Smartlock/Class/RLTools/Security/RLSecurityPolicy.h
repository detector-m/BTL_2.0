//
//  RLSecurityPolicy.h
//  Smartlock
//
//  Created by RivenL on 15/6/13.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XXTEA.h"

extern long long getTimestamp();
extern long long getXorPwdTimestamp(long long timestamp);
extern int offsetHeadCertificate();
extern int offsetTotal(long long timestamp);
extern int offsetTwo(long long timestamp);
extern int jumpNumber(long long timestamp);

extern Byte *getKeyFromCertificate(long long timestamp, NSData *certificazteData);

NSData *encryptStringWithVariableKey(NSString *string, Byte *key);
NSData *encryptStringWithFinalKey(NSString *string);

extern NSData *encryptWithVariableKey(NSData *data, Byte *key);
extern NSData *encryptWithFinalKey(NSData *data);
extern NSData *decryptWithFinalKey(NSData *data);
extern NSData *decryptWithVariableKey(NSData *data, Byte *key);

extern NSString *encryptedTokenToBase64(NSString *token, NSData *certificazteData);

@interface RLSecurityPolicy : NSObject

@end
