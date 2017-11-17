//
//  FMBaseFirstVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMBaseFirstVC.h"
#import "AppDelegate.h"

@interface FMBaseFirstVC ()

@end

@implementation FMBaseFirstVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //左按钮
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 56, 56)];
    [leftBtn addTarget:self action:@selector(showLeftMenu) forControlEvents:UIControlEventTouchUpInside];//设置按钮点击事件
    [leftBtn setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];//设置按钮正常状态图片
    [leftBtn setImage:[UIImage imageNamed:@"menu_select"] forState:UIControlStateHighlighted];

    UIBarButtonItem *leftBarButon = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16 - 2*([UIScreen mainScreen].scale - 1);//这个数值可以根据情况自由变化
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, leftBarButon];
    [self.cyl_tabBarController.tabBar setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.cyl_tabBarController.tabBar setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.cyl_tabBarController.tabBar setHidden:NO];
//    [UIApplication sharedApplication].statusBarHidden = NO;
}

-(void)showLeftMenu{
    if (MyAppDelegate.leftManager.menu) {
        [MyAppDelegate.leftManager.menu show];
    }
}

@end
