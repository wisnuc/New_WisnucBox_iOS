//
//  WBStationManageRebotViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageRebotViewController.h"
#import "WBStationBootAPI.h"

@interface WBStationManageRebotViewController ()
@property (weak, nonatomic) IBOutlet UIButton *rebotButton;
@property (weak, nonatomic) IBOutlet UIButton *shutDownButton;
@property (weak, nonatomic) IBOutlet UIButton *maintainButton;

@end

@implementation WBStationManageRebotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关机与重启";
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
//    [_rebotButton.layer setMasksToBounds:YES];
//
//    [_rebotButton.layer setCornerRadius:3.0]; //设置矩圆角半径
//
//    [_rebotButton.layer setBorderWidth:1.0];   //边框宽度
//
//    [_rebotButton.layer setBorderColor:COR1.CGColor];
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

- (IBAction)shutDownButtonClick:(UIButton *)sender {
//    NSLog(@"%@",WB_UserService.currentUser.localToken);
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定关机吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了确定按钮");
        [SXLoadingView showProgressHUD:@"正在关机"];
        WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"poweroff" Mode:nil];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:@"关机成功" duration:1.5];
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:@"关机失败" duration:1.5];
            NSLog(@"%@",request.error);
            NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            if(errorData.length >0){
                NSMutableArray *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                NSLog(@"Upload Failure ---> :serializedData %@", serializedData);
            }
        }];
        
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [self presentViewController:alertVc animated:YES completion:^{
    }];
}

- (IBAction)rebotButtonClick:(UIButton *)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定重启设备吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了确定按钮");
        [SXLoadingView showProgressHUD:@"正在重启"];
        WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"reboot" Mode:nil];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:@"重启成功" duration:1.5];
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:@"重启失败" duration:1.5];
        }];
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [self presentViewController:alertVc animated:YES completion:^{
    }];

}

- (IBAction)miantainButtonClick:(UIButton *)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定进入维护模式吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了确定按钮");
        [SXLoadingView showProgressHUD:@"正在进入维护模式"];
        WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"reboot" Mode:@"maintenance"];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:@"已进入维护模式" duration:1.5];
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:@"进入维护模式失败" duration:1.5];
        }];
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [self presentViewController:alertVc animated:YES completion:^{
    }];
}

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
