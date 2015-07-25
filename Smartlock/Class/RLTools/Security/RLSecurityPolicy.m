//
//  RLSecurityPolicy.m
//  Smartlock
//
//  Created by RivenL on 15/6/13.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLSecurityPolicy.h"
#import "RLDate.h"

#define Tranverse64(X) ((((int64_t)(X) & 0xff00000000000000) >> 56) | (((int64_t)(X) & 0x00ff000000000000) >> 40) | (((int64_t)(X) & 0x0000ff0000000000) >> 24) | (((int64_t)(X) & 0x000000ff00000000) >> 8) | \
(((int64_t)(X) & 0x00000000ff000000) << 8) | (((int64_t)(X) & 0x0000000000ff0000) << 24) | (((int64_t)(X) & 0x000000000000ff00) << 40) | (((int64_t)(X) & 0x00000000000000ff) << 56))

#define TimestampXorPWD 0xcb236d9fdb797f63
#define HEAD_OFFSET 24

Byte finalKey[16] = {0xDB,0x8F,0xBB,0x54,0xCA,0x77,0x0C,0x7A,0xEF,0x9F,0x41,0xE2,0xBF,0xFF,0x57,0x40};

long long getTimestamp() {
    long long timestamp = (long long)(timestampSince1970WithReal()*1000);
    
    return timestamp;
}

long long getTimestampForTranverse(long long timestamp) {
    return Tranverse64(timestamp);
}
long long getXorPwdTimestamp(long long timestamp) {
    timestamp ^= TimestampXorPWD;
    
    return timestamp;
}

int offsetHeadCertificate() {
    return HEAD_OFFSET;
}

int offsetTwo(long long timestamp) {
    Byte *bytes = (Byte *)&timestamp;
    return (int)bytes[1];
}

int offsetTotal(long long timestamp) {
    return offsetTwo(timestamp) + offsetHeadCertificate();
}

int jumpNumber(long long timestamp) {
    Byte *bytes = (Byte *)&timestamp;
    return (bytes[0] >> 4) & 0xf;
}

Byte *getKeyFromCertificate(long long timestamp, NSData *certificazteData) {
    static Byte keyBytes[XXTeaKeyLength] = {0};
    memset(keyBytes, 0, XXTeaKeyLength);
    Byte *dataBytes = (Byte *)certificazteData.bytes;
    int i = 0;
    int offset = offsetTotal(timestamp);
    int jump = jumpNumber(timestamp)+1;
    
    for(; i<XXTeaKeyLength; i++, offset += jump) {
        keyBytes[i] = dataBytes[offset];
    }
    return keyBytes;
}

NSData *encryptStringWithVariableKey(NSString *string, Byte *key) {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
   
    return encryptWithVariableKey(data, key);
}

NSData *encryptWithVariableKey(NSData *data, Byte *key) {
    return XXTEAEncryptData(data, key);
}

NSData *encryptStringWithFinalKey(NSString *string) {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return encryptWithFinalKey(data);
}

NSData *encryptWithFinalKey(NSData *data) {
    return XXTEAEncryptData(data, finalKey);
}

NSData *decryptWithFinalKey(NSData *data) {
    return XXTEADecryptData(data, finalKey);
}

NSData *decryptWithVariableKey(NSData *data, Byte *key) {
    return XXTEADecryptData(data, key);
}

NSData *appendEncryptedDatas(long long timestamp, NSData *originData, NSData *encryptedData) {
    NSMutableData *data = [NSMutableData dataWithBytes:(Byte *)&timestamp length:sizeof(long long)];
    [data appendData:originData];
    [data appendData:encryptedData];
    
    return data ;
}

NSData *encryptAndAppend(NSString *token, NSData *certificazteData) {
    long long timestamp = getTimestamp();
    Byte *key = getKeyFromCertificate(getXorPwdTimestamp(timestamp), certificazteData);
    
//    DLog(@"key = %@", [NSData dataWithBytes:key length:16]);
    NSData *finalEncryptData = encryptStringWithFinalKey(token);
    NSData *variableEncryptData = encryptStringWithVariableKey(token, key);
    
    return appendEncryptedDatas(getTimestampForTranverse(timestamp), finalEncryptData, variableEncryptData);
}

NSString *encryptedTokenToBase64(NSString *token, NSData *certificazteData) {
    NSData *data = encryptAndAppend(token, certificazteData);
    
    return [GTMBase64 stringByWebSafeEncodingData:data padded:NO];
}

@implementation RLSecurityPolicy

@end
