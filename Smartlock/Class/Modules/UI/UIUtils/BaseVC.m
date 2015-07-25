//
//  BaseVC.m
//  Smartlock
//
//  Created by RivenL on 15/3/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BaseVC.h"
#import "RLColor.h"
@interface BaseVC ()
@property (nonatomic, readwrite, weak) UIImageView *backgroundImage;

@end

@implementation BaseVC
- (void)viewDidLoad {
    [super viewDidLoad];
//    if([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        if(self.navigationController) {
//            CGRect frame = self.view.frame;
//            self.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height-64);
//        }
//    }
    [self setNavigationBar];
    [self setupBackgroundImage];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupBackItem];
    [self setupRightItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupBackgroundImage {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:imageView];
    self.backgroundImage = imageView;
}

- (void)setupBackItem {
    self.navigationItem.backBarButtonItem = [UIBarButtonItem new];
    [self.navigationItem.backBarButtonItem setTitle:NSLocalizedString(@"Back", nil)];
}

- (void)setupRightItem {

}

- (void)setNavigationBar {
    [self.navigationController.navigationBar setBarTintColor:[RLColor colorWithHexString:@"#0099cc"]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // set title color and font
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
}

#pragma mark - 
- (void)setBackButtonHide:(BOOL)hide {
    [self.navigationItem setHidesBackButton:hide];
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = !hide;
//        if(hide) {
//            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//        }
//        else {
//            self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
//        }
//    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer == self.navigationController.interactivePopGestureRecognizer)
        return YES;
    return YES;
}

#pragma mark -
- (void)endEditing {
    [self.view endEditing:YES];
}

@end
