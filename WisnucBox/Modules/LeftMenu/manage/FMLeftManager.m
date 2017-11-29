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
    if(WB_UserService.currentUser.isFirstUser || WB_UserService.currentUser.isAdmin) {
        _leftMenu.menus = LeftMenu_AdminTitles;
        _leftMenu.imageNames = LeftMenu_AdminImages;
    }else{
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
    [self _hiddenMenu];
    
#warning user change login
//    [SXLoadingView showProgressHUD:@"正在切换"];
//    
//    @weaky(MyAppDelegate);
//    [[FMCheckManager shareCheckManager] beginSearchingWithBlock:^(NSArray *discoveredServers) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            BOOL canFindDevice = NO;
//            NSLog(@"😁😁😁😁%@",discoveredServers);
//            for (NSNetService * service in discoveredServers) {
//                if ([service.hostName isEqualToString:info.bonjour_name]) {
//                    canFindDevice = YES;
//                    NSString * addressIP = [FMCheckManager serverIPFormService:service];
//                    BOOL isAlive = [FMCheckManager testServerWithIP:addressIP andToken:info.jwt_token];
//                    if (isAlive) { //如果可以跳转
//                        
//                        [SXLoadingView hideProgressHUD];
//                        
//                        //切换操作
//                        [FMDBControl reloadTables];
//                        [FMDBControl asyncLoadPhotoToDB];
//                        
//                        //清除deviceID
//                        FMConfigInstance.deviceUUID = info.deviceId;//清除deviceUUID
//                        FMConfigInstance.userToken = info.jwt_token;
//                        FMConfigInstance.userUUID = info.uuid;
//                        
//                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DRIVE_UUID_STR];
//                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DIR_UUID_STR];
//                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ENTRY_UUID_STR];
//                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
//                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
//                        
//                        //                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UUID_STR];
//                        
//                        JYRequestConfig * config = [JYRequestConfig sharedConfig];
//                        config.baseURL = [NSString stringWithFormat:@"%@:3000/",addressIP];
//                        //重置数据
//                        [weak_MyAppDelegate resetDatasource];
//                        
//                        if(IsNilString(USER_SHOULD_SYNC_PHOTO) || IsEquallString(USER_SHOULD_SYNC_PHOTO, info.uuid)){
//                            //设置   可备份用户为
//                            [[NSUserDefaults standardUserDefaults] setObject:info.uuid forKey:USER_SHOULD_SYNC_PHOTO_STR];
//                            [[NSUserDefaults standardUserDefaults] synchronize];
//                            //重启photoSyncer
//                            [PhotoManager shareManager].canUpload = YES;
//                        }else{
//                            [PhotoManager shareManager].canUpload = NO;//停止上传
//                        }
//                        //组装UI
//                        
//                        self.window.rootViewController = nil;
//                        [self.window resignKeyWindow];
//                        [self.window removeFromSuperview];
//                        
//                        weak_MyAppDelegate.sharesTabBar = [[RDVTabBarController alloc]init];
//                        [weak_MyAppDelegate initWithTabBar:MyAppDelegate.sharesTabBar];
//                        [weak_MyAppDelegate.sharesTabBar setSelectedIndex:0];
//                        weak_MyAppDelegate.filesTabBar = nil;
//                        [weak_MyAppDelegate reloadLeftMenuIsAdmin:NO];
//                        [weak_MyAppDelegate asynAnyThings];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            
//                            self.window.rootViewController = weak_MyAppDelegate.sharesTabBar;
//                            [self.window makeKeyAndVisible];
//                            //                            [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
//                        });
//                    }else{
//                        [SXLoadingView showAlertHUD:@"切换失败，设备当前状态未知，请检查" duration:1];
//                        //                        [self skipToLogin];
//                    }
//                    break;
//                }
//            }
//            [SXLoadingView hideProgressHUD];
//            if (!canFindDevice) {
//                [SXLoadingView showAlertHUD:@"切换失败，可能设备不在附近" duration:1];
//                //                [self skipToLogin];
//            }
//        });
//    }];
    
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
    }
    
        else if(IsEquallString(title, @"用户管理")){
                vc = [[FMUserSetting alloc]init];
                if ([selectVC isKindOfClass:[NavViewController class]]) {
                    [selectVC  pushViewController:vc animated:YES];
                }
        }

    
//    else if(IsEquallString(title, @"设备管理")){
//        if (!WB_UserService.currentUser.isCloudLogin) {
//            vc = [[WBStationManageRootViewController alloc]init];
//            if ([selectVC isKindOfClass:[NavViewController class]]) {
//                [selectVC  pushViewController:vc animated:YES];
//            }
//        }
//    }

    else if (IsEquallString(title, @"文件下载")){
        vc = [[LocalDownloadViewController alloc]init];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
    else if (IsEquallString(title, @"设置")){
        vc = [[FMSetting alloc]initPrivate];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
    else if(IsEquallString(title,@"注销")){
        NSLog(@"注销");
        //!!!!!: logout do something
        [SXLoadingView showProgressHUD:@"正在注销"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self skipToLogin];
        });
    }else if(IsEquallString(title,@"USER_FOOTERVIEW_CLICK")){
        vc = [FMUserLoginSettingVC new];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
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
