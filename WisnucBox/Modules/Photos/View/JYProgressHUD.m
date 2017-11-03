//
//  JYProgressHUD.m
//  Photos
//
//  Created by JackYang on 2017/10/17.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYProgressHUD.h"
#import "JYConst.h"

@implementation JYProgressHUD

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    self.frame = [UIScreen mainScreen].bounds;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 80)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 5.0f;
    view.backgroundColor = [UIColor darkGrayColor];
    view.alpha = 0.8;
    view.center = self.center;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(40, 15, 30, 30)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [indicator startAnimating];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 110, 30)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont systemFontOfSize:16];
    lab.text = @"加载中";
    
    [view addSubview:indicator];
    [view addSubview:lab];
    
    [self addSubview:view];
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide];
    });
}

- (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}


@end
