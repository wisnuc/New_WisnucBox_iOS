//
// Created by wisnuc-imac on 2017/11/15.
// Copyright (c) 2017 JackYang. All rights reserved.
//

#import "UIViewController+controller.h"


@implementation UIViewController (controller)
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //当前windows的根控制器
    UIViewController *controller = window.rootViewController;
    //通过循环一层一层往下查找
    while (YES) {
        //先判断是否有present的控制器
        if (controller.presentedViewController) {
            //有的话直接拿到弹出控制器，省去多余的判断
            controller = controller.presentedViewController;
        } else {
            if ([controller isKindOfClass:[UINavigationController class]]) {
                //如果是NavigationController，取最后一个控制器（当前）
                controller = [controller.childViewControllers lastObject];
            } else if ([controller isKindOfClass:[UITabBarController class]]) {
                //如果TabBarController，取当前控制器
                UITabBarController *tabBarController = (UITabBarController *)controller;
                controller = tabBarController.selectedViewController;
            } else {
                if (controller.childViewControllers.count > 0) {
                    //如果是普通控制器，找childViewControllers最后一个
                    controller = [controller.childViewControllers lastObject];
                } else {
                    //没有present，没有childViewController，则表示当前控制器
                    return controller;
                }
            }
        }
    }
}

- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage andHighlightButtonImage:(UIImage *)image  andSEL:(SEL)sel{
    UIButton * left = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    [left setImage:buttonImage forState:UIControlStateNormal];
    if (image) {
        [left setImage:image forState:UIControlStateHighlighted];
    }
    [left addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = leftButton;
}


@end
