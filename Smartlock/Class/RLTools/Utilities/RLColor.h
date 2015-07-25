//
//  RLColor.h
//  GlobalVillage
//
//  Created by RivenL on 15/1/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLColor : NSObject
//颜色转换，ios中16进制的颜色转换为UIColor
+ (UIColor *)colorWithHexString:(NSString *)aColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(long)hexColor;

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
@end
