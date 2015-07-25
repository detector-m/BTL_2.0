//
//  RLLocationManager.h
//  GlobalVillage
//
//  Created by RivenL on 15/1/21.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLLocation.h"

@interface RLLocationManager : NSObject
@property (nonatomic, readonly, weak) RLLocation *curLoction;
+ (instancetype)sharedLocationManager;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
@end
