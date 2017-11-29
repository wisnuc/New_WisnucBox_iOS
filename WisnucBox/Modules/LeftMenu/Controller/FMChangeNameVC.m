//
//  FMChangeNameVC.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FMChangeNameVC.h"
#import "FMUpdateUserAPI.h"

@interface FMChangeNameVC ()
@property (weak, nonatomic) IBOutlet UITextField *uNameTF;
@end

@implementation FMChangeNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)btnClick:(id)sender {
    if(IsEquallString(WB_UserService.currentUser.userName, _uNameTF.text)) return [SXLoadingView showAlertHUD:@"请输入不同的用户名" duration:1];
    if(IsNilString(_uNameTF.text)) return [SXLoadingView showAlertHUD:@"用户名不能为空" duration:1];
    FMUpdateUserAPI * api = [FMUpdateUserAPI new];
    api.userName = _uNameTF.text;
    [SXLoadingView showProgressHUD:@"正在修改..."];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSDictionary *dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        WB_UserService.currentUser.userName = dic[@"username"];
        [WB_UserService synchronizedCurrentUser];
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
