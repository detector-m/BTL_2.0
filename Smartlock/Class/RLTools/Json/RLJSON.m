//
//  RLJSON.m
//  Smartlock
//
//  Created by RivenL on 15/5/21.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLJSON.h"

@implementation RLJSON
+ (id)JSONObjectWithData:(NSData *)data {
//    if(![NSJSONSerialization isValidJSONObject:data]) {
//        return nil;
//    }
    
    NSError *error = nil;
    id retJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if(error) {
        DLog(@"%@", error);
        
        return nil;
    }
    
    return retJson;
}

+ (id)JSONObjectWithString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self JSONObjectWithData:data];
}
@end
