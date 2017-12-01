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

@interface FMUserEditVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImageView;

@property (weak, nonatomic) IBOutlet UIButton *headerEditBtn;
@property (weak, nonatomic) IBOutlet UIButton *userName;
@property (weak, nonatomic) IBOutlet UIButton *bindWechatButton;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (strong,nonatomic) TicketModel *model;
@property (strong,nonatomic) UserModel *userModel;
@end

@implementation FMUserEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑用户信息";
<<<<<<< HEAD
    self.navigationController.navigationBar.translucent = NO;
    [self.userHeaderImageView setImage:[UIImage imageForName:WB_UserService.currentUser.userName size:self.userHeaderImageView.bounds.size]];
=======
>>>>>>> 08262f3f823774daaac92e4535f5f1a52680dd4c
    [self.userName setTitle:WB_UserService.currentUser.userName forState:UIControlStateNormal];
    
}
- (void)getUserData{
    [[FMAccountUsersAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
//        NSLog(@"%@",request.responseJsonObject);
        UserModel *userModel = [UserModel yy_modelWithDictionary:dic];
        if (userModel.global) {
            _userModel = userModel;
            [self.bindWechatButton setHidden:YES];
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
<<<<<<< HEAD
    [self.navigationController setNavigationBarHidden:YES animated:animated];
=======
    self.navigationController.navigationBarHidden = YES;
    if (!WB_UserService.currentUser.isCloudLogin) {
        [self getUserData];
    }else{
        [self.bindWechatButton setHidden:YES];
    }
>>>>>>> 08262f3f823774daaac92e4535f5f1a52680dd4c
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
<<<<<<< HEAD
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
=======
    self.navigationController.navigationBarHidden = NO;
>>>>>>> 08262f3f823774daaac92e4535f5f1a52680dd4c
}

- (IBAction)changeAvater:(id)sender {

}

- (IBAction)bindWechatButtonClick:(UIButton *)sender {
    @weaky(self)
    [SXLoadingView showProgressHUD:@"正在准备绑定，请稍候"];
    [[WBStationTicketsAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
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
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
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

@end

@implementation TicketModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"ticketId": @"id",
             };
}
@end
