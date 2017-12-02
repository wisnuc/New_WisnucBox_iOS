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
#import "FirstFilesViewController.h"
#import "FMUserEditVC.h"
#import "CSUploadHelper.h"
#import "LocalDownloadViewController.h"

@interface AppDelegate () <WXApiDelegate>
@property (nonatomic,strong) FMLoginViewController *loginController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStack];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelWarn];
    [self configWeChat];
//    if(WB_IS_DEBUG)
//        [self redirectNSlogToDocumentFolder];
    [AppServices sharedService];
    [self initRootVC];
    return YES;
}

- (void)initRootVC {
    self.window.rootViewController = nil;
    if(WB_UserService.isUserLogin) {
        // userHome / backupdir / backupbasedir / token / address
        // To TabBar
        [self setUpLeftManager];
        CYLTabBarController * tabbar = [self setUpTabbar];
        self.window.rootViewController = tabbar;
    }else{
        // TO Login VC
        self.leftManager = nil;
        FMLoginViewController *loginController = [[FMLoginViewController alloc]init];
        _loginController = loginController;
        UINavigationController *rootNaviController = [[UINavigationController alloc]initWithRootViewController:loginController];
        self.window.rootViewController = rootNaviController;
    }
    [self.window makeKeyAndVisible];
}

- (CYLTabBarController *)setUpTabbar {
    CYLTabBarController * tabbar = [CYLTabBarController new];
    JYThumbVC * photosVC = [[JYThumbVC alloc] initWithLocalDataSource:[AppServices sharedService].assetServices.allAssets];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [WB_AssetService getNetAssets:^(NSError *error, NSArray<WBAsset *> *netAssets) {
            if(!error)
                return [photosVC addNetAssets:netAssets];
            NSLog(@"Fetch Net Assets Error --> : %@", error);
        }];
        
        [WB_AppServices updateCurrentUserInfoWithCompleteBlock:nil];
    });
    
    [[CSUploadHelper shareManager]startUploadAction];
    FirstFilesViewController *filesViewController = [[FirstFilesViewController alloc]init];
    NavViewController *nav1 = [[NavViewController alloc] initWithRootViewController:photosVC];
    NavViewController *nav2 = [[NavViewController alloc] initWithRootViewController:filesViewController];
    photosVC.title = @"照片";
    filesViewController.title = @"文件";
    NSDictionary *dict1 = @{
                            CYLTabBarItemImage : @"photo",
                            CYLTabBarItemSelectedImage : @"photo_select",
                            };
    NSDictionary *dict2 = @{
                            CYLTabBarItemImage : @"storage",
                            CYLTabBarItemSelectedImage : @"storage_select",
                            };
    
    NSArray *tabBarItemsAttributes = @[ dict1, dict2 ];
    tabbar.tabBarItemsAttributes = tabBarItemsAttributes;
    [tabbar.tabBar setBackgroundImage:[UIImage new]];
    [tabbar.tabBar setShadowImage:[self lineImageWithColor:[UIColor whiteColor]]];
   
    tabbar.tabBar.backgroundColor  = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    NSMutableArray *viewControllersMutArr = [[NSMutableArray alloc] initWithObjects:nav1,nav2,nil];
    [tabbar setViewControllers:viewControllersMutArr];
    tabbar.selectedIndex = 0;
    
    return tabbar;
}

// 将NSlog打印信息保存到Document目录下的文件中
- (void)redirectNSlogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"winsun.log"];// 注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
    //    NSFileManager *defaultManager = [NSFileManager defaultManager];
    //    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (UIImage *)lineImageWithColor:(UIColor *)lineColor {
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, lineColor.CGColor);
    CGContextFillRect(ctx, rect);
    UIImage *lineImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lineImage;
    
}

- (void)dropShadowWithTabbarController:(CYLTabBarController *)tabbar Offset:(CGSize)offset
                                radius:(CGFloat)radius
                                 color:(UIColor *)color
                               opacity:(CGFloat)opacity {
    
    // Creating shadow path for better performance
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, tabbar.tabBar.bounds);
    tabbar.tabBar.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    tabbar.tabBar.layer.shadowColor = color.CGColor;
    tabbar.tabBar.layer.shadowOffset = offset;
    tabbar.tabBar.layer.shadowRadius = radius;
    tabbar.tabBar.layer.shadowOpacity = opacity;
    
    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    tabbar.tabBar.clipsToBounds = NO;
}

- (void)setUpLeftManager {
    self.leftManager = [[FMLeftManager alloc] initLeftMenuWithTitles:@[] andImages:@[]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"%@",NSStringFromClass([[UIViewController getCurrentVC] class]));
    NSString *controllerString = NSStringFromClass([[UIViewController getCurrentVC] class]);
    if (self.window) {
        if (url) {
            NSString *fileNameStr = [url lastPathComponent];
            NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:KUploadFilesDocument createIfNotExist:YES];
            NSString* saveFile = [savePath stringByAppendingPathComponent:fileNameStr];
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSFileManager *manager = [NSFileManager defaultManager];
            if ([manager fileExistsAtPath:saveFile]) {
                NSError *error ;
                [manager removeItemAtPath:saveFile error:&error];
            }
            if (![data writeToFile:saveFile atomically:YES])
            {
                NSLog(@"%@写入失败",saveFile);
            }else{
               
               NSNumber* fileSize = [NSNumber numberWithLongLong:[[manager attributesOfItemAtPath:saveFile error:nil]fileSize]];
                NSLog(@"%@",fileSize);
            
                [[CSUploadHelper shareManager] readyUploadFilesWithFilePath:saveFile];
                if (![controllerString isEqualToString:NSStringFromClass([LocalDownloadViewController class])]) {
                    CYLTabBarController * tVC = (CYLTabBarController *)MyAppDelegate.window.rootViewController;
                    NavViewController * selectVC = (NavViewController *)tVC.selectedViewController;
                    LocalDownloadViewController *localViewController  = [[LocalDownloadViewController alloc]init];
                    
                    if ([selectVC isKindOfClass:[NavViewController class]]) {
                        [selectVC  pushViewController:localViewController animated:YES];
                    }
                }
                NSLog(@"%@写入成功",saveFile);
            }
        }
    }
   return [WXApi handleOpenURL:url delegate:self];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    if(WB_AppServices.photoUploadManager.shouldUpload) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
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
            SendAuthResp *aresp = (SendAuthResp *)resp;
            NSLog(@"%@",NSStringFromClass([[UIViewController getCurrentVC] class]));
            if ([[UIViewController getCurrentVC] isKindOfClass:[FMLoginViewController class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(FMLoginViewController *)[UIViewController getCurrentVC] weChatCallBackRespCode:aresp.code];
                });
            }else  if([[UIViewController getCurrentVC] isKindOfClass:[FMUserEditVC class]]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(FMUserEditVC *)[UIViewController getCurrentVC] weChatCallBackRespCode:aresp.code];
                });
            }else{
                [SXLoadingView hideProgressHUD];
            }
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

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    self.completeBlock = completionHandler;
}

@end
