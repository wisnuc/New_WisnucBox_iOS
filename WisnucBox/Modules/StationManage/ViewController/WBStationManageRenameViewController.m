//
//  WBStationManageRenameViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageRenameViewController.h"
#import "WBReNameAPI.h"

@interface WBStationManageRenameViewController ()

@end

@implementation WBStationManageRenameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑设备名";
    self.renameTextField.text = _stationName;
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
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

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
     [self patchToReName];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
}

- (void)patchToReName{
    if (![_renameTextField.text isEqualToString:_stationName]) {
        [SXLoadingView showProgressHUDText:@"正在修改设备名,请稍候..." duration:1.2];
        WBReNameAPI *api = [WBReNameAPI apiWithName:_renameTextField.text];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.responseJsonObject);
            if (self.delegate && [self.delegate respondsToSelector:@selector(reNameComplete)]) {
                [self.delegate reNameComplete];
            }
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
