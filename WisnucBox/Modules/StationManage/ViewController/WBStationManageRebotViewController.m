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
#import "GCDAsyncSocket.h"
#import "WBStationEnterMaintanceAlertViewController.h"
#import "WBStationEnterMaintanceConfirmAVC.h"
#import "ServerBrowser.h"
#import "WBStationBootAPI.h"
#import "BootModel.h"

@interface WBStationManageRebotViewController ()<NSNetServiceBrowserDelegate,NSNetServiceDelegate,ServerBrowserDelegate>
{
     NSTimer* _reachabilityTimer;
}
@property (weak, nonatomic) IBOutlet UIButton *rebotButton;
@property (weak, nonatomic) IBOutlet UIButton *shutDownButton;
@property (weak, nonatomic) IBOutlet UIButton *maintainButton;
@property (weak, nonatomic) IBOutlet UILabel *rebootPowerOffLabel;
@property (weak, nonatomic) IBOutlet UILabel *miantainLabel;
@property (weak, nonatomic) IBOutlet UILabel *miantainDetailLabel;

@property (nonatomic) ServerBrowser* browser;
@property (nonatomic) UIViewController *alertViewController1;
@property (nonatomic) UIViewController *alertViewController2;
@property(nonatomic, strong) MDCDialogTransitionController *transitionController;
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
    self.transitionController = [[MDCDialogTransitionController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:COR1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [_reachabilityTimer invalidate];
    _reachabilityTimer = nil;
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
    @weaky(self);
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
        [self.view setUserInteractionEnabled:NO];
//        [SXLoadingView showProgressHUD:WBLocalizedString(@"entering_maintenance_mode", nil) duration:180.0f];
        
        NSBundle *bundle = [NSBundle bundleForClass:[WBStationEnterMaintanceAlertViewController class]];
        UIStoryboard *storyboard =
        [UIStoryboard storyboardWithName:NSStringFromClass([WBStationEnterMaintanceAlertViewController class]) bundle:bundle];
        NSString *identifier = NSStringFromClass([WBStationEnterMaintanceAlertViewController class]);
        
        UIViewController *alertViewController1 =
        [storyboard instantiateViewControllerWithIdentifier:identifier];
        
        alertViewController1.modalPresentationStyle = UIModalPresentationCustom;
        alertViewController1.transitioningDelegate = self.transitionController;
        _alertViewController1 = alertViewController1;
        [self presentViewController:alertViewController1 animated:YES completion:nil];
        
        MDCDialogPresentationController *presentationController =
        alertViewController1.mdc_dialogPresentationController;
        if (presentationController) {
            presentationController.dismissOnBackgroundTap = NO;
        }
        
        WBStationBootAPI *api = [WBStationBootAPI apiWithState:@"reboot" Mode:@"maintenance"];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//            [SXLoadingView hideProgressHUD];
//            [SXLoadingView showProgressHUDText:WBLocalizedString(@"enter_maintenance_mode_successfully", nil) duration:1.5];
//            [self logOutAction];
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0/*延迟执行时间*/ * NSEC_PER_SEC));

            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                 [weak_self getNetService];
            });
           
            [self.view setUserInteractionEnabled:YES];
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"enter_maintenance_mode_failed", nil) duration:1.5];
            [self.view setUserInteractionEnabled:YES];
        }];
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [self presentViewController:alertVc animated:YES completion:^{
    }];
}

- (void)getNetService{
    
   
    _browser = [[ServerBrowser alloc] initWithServerType:@"_http._tcp" port:-1];
    _browser.delegate = self;
    _reachabilityTimer =  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    [_reachabilityTimer fire];
}

- (void)refresh{
    if (_browser) {
        _browser = nil;
    }
    _browser = [[ServerBrowser alloc] initWithServerType:@"_http._tcp" port:-1];
    _browser.delegate = self;
}

/*
 * 发现客户端服务
 */
//- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
//    aNetService.delegate = self;
//    [aNetService resolveWithTimeout:6.0];
//    if ([aNetService.hostName rangeOfString:@"wisnuc-"].location !=NSNotFound) {
//        for (NSData * address in aNetService.addresses) {
//            NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
//            if ([addressString isEqualToString:WB_UserService.currentUser.sn_address]) {
//
//                //                [SXLoadingView hideProgressHUD];
//            }
//        }
//    }
//}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
   
}

- (void)dealloc{
    
}

- (void)serverBrowserFoundService:(NSNetService *)service {
    NSLog(@"%@",service.hostName);
    if ([service.hostName rangeOfString:@"wisnuc-"].location !=NSNotFound) {
        for (NSData * address in service.addresses) {
            NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
            if ([addressString isEqualToString:WB_UserService.currentUser.sn_address]) {
                NSLog(@"%@/%@",WB_UserService.currentUser.sn_address,addressString);
             NSString* urlString = [NSString stringWithFormat:@"http://%@:3000/", addressString];
                [self getBootInfoWithPath:urlString completeBlock:^(BootModel *model) {
                    if ([model.mode isEqualToString:@"maintenance"]) {
                    
                    [_alertViewController1 dismissViewControllerAnimated:YES completion:nil];

                    NSBundle *bundle = [NSBundle bundleForClass:[WBStationEnterMaintanceConfirmAVC class]];
                    UIStoryboard *storyboard =
                    [UIStoryboard storyboardWithName:NSStringFromClass([WBStationEnterMaintanceConfirmAVC class]) bundle:bundle];
                    NSString *identifier = NSStringFromClass([WBStationEnterMaintanceConfirmAVC class]);
                    
                    UIViewController *alertViewController2 =
                    [storyboard instantiateViewControllerWithIdentifier:identifier];
                    
                    alertViewController2.modalPresentationStyle = UIModalPresentationCustom;
                    alertViewController2.transitioningDelegate = self.transitionController;
                    _alertViewController2 = alertViewController2;
                    [self presentViewController:alertViewController2 animated:YES completion:NULL];
                    
                    MDCDialogPresentationController *presentationController =
                    alertViewController2.mdc_dialogPresentationController;
                    if (presentationController) {
                        presentationController.dismissOnBackgroundTap = NO;
                    }
                    [_reachabilityTimer invalidate];
                    _reachabilityTimer = nil;
                    }
                }];
                 break;
            }
        }
    }
}

- (void)getBootInfoWithPath:(NSString *)path completeBlock:(void(^)(BootModel *model))block{
    [[WBStationBootAPI apiWithPath:path RequestMethod:@"GET"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        @weaky(self)
        NSLog(@"%@",request.responseJsonObject);
        BootModel *bootModel = [BootModel modelWithJSON:request.responseJsonObject];
        //        if (bootModel.current) {
        if ([bootModel.state isEqualToString:@"started"]) {
            block(bootModel);
        }else if ([bootModel.state isEqualToString:@"stopping"]){
            
        }else{
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
            
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//                _count ++;
                //                    if (_count<11) {
                [weak_self getBootInfoWithPath:path completeBlock:block];
                //                    }
            });
        }
        //        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
}

- (void)serverBrowserLostService:(NSNetService *)service index:(NSUInteger)index {
    
}


- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
