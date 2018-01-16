    //
//  FMLeftManager.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/9.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FMLeftManager.h"
#import "FMUserSetting.h"
#import "FMSetting.h"
#import "AppDelegate.h"
#import "UIApplication+JYTopVC.h"
#import "FMUserLoginSettingVC.h"
#import "LocalDownloadViewController.h"
#import "WBStationManageRootViewController.h"
#import "FMUserEditVC.h"
#import "WBInviteWechatViewController.h"
#import "FMCheckManager.h"
#import "GCDAsyncSocket.h"
#import "WBppgViewController.h"

@interface FMLeftManager ()<FMLeftMenuDelegate>

@property (nonatomic) BOOL isUpdateingProgress;
@property (nonatomic) BOOL needRefrushProgress;

@end

@implementation FMLeftManager

- (instancetype)initLeftMenuWithTitles:(NSArray *)titles andImages:(NSArray *)imageNames {
    if(self = [super init]) {
        FMLeftMenu * leftMenu = [[[NSBundle mainBundle]loadNibNamed:@"FMLeftMenu" owner:nil options:nil]lastObject];
        leftMenu.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width * 0.8, [[UIScreen mainScreen] bounds].size.height);
        _leftMenu = leftMenu;
        
        leftMenu.delegate = self;
        leftMenu.menus = LeftMenu_NotAdminTitles;//@"个人信息", @"我的私有云", @"用户管理", @"设置", @"帮助",
        leftMenu.imageNames = LeftMenu_NotAdminImages;//@"personal",@"cloud",@"user",@"set",@"help",
        //配置Users 列表
        
        leftMenu.usersDatasource = [self getUsersInfo];
        
        [leftMenu.settingTabelView reloadData];
        //add observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoChange) name:UserInfoChangedNotify object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBackupProgress) name:WBBackupCountChangeNotify object:nil];
        self.menu = [MenuView MenuViewWithDependencyView:MyAppDelegate.window MenuView:leftMenu isShowCoverView:YES];
        self.menu.showBlock = ^() {
            
            UIViewController * topVC = [UIApplication topViewController];
            
            if([topVC isKindOfClass:[RTContainerController class]])
                topVC = ((RTContainerController *)topVC).contentViewController;
            if ([topVC isKindOfClass:[FMBaseFirstVC class]]) {
                return YES;
            }
            return NO;
        };
    }
    return self;
}

- (void)changeBackupProgress {
    if(_isUpdateingProgress) {
        _needRefrushProgress = YES;
        return;
    }
    @weaky(self);
    [WB_PhotoUploadManager getAllCount:^(NSInteger allCount) {
        weak_self.isUpdateingProgress = YES;
        weak_self.needRefrushProgress = NO;
        [weak_self.leftMenu updateProgressWithAllCount:allCount currentCount:WB_PhotoUploadManager.uploadedQueue.count complete:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weak_self.isUpdateingProgress = NO;
                if(weak_self.needRefrushProgress) [weak_self changeBackupProgress];
            });
        }];
    }];
}

- (void)delloc {
    NSLog(@"FMLeftManager delloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// userinfo update
- (void)userInfoChange {
    if(WB_UserService.currentUser.isBindWechat &&(WB_UserService.currentUser.isFirstUser || WB_UserService.currentUser.isAdmin)) {
        _leftMenu.menus = LeftMenu_AdminBindWechetTitles;
        _leftMenu.imageNames = LeftMenu_AdminBindWechetImages;
    }
    else if (WB_UserService.currentUser.isFirstUser || WB_UserService.currentUser.isAdmin){
        _leftMenu.menus = LeftMenu_AdminTitles;
        _leftMenu.imageNames = LeftMenu_AdminImages;
    }else {
        _leftMenu.menus = LeftMenu_NotAdminTitles;//@"个人信息", @"我的私有云", @"用户管理", @"设置", @"帮助",
        _leftMenu.imageNames = LeftMenu_NotAdminImages;
    }
    [_leftMenu.settingTabelView reloadData];
}

- (NSMutableArray *)getUsersInfo {
    NSMutableArray *allUser = [NSMutableArray arrayWithArray:[[AppServices sharedService].userServices getAllLoginUser]];
    [allUser enumerateObjectsUsingBlock:^(WBUser *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(IsEquallString(obj.uuid, [AppServices sharedService].userServices.currentUser.uuid)){
            *stop = YES;
            [allUser removeObjectAtIndex:idx];
        }
    }];
    return allUser;
}

-(void)_hiddenMenu{
    if (self.menu) {
        [self.menu hidenWithAnimation];
    }
}


#pragma mark - leftmenu Delegate

//切换 账户 响应
-(void)LeftMenuViewClickUserTable:(WBUser *)info{
    @weaky(self)
    [SXLoadingView showProgressHUD:@"正在切换"];
    [self _hiddenMenu];
    if (WB_UserService.currentUser.isCloudLogin && IsEquallString(info.cloudToken, WB_UserService.currentUser.cloudToken)) {
        [SXLoadingView hideProgressHUD];
        dispatch_async(dispatch_get_main_queue(), ^{
            [WB_UserService logoutUser];
            [WB_AppServices rebulid];
//            [WB_UserService setCurrentUser:info];
//            [WB_UserService synchronizedCurrentUser];
            [WB_NetService testForLANIP:info.localAddr commplete:^(BOOL success) { // test for it
                if(success) {
                    [WB_NetService getLocalTokenWithCloud:^(NSError *error, NSString *token) {
                        if(!error) {
                            WB_UserService.currentUser.isCloudLogin = NO;
                            [WB_AppServices.netServices updateIsCloud:NO andLocalURL:info.localAddr andCloudURL:WX_BASE_URL];
                            WB_UserService.currentUser.localToken = token;
                        }
                        [WB_UserService setCurrentUser:info];
                        [WB_UserService synchronizedCurrentUser];
                        [WB_AppServices nextSteapForLogin:^(NSError *error, WBUser *user) {
                            if (!error) {
                                AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate ;
                                app.window.rootViewController = nil;
                                [app.window resignKeyWindow];
                                [app.window removeFromSuperview];
                                [MyAppDelegate initRootVC];
                                [SXLoadingView showAlertHUD:@"切换成功" duration:1.2];
                            }
                        }];
                    }];
                }else
                    [WB_AppServices nextSteapForLogin:^(NSError *error, WBUser *user) {
                        if (!error) {
                            AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate ;
                            app.window.rootViewController = nil;
                            [app.window resignKeyWindow];
                            [app.window removeFromSuperview];
                            [MyAppDelegate initRootVC];
                            [SXLoadingView showAlertHUD:@"切换成功" duration:1.2];
                        }
                 }];
            }];
            
        });
        return;
    }
#warning user change login
//    @weaky(MyAppDelegate);
    [[FMCheckManager shareCheckManager] beginSearchingWithBlock:^(NSArray *discoveredServers) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL canFindDevice = NO;
            NSLog(@"😁😁😁😁%@",discoveredServers);
            for (NSNetService * service in discoveredServers) {
                for (NSData * address in service.addresses) {
                    NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
                    if ([addressString isEqualToString:info.sn_address]) {
                        canFindDevice = YES;
                        NSString * addressIP = [FMCheckManager serverIPFormService:service];
                        BOOL isAlive = [FMCheckManager testServerWithIP:addressIP andToken:info.localToken];
                        if (isAlive) { //如果可以跳转
                            [SXLoadingView hideProgressHUD];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                            [WB_UserService logoutUser];
                            [WB_AppServices rebulid];
                            [WB_UserService setCurrentUser:info];
                            [WB_UserService synchronizedCurrentUser];
                                [WB_AppServices nextSteapForLogin:^(NSError *error, WBUser *user) {
                                    if(!error){
                                        AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate ;
                                        app.window.rootViewController = nil;
                                        [app.window resignKeyWindow];
                                        [app.window removeFromSuperview];
                                        [MyAppDelegate initRootVC];
                                        [weak_self userInfoChange];
                                        [SXLoadingView showAlertHUD:@"切换成功" duration:1.2];
                                    }else{
                                         [SXLoadingView showAlertHUD:@"切换失败，请重新登录" duration:1.2];
                                         [MyAppDelegate initRootVC];
                                    }
                                }];
                               NSLog(@"%@", WB_UserService.currentUser);
                           
                             
                            });
                        }else{
                            [SXLoadingView showAlertHUD:@"切换失败，设备当前状态未知，请检查" duration:1];
                            //                        [self skipToLogin];
                        }
                        break;
                    }
                }
                [SXLoadingView hideProgressHUD];
                }
               
            if (!canFindDevice) {
                [SXLoadingView showAlertHUD:@"切换失败，可能设备不在附近" duration:1];
                //                [self skipToLogin];
            }
        });
    }];
    
}

-(void)LeftMenuViewClickSettingTable:(NSInteger)tag andTitle:(NSString *)title{
    [self _hiddenMenu];
    UIViewController * vc = nil;
    CYLTabBarController * tVC = (CYLTabBarController *)MyAppDelegate.window.rootViewController;
    NavViewController * selectVC = (NavViewController *)tVC.selectedViewController;
    if(IsEquallString(title, @"个人信息")){
        vc = [FMUserEditVC new];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }else
    
    if (IsEquallString(title,LeftMenuTransmissionManageString)){
        vc = [[LocalDownloadViewController alloc]init];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
    
    else if(IsEquallString(title, LeftMenuEquipmentManageString)){
        if (!WB_UserService.currentUser.isCloudLogin) {
            vc = [[WBStationManageRootViewController alloc]init];
            if ([selectVC isKindOfClass:[NavViewController class]]) {
                [selectVC.navigationBar setBarTintColor:COR1];
                [selectVC  pushViewController:vc animated:YES];
            }
        }else{
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"operation_not_support", nil) duration:1.5];
        }
    }
    
    else if (IsEquallString(title, LeftMenuInvitationString)){
//        if (!WB_UserService.currentUser.isCloudLogin) {
        vc = [[WBInviteWechatViewController alloc]init];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
//        }else{
//            [SXLoadingView showProgressHUDText:WBLocalizedString(@"operation_not_support", nil) duration:1.5];
//        }
    }
    
    else if (IsEquallString(title,LeftMenuPpgManageString)){
        vc = [[WBppgViewController alloc]init];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC.navigationBar setBarTintColor:COR1];
            [selectVC  pushViewController:vc animated:YES];
        }
    }
    
    else if (IsEquallString(title, LeftMenuSettingString)){
        vc = [[FMSetting alloc]initPrivate];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
//    }
//    else if(IsEquallString(title,@"注销")){
//        NSLog(@"注销");
//        //!!!!!: logout do something
//        [SXLoadingView showProgressHUD:@"正在注销"];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self skipToLogin];
//        });
    }else if(IsEquallString(title,@"USER_FOOTERVIEW_CLICK")){
        vc = [FMUserLoginSettingVC new];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
}

- (void)reloadUser{
    self.leftMenu.usersDatasource = [self getUsersInfo];
    [self.leftMenu.usersTableView reloadData];
}

- (void)reloadWithTitles:(NSArray *)titles andImages:(NSArray *)imageNames {
    
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
        [self reloadWithTitles:LeftMenu_NotAdminTitles andImages:LeftMenu_NotAdminImages];
        
        FMLoginViewController * vc = [[FMLoginViewController alloc]init];
        NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
        MyAppDelegate.window.rootViewController = nav;
        [MyAppDelegate.window makeKeyAndVisible];
    });
}


@end
