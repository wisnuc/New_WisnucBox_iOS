//
//  FMUserEditVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserEditVC.h"
#import "FMChangePwdVC.h"
#import "FMChangeNameVC.h"
#import "FMAccountUsersAPI.h"
#import "WBStationTicketsAPI.h"
#import "WBTicketsUserAPI.h"
#import "TicketUserModel.h"
#import "WBStationTicketsWechatAPI.h"
#import "WBCloudLoginAPI.h"
#import "CloudLoginModel.h"
#import "AppDelegate.h"
#import "FMAccountUsersAPI.h"
#import "UserModel.h"
#import "WBSettingSelectRolesViewController.h"


#define LogOutButtonColor UICOLOR_RGB(0xf44336)

@interface FMUserEditVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,SettingSelectRolesAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *navigationTitle;
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImageView;

@property (weak, nonatomic) IBOutlet UIButton *headerEditBtn;
@property (weak, nonatomic) IBOutlet UIButton *userName;
@property (weak, nonatomic) IBOutlet UIButton *bindWechatButton;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *bindWechatImageView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *leftNaviButton;

@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;
@property (strong,nonatomic) TicketModel *model;
@property (weak, nonatomic) IBOutlet UIButton *firstEditButton;
@property (weak, nonatomic) IBOutlet UIButton *secondEditButton;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;

@end

@implementation FMUserEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"编辑用户信息";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationTitle.text = WBLocalizedString(@"modify_user_info", nil);
    [self.leftNaviButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:10];
    [self.userHeaderImageView setImage:[UIImage imageForName:WB_UserService.currentUser.userName size:self.userHeaderImageView.bounds.size]];
    [self.userName setTitle:WB_UserService.currentUser.userName forState:UIControlStateNormal];
    [self.userName setEnlargeEdgeWithTop:3 right:10 bottom:3 left:2];
    [self.passwordButton setEnlargeEdgeWithTop:3 right:10 bottom:3 left:2];
    [self.headerEditBtn setEnlargeEdgeWithTop:3 right:10 bottom:3 left:2];
    [self.bindWechatButton setEnlargeEdgeWithTop:3 right:10 bottom:3 left:2];
    [self.bindWechatButton setTitle:WBLocalizedString(@"bind_wechat_user", nil) forState:UIControlStateNormal];
    [self.logoutButton setTitle:WBLocalizedString(@"logout", nil) forState:UIControlStateNormal];
  
    self.logoutButton.layer.cornerRadius = 2;
    self.logoutButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.logoutButton.layer.shadowRadius = 2.f;
    self.logoutButton.layer.shadowOffset = CGSizeMake(0, 3);
    self.logoutButton.layer.shadowOpacity = 0.4f;
    
}

- (void)getUserData{
    [[FMAccountUsersAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
//        NSLog(@"%@",request.responseJsonObject);
        UserModel *userModel = [UserModel modelWithDictionary:dic];
        if (userModel.global) {
            _userModel = userModel;
            [self.bindWechatButton setHidden:YES];
            [self.bindWechatImageView setHidden:YES];
            if (!WB_UserService.currentUser.avaterURL) {
                return ;
            }
            NSString *avatarUrl = WB_UserService.currentUser.avaterURL;
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:avatarUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.userHeaderImageView.image = [UIImage imageCirclewithImage:image];
                });
            }];
            
        }else{
            [self.userHeaderImageView setImage:[UIImage imageForName:WB_UserService.currentUser.userName size:self.userHeaderImageView.bounds.size]];
        }
//       [self.bindWechatButton setHidden:YES];
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"GET user info error : %@", request.error);
       
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if (self.type == UserDetail) {
        [self setDetailType];
    }else
    {
    if (!WB_UserService.currentUser.isCloudLogin) {
        [self getUserData];
    }else{
        [self.bindWechatButton setHidden:YES];
        [self.bindWechatImageView setHidden:YES];
    }
    [self.userHeaderImageView setImage:[UIImage imageForName:WB_UserService.currentUser.userName size:self.userHeaderImageView.bounds.size]];
    [self.userName setTitle:WB_UserService.currentUser.userName forState:UIControlStateNormal];
    [self.userName setUserInteractionEnabled:YES];
    [self.passwordButton setUserInteractionEnabled:YES];
    [self.bindWechatButton setUserInteractionEnabled:YES];
    [self.userTypeLabel setHidden:YES];
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)setDetailType{

    [self.userName setTitle:_userModel.username forState:UIControlStateNormal];
    [self.userHeaderImageView setImage:[UIImage imageForName:_userModel.username size:self.userHeaderImageView.bounds.size]];
    [self.userName setUserInteractionEnabled:NO];
    [self.passwordButton setUserInteractionEnabled:NO];
    [self.bindWechatButton setUserInteractionEnabled:NO];
    if (_userModel.global) {
        [_bindWechatButton setTitle:WBLocalizedString(@"WeChat_is_bound", nil) forState:UIControlStateNormal];
    }else{
        [_bindWechatButton setTitle:WBLocalizedString(@"WeChat_is_not_bound", nil) forState:UIControlStateNormal];
    }
    [_firstEditButton setHidden:YES];
    [_secondEditButton setHidden:YES];
    _secondImageView.image = [UIImage imageNamed:@"ic_account_circle"];
    if ([_userModel.isAdmin boolValue]&& [_userModel.isFirstUser boolValue]) {
        [_logoutButton setBackgroundColor:[UIColor lightGrayColor]];
        [_logoutButton setUserInteractionEnabled:NO];
        [_passwordButton setTitle:WBLocalizedString(@"super_administrator", nil) forState:UIControlStateNormal];
    }else if ([_userModel.isAdmin boolValue]&& ![_userModel.isFirstUser boolValue]){
        [_passwordButton setTitle:WBLocalizedString(@"administrator", nil) forState:UIControlStateNormal];
        if (WB_UserService.currentUser.isAdmin && WB_UserService.currentUser.isFirstUser) {
            [self.passwordButton setUserInteractionEnabled:YES];
            [_secondEditButton setHidden:NO];
        }else if(WB_UserService.currentUser.isAdmin && !WB_UserService.currentUser.isFirstUser){
            [_logoutButton setBackgroundColor:[UIColor lightGrayColor]];
            [_logoutButton setUserInteractionEnabled:NO];
        }
    }else if (![_userModel.isAdmin boolValue]&& ![_userModel.isFirstUser boolValue]){
        [_passwordButton setTitle:WBLocalizedString(@"general_user", nil) forState:UIControlStateNormal];
        if (WB_UserService.currentUser.isAdmin && WB_UserService.currentUser.isFirstUser) {
          [self.passwordButton setUserInteractionEnabled:YES];
          [_secondEditButton setHidden:NO];
        }
    }
    if ([_userModel.disabled boolValue]) {
        [_userTypeLabel setText:WBLocalizedString(@"disabled", nil)];
        [_userTypeLabel setHidden:NO];
        [_logoutButton setTitle:WBLocalizedString(@"enable", nil) forState:UIControlStateNormal];
    }else{
        [_userTypeLabel setHidden:YES];
        [_logoutButton setTitle:WBLocalizedString(@"disable", nil) forState:UIControlStateNormal];
    }

}

- (void)confirmWithTypeString:(NSString *)typeString{

    if ([typeString containsString:WBLocalizedString(@"administrator", nil)]) {
        if (![_userModel.isAdmin boolValue]) {
            [SXLoadingView showProgressHUD:@""];
            [[FMAccountUsersAPI apiWithRequestMethod:@"PATCH" IsAdmin:YES UUID:_userModel.uuid] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                NSLog(@"%@",request.responseJsonObject);
                NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
                UserModel *userModel = [UserModel modelWithDictionary:dic];
                _userModel = userModel;
                [_passwordButton setTitle:WBLocalizedString(@"administrator", nil) forState:UIControlStateNormal];
                [SXLoadingView hideProgressHUD];
//                [SXLoadingView showProgressHUDText:WBLocalizedString(@"enabled", nil) duration:1.2f];
            } failure:^(__kindof JYBaseRequest *request) {
                [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.2f];
                NSLog(@"%@",request.error);
                NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                if(errorData.length >0){
                    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                    NSLog(@"失败,%@",serializedData);
                }
            }];
        }
    }else{
        if ([_userModel.isAdmin boolValue]) {
            [SXLoadingView showProgressHUD:@""];
            [[FMAccountUsersAPI apiWithRequestMethod:@"PATCH" IsAdmin:NO UUID:_userModel.uuid] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                NSLog(@"%@",request.responseJsonObject);
                NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
                UserModel *userModel = [UserModel modelWithDictionary:dic];
                _userModel = userModel;
                [_passwordButton setTitle:WBLocalizedString(@"general_user", nil) forState:UIControlStateNormal];
                [SXLoadingView hideProgressHUD];
//                [_logoutButton setBackgroundColor:[UIColor lightGrayColor]];
//                [_logoutButton setUserInteractionEnabled:NO];
                //                [SXLoadingView showProgressHUDText:WBLocalizedString(@"enabled", nil) duration:1.2f];
            } failure:^(__kindof JYBaseRequest *request) {
                [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.2f];
                NSLog(@"%@",request.error);
                NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                if(errorData.length >0){
                    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                    NSLog(@"失败,%@",serializedData);
                }
            }];
        }
    }
}


- (IBAction)changUserName:(id)sender {
    FMChangeNameVC * vc = [FMChangeNameVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)changePwdBtn:(id)sender {
    if (self.type == UserDetail) {
    if ((![_userModel.isAdmin boolValue]&& ![_userModel.isFirstUser boolValue]) ||([_userModel.isAdmin boolValue]&& ![_userModel.isFirstUser boolValue]) ) {
        NSBundle *bundle = [NSBundle bundleForClass:[WBSettingSelectRolesViewController class]];
        UIStoryboard *storyboard =
        [UIStoryboard storyboardWithName:NSStringFromClass([WBSettingSelectRolesViewController class]) bundle:bundle];
        NSString *identifier = NSStringFromClass([WBSettingSelectRolesViewController class]);
        
        UIViewController *viewController =
        [storyboard instantiateViewControllerWithIdentifier:identifier];
        
        viewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];
        WBSettingSelectRolesViewController *vc = (WBSettingSelectRolesViewController *)viewController;
        if ([_userModel.isAdmin boolValue]) {
            vc.typeString =  WBLocalizedString(@"administrator", nil);
    
        }else{
            vc.typeString =  WBLocalizedString(@"general_user", nil);
        }
        vc.delegate = self;
        [self presentViewController:viewController animated:YES completion:NULL];
    }
    }else{
        FMChangePwdVC * vc = [[FMChangePwdVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (IBAction)changeAvater:(id)sender {

}

- (IBAction)bindWechatButtonClick:(UIButton *)sender {
    @weaky(self)
  
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [[WBStationTicketsAPI apiWithRequestMethodString:@"POST" Type:@"bind"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        TicketModel *model = [TicketModel modelWithJSON:request.responseJsonObject];
        _model = model;
            if ([WXApi isWXAppInstalled]) {
                SendAuthReq *req = [[SendAuthReq alloc] init];
                req.scope = @"snsapi_userinfo";
                req.state = @"App";
                [WXApi sendReq:req];
            }
            else {
                [weak_self setupAlertController];
            }
     
        NSLog(@"%@",request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            
            NSLog(@"%@",serializedData);
        }
        [SXLoadingView hideProgressHUD];
    }];
}

- (void)setupAlertController{
    [SXLoadingView showProgressHUDText:WBLocalizedString(@"not_installed_WeChat", nil) duration:1.5];
}

- (void)weChatCallBackRespCode:(NSString *)code{
    @weaky(self);
    [SXLoadingView showProgressHUD:nil];
    [[WBCloudLoginAPI apiWithCode:code] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        CloudLoginModel * model = [CloudLoginModel modelWithJSON:request.responseJsonObject];
        [weak_self bindWechtWithCloudToken:model.data.token];
//        weak_self.avatarUrl = model.data.user.avatarUrl;
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
    
}

- (void)bindWechtWithCloudToken:(NSString *)token{
    @weaky(self);
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    RACSubject *subject = [RACSubject subject];
    [[WBTicketsUserAPI apiWithTicketId:_model.ticketId WithToken:token]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * responseDic =  request.responseJsonObject[@"data"];
        TicketUserModel *model = [TicketUserModel modelWithDictionary:responseDic];
        [SXLoadingView hideProgressHUD];
        [subject sendNext:model];
        NSLog(@"%@",request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSLog(@"%@",request.error);
    }];
    
    [subject subscribeNext:^(id  _Nullable x) {
        TicketUserModel *userModel = x;
        NSString *alertActionTitleString = WBLocalizedString(@"bind", nil);
        NSString *alertTitleString = WBLocalizedString(@"confirm_binding_WeChat", nil);
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:alertTitleString message:WBLocalizedString(@"binding_WeChat?", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"点击了取消按钮");
            
             [weak_self bindWechatLastActionWith:userModel IsBind:NO];
        }];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:alertActionTitleString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"点击了确定按钮");
            [SXLoadingView showProgressHUD:WBLocalizedString(@"binding", nil)];
            [weak_self bindWechatLastActionWith:userModel IsBind:YES];
            
        }];
        [alertVc addAction:cancle];
        [alertVc addAction:confirm];
        [self presentViewController:alertVc animated:YES completion:^{
        }];
      
    }];
}

- (void)bindWechatLastActionWith:(TicketUserModel *)model IsBind:(BOOL)isBind{
    [[WBStationTicketsWechatAPI apiWithTicketId:_model.ticketId Guid:model.userId Isbind:isBind] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        
        WBUser *user = WB_UserService.currentUser;
        user.avaterURL = model.avatarUrl;
        user.isBindWechat = YES;
        [WB_UserService setCurrentUser:user];
        [WB_UserService synchronizedCurrentUser];
        if (isBind) {
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"success", nil) duration:1.5];
        }
        [_bindWechatImageView setHidden:YES];
        [_bindWechatButton setHidden:YES];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length>0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"%@",serializedData);
             [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"error，reason：%@",serializedData[@"message"]] duration:1.5];
        }
    }];
}

- (IBAction)logoutButtonClick:(UIButton *)sender {
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    if (self.type == UserDetail) {
        if ([_userModel.disabled boolValue]) {
            [[FMAccountUsersAPI apiWithRequestMethod:@"PATCH" Disabled:NO UUID:_userModel.uuid] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                NSLog(@"%@",request.responseJsonObject);
                NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
                 UserModel *userModel = [UserModel modelWithDictionary:dic];
                _userModel = userModel;
                [_logoutButton setTitle:WBLocalizedString(@"disable", nil) forState:UIControlStateNormal];
                [_userTypeLabel setHidden:YES];
                [SXLoadingView showProgressHUDText:WBLocalizedString(@"enabled", nil) duration:1.2f];
            } failure:^(__kindof JYBaseRequest *request) {
                [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.2f];
                NSLog(@"%@",request.error);
                NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                if(errorData.length >0){
                    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                    NSLog(@"失败,%@",serializedData);
                }
            }];
        }else{
            [[FMAccountUsersAPI apiWithRequestMethod:@"PATCH" Disabled:YES UUID:_userModel.uuid] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                 NSLog(@"%@",request.responseJsonObject);
                NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
                UserModel *userModel = [UserModel modelWithDictionary:dic];
                _userModel = userModel;
                
                  [_logoutButton setTitle:WBLocalizedString(@"enable", nil) forState:UIControlStateNormal];
                if ([_userModel.disabled boolValue]) {
                    [_userTypeLabel setText:WBLocalizedString(@"disabled", nil)];
                    [_userTypeLabel setHidden:NO];
                    [_logoutButton setTitle:WBLocalizedString(@"enable", nil) forState:UIControlStateNormal];
                }else{
                    [_userTypeLabel setHidden:YES];
                    [_logoutButton setTitle:WBLocalizedString(@"disable", nil) forState:UIControlStateNormal];
                }

                 [SXLoadingView showProgressHUDText:WBLocalizedString(@"disabled", nil) duration:1.2f];
            } failure:^(__kindof JYBaseRequest *request) {
                [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.2f];
                 NSLog(@"%@",request.error);
                NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                if(errorData.length >0){
                    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                    NSLog(@"失败,%@",serializedData);
                }
            }];
        }
    }else
    {
        [SXLoadingView showProgressHUD:WBLocalizedString(@"logout...", nil)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self skipToLogin];
        });
    }
}

-(void)skipToLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        MyAppDelegate.window.rootViewController = nil;
        [MyAppDelegate.window resignKeyWindow];
        [WB_UserService logoutUser];
        [WB_AppServices rebulid];
        for (UIView *view in MyAppDelegate.window.subviews) {
            [view removeFromSuperview];
        }
        //reload menu
//        [self reloadWithTitles:LeftMenu_NotAdminTitles andImages:LeftMenu_NotAdminImages];
        
        FMLoginViewController * vc = [[FMLoginViewController alloc]init];
        NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
        MyAppDelegate.window.rootViewController = nav;
        [MyAppDelegate.window makeKeyAndVisible];
    });
}


@end

@implementation TicketModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"ticketId": @"id",
             };
}
@end
