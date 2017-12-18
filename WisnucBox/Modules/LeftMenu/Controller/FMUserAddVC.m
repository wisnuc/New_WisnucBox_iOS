//
//  FMUserAddVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/29.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserAddVC.h"
#import "NSString+Validate.h"
//#import "FMCreateUserAPI.h"

@interface FMUserAddVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *doubleCheckTF;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (nonatomic) id navDelegate;
@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameTitileLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmTitleLabel;

@end

@implementation FMUserAddVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *titleString = WBLocalizedString(@"confirm", nil);
    [self.confirmButton setTitle:titleString forState:UIControlStateNormal];
    [_backButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
    self.userNameTF.returnKeyType = UIReturnKeyDone;
    self.userNameTF.delegate = self;
    self.passwordTF.returnKeyType = UIReturnKeyDone;
    self.passwordTF.delegate = self;
    self.doubleCheckTF.delegate = self;
    self.doubleCheckTF.returnKeyType = UIReturnKeyDone;
    self.navigationTitleLabel.text = WBLocalizedString(@"create_user", nil);
    self.userNameTitileLabel.text = WBLocalizedString(@"user_name", nil);
    self.passwordTitleLabel.text = WBLocalizedString(@"password_text", nil);
    self.confirmTitleLabel.text = WBLocalizedString(@"confirm_user_password", nil);
    self.userNameTF.placeholder = WBLocalizedString(@"user_name", nil);
    self.passwordTF.placeholder = WBLocalizedString(@"password_text", nil);
    self.doubleCheckTF.placeholder = WBLocalizedString(@"confirm_user_password", nil);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.navDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self.navDelegate;
}

- (IBAction)addBtnClick:(id)sender {
    if (![NSString isUserName:_userNameTF.text]) {
        [SXLoadingView  showProgressHUDText:WBLocalizedString(@"username_has_illegal_character", nil) duration:1];
        return;
    }
    
    if (![NSString isPassword:_passwordTF.text]) {
        [SXLoadingView  showProgressHUDText:WBLocalizedString(@"password_has_illegal_character", nil) duration:1];
        return;
    }
    
    if (self.passwordTF.text.length<=0) {
        [SXLoadingView  showProgressHUDText:WBLocalizedString(@"empty_password", nil) duration:1];
        return;
    }
    if (self.userNameTF.text.length<=0)
        [SXLoadingView  showProgressHUDText:WBLocalizedString(@"empty_username", nil) duration:1];
    else if(self.userNameTF.text.length > 16)
     [SXLoadingView  showProgressHUDText:WBLocalizedString(@"username_exceed_character", nil) duration:1];
    else if(self.passwordTF.text.length > 30)
     [SXLoadingView  showProgressHUDText:WBLocalizedString(@"password_exceed_character", nil) duration:1];
    else if(!IsEquallString(self.passwordTF.text, self.doubleCheckTF.text))
     [SXLoadingView  showProgressHUDText:WBLocalizedString(@"new_password_inconsistent",nil) duration:1];
    else{
        FMCreateUserAPI * api = [FMCreateUserAPI new];
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:self.userNameTF.text forKey:@"username"];
        [dic setObject:IsNilString(self.passwordTF.text)?@"":self.passwordTF.text forKey:@"password"];
        api.param = dic;
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView showAlertHUD:WBLocalizedString(@"success",nil) duration:1];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"FMCreateUserAPI %@",request.error);
            [SXLoadingView showAlertHUD:@"error" duration:1];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (textField == _userNameTF) {
//        if (string.length == 0) {
//            return YES;
//        }
//        else if (textField.text.length + string.length >20 ) {
//            [MyAppDelegate.notification displayNotificationWithMessage:@"用户名称不能大于!" forDuration:1];
//            return NO;
//        }
//    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField

{
    
    NSLog(@"textFieldDidBeginEditing");
    
    CGRect frame = textField.frame;
    
    CGFloat heights = self.view.frame.size.height;
    
    // 当前点击textfield的坐标的Y值 + 当前点击textFiled的高度 - （屏幕高度- 键盘高度 - 键盘上tabbar高度）
    
    // 在这一部 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
    
    int offset = frame.origin.y + 42- ( heights - 216.0-35.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    
    float height = self.view.frame.size.height;
    
    if(offset > 0)
        
    {
        
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        
        self.view.frame = rect;
        
    }
    
    [UIView commitAnimations];
    
}

- (IBAction)backButtonClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
    
}



@end
