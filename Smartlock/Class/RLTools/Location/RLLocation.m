//
//  RLLocation.m
//  Smartlock
//
//  Created by RivenL on 15/4/9.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLLocation.h"

@implementation RLLocation
- (void)dealloc {
    [self dataClear];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        self.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        self.country = [aDecoder decodeObjectForKey:@"country"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.city forKey:@"city"];
}

- (NSString *)description {
    NSDictionary *descriptionDic = @{
                                     @"latitude":[NSNumber numberWithDouble:self.latitude],
                                     @"longitude":[NSNumber numberWithDouble:self.longitude],
                                     @"country":self.country,
                                     @"city":self.city};
    
    return [NSString stringWithFormat:@"(%@ : %p, %@)",[self class],self, descriptionDic];
}

- (void)dataClear {
    self.latitude = CGFLOAT_MAX;
    self.longitude = CGFLOAT_MAX;
    
    self.country = nil;
    self.city = nil;
}
@end
