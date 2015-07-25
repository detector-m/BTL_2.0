//
//  BTLcmdResponse.h
//  Smartlock
//
//  Created by RivenL on 15/7/24.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BTLCommand.h"

@interface BTLcmdResponse : BTLCommand
- (instancetype)initWithcmdResponseData:(NSData *)cmdResData;

- (Byte)cmd_cmdResponseResult;
@end
