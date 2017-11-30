//
//  WBStationManageRebotViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageRebotViewController.h"
#import "WBStationBootAPI.h"

@interface WBStationManageRebotViewController ()
@property (weak, nonatomic) IBOutlet UIButton *rebotButton;
@property (weak, nonatomic) IBOutlet UIButton *shutDownButton;
@property (weak, nonatomic) IBOutlet UIButton *maintainButton;

@end

@implementation WBStationManageRebotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关机与重启";
//    [_rebotButton.layer setMasksToBounds:YES];
//
//    [_rebotButton.layer setCornerRadius:3.0]; //设置矩圆角半径
//
//    [_rebotButton.layer setBorderWidth:1.0];   //边框宽度
//
//    [_rebotButton.layer setBorderColor:COR1.CGColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UICOLOR_RGB(0x03a9f4)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkTextColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (IBAction)shutDownButtonClick:(UIButton *)sender {
    WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"shutdown" Mode:nil];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView showProgressHUDText:@"关机成功" duration:1.5];
    } failure:^(__kindof JYBaseRequest *request) {
        
    }];
}

- (IBAction)rebotButtonClick:(UIButton *)sender {
    WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"reboot" Mode:nil];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView showProgressHUDText:@"重启成功" duration:1.5];
    } failure:^(__kindof JYBaseRequest *request) {
        
    }];
}

- (IBAction)miantainButtonClick:(UIButton *)sender {
    WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"reboot" Mode:@"maintenance"];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView showProgressHUDText:@"已进入维护模式" duration:1.5];
    } failure:^(__kindof JYBaseRequest *request) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
