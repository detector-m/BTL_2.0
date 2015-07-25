//
//  RLBaseNavigationController.m
//  Smartlock
//
//  Created by RivenL on 15/3/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLBaseNavigationController.h"

@interface RLBaseNavigationController ()

@end

@implementation RLBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    

//    [self setNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar {
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:194/255.0 green:18/255.0 blue:40/255.0 alpha:0.9]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // set title color and font
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
}
@end
