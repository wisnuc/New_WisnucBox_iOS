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
#import "UserModel.h"
#import "WBStationTicketsAPI.h"
#import "WBTicketsUserAPI.h"
#import "TicketUserModel.h"
#import "WBStationTicketsWechatAPI.h"
#import "WBCloudLoginAPI.h"
#import "CloudLoginModel.h"
#import "AppDelegate.h"

@interface FMUserEditVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImageView;

@property (weak, nonatomic) IBOutlet UIButton *headerEditBtn;
@property (weak, nonatomic) IBOutlet UIButton *userName;
@property (weak, nonatomic) IBOutlet UIButton *bindWechatButton;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *bindWechatImageView;

@property (strong,nonatomic) TicketModel *model;
@property (strong,nonatomic) UserModel *userModel;
@end

@implementation FMUserEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑用户信息";
    self.navigationController.navigationBar.translucent = NO;
    [self.userHeaderImageView setImage:[UIImage imageForName:WB_UserService.currentUser.userName size:self.userHeaderImageView.bounds.size]];
    [self.userName setTitle:WB_UserService.currentUser.userName forState:UIControlStateNormal];
    [self.userName setEnlargeEdgeWithTop:3 right:10 bottom:3 left:2];
    [self.headerEditBtn setEnlargeEdgeWithTop:3 right:10 bottom:3 left:2];
    [self.bindWechatButton setEnlargeEdgeWithTop:3 right:10 bottom:3 left:2];
}
- (void)getUserData{
    [[FMAccountUsersAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
//        NSLog(@"%@",request.responseJsonObject);
        UserModel *userModel = [UserModel yy_modelWithDictionary:dic];
        if (userModel.global) {
            _userModel = userModel;
            [self.bindWechatButton setHidden:YES];
            [self.bindWechatImageView setHidden:YES];
            if (!WB_UserService.currentUser.avaterURL) {
                return ;
            }
            NSString *avatarUrl = WB_UserService.currentUser.avaterURL;
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:avatarUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
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
    if (!WB_UserService.currentUser.isCloudLogin) {
        [self getUserData];
    }else{
        [self.bindWechatButton setHidden:YES];
        [self.bindWechatImageView setHidden:YES];
    }
    [self.userHeaderImageView setImage:[UIImage imageForName:WB_UserService.currentUser.userName size:self.userHeaderImageView.bounds.size]];
    [self.userName setTitle:WB_UserService.currentUser.userName forState:UIControlStateNormal];
}

- (IBAction)changUserName:(id)sender {
    FMChangeNameVC * vc = [FMChangeNameVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)changePwdBtn:(id)sender {
    FMChangePwdVC * vc = [[FMChangePwdVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (IBAction)changeAvater:(id)sender {

}

- (IBAction)bindWechatButtonClick:(UIButton *)sender {
    @weaky(self)
    [SXLoadingView showProgressHUD:@"正在准备绑定，请稍候"];
    [[WBStationTicketsAPI apiWithRequestMethodString:@"POST" Type:@"bind"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        TicketModel *model = [TicketModel yy_modelWithJSON:request.responseJsonObject];
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
        [SXLoadingView hideProgressHUD];
    }];
    
}

- (void)setupAlertController{
    [SXLoadingView showProgressHUDText:@"您尚未安装微信" duration:1.5];
}

- (void)weChatCallBackRespCode:(NSString *)code{
    @weaky(self);
    [SXLoadingView showProgressHUD:nil];
    [[WBCloudLoginAPI apiWithCode:code] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        CloudLoginModel * model = [CloudLoginModel yy_modelWithJSON:request.responseJsonObject];
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
        TicketUserModel *model = [TicketUserModel yy_modelWithDictionary:responseDic];
        [SXLoadingView hideProgressHUD];
        [subject sendNext:model];
        NSLog(@"%@",request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSLog(@"%@",request.error);
    }];
    
    [subject subscribeNext:^(id  _Nullable x) {
        TicketUserModel *userModel = x;
        
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要绑定该微信吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"点击了取消按钮");
            
//             [weak_self bindWechatLastActionWith:userModel IsBind:NO];
        }];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"点击了确定按钮");
            [SXLoadingView showProgressHUD:@"正在绑定..."];
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
            [SXLoadingView showProgressHUDText:@"微信绑定成功" duration:1.5];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length>0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"%@",serializedData);
             [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"微信绑定失败，原因：%@",serializedData[@"message"]] duration:1.5];
        }
    }];
}
- (IBAction)logoutButtonClick:(UIButton *)sender {
    [SXLoadingView showProgressHUD:@"正在注销"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self skipToLogin];
    });
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
