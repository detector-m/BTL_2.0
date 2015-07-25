//
//  RLLocationManager.m
//  GlobalVillage
//
//  Created by RivenL on 15/1/21.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLLocationManager.h"
#import "RLDebug.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>


@interface RLLocationManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) RLLocation *location;
@end

@implementation RLLocationManager

- (void)dealloc {
    if(self.locManager) {
        [self.locManager stopUpdatingLocation];
        self.locManager = nil;
        self.location = nil;
        [self.geocoder cancelGeocode];
        self.geocoder = nil;
    }
}

+ (instancetype)sharedLocationManager {
    static RLLocationManager *_sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLocationManager = [[self alloc] init];
    });
    
    return _sharedLocationManager;
}

- (instancetype)init {
    if(self = [super init]) {
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locManager.distanceFilter = 5.0f;
        self.location = [[RLLocation alloc] init];
        self.location.city = @"yichun";
//        [self startUpdatingLocation];
        
        self.geocoder = [[CLGeocoder alloc] init];
        
        if([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
            [self.locManager requestWhenInUseAuthorization];
        }
    }
    
    return self;
}

#pragma mark -
- (void)startUpdatingLocation {
    if(self.locManager) {
        [self.locManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation {
    if(self.locManager) {
        [self.locManager stopUpdatingLocation];
        [self.geocoder cancelGeocode];
    }
}

//----------------------------------------//
#pragma mark -
- (RLLocation *)curLoction {
    return self.location;
}
//----------------------------------------//

//CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.location.latitude = newLocation.coordinate.latitude;
    self.location.longitude = newLocation.coordinate.longitude;
    
    DLog(@"location %f, %f", self.location.latitude, self.location.longitude);
    
//    __weak CLGeocoder *blockGeocoder = self.geocoder;
    __weak RLLocation *blockLocation = self.location;
    __weak __typeof(self)weakSelf = self;
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error != nil) {
            DLog(@"reverseGeocodeLocation %@", error);
//            [blockGeocoder cancelGeocode];
            [weakSelf stopUpdatingLocation];
            blockLocation.country = @"中国";
            blockLocation.city = @"宜春";
            return ;
        }
        
        if(!(placemarks.count > 0)) {
            DLog(@"reverseGeocodeLocation placemarks count == 0");
//            [blockGeocoder cancelGeocode];
            [weakSelf stopUpdatingLocation];
            return;
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        blockLocation.country = placemark.country;
        blockLocation.city = placemark.locality;
        
        /*
         {
         City = "\U897f\U5b89\U5e02";// 城市名字
         Country = "\U4e2d\U56fd";// 国家名字
         CountryCode = CN;// 国家编码
         FormattedAddressLines = (
         "\U4e2d\U56fd",
         "\U9655\U897f\U7701\U897f\U5b89\U5e02\U96c1\U5854\U533a",
         "\U9ad8\U65b0\U516d\U8def34\U53f7"
         ); // 这个应该是格式化后的地址了
         State = "\U9655\U897f\U7701"; // 省
         Street = "\U9ad8\U65b0\U516d\U8def 34\U53f7";// 街道完整名称
         SubLocality = "\U96c1\U5854\U533a";//区名
         SubThoroughfare = "34\U53f7";//具体地址
         Thoroughfare = "\U9ad8\U65b0\U516d\U8def";//街道名称
         }
         */
        
        //        CLPlacemark *placemark = [placemarks firstObject];
        //        NSString *country = placemark.ISOcountryCode;
        //        NSString *localcity = placemark.locality;

        [weakSelf stopUpdatingLocation];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DLog(@"%@", error);
    [self stopUpdatingLocation];
}
@end
