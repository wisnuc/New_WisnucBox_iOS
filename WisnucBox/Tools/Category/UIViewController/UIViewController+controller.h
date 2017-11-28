//
// Created by wisnuc-imac on 2017/11/15.
// Copyright (c) 2017 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (controller)

+ (UIViewController *)getCurrentVC;
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage andHighlightButtonImage:(UIImage *)image  andSEL:(SEL)sel;
@end
