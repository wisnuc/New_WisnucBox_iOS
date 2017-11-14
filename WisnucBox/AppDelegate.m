//
//  AppDelegate.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "AppDelegate.h"
#import "FMLoginViewController.h"
#import "WBUser+CoreDataClass.h"
#import "AppServices.h"
#import "FilesViewController.h"
#import "AppServices.h"
#import "JYThumbVC.h"

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStack];
    [self configWeChat];
    [AppServices sharedService];
    [self initRootVC];
    return YES;
}


- (void)initRootVC {
    self.window.rootViewController = nil;
    UserServices * services = [AppServices sharedService].userServices;
    if(services.isUserLogin) {
        // userHome / backupdir / backupbasedir / token / address
        // To TabBar
        [self setUpLeftManager];
        RDVTabBarController * tabbar = [self setUpTabbar];
        self.window.rootViewController = tabbar;
    }else{
        // TO Login VC
        FMLoginViewController *loginController = [[FMLoginViewController alloc]init];
        UINavigationController *rootNaviController = [[UINavigationController alloc]initWithRootViewController:loginController];
        self.window.rootViewController = rootNaviController;
    }
    [self.window makeKeyAndVisible];
}

- (RDVTabBarController *)setUpTabbar {
    RDVTabBarController * tabbar = [RDVTabBarController new];
    JYThumbVC * photosVC = [[JYThumbVC alloc] initWithDataSource:[AppServices sharedService].assetServices.allAssets];
    FilesViewController *filesViewController = [[FilesViewController alloc]init];
    NavViewController *nav1 = [[NavViewController alloc] initWithRootViewController:photosVC];
    NavViewController *nav2 = [[NavViewController alloc] initWithRootViewController:filesViewController];
    photosVC.title = @"照片";
    filesViewController.title = @"文件";
    
    NSMutableArray *viewControllersMutArr = [[NSMutableArray alloc] initWithObjects:nav1,nav2,nil];
    [tabbar setViewControllers:viewControllersMutArr];
    
    NSArray *tabBarItemImages = @[ @"photo", @"storage"];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabbar tabBar] items]) {
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_select",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        index++;
    }
    tabbar.selectedIndex = 0;
    
    return tabbar;
}

- (void)setUpLeftManager {
    self.leftManager = [[FMLeftManager alloc] initLeftMenuWithTitles:@[] andImages:@[]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
}

//Wechat
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    //    FMLoginViewController * loginVC = [[FMLoginViewController alloc] init];
    BOOL res = [WXApi handleOpenURL:url delegate:self];
    return res;
}

-(void)onReq:(BaseReq*)req{
    
    //onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
}


- (void)onResp:(BaseResp*)resp{
    switch (resp.errCode) {
        case WXSuccess://用户同意
        {
//            SendAuthResp *aresp = (SendAuthResp *)resp;
//            [_zhuxiao weChatCallBackRespCode:aresp.code];
        }
            break;
        case WXErrCodeAuthDeny://用户拒绝授权
            [SXLoadingView showProgressHUDText:@"授权失败" duration:1.5];
            break;
        case WXErrCodeSentFail://用户取消
            [SXLoadingView showProgressHUDText:@"发送失败" duration:1.5];
            break;
        case WXErrCodeUnsupport://用户取消
            [SXLoadingView showProgressHUDText:@"微信不支持" duration:1.5];
            break;
        case WXErrCodeUserCancel://用户取消
            [SXLoadingView showProgressHUDText:@"用户点击取消并返回" duration:1.5];
            break;
        case WXErrCodeCommon://用户取消
            [SXLoadingView showProgressHUDText:@"普通错误类型" duration:1.5];
            break;
        default:
            break;
    }
}

- (BOOL)sendReq:(BaseReq*)req{
    return YES;
}


- (void)configWeChat{
    [WXApi registerApp:KWxAppID];
}

@end
