//
//  NSString+XXTEA.m
// 
//  http://github.com/nightsailer/xxtea4cocoa
//
//  original source: http://code.google.com/p/xxtea-algorithm/
//
//  ported by: Pan Fan (nightsailer#gmail)
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//


#import "XXTEA.h"

#if 1
typedef uint32_t xxtea_long;

#define XXTEA_MX (z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z)
#define XXTEA_DELTA 0x9e3779b9

void xxtea_long_encrypt(xxtea_long *v, xxtea_long len, xxtea_long *k) {
    xxtea_long n = len - 1;
    xxtea_long z = v[n], y = v[0], p, q = 6 + 52 / (n + 1), sum = 0, e;
    if (n < 1) {
        return;
    }
    while (0 < q--) {
        sum += XXTEA_DELTA;
        e = sum >> 2 & 3;
        for (p = 0; p < n; p++) {
            y = v[p + 1];
            z = v[p] += XXTEA_MX;
        }
        y = v[0];
        z = v[n] += XXTEA_MX;
    }
}

void xxtea_long_decrypt(xxtea_long *v, xxtea_long len, xxtea_long *k) {
    xxtea_long n = len - 1;
    xxtea_long z = v[n], y = v[0], p, q = 6 + 52 / (n + 1), sum = q * XXTEA_DELTA, e;
    if (n < 1) {
        return;
    }
    while (sum != 0) {
        e = sum >> 2 & 3;
        for (p = n; p > 0; p--) {
            z = v[p - 1];
            y = v[p] -= XXTEA_MX;
        }
        z = v[n];
        y = v[0] -= XXTEA_MX;
        sum -= XXTEA_DELTA;
    }
}

static xxtea_long *xxtea_to_long_array(const unsigned char *data, xxtea_long len, int include_length, xxtea_long *ret_len) {
    xxtea_long i, n, *result;
    n = len >> 2;
    n = (((len & 3) == 0) ? n : n + 1);
    if (include_length) {
        result = (xxtea_long *)malloc((n + 1) << 2);
        result[n] = len;
        *ret_len = n + 1;
    } else {
        result = (xxtea_long *)malloc(n << 2);
        *ret_len = n;
    }
    memset(result, 0, n << 2);
    for (i = 0; i < len; i++) {
        result[i >> 2] |= (xxtea_long)data[i] << ((i & 3) << 3);
    }
    return result;
}

static char *xxtea_to_byte_array(xxtea_long *data, xxtea_long len, int include_length, xxtea_long *ret_len) {
    xxtea_long i, n, m;
    char *result;
    n = len << 2;
    if (include_length) {
        m = data[len - 1];
        if ((m < n - 7) || (m > n - 4)){
//            NSLog(@"m:%i n:%i ",m,n);
            return NULL;
        }
        n = m;
    }
    result = (char *)malloc(n + 1);
    for (i = 0; i < n; i++) {
        result[i] = (char)((data[i >> 2] >> ((i & 3) << 3)) & 0xff);
    }
    result[n] = '\0';
    *ret_len = n;
    return result;
}
#endif

#define XXTEA_BTYPE_MX (z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z)
#define XXTEA_BTYPE_DELTA 0x9e3779b9

void xxtea_byte_encrypt(uint8_t *v, uint32_t len, uint32_t *k) {
    uint32_t n = len - 1;
    uint8_t z = v[n], y = v[0], p, q = 6 + 52 / (n + 1), sum = 0, e;
    if (n < 1) {
        return;
    }
    while (0 < q--) {
        sum += XXTEA_BTYPE_DELTA;
        e = sum >> 2 & 3;
        for (p = 0; p < n; p++) {
            y = v[p + 1];
            z = v[p] += XXTEA_BTYPE_MX;
        }
        y = v[0];
        z = v[n] += XXTEA_BTYPE_MX;
    }
}

void xxtea_byte_decrypt(uint8_t *v, uint32_t len, uint32_t *k) {
    uint32_t n = len - 1;
    uint8_t z = v[n], y = v[0], p, q = 6 + 52 / (n + 1), sum = q * XXTEA_BTYPE_DELTA, e;
    if (n < 1) {
        return;
    }
    while (sum != 0) {
        e = sum >> 2 & 3;
        for (p = n; p > 0; p--) {
            z = v[p - 1];
            y = v[p] -= XXTEA_BTYPE_MX;
        }
        z = v[n];
        y = v[0] -= XXTEA_BTYPE_MX;
        sum -= XXTEA_BTYPE_DELTA;
    }
}


#pragma mark -
const size_t XXTEA_KEY_LENGTH = 16;

#define EVERBEEN_XXTEA_DELTA 0x9e3779b9
#define EVERBEEN_XXTEA_MX (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (k[(p&3)^e]^z)))

static void btea(uint32_t *v, int n, uint32_t const k[4]) {
    uint32_t y, z, sum;
    unsigned p, rounds, e;
    if (n > 1) {              /* Coding Part */
        rounds = 6 + 52/n;
        sum = 0;
        z = v[n-1];
        do {
            sum += EVERBEEN_XXTEA_DELTA;
            e = (sum >> 2) & 3;
            for (p=0; p<n-1; p++) {
                y = v[p+1];
                z = v[p] += EVERBEEN_XXTEA_MX;
            }
            y = v[0];
            z = v[n-1] += EVERBEEN_XXTEA_MX;
        } while (--rounds);
    } else if (n < -1) {      /* Decoding Part */
        n = -n;
        rounds = 6 + 52/n;
        sum = rounds*EVERBEEN_XXTEA_DELTA;
        y = v[0];
        do {
            e = (sum >> 2) & 3;
            for (p=n-1; p>0; p--) {
                z = v[p-1];
                y = v[p] -= EVERBEEN_XXTEA_MX;
            }
            z = v[n-1];
            y = v[0] -= EVERBEEN_XXTEA_MX;
        } while ((sum -= EVERBEEN_XXTEA_DELTA) != 0);
    }
}

NSData *XXTEAEncryptData(NSData *data, const void *key) {
    uint32_t data_length = (uint32_t)data.length;
    uint32_t len = (data_length + 4) >> 2;
    if ((data_length & 3) != 0) ++len;
    uint32_t bytes_len = len << 2;
    unsigned char *bytes = (unsigned char *)malloc(bytes_len);
    memcpy(bytes, data.bytes, data.length);
    memcpy(bytes+bytes_len-4, &data_length, 4);
    
    btea((uint32_t *)bytes, len, (uint32_t *)key);
    return [NSData dataWithBytesNoCopy:bytes length:bytes_len];
}

NSData *XXTEADecryptData(NSData *code, const void *key) {
    if ((code.length & 3) != 0)
        return nil;
    uint32_t bytes_len = (uint32_t)code.length;
    unsigned char *bytes = (unsigned char *)malloc(bytes_len);
    memcpy(bytes, code.bytes, bytes_len);
    btea((uint32_t *)bytes, (uint32_t)-(code.length>>2), (uint32_t *)key);
    uint32_t len = *(uint32_t *)(bytes+code.length-4);
    if (len > bytes_len) {
        free(bytes);
        return nil;
    }
    return [NSData dataWithBytesNoCopy:bytes length:len];
}


void XXTEAFillRandomKey(void *key) {
    arc4random_buf(key, XXTEA_KEY_LENGTH);
}

@implementation XXTEA

@end

#pragma mark -
@implementation NSString (XXTEA)

- (NSString *)encryptXXTEA:(NSString *)key {
    const unsigned char *data = (const unsigned char *)[self UTF8String];
    const unsigned char *strkey = (const unsigned char *)[key UTF8String];
    
    xxtea_long len = (xxtea_long) strlen((const char *)data);
    xxtea_long ret_len;
    
    const char *result;
    xxtea_long *v, *k, v_len, k_len;
    v = xxtea_to_long_array(data, len, 1, &v_len);
    k = xxtea_to_long_array(strkey, 16, 0, &k_len);
    xxtea_long_encrypt(v, v_len, k);
    result = xxtea_to_byte_array(v, v_len, 0, &ret_len);
    free(v);
    free(k);
    
    NSString *newstr = [GTMBase64 stringByEncodingBytes:result length:ret_len];
    //    NSLog(@"ecncryped neew str is %@",newstr);
    free((void *)result);
    return newstr;
}

- (NSString *)decryptXXTEA:(NSString *)key {
    NSData *_data = [GTMBase64 decodeString:self];
    const unsigned char *data = (const unsigned char *)[_data bytes];
    const unsigned char *strkey = (const unsigned char *)[key UTF8String];
    xxtea_long len = (xxtea_long) strlen((const char *)data);
    
    xxtea_long ret_len;
    const unsigned char *result;
    xxtea_long *v, *k, v_len, k_len;
    v = xxtea_to_long_array(data, len, 0, &v_len);
    k = xxtea_to_long_array(strkey, 16, 0, &k_len);
    xxtea_long_decrypt(v, v_len, k);
    //    NSLog(@"v_len %i k_len %i",v_len,k_len);
    result = (unsigned char *)xxtea_to_byte_array(v, v_len, 1, &ret_len);
    //    NSLog(@"result len is %i",ret_len);
    free(v);
    free(k);
    //    NSLog(@"decrypted str is %s",result);
    NSString * newstr = [[NSString alloc] initWithCString:(const char *)result encoding:NSUTF8StringEncoding];
    //    NSLog(@"neew str is %@",newstr);
    free((void *)result);
    return newstr;
}
@end

