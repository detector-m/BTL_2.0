//
//  RLImage.h
//  GlobalVillage
//
//  Created by RivenL on 15/1/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLImage : NSObject
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//等比缩放
+ (UIImage *)scaleImage:(UIImage *)originalImage toScale:(CGFloat)ratio;
//自定size
+ (UIImage *)resizeImage:(UIImage *)originalImage size:(CGSize)size;
//处理某个特定View
+ (UIImage *)captureView:(UIView *)view;
//裁剪图片
+ (UIImage *)cropImage:(UIImage *)originalImage rect:(CGRect)rect;

- (UIImage *)iconImage:(UIImage *)oriImage;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

#pragma mark - UIImage + Blur
+ (UIImage *)boxblurImageWithBlur:(CGFloat)blur image:(UIImage *)image;
+ (UIImage *)closeButtonImageWithFrame:(CGRect)bounds;
@end
