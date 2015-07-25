//
//  RLLocation.h
//  Smartlock
//
//  Created by RivenL on 15/4/9.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLLocation : NSObject <NSCoding>
@property (nonatomic, readwrite, assign) CGFloat latitude;
@property (nonatomic, readwrite, assign) CGFloat longitude;

@property (nonatomic, readwrite, copy) NSString *country;
@property (nonatomic, readwrite, copy) NSString *city;

- (void)dataClear;
@end
