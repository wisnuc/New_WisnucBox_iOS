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

@interface FMLeftManager ()<FMLeftMenuDelegate>

@end

@implementation FMLeftManager

- (instancetype)initLeftMenuWithTitles:(NSArray *)titles andImages:(NSArray *)imageNames {
    if(self = [super init]) {
        FMLeftMenu * leftMenu = [[[NSBundle mainBundle]loadNibNamed:@"FMLeftMenu" owner:nil options:nil]lastObject];
        [leftMenu getAllPhoto];
        leftMenu.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width * 0.8, [[UIScreen mainScreen] bounds].size.height);
        _leftMenu = leftMenu;
        
        leftMenu.delegate = self;
        leftMenu.menus = [NSMutableArray arrayWithObjects:@"文件下载",@"设置",@"注销",nil];//@"个人信息", @"我的私有云", @"用户管理", @"设置", @"帮助",
        leftMenu.imageNames = [NSMutableArray arrayWithObjects:@"storage",@"set",@"cancel",nil];//@"personal",@"cloud",@"user",@"set",@"help",
        //配置Users 列表
        
        leftMenu.usersDatasource = [self getUsersInfo];
        
        [leftMenu.settingTabelView reloadData];
        _userManagerVC = [[FMUserSetting alloc]init];
        _settingVC =  [[FMSetting alloc]initPrivate];
        _loginManager = [[FMLoginViewController alloc]init];
        
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
    RDVTabBarController * tVC = (RDVTabBarController *)MyAppDelegate.window.rootViewController;
    NavViewController * selectVC = (NavViewController *)tVC.selectedViewController;
    if(IsEquallString(title, @"个人信息")){
//        vc = self.Info;
//        if ([selectVC isKindOfClass:[NavViewController class]]) {
//            [selectVC  pushViewController:vc animated:YES];
//        }
    }else if(IsEquallString(title, @"用户管理")){
        vc = self.userManagerVC;
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
    else if (IsEquallString(title, @"文件下载")){
//        vc = self.downAndUpLoadManager;
//        if ([selectVC isKindOfClass:[NavViewController class]]) {
//            [selectVC  pushViewController:vc animated:YES];
//        }
        
    }
    else if (IsEquallString(title, @"设置")){
        vc = self.settingVC;
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
    else if(IsEquallString(title,@"注销")){
        NSLog(@"注销");
#warning logout
//        vc = self.zhuxiao;
//        [SXLoadingView showProgressHUD:@"正在注销"];
//        [PhotoManager shareManager].canUpload = NO;//停止上传
//        FMConfigInstance.userToken = @"";
//        FMConfigInstance.isCloud = NO;
//        [self resetDatasource];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
//        //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KSWITHCHON];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"siftPhoto"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"addCount"];
//        
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DRIVE_UUID_STR];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DIR_UUID_STR];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ENTRY_UUID_STR];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KSTATIONID_STR];
//        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//        [[PhotoManager shareManager] cleanUploadTask];
//        [[FMPhotoManager  defaultManager] stop];
//        [[FMPhotoManager  defaultManager] destroy];
//        [[TYDownLoadDataManager manager] cleanTask];
//        //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"addCountNumber"];
//        
//        //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UUID_STR];
//        [SXLoadingView hideProgressHUD];
//        [FMDBControl reloadTables];
//        [FMDBControl asyncLoadPhotoToDB];
//        
//        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
//        [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
//        [[SDImageCache sharedImageCache] clearMemory];
//        [[YYImageCache sharedCache].diskCache removeAllObjects];
//        [[YYImageCache sharedCache].memoryCache removeAllObjects];
//        self.filesTabBar = nil;
//        self.sharesTabBar = nil;
//        
//        _Info = nil;
//        _OwnCloud = nil;
//        _UserSetting = nil;
//        _Setting = nil;
//        _Help = nil;
//        //        _zhuxiao = [[FMLoginViewController alloc]init];
//        _downAndUpLoadManager = nil;
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

-(void)skipToLogin{
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.window.rootViewController = nil;
//        [self.window resignKeyWindow];
//        
//        for (UIView *view in self.window.subviews) {
//            [view removeFromSuperview];
//        }
//        [self.window removeFromSuperview];
//        self.UserSetting = nil;
//        
//        [self reloadLeftMenuIsAdmin:NO];
//        FMLoginViewController * vc = [[FMLoginViewController alloc]init];
//        _zhuxiao = vc;
//        //        vc.title = @"搜索附近设备";
//        NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
//        self.window.rootViewController = nav;
//        [self.window makeKeyAndVisible];
//    });
}


@end
