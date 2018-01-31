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
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    [leftBtn addTarget:self action:@selector(showLeftMenu) forControlEvents:UIControlEventTouchUpInside];//设置按钮点击事件
    [leftBtn setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];//设置按钮正常状态图片
    [leftBtn setImage:[UIImage imageNamed:@"menu_select"] forState:UIControlStateHighlighted];
    [leftBtn setEnlargeEdgeWithTop:5 right:5 bottom:5 left:10];
    UIBarButtonItem *leftBarButon = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItems = @[leftBarButon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //左按钮
    

    [self.cyl_tabBarController.tabBar setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.cyl_tabBarController.tabBar setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.cyl_tabBarController.tabBar setHidden:NO];
    [self setNeedsStatusBarAppearanceUpdate];
}



- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)showLeftMenu{
    if (MyAppDelegate.leftManager.menu) {
        [MyAppDelegate.leftManager.menu show];
    }
}

@end
