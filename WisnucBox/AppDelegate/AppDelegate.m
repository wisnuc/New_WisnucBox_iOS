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
#import "WBLoginViewController.h"
#import "WBInitializationViewController.h"
#import "FMSetting.h"
#import <AvoidCrash/AvoidCrash.h>
#import "WBPpgAskToUploadAlertViewController.h"
#import "WBppgViewController.h"
#import "WBPpgDownloadSwitchAPI.h"
#import "WBBoxViewController.h"
#import "WBChatListViewController.h"

@interface AppDelegate () <WXApiDelegate,WBPpgAskToUploadAlertDelegate>
@property (nonatomic,strong) FMLoginViewController *loginController;
@property (nonatomic,strong) NSString *filePath;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStack];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelWarn];
    [AvoidCrash becomeEffective];
    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
    [self configWeChat];
//    if(WB_IS_DEBUG){
//        [self redirectNSlogToDocumentFolder];
//    }
    [AppServices sharedService];
    [self initRootVC];
    return YES;
}

- (void)dealwithCrashMessage:(NSNotification *)note {
    //注意:所有的信息都在userInfo中
    //你可以在这里收集相应的崩溃信息进行相应的处理(比如传到自己服务器)
    NSLog(@"%@",note.userInfo);
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
//        id x = [UIApplication sharedApplication].delegate;
        self.leftManager = nil;
        FMLoginViewController *loginController = [[FMLoginViewController alloc]init];
        _loginController = loginController;
        UINavigationController *rootNaviController = [[UINavigationController alloc]initWithRootViewController:loginController];
        self.window.rootViewController = rootNaviController;
    }
    [self.window makeKeyAndVisible];
}

- (void)saveBoxesToken {
    [WB_NetService getBoxesToken:^(NSError *error, NSString *token) {
        if (!error) {
            WB_UserService.currentUser.boxToken = token;
            [WB_UserService setCurrentUser:WB_UserService.currentUser];
            [WB_UserService synchronizedCurrentUser];
        }else{
            NSLog(@"%@",error);
        }
    }];
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
        [WB_UserService upgradeCheckAction];
        NSLog(@"%@",WB_UserService.currentUser.guid);
        if (WB_UserService.currentUser.guid) {
            [self saveBoxesToken];
        }
    });
    
    [[CSUploadHelper shareManager]startUploadAction];
    
    FirstFilesViewController *filesViewController = [[FirstFilesViewController alloc]init];
    WBChatListViewController *chatViewController = [[WBChatListViewController alloc]init];
    NavViewController *nav2 = [[NavViewController alloc] initWithRootViewController:photosVC];
    NavViewController *nav3 = [[NavViewController alloc] initWithRootViewController:filesViewController];
    NavViewController *nav1 = [[NavViewController alloc] initWithRootViewController:chatViewController];
    photosVC.title = kPhotoTabBarTitle;
    filesViewController.title = kFileTabBarTitle;
    chatViewController.title = kChatTabBarTitle;
    NSDictionary *dict1 = @{
                            CYLTabBarItemImage : @"group",
                            CYLTabBarItemSelectedImage : @"group_highLight",
                            };
    NSDictionary *dict2 = @{
                            CYLTabBarItemImage : @"photo",
                            CYLTabBarItemSelectedImage : @"photo_select",
                            };
    NSDictionary *dict3 = @{
                            CYLTabBarItemImage : @"storage",
                            CYLTabBarItemSelectedImage : @"storage_select",
                            };

    
    NSArray *tabBarItemsAttributes = @[ dict1, dict2,dict3];
    tabbar.tabBarItemsAttributes = tabBarItemsAttributes;
    [tabbar.tabBar setBackgroundImage:[UIImage new]];
    [tabbar.tabBar setShadowImage:[UIImage new]];
    [self dropShadowWithTabbarController:tabbar Offset:CGSizeMake(0, -1) radius:1 color:[UIColor blackColor] opacity:0.3];
    tabbar.tabBar.backgroundColor  = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1];
    NSMutableArray *viewControllersMutArr = [[NSMutableArray alloc] initWithObjects:nav1,nav2,nav3,nil];
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

- (void)leftMenuReloadData{
    [self.leftManager reloadUser];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"%@",NSStringFromClass([[UIViewController getCurrentVC] class]));
    //    NSString *controllerString = NSStringFromClass([[UIViewController getCurrentVC] class]);
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
                NSLog(@"%@写入成功",saveFile);
                _filePath = saveFile;
                int char1 = 0 ,char2 =0 ; //必须这样初始化
                [data getBytes:&char1 range:NSMakeRange(0, 1)];
                [data getBytes:&char2 range:NSMakeRange(1, 1)];
                NSLog(@"%d%d",char1,char2);
                NSString *numStr = [NSString stringWithFormat:@"%i%i",char1,char2];
                if (url && [numStr isEqualToString:@"10056"]) {
                    if (!WB_UserService.currentUser.ppgSelectType) {
                        WB_UserService.currentUser.ppgSelectType = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:PpgTypeAskAllTime]];
                        [WB_UserService synchronizedCurrentUser];
                        [self ppgDownloadAlert];
                    
                    }else{
                        if ([WB_UserService.currentUser.ppgSelectType intValue] == PpgTypeAskAllTime) {
                            [self ppgDownloadAlert];
                        }else if ([WB_UserService.currentUser.ppgSelectType intValue] == PpgTypeCreatNewTask){
                            [self ppgDownloadActionWithFilePath:saveFile];
                        }else if ([WB_UserService.currentUser.ppgSelectType intValue] == PpgTypeUpload){
                             [self uploadWithFilePath:saveFile];
                        }
                    }

                }else{
                [self uploadWithFilePath:saveFile];
            }
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
            }else  if([[UIViewController getCurrentVC] isKindOfClass:[WBInitializationViewController class]]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(WBInitializationViewController *)[UIViewController getCurrentVC] weChatCallBackRespCode:aresp.code];
                });
            }else{
                [SXLoadingView hideProgressHUD];
            }
        }
            break;
        case WXErrCodeAuthDeny://用户拒绝授权
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"rejected_authorization", nil) duration:1.5];
            break;
        case WXErrCodeSentFail://用户取消
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.5];
            break;
        case WXErrCodeUnsupport://用户取消
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"WeChat_not_support", nil) duration:1.5];
            break;
        case WXErrCodeUserCancel://用户取消
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"user_cancel_wechat", nil) duration:1.5];
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

- (void)ppgDownloadAlert{
    NSBundle *bundle = [NSBundle bundleForClass:[WBPpgAskToUploadAlertViewController class]];
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:NSStringFromClass([WBPpgAskToUploadAlertViewController class])bundle:bundle];
    NSString *identifier = NSStringFromClass([WBPpgAskToUploadAlertViewController class]);
    
    UIViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:identifier];
    WBPpgAskToUploadAlertViewController *vc = (WBPpgAskToUploadAlertViewController *)viewController;
    vc.delegate = self;
    viewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];
    
    //    viewController
    [self.window.rootViewController presentViewController:viewController animated:YES completion:NULL];
}

- (void)uploadWithFilePath:(NSString *)filePath{
    NSString *controllerString = NSStringFromClass([[UIViewController getCurrentVC] class]);
    NSFileManager *manager = [NSFileManager defaultManager];
    NSNumber* fileSize = [NSNumber numberWithLongLong:[[manager attributesOfItemAtPath:filePath error:nil]fileSize]];
    NSLog(@"%@",fileSize);
    
    [[CSUploadHelper shareManager] readyUploadFilesWithFilePath:filePath];
    if (![controllerString isEqualToString:NSStringFromClass([LocalDownloadViewController class])]) {
        CYLTabBarController * tVC = (CYLTabBarController *)MyAppDelegate.window.rootViewController;
        NavViewController * selectVC = (NavViewController *)tVC.selectedViewController;
        LocalDownloadViewController *localViewController  = [[LocalDownloadViewController alloc]init];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            selectVC.navigationBar.barTintColor = kWhiteColor;
            [selectVC  pushViewController:localViewController animated:YES];
        }
    }
}

- (void)confirmWithTypeString:(NSString *)typeString isAlways:(BOOL)always{
    if ([typeString containsString:@"新建"]) {
        [self ppgDownloadActionWithFilePath:_filePath];
    }else{
        if (_filePath) {
            [self uploadWithFilePath:_filePath];
        }
    }
    
    if (always) {
        if ([typeString containsString:@"新建"]) {
            WB_UserService.currentUser.ppgSelectType = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:PpgTypeCreatNewTask]];
          
        }else{
            WB_UserService.currentUser.ppgSelectType = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:PpgTypeUpload]];
        }
          [WB_UserService synchronizedCurrentUser];
        
    }
}

- (void)ppgDownloadActionWithFilePath:(NSString *)filePath{
    @weaky(self)
    NSString *controllerString = NSStringFromClass([[UIViewController getCurrentVC] class]);
    [SXLoadingView showProgressHUD:@""];
    [[WBPpgDownloadSwitchAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * responseDic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSNumber *number = responseDic[@"switch"];
//        NSLog(@"%@",dic);
        BOOL swichOn = [number boolValue];
        if (swichOn) {
            [weak_self startPpgDownloadWithFilePath:filePath];
        }else{
            if (![controllerString isEqualToString:NSStringFromClass([WBppgViewController class])]) {
                CYLTabBarController * tVC = (CYLTabBarController *)MyAppDelegate.window.rootViewController;
                NavViewController * selectVC = (NavViewController *)tVC.selectedViewController;
                WBppgViewController *localViewController  = [[WBppgViewController alloc]init];
                if ([selectVC isKindOfClass:[NavViewController class]]) {
                     selectVC.navigationBar.barTintColor = COR1;
                    [selectVC  pushViewController:localViewController animated:YES];
                }
            }
        }
        [SXLoadingView hideProgressHUD];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
    }];
}

- (void)startPpgDownloadWithFilePath:(NSString *)filePath{
    NSString *controllerString = NSStringFromClass([[UIViewController getCurrentVC] class]);
    [WB_NetService getDirUUIDWithDirName:BackUpPpgDirName BaseDir:^(NSError *error, NSString *dirUUID) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            NSLog(@"%@",dirUUID);
            [[CSUploadHelper shareManager] readyUploadPpgFilesWithFilePath:filePath DirUUID:dirUUID Complete:^(BOOL isComplete) {
                if (isComplete) {
                    if (![controllerString isEqualToString:NSStringFromClass([WBppgViewController class])]) {
                        CYLTabBarController * tVC = (CYLTabBarController *)MyAppDelegate.window.rootViewController;
                        NavViewController * selectVC = (NavViewController *)tVC.selectedViewController;
                        WBppgViewController *localViewController  = [[WBppgViewController alloc]init];
                        if ([selectVC isKindOfClass:[NavViewController class]]) {
                            selectVC.navigationBar.barTintColor = COR1;
                            [selectVC  pushViewController:localViewController animated:YES];
                        }
                    }
                }
            }];
        }
    }];
}


@end
