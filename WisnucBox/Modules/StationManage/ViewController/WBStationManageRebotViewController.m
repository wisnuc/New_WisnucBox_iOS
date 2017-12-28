//
//  WBStationManageRebotViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageRebotViewController.h"
#import "WBStationBootAPI.h"
#import "AppDelegate.h"

@interface WBStationManageRebotViewController ()
@property (weak, nonatomic) IBOutlet UIButton *rebotButton;
@property (weak, nonatomic) IBOutlet UIButton *shutDownButton;
@property (weak, nonatomic) IBOutlet UIButton *maintainButton;
@property (weak, nonatomic) IBOutlet UILabel *rebootPowerOffLabel;
@property (weak, nonatomic) IBOutlet UILabel *miantainLabel;
@property (weak, nonatomic) IBOutlet UILabel *miantainDetailLabel;

@end

@implementation WBStationManageRebotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = kStationManageRebootShutdownString;
    [_shutDownButton setTitle:WBLocalizedString(@"shutdown", nil) forState:UIControlStateNormal];
    [_rebotButton setTitle:WBLocalizedString(@"reboot", nil) forState:UIControlStateNormal];
    [_maintainButton setTitle:WBLocalizedString(@"reboot_and_enter_maintenance", nil) forState:UIControlStateNormal];
    [_rebootPowerOffLabel setText:WBLocalizedString(@"reboot_shutdown", nil)];
    [_miantainDetailLabel setText:WBLocalizedString(@"maintenance_explain", nil)];
    [_miantainLabel setText:WBLocalizedString(@"enter_maintenance", nil)];
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];

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
    NSString *confirmTitle = WBLocalizedString(@"confirm", nil);
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    NSString *titileString = WBLocalizedString(@"confirm_shutdown_title", nil);
    NSString *message = WBLocalizedString(@"confirm_shutdown", nil);
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:titileString message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了确定按钮");
        [SXLoadingView showProgressHUD:WBLocalizedString(@"shutting_down", nil)];
        WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"poweroff" Mode:nil];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"shut_down_successfully", nil) duration:1.5];
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"shutdown_failed", nil) duration:1.5];
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
    NSString *confirmTitle = WBLocalizedString(@"confirm", nil);
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    NSString *titileString = WBLocalizedString(@"confirm_reboot_title", nil);
    NSString *message = WBLocalizedString(@"confirm_reboot", nil);
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:titileString message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        
    }];
 
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了确定按钮");
        [SXLoadingView showProgressHUD:WBLocalizedString(@"rebooting", nil)];
        WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"reboot" Mode:nil];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"reboot_successfully", nil) duration:1.5];
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"reboot_failed", nil) duration:1.5];
        }];
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [self presentViewController:alertVc animated:YES completion:^{
    }];

}

- (IBAction)miantainButtonClick:(UIButton *)sender {
    NSString *confirmTitle = WBLocalizedString(@"confirm", nil);
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    NSString *titileString = WBLocalizedString(@"confirm_maintenance_title", nil);
    NSString *message = WBLocalizedString(@"confirm_maintenance", nil);
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:titileString message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了确定按钮");
        [SXLoadingView showProgressHUD:WBLocalizedString(@"entering_maintenance_mode", nil)];
        WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"reboot" Mode:@"maintenance"];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"enter_maintenance_mode_successfully", nil) duration:1.5];
            [self logOutAction];
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"enter_maintenance_mode_failed", nil) duration:1.5];
        }];
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [self presentViewController:alertVc animated:YES completion:^{
    }];
}

- (void)logOutAction{
    [SXLoadingView showProgressHUD:WBLocalizedString(@"logout...", nil)];
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


- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
