//
//  RLUtilitiesMethods.m
//  GlobalVillage
//
//  Created by RivenL on 15/1/29.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLUtilitiesMethods.h"

@implementation RLUtilitiesMethods

@end

NSString *resourcePathWithResourceName(NSString *name) {
    return [[NSBundle mainBundle] pathForResource:name ofType:nil];
}

NSString* RLEncode(NSString * value) {
    if (value == nil)
        return @"";
    
    NSString *string = value;
    
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    string = [string stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    string = [string stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
    string = [string stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    
    return string;
}

NSString* RLEncodeURL(NSURL * value) {
    if (value == nil)
        return @"";
    
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)value.absoluteString, NULL,                                          CFSTR("!*'();:@&=+$,/?%#[]"),                                    kCFStringEncodingUTF8);
    return result;
}

NSString* RLFlattenHTML(NSString * value, BOOL preserveLineBreaks) {
    // Modified from http://rudis.net/content/2009/01/21/flatten-html-content-ie-strip-tags-cocoaobjective-c
    NSScanner *scanner;
    NSString *text = nil;
    
    scanner = [NSScanner scannerWithString:value];
    
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&text];
        
        value = [value stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
    }
    
    if (preserveLineBreaks == NO) {
        value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

NSString* RLLocalizedStringFormat(NSString* key) {
#if 0
    static NSBundle* bundle = nil;
    if (nil == bundle) {
        
        NSString *path = [RL shareKitLibraryBundlePath];
        bundle = [NSBundle bundleWithPath:path];
        NSCAssert(bundle != nil,@"ShareKit has been refactored to be used as Xcode subproject. Please follow the updated installation wiki and re-add it to the project. Please do not forget to clean project and clean build folder afterwards. In case you use CocoaPods override - (NSNumber *)isUsingCocoaPods; method in your configurator subclass and return [NSNumber numberWithBool:YES]");
    }
    NSString *result = [bundle localizedStringForKey:key value:nil table:nil];
    return result;
#endif
    
    return NSLocalizedString(key, nil);
}

NSString* RLLocalizedString(NSString* key, ...) {
    // Localize the format
    NSString *localizedStringFormat = RLLocalizedStringFormat(key);
    
    va_list args;
    va_start(args, key);
    NSString *string = [[NSString alloc] initWithFormat:localizedStringFormat arguments:args];
    va_end(args);
    
    return string;
}

NSData *hexStringToBytes(NSString *aHexString) {
    NSString *hexString=[[aHexString uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    
    return bytes;
}

//
NSString *hexStringFromData(NSData *data) {
    Byte *bytes = (Byte *)[data bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1) {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    
    return hexStr;
}

#if 0
/*
 * 把16进制字符串转换成字节数组 @param hex @return
 */
public static byte[] hexStringToByte(String hex) {
    int len = (hex.length() / 2);
    byte[] result = new byte[len];
    char[] achar = hex.toCharArray();
    for (int i = 0; i < len; i++) {
        int pos = i * 2;
        result[i] = (byte) (toByte(achar[pos]) << 4 | toByte(achar[pos + 1]));
    }
    return result;
}

private static byte toByte(char c) {
    byte b = (byte) "0123456789ABCDEF".indexOf(c);
    return b;
}

/**
 * 把字节数组转换成16进制字符串
 *
 * @param bArray
 * @return
 */
public static final String bytesToHexString(byte[] bArray) {
    StringBuffer sb = new StringBuffer(bArray.length);
    String sTemp;
    for (int i = 0; i < bArray.length; i++) {
        sTemp = Integer.toHexString(0xFF & bArray[i]);
        if (sTemp.length() < 2)
            sb.append(0);
        sb.append(sTemp.toUpperCase());
    }
    return sb.toString();
}

/**
 * @函数功能: BCD码转为10进制串(阿拉伯数据)
 * @输入参数: BCD码
 * @输出结果: 10进制串
 */
public static String bcd2Str(byte[] bytes) {
    StringBuffer temp = new StringBuffer(bytes.length * 2);
    
    for (int i = 0; i < bytes.length; i++) {
        temp.append((byte) ((bytes[i] & 0xf0) >>> 4));
        temp.append((byte) (bytes[i] & 0x0f));
    }
    return temp.toString().substring(0, 1).equalsIgnoreCase("0") ? temp.toString().substring(1) : temp.toString();
}
/**
 * @函数功能: 10进制串转为BCD码
 * @输入参数: 10进制串
 * @输出结果: BCD码
 */
public static byte[] str2Bcd(String asc) {
    int len = asc.length();
    int mod = len % 2;
    
    if (mod != 0) {
        asc = "0" + asc;
        len = asc.length();
    }
    
    byte abt[] = new byte[len];
    if (len >= 2) {
        len = len / 2;
    }
    
    byte bbt[] = new byte[len];
    abt = asc.getBytes();
    int j, k;
    
    for (int p = 0; p < asc.length() / 2; p++) {
        if ((abt[2 * p] >= '0') && (abt[2 * p] <= '9')) {
            j = abt[2 * p] - '0';
        } else if ((abt[2 * p] >= 'a') && (abt[2 * p] <= 'z')) {
            j = abt[2 * p] - 'a' + 0x0a;
        } else {
            j = abt[2 * p] - 'A' + 0x0a;
        }
        
        if ((abt[2 * p + 1] >= '0') && (abt[2 * p + 1] <= '9')) {
            k = abt[2 * p + 1] - '0';
        } else if ((abt[2 * p + 1] >= 'a') && (abt[2 * p + 1] <= 'z')) {
            k = abt[2 * p + 1] - 'a' + 0x0a;
        } else {
            k = abt[2 * p + 1] - 'A' + 0x0a;
        }
        
        int a = (j << 4) + k;
        byte b = (byte) a;
        bbt[p] = b;
    }
    return bbt;
}

public static void main(String[] arg) {
    /**
     * 68 65 6C 6C 6 F 0A
     * C4 E3 BA C3
     */
    String[] str = {"C4", "E3", "BA", "C3"};
    //		String[] str = {"7E","02","04","00","07","10","00","00","00","00","13","08","4F","01","0B","0B","15","10","14","13","44","7E"};
    byte[] b = new byte[str.length];
    for(int i=0;i<str.length;i++){
        b[i] = hexStringToByte(str[i])[0];
    }
    System.out.println(new String(b));
    
    
    String strC	="你好";
    String bth=bytesToHexString(strC.getBytes());
    System.out.println(bth);
    System.out.println(Short.MAX_VALUE);
    System.out.println(Integer.toBinaryString(280));
}
#endif
