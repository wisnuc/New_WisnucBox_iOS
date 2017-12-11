//
//  FMUserLoginViewController.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/15.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMUserLoginViewController.h"
#import "FMLoginTextField.h"
#import "Base64.h"
#import "AppDelegate.h"
//#import "FMGetUserInfo.h"
//#import "FMUploadFileAPI.h"
//#import "LoginAPI.h"
#define  MainColor  UICOLOR_RGB(0x03a9f4)

@interface FMUserLoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) UIView *navigationView;
@property (strong, nonatomic) UIView *userNameBackgroudView;
@property (strong, nonatomic) UIImageView *userNameView;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIImageView *leftTextFieldImageView;
@property (strong, nonatomic) FMLoginTextField *loginTextField;
@property (strong, nonatomic) UILabel *passwordLabel;
@property (strong, nonatomic) UIButton *eyeButton;
@end

@implementation FMUserLoginViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:animated];
    [self.loginTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.loginTextField resignFirstResponder];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.loginTextField resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.userNameBackgroudView];
    [self setShadowForUserNameView];
    [self.userNameBackgroudView addSubview:self.userNameView];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.leftTextFieldImageView];
    [self.view addSubview:self.passwordLabel];
    [self.view addSubview:self.loginTextField];
    [self.view addSubview:[self setTextFieldLine]];
    [self.view addSubview:self.eyeButton];
}

-(void)dealloc{
    
}

#pragma mark textFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
     [self.view endEditing:YES];
    return YES;
}

- (void)eyeButtonAction:(UIButton *)sender{
      sender.selected = !sender.selected;
    if (!sender.selected) {
        _loginTextField.secureTextEntry = YES;
    }else{
        _loginTextField.secureTextEntry = NO;
    }
}

- (void)loginButtonClick:(UIButton *)sender{
    [self.view endEditing:YES];
    sender.userInteractionEnabled = NO;
    [SXLoadingView showProgressHUD:WBLocalizedString(@"logging_in", nil)];
    NSString * UUID = [NSString stringWithFormat:@"%@:%@",_user.uuid,IsNilString(_loginTextField.text)?@"":_loginTextField.text];
    NSString * Basic = [UUID base64EncodedString];
    [WB_AppServices loginWithBasic:Basic userUUID:_user.uuid StationName:_service.name UserName:_user.username addr:_service.displayPath AvatarURL:_user.avatar isWechat:NO completeBlock:^(NSError *error, WBUser *user) {
        if(error || IsNilString(user.userHome)){
            if(!user) NSLog(@"GET TOKEN ERROR");
            else NSLog(@"Get User Home Error");
            [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"%@ code: %ld", WBLocalizedString(@"login_failed", nil),(long)error.wbCode] duration:1];
            sender.userInteractionEnabled = YES;
        }else{
            AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate ;
            app.window.rootViewController = nil;
            [app.window resignKeyWindow];
            [app.window removeFromSuperview];
            sender.userInteractionEnabled = YES;
            [MyAppDelegate initRootVC];
            [SXLoadingView hideProgressHUD];
            sender.userInteractionEnabled = YES;
        }
    }];
}


#pragma mark - 验证手机号
+(BOOL)checkForMobilePhoneNo:(NSString *)mobilePhone{
    
    NSString *regEx = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    return [self baseCheckForRegEx:regEx data:mobilePhone];
}

#pragma mark - 私有方法
/**
 *  基本的验证方法
 *
 *  @param regEx 校验格式
 *  @param data  要校验的数据
 *
 *  @return YES:成功 NO:失败
 */
+(BOOL)baseCheckForRegEx:(NSString *)regEx data:(NSString *)data{
    
    NSPredicate *card = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    
    if (([card evaluateWithObject:data])) {
        return YES;
    }
    return NO;
}

- (UILabel *)setTextFieldLine{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_loginTextField.frame), CGRectGetMaxY(_loginTextField.frame) + 8, _loginTextField.frame.size.width, 1)];
    label.backgroundColor = COR1;
    return label;
}

- (void)setShadowForUserNameView {
    UIView *userNameShadow = [[UIView alloc]init];
    userNameShadow.frame = CGRectMake(0, 0, 100, 100);
    userNameShadow.center = CGPointMake(__kWidth/2, _userNameBackgroudView.frame.size.height/2 -25);
    userNameShadow.backgroundColor = [UIColor whiteColor];
    userNameShadow.alpha = 0.12;
    userNameShadow.layer.masksToBounds = YES;
    userNameShadow.layer.cornerRadius = 50;
    [self.userNameBackgroudView addSubview:userNameShadow];
}

- (void)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)navigationView{
    if (!_navigationView) {
        _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 64)];
        _navigationView.backgroundColor = MainColor;
        UIImage *image = [UIImage imageNamed:@"back"];
        UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(16, CGRectGetMidY(_navigationView.frame), image.size.width, image.size.height)];
        [backButton setImage:image forState:UIControlStateNormal];
        [backButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
        [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:backButton];
    }
    return _navigationView;
}

- (UIView *)userNameBackgroudView{
    if (!_userNameBackgroudView) {
        _userNameBackgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_navigationView.frame), __kWidth , 160)];
        _userNameBackgroudView.backgroundColor = MainColor;
    }
    return _userNameBackgroudView;
}

- (UIImageView *)userNameView{
    if (!_userNameView) {
        _userNameView = [[UIImageView alloc]init];
        _userNameView.frame = CGRectMake(0, 0, 88, 88);
        _userNameView.center = CGPointMake(__kWidth/2, _userNameBackgroudView.frame.size.height/2 - 25);
        _userNameView.backgroundColor = [UIColor whiteColor];
        _userNameView.layer.masksToBounds = YES;
        _userNameView.layer.cornerRadius = 44;
        _userNameView.image = [UIImage imageWhiteForName:_user.username size:_userNameView.bounds.size];
    }
    return _userNameView;
}

- (UIButton *)loginButton{
    if (!_loginButton) {
        _loginButton = [UIButton buttionWithTitle:@"登录" target:self action:@selector(loginButtonClick:)];
    }
    return _loginButton;
}

- (UIImageView *)leftTextFieldImageView{
    if (!_leftTextFieldImageView) {
        UIImage *image = [UIImage imageNamed:@"key"];
        _leftTextFieldImageView = [[UIImageView alloc]initWithImage:image];
        _leftTextFieldImageView.frame = CGRectMake(16, CGRectGetMaxY(_userNameBackgroudView.frame) + 32 + 8 +15, image.size.width, image.size.height);
    }
    return _leftTextFieldImageView;
}

-(UILabel *)passwordLabel{
    if (!_passwordLabel) {
        _passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(16+CGRectGetMaxX(_leftTextFieldImageView.frame), CGRectGetMaxY(_userNameBackgroudView.frame) + 32, 100, 15)];
        _passwordLabel.text = WBLocalizedString(@"password_text", nil);
        _passwordLabel.font = [UIFont systemFontOfSize:12];
        _passwordLabel.textColor = kBlackColor;
        _passwordLabel.alpha = 0.54;
    }
    return _passwordLabel;
}
- (FMLoginTextField *)loginTextField{
    if (!_loginTextField) {
        _loginTextField = [[FMLoginTextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(_passwordLabel.frame), CGRectGetMaxY(_passwordLabel.frame) + 8, __kWidth - CGRectGetMinX(_passwordLabel.frame) - 16, 20)];
        _loginTextField.secureTextEntry = YES;
        _loginTextField.returnKeyType = UIReturnKeyDone;
        _loginTextField.delegate = self;
    }
    return _loginTextField;
}

- (UIButton *)eyeButton{
    if (!_eyeButton) {
        UIImage *imageEye = [UIImage imageNamed:@"eye"];
        UIImage *imageEyeOff = [UIImage imageNamed:@"eye_off"];
        _eyeButton = [[UIButton alloc]initWithFrame:CGRectMake(__kWidth - 16 - imageEye.size.width, CGRectGetMinY(_leftTextFieldImageView.frame),imageEye.size.width , imageEye.size.height)];
        [_eyeButton setEnlargeEdgeWithTop:3 right:3 bottom:3 left:3];
        [_eyeButton setImage:imageEye forState:UIControlStateSelected];
        [_eyeButton setImage:imageEyeOff forState:UIControlStateNormal];
        [_eyeButton addTarget:self action:@selector(eyeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eyeButton;
}
@end
