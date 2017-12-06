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
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation FMChangePwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"modify_password", nil);
    NSString *buttonTitle = WBLocalizedString(@"confirm", nil);
    [_confirmButton setTitle:buttonTitle forState:UIControlStateNormal];
    [_oldPwd setPlaceholder:WBLocalizedString(@"original_user_password", nil)];
    [_pwdTF setPlaceholder:WBLocalizedString(@"new_user_password", nil)];
    [_rePwdTF setPlaceholder:WBLocalizedString(@"confirm_user_password", nil)];
}

- (IBAction)btnClick:(id)sender {
    if(IsNilString(_oldPwd.text)) return [SXLoadingView showAlertHUD:WBLocalizedString(@"enter_original_password", nil) duration:1];
    if(IsNilString(_pwdTF.text)) return [SXLoadingView showAlertHUD:WBLocalizedString(@"enter_new_password", nil) duration:1];
    if(IsNilString(_rePwdTF.text)) return [SXLoadingView showAlertHUD:WBLocalizedString(@"confirm_new_password", nil) duration:1];
    if(!IsEquallString(_pwdTF.text, _rePwdTF.text)) return [SXLoadingView showAlertHUD:WBLocalizedString(@"new_password_inconsistent", nil) duration:1];
    
    FMUpdateUserPasswordAPI * api = [FMUpdateUserPasswordAPI new];
    api.oldPwd = _oldPwd.text;
    api.nPwd = _pwdTF.text;
    [SXLoadingView showProgressHUD:@"loading..."];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        [SXLoadingView showAlertHUD:WBLocalizedString(@"success", nil) duration:1];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        [SXLoadingView showAlertHUD:WBLocalizedString(@"error", nil) duration:1];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
