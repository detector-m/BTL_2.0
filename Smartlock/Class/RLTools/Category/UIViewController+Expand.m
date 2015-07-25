//
//  UIViewController+Expand.m
//  GlobalVillage_First
//
//  Created by RivenL on 14/11/22.
//  Copyright (c) 2014年 RivenL. All rights reserved.
//

#import "UIViewController+Expand.h"
//#import "MainVC.h"

static CGFloat fWidth = 1.0;
static CGFloat fHeight = 1.0;

const CGFloat getFixWidth()
{
    return fWidth;
}

const CGFloat getFixHeight()
{
    return fHeight;
}

@implementation UIViewController (Expand)
#define IphoneBaseScreenWidth 320.0
#define IPhoneBaseScreenHeight 480.0
+ (void)setupFix{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        
        fWidth = width/IphoneBaseScreenWidth;
        fHeight = height/IPhoneBaseScreenHeight;
    }
}

- (void)screenFix{
    if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
- (void)screenFixNavigationBarAndStartusBar{
    [self screenFix];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-(self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height));
}

- (void)screenFixView {
    [self screenFix];
    CGRect statusFrame = [UIApplication sharedApplication].statusBarFrame;
    CGRect navigationFrame = self.navigationController.navigationBarHidden ? CGRectZero : self.navigationController.navigationBar.bounds;
    CGRect tabBarFrame = self.tabBarController.tabBar.hidden ? CGRectZero : self.tabBarController.tabBar.frame;
    
    CGRect frame = self.view.frame;
    CGFloat height = frame.size.height - (navigationFrame.size.height +
                                          statusFrame.size.height +
                                          tabBarFrame.size.height);
    
    CGFloat originY = 0.0f;
    if(self.navigationController == nil || self.navigationController.navigationBarHidden) {
        originY = statusFrame.size.height;
    }

    frame = CGRectMake(frame.origin.x, frame.origin.y + originY, frame.size.width, height);
    self.view.frame = frame;
}

#pragma mark 
//设置返回按钮
- (void)setBarBackItem
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setTitle:@"返回"];
    self.navigationItem.backBarButtonItem = backItem;
}
@end

@implementation UIViewController (DismissKeyboard)
- (void)setupForDismissKeyboard{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnywhereToDismissKeyboard:)];
    
    __weak UIViewController *weakSelf = self;
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification object:nil queue:mainQueue usingBlock:^(NSNotification *note) {
        [weakSelf.view addGestureRecognizer:singleTapGR];
    }];
    
    [nc addObserverForName:UIKeyboardWillHideNotification object:nil queue:mainQueue usingBlock:^(NSNotification *note) {
        [weakSelf.view removeGestureRecognizer:singleTapGR];
    }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureReconizer{
    //此处method会将self.view里面所有的subview的first responder都resign掉
    [self.view endEditing:YES];
}
@end

@implementation UIViewController (BackButtonHandler)

@end

@implementation UINavigationController (PopOnBackButton)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if([self.viewControllers count] < navigationBar.items.count) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    UIViewController *vc = [self topViewController];
    if([vc respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
        shouldPop = [(id<BackButtonHandlerProtocol>)vc navigationShouldPopOnBackButton];
    }
    
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    else {
        for(UIView *subview in [navigationBar subviews]) {
            if(subview.alpha < 1.0f) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0f;
                }];
            }
        }
    }
    
    return NO;
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    UIViewController *vc = [self topViewController];
    if([vc respondsToSelector:@selector(navigationDidPopOnBackButton)]) {
        [(id<BackButtonHandlerProtocol>)vc navigationDidPopOnBackButton];
    }
}
@end

@implementation UINavigationBar (ChangeNavHeight)
#define kDefaultNavHeight 44.0f
- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGSize newSize = CGSizeMake(width, kDefaultNavHeight);
//    if(CGSizeEqualToSize(size, CGSizeZero)) {
//    }
//    else {
//        newSize = CGSizeMake(width,size.height);
//    }
    return newSize;
}

//- (CGSize)changeHeight:(CGSize)size {
//    return [self sizeThatFits:size];
//}
@end
