//
//  RLTextSize.h
//  GlobalVillage
//
//  Created by RivenL on 15/1/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLTextSize : NSObject
+ (CGSize)textSizeWithString:(NSString *)text andFont:(UIFont *)font;
+ (CGFloat)textHeightWithString:(NSString *)text andFont:(UIFont *)font andWidth:(CGFloat)width;
+ (CGFloat)textWidthWithString:(NSString *)text andFont:(UIFont *)font andHeight:(CGFloat)height;

+ (CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
@end
