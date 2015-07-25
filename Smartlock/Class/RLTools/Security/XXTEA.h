//
//  XXTEA.h
//  Smartlock
//
//  Created by RivenL on 15/6/15.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTMBase64.h"

#define XXTeaKeyLength (16)

/**
 * Secret key length.
 */
extern const size_t XXTEA_KEY_LENGTH;

/**
 * Encrypt @p data using specified key @p key.
 *
 * @param data The @p NSData object to be encrypted.
 * @param key 16 bytes secret key.
 *
 * @return Encrypted data chunk or @p nil if error occurred.
 */
NSData *XXTEAEncryptData(NSData *data, const void *key);

/**
 * Decrypt data chunk @p data using specified key @p key.
 *
 * @param data Data chunk to be decrypted.
 * @param key 16 bytes secret key.
 *
 * @return Origin data or @p nil if error occurred.
 */
NSData *XXTEADecryptData(NSData *data, const void *key);

@interface XXTEA : NSObject

@end
