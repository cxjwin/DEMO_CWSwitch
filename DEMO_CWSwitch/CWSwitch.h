//
//  CWSwitch.h
//  DEMO_CWSwitch
//
//  Created by 蔡 雪钧 on 14-3-20.
//  Copyright (c) 2014年 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>

// custom view like UISwitch
@interface CWSwitch : UIControl

// is on or off
@property(nonatomic, getter = isOn) BOOL on;

// This class enforces a size appropriate for the control. The frame size is ignored.
- (id)initWithFrame:(CGRect)frame;

// does not send action
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
