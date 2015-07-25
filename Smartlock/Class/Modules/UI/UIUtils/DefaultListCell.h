//
//  DefaultListCell.h
//  Smartlock
//
//  Created by RivenL on 15/5/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ImageViewSize (44)

#define TimeLabelHeight (16)
#define TimeLabelWidth (80)

#define BadgeLabelHeight (20)
#define BadgeLabelWidth (20)

#define Space (5)

extern NSString *kCellIdentifier;

@interface DefaultListCell : UITableViewCell

- (void)setDefaultProperties;
@end
