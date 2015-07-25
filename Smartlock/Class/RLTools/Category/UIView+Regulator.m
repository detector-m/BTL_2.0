//
//  UIView+Regulator.m
//  GlobalVillage
//
//  Created by RivenL on 15/1/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "UIView+Regulator.h"

@implementation UIView (Regulator)
- (void)regulateFrameOrigin {
    const float x = self.frame.origin.x;
    const float y = self.frame.origin.y;
    const float w = self.frame.size.width;
    const float h = self.frame.size.height;
    
    //    if(FWidth<1.0 && FHeight<1.0)
    {
        self.frame = CGRectMake(FWidth*x, FHeight*y, w, h);
    }

}
- (void)regulateFrameOriginX {
    const float x = self.frame.origin.x;
    const float y = self.frame.origin.y;
    const float w = self.frame.size.width;
    const float h = self.frame.size.height;
    
    self.frame = CGRectMake(FWidth*x, y, w, h);
}
- (void)regulateFrameOriginY {
    const float x = self.frame.origin.x;
    const float y = self.frame.origin.y;
    const float w = self.frame.size.width;
    const float h = self.frame.size.height;
    
    self.frame = CGRectMake(x, FHeight*y, w, h);
}
@end
