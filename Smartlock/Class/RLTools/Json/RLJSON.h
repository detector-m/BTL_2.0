//
//  RLJSON.h
//  Smartlock
//
//  Created by RivenL on 15/5/21.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLJSON : NSObject
+ (id)JSONObjectWithData:(NSData *)data;
+ (id)JSONObjectWithString:(NSString *)string;
@end
