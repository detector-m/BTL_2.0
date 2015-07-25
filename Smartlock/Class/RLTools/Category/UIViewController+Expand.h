//
//  UIViewController+Expand.h
//  GlobalVillage_First
//
//  Created by RivenL on 14/11/22.
//  Copyright (c) 2014年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

const CGFloat getFixWidth();
const CGFloat getFixHeight();

#define FWidth (getFixWidth())
#define FHeight (getFixHeight())

@interface UIViewController (Expand)
+ (void)setupFix;
- (void)screenFix;
- (void)screenFixNavigationBarAndStartusBar;

- (void)screenFixView;

//设置返回按钮
- (void)setBarBackItem;
@end

@interface UIViewController (DismissKeyboard)
- (void)setupForDismissKeyboard;
@end

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
- (BOOL)navigationShouldPopOnBackButton;
- (void)navigationDidPopOnBackButton;
@end

@interface UIViewController (BackButtonHandler)

@end

@interface UINavigationBar (ChangeNavHeight)
//- (CGSize)changeHeight:(CGSize)size;
@end