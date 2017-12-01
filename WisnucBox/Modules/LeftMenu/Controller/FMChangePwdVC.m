//
//  FMChangePwdVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMChangePwdVC.h"
#import "FMUpdateUserPasswordAPI.h"

@interface FMChangePwdVC ()

@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UITextField *rePwdTF;
@property (weak, nonatomic) IBOutlet UITextField *oldPwd;

@end

@implementation FMChangePwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改登录密码";
}

- (IBAction)btnClick:(id)sender {
    if(IsNilString(_oldPwd.text)) return [SXLoadingView showAlertHUD:@"请输入原密码" duration:1];
    if(IsNilString(_pwdTF.text)) return [SXLoadingView showAlertHUD:@"请输入新密码" duration:1];
    if(IsNilString(_rePwdTF.text)) return [SXLoadingView showAlertHUD:@"请确认新密码" duration:1];
    if(!IsEquallString(_pwdTF.text, _rePwdTF.text)) return [SXLoadingView showAlertHUD:@"两次输入的新密码不一致" duration:1];
    
    FMUpdateUserPasswordAPI * api = [FMUpdateUserPasswordAPI new];
    api.oldPwd = _oldPwd.text;
    api.nPwd = _pwdTF.text;
    [SXLoadingView showProgressHUD:@"正在修改..."];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        [SXLoadingView showAlertHUD:@"修改成功" duration:1];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        [SXLoadingView showAlertHUD:@"修改失败" duration:1];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
