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
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@end

@implementation FMChangeNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"modify_user_name", nil);
    NSString *titleString = WBLocalizedString(@"confirm", nil);
    [self.confirmButton setTitle:titleString forState:UIControlStateNormal];
    [self.uNameTF setPlaceholder:WBLocalizedString(@"user_name", nil)];
    UIButton * rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 24)];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitleColor:COR1 forState:UIControlStateNormal];
    [rightButton setTitle:WBLocalizedString(@"finish_text", nil) forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setEnlargeEdgeWithTop:5 right:10 bottom:5 left:5];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)rightButtonClick:(UIButton *)sender{
    if(IsEquallString(WB_UserService.currentUser.userName, _uNameTF.text)) return [SXLoadingView showAlertHUD:WBLocalizedString(@"different_user_name", nil) duration:1];
    if(IsNilString(_uNameTF.text)) return [SXLoadingView showAlertHUD:WBLocalizedString(@"empty_username", nil) duration:1];
    FMUpdateUserAPI * api = [FMUpdateUserAPI new];
    api.userName = _uNameTF.text;
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSDictionary *dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        WB_UserService.currentUser.userName = dic[@"username"];
        [WB_UserService synchronizedCurrentUser];
        [SXLoadingView showAlertHUD:WBLocalizedString(@"success", nil) duration:1];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        [SXLoadingView showAlertHUD:WBLocalizedString(@"error", nil) duration:1];
    }];
}

- (IBAction)btnClick:(id)sender {
   
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
