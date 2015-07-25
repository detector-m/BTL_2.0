//
//  RLColor.m
//  GlobalVillage
//
//  Created by RivenL on 15/1/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLColor.h"

@implementation RLColor
+ (UIColor *)colorWithHexString:(NSString *)aColor {
    NSString *colorStr = [aColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    colorStr = [[colorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    if(colorStr.length < 6) {
        return [UIColor clearColor];
    }
    
    //
    if([colorStr hasPrefix:@"0x"]) {
        colorStr = [colorStr substringFromIndex:2];
    }
    if([colorStr hasPrefix:@"#"]) {
        colorStr = [colorStr substringFromIndex:1];
    }
    if(colorStr.length != 6) {
        return [UIColor clearColor];
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [colorStr substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [colorStr substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [colorStr substringWithRange:range];
    
    // scan values
    unsigned r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return ([UIColor colorWithRed:((CGFloat)r/255.0f) green:((CGFloat)g/255.0f) blue:((CGFloat)b/255.0f) alpha:1.0f]);
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(CGFloat)alpha {
    float red = ((CGFloat) ((hexColor & 0xff0000) >> 16)) / 255.0f;
    float green = ((CGFloat) ((hexColor & 0xff00) >> 8)) / 255.0f;
    float blue = ((CGFloat) (hexColor & 0xff)) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithHex:(long)hexColor {
    return [self.class colorWithHex:hexColor alpha:1.0f];
}

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:green/255.0 alpha:alpha/255.0];
}

@end
