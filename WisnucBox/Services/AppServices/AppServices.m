//
//  AppServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "AppServices.h"
#import "PHAsset+JYEXT.h"
#import "AppDelegate.h"
#import "FMAccountUsersAPI.h"
#import "CSFileDownloadManager.h"
#import "FilesDataSourceManager.h"
#import "FLFIlesHelper.h"
#import "CSDownloadHelper.h"
#import "NSError+WBCode.h"
#import "CSFilesOneDownloadManager.h"
#import "CSFileUploadManager.h"
#import "CSUploadHelper.h"
#import "UserModel.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "FMCheckManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AppServices ()
@end

@implementation AppServices {
    BOOL _isRebuildingPhotoUploader;
    NSInteger _notiNumber;
    BOOL _isLogining; // 是否正在登陆
    BOOL _isBuilding; // 是否正在初始化
}
// init asset
// init userServices
// init net if has user (config baseurl)
// startup photoUploadManager
// if need upload start backup
+ (instancetype)sharedService {
    static AppServices * appServices;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appServices = [[AppServices alloc] init];
    });
    return appServices;
}

- (instancetype)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserAuthChange) name:ASSETS_AUTH_CHANGE_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetReachabilityNotify:) name:NETWORK_REACHABILITY_CHANGE_NOTIFY object:nil];
    _notiNumber = 0;
    [self _build];
    return self;
}

- (void)_build {
    [self assetServices];
    _isLogining = NO;
    _isBuilding = NO;
    isStartingUpload = NO;
    needRestart = NO;
    if(self.userServices.currentUser) [self netServices];
    if(self.assetServices.userAuth) {
        NSArray * allLocalAsset = [self.assetServices allAssets];
        [self.photoUploadManager startWithLocalAssets:allLocalAsset andNetAssets:@[]];
    }
}

- (void)rebulidCutUser{
    NSLog(@"%@",self.userServices.currentUser);
    [self abortCutUser];
    [self _build];
}

- (void)rebulid {
    [self abort];
    [self _build];
}

- (void)receiveMemoryWarning {
    [[SDWebImageManager sharedManager].imageCache clearMemory];
}

- (void)delloc {
    NSLog(@"AppServices dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Notification Handle
- (void)handleUserAuthChange {
    if(WB_AssetService.userAuth){
        NSArray * allLocalAsset = [self.assetServices allAssets];
        [self.photoUploadManager startWithLocalAssets:allLocalAsset andNetAssets:@[]];
    }
}

// Net Reachability
- (void)handleNetReachabilityNotify:(NSNotification *)noti {
    _notiNumber ++;
    AFNetworkReachabilityStatus status = self.netServices.status;
    if (_notiNumber>0) {
        if (status != AFNetworkReachabilityStatusReachableViaWiFi) {
            if ([CSFileDownloadManager sharedDownloadManager].downloadingTasks.count >0) {
                [[CSFileDownloadManager sharedDownloadManager] pauseAllDownloadTask];
            }
        }else{
          
            if ([CSFileDownloadManager sharedDownloadManager].downloadingTasks.count >0) {
                [[CSFileDownloadManager sharedDownloadManager] startAllDownloadTask];
            }
             [[CSUploadHelper shareManager]startUploadAction];
        }
    }
    
    if(_isLogining) return;
    if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        if (WB_UserService.currentUser && WB_UserService.currentUser.autoBackUp) {
            [self.photoUploadManager stop];
            if(!WB_UserService.currentUser.isCloudLogin)
                [WB_NetService checkForLANIP:WB_UserService.currentUser.localAddr commplete:^(BOOL success) { //测试是否可用网络
                    if(success){
                        [self startUploadAssets:nil];
                    }else{
                        [WB_NetService testAndCheckoutCloudIfSuccessComplete:^{
                            //                     [self startUploadAssets:nil];
                        }];
                    }
                }];
            else
                [WB_NetService testAndCheckoutIfSuccessComplete:^{
//                    [self startUploadAssets:nil];
                }];
        }else if(WB_UserService.currentUser &&!WB_UserService.currentUser.autoBackUp){
            if(!WB_UserService.currentUser.isCloudLogin)
                [WB_NetService checkForLANIP:WB_UserService.currentUser.localAddr commplete:^(BOOL success) { //测试是否可用网络
                    if(success){
                      [self startUploadAssets:nil];
                    }else{
                        [WB_NetService testAndCheckoutCloudIfSuccessComplete:^{
//                            [self startUploadAssets:nil];
                        }];
                    }
                }];
            else
                [WB_NetService testAndCheckoutIfSuccessComplete:^{
//                    [self startUploadAssets:nil];
                }];
        }
    }
    
    if(!WB_UserService.currentUser) return;
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        if(!WB_UserService.currentUser.isCloudLogin)
           [WB_NetService checkForLANIP:WB_UserService.currentUser.localAddr commplete:^(BOOL success) { //测试是否可用网络
               if (WB_UserService.currentUser.autoBackUp) {
                   if(success) {
                       [self startUploadAssets:nil];
//                   }else{
//                       [WB_NetService testAndCheckoutCloudIfSuccessComplete:^{
//                           //                            [self startUploadAssets:nil];
//                       }];
                   }
               }
           }];
        else
            [WB_NetService testAndCheckoutIfSuccessComplete:^{
                if (WB_UserService.currentUser.autoBackUp) {
                    [self startUploadAssets:nil];
                }
            }];
    }else {
        [self.photoUploadManager stop];
    }
}

//获取当前window
+ (UIWindow *)mainWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)])
    {
        return [app.delegate window];
    }
    else
    {
        return [app keyWindow];
    }
}

//need destroy photoUploadManager and rebulid if currentuser`s backupdir notfound,
- (void)rebulidUploadManager{
    if (_isRebuildingPhotoUploader)  return;
    _isRebuildingPhotoUploader = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_photoUploadManager) [_photoUploadManager destroy];
        _photoUploadManager = nil;
        @weaky(self);
        [self updateUserBackupDir:^(NSError *error, WBUser *user) {
            _isRebuildingPhotoUploader = false;
            if(!error) {
                [weak_self.photoUploadManager startWithLocalAssets:[self.assetServices allAssets] andNetAssets:@[]];
                [weak_self startUploadAssets:nil];
            } else
                NSLog(@"--------->> Update User BackUp Dir Error <<------------- \n error: %@", error);
        }];
    });
}

// get token
// create userSession
// isFirstUser ?
// config address
// userHome
// backupDir

// error.wbCode
// 10001 : get token error
// 10002 : get userHome error
// 10003 : get userBackupDir error
- (void)loginWithBasic:(NSString *)basic userUUID:(NSString *)uuid StationName:(NSString *)stationName UserName:(NSString *)userName addr:(NSString *)addr AvatarURL:(NSString *)avatar isWechat:(BOOL)isWechat completeBlock:(void(^)(NSError *error, WBUser *user))callback {
    @weaky(self);
    if(_isLogining) return;
    _isLogining = YES;
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSString* urlString = [NSString stringWithFormat:@"http://%@:3000/", addr];
    void(^_callback)(NSError *error, WBUser *user) = ^(NSError *error, WBUser *user) {
        _isLogining = NO;
        callback(error, user);
    };
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",basic] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@token",urlString] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString * token = responseObject[@"token"];
        self.netServices = [[NetServices alloc]initWithLocalURL:urlString andCloudURL:nil];
        WBUser *user = [WB_UserService createUserWithUserUUID:uuid];
        user.userName = userName;
        user.localAddr = urlString;
//        user.cloudToken = nil;
        user.localToken = token;
        user.isFirstUser = NO;
        user.isAdmin = NO;
        user.isCloudLogin = NO;
        user.bonjour_name = stationName;
        user.sn_address = addr;
        if (avatar) {
            user.avaterURL = avatar;
        }
        [WB_UserService setCurrentUser:user];
        [WB_UserService synchronizedCurrentUser];
        NSLog(@"GET Token Success");
        [weak_self nextSteapForLogin:_callback];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        error.wbCode = 10001;
        _callback(error, NULL);
    }];
}

- (void)wechatLoginWithUserModel:(CloudModelForUser *)cloudUserModel Token:(NSString *)cloudToken AvatarUrl:(NSString *)avatarUrl addr:(NSString *)addr completeBlock:(void(^)(NSError *error, WBUser *user))callback{
    @weaky(self);
    if(_isLogining) return;
    _isLogining = YES;
    void(^_callback)(NSError *error, WBUser *user) = ^(NSError *error, WBUser *user) {
        _isLogining = NO;
        callback(error, user);
    };
    self.netServices = [[NetServices alloc]initWithLocalURL:nil andCloudURL:addr];
    WBUser *user = [WB_UserService createUserWithUserUUID:cloudUserModel.uuid];
    user.userName = cloudUserModel.username;
    user.bonjour_name = cloudUserModel.name;
    user.stationId = cloudUserModel.stationId;
    user.cloudToken = cloudToken;
    user.isFirstUser = [cloudUserModel.isFirstUser boolValue];
    user.isAdmin = [cloudUserModel.isAdmin boolValue];
    user.isCloudLogin = YES;
    user.avaterURL = avatarUrl;
    if (!IsNilString(cloudUserModel.LANIP)) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:3000/", cloudUserModel.LANIP];
        user.localAddr = urlString;
    }
    [WB_UserService setCurrentUser:user];
    [WB_UserService synchronizedCurrentUser];
    NSLog(@"GET Token Success");
    [WB_NetService testForLANIP:user.localAddr commplete:^(BOOL success) { // test for it
        if(success) {
            [WB_NetService getLocalTokenWithCloud:^(NSError *error, NSString *token) {
                if(!error) {
                    user.isCloudLogin = NO;
                    [self.netServices updateIsCloud:NO andLocalURL:user.localAddr andCloudURL:WX_BASE_URL];
                    user.localToken = token;
                }
                [WB_UserService setCurrentUser:user];
                [WB_UserService synchronizedCurrentUser];
                [weak_self nextSteapForLogin:_callback];
            }];
        }else
            [weak_self nextSteapForLogin:_callback];
    }];
}

- (void)nextSteapForLogin:(void(^)(NSError *error, WBUser *user))callback{
    WBUser * user = WB_UserService.currentUser;
    @weaky(self);
    [WB_NetService getUserHome:^(NSError *error, NSString *userHome) {
        if(error) {
            [WB_UserService logoutUser];
            return callback(({error.wbCode = 10002; error;}), user);
        }
        user.userHome = userHome;
        [WB_UserService synchronizedCurrentUser];
        NSLog(@"GET USER HOME SUCCESS");
        [WB_NetService getUserBackupDirName:BackUpAssetDirName BackupDir:^(NSError *error, NSString *entryUUID) {
            if(error) {
                [WB_UserService logoutUser];
                return callback(({error.wbCode = 10003; error;}), user);
            }
            user.backUpDir = entryUUID;
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"GET BACKUP DIR SUCCESS");
            NSLog(@"%d",user.askForBackup);
            if(!user.askForBackup)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weak_self requestForBackupPhotos:^(BOOL shouldUpload) {
                        user.askForBackup = YES;
                        user.autoBackUp = shouldUpload;
                        [WB_UserService synchronizedCurrentUser];
                        if(shouldUpload) {
                            [weak_self startUploadAssets:nil];
                        }
                    }];
                });
            else if(user.autoBackUp && WB_NetService.status == AFNetworkReachabilityStatusReachableViaWiFi)
                [weak_self startUploadAssets:nil];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [weak_self updateCurrentUserInfoWithCompleteBlock:nil];
            });
            return callback(nil, user);
        }];
    }];
}

- (void)updateCurrentUserInfoWithCompleteBlock:(void(^)(NSError *, BOOL success))callback {
    [[FMAccountUsersAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSLog(@"%@",request.responseJsonObject);
         UserModel *userModel = [UserModel modelWithDictionary:dic];
        if (IsEquallString(userModel.uuid, WB_UserService.currentUser.uuid)) {
            WB_UserService.currentUser.isAdmin = [userModel.isAdmin boolValue];
            WB_UserService.currentUser.isFirstUser = [userModel.isFirstUser boolValue];
            if (userModel.global) {
                WB_UserService.currentUser.guid = userModel.global.guid;
                WB_UserService.currentUser.isBindWechat = YES;
            }else{
                WB_UserService.currentUser.isBindWechat = NO;
            }
            [WB_UserService synchronizedCurrentUser];
            //notify
            [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoChangedNotify object:nil];
        }
      
      
        if(callback) return callback(nil, WB_UserService.currentUser.isAdmin);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"Update user info error : %@", request.error);
        if(callback) return callback(request.error, NO);
    }];
}

- (void)updateUserBackupDir:(void(^)(NSError *, WBUser *))callback {
    [WB_NetService getUserHome:^(NSError *error, NSString *userHome){
        if(error) return callback(({error.wbCode = 10002; error;}), WB_UserService.currentUser);
        WB_UserService.currentUser.userHome = userHome;
        [WB_UserService synchronizedCurrentUser];
        NSLog(@"GET USER HOME SUCCESS");
        [WB_NetService getUserBackupDirName:BackUpAssetDirName BackupDir:^(NSError *error, NSString *entryUUID) {
            if(error) return callback(({error.wbCode = 10003; error;}), WB_UserService.currentUser);
            WB_UserService.currentUser.backUpDir = entryUUID;
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"GET BACKUP DIR SUCCESS");
            return callback(nil, WB_UserService.currentUser);
        }];
    }];
}

- (void)requestForBackupPhotos:(void(^)(BOOL shouldUpload))callback {
    NSString *alertTitle = WBLocalizedString(@"backup_tips", nil);
    NSString *alertMessage = WBLocalizedString(@"backup_alert_message", nil);
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        WB_UserService.currentUser.autoBackUp = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:UserBackUpConfigChangeNotify object:@(0)];
        [WB_UserService synchronizedCurrentUser];
        callback(NO);
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:WBLocalizedString(@"backup", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击了确定按钮");
        WB_UserService.currentUser.autoBackUp = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:UserBackUpConfigChangeNotify object:@(1)];
        [WB_UserService synchronizedCurrentUser];
        callback(YES);
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [MyAppDelegate.window.rootViewController presentViewController:alertVc animated:YES completion:^{
    }];
}

static BOOL isStartingUpload = NO;
static BOOL needRestart = NO;
- (void)startUploadAssets:(void(^)(void))complete {
    @weaky(self);
    if(isStartingUpload) {
        needRestart = YES;
        if(complete) complete();
        return;
    }
    isStartingUpload = YES;
    if(self.netServices.status != AFNetworkReachabilityStatusReachableViaWiFi) return [SXLoadingView showAlertHUD:WBLocalizedString(@"non_wifi", nil) duration:1];
    [self.netServices getEntriesInUserBackupDir:^(NSError *error, NSArray<EntriesModel *> *entries) {
        if(error) {
            isStartingUpload = NO;
            if(error.wbCode == WBUploadDirNotFound)
                [weak_self rebulidUploadManager];
            return NSLog(@"Get BackupDir entries error");
        }
        NSLog(@"Start Upload ...");
        NSMutableArray * netEntries = [NSMutableArray arrayWithArray:entries];
        [self.photoUploadManager setNetAssets:netEntries];
        [self.photoUploadManager startUpload];
        isStartingUpload = NO;
        if(complete) complete();
    }];
}


// services load
- (WBUploadManager *)photoUploadManager {
    @synchronized (self) {
        if(!_photoUploadManager) {
            _photoUploadManager = [[WBUploadManager alloc] init];
        }
        return _photoUploadManager;
    }
}

- (UserServices *)userServices {
    @synchronized (self) {
        if(!_userServices){
            _userServices = [[UserServices alloc]init];
        }
        return _userServices;
    }
}

- (AssetsServices *)assetServices {
    if(!_assetServices) {
        _assetServices = [[AssetsServices alloc]init];
        __weak typeof(self) weakSelf = self;
        _assetServices.AssetChangeBlock = ^(NSArray<JYAsset *> *removeObjs, NSArray<JYAsset *> *insertObjs) {
            [weakSelf.photoUploadManager addTasks:insertObjs];
            [weakSelf.photoUploadManager removeTasks:removeObjs];
        };
    }
    return _assetServices;
}

- (FilesServices *)fileServices {
    @synchronized (self) {
        if(!_fileServices) {
            _fileServices = [[FilesServices alloc] init];
        }
        return _fileServices;
    }
}

- (NetServices *)netServices {
    @synchronized (self) {
        if(!_netServices) {
            if(self.userServices.currentUser)
                _netServices = [[NetServices alloc] initWithLocalURL:self.userServices.currentUser.localAddr andCloudURL:nil];
            else{
                _netServices = [NetServices new];
                NSLog(@"Not Allow To New A NetService");
            }
        }
        return _netServices;
    }
}

- (DBServices *)dbServices {
    @synchronized (self) {
        if(!_dbServices) {
            _dbServices = [[DBServices alloc] init];
        }
        return _dbServices;
    }
}

- (JYProcessView *)progressView{
    if (!_progressView){
        _progressView = [JYProcessView processViewWithType:ProcessTypeLine];
    }
    return _progressView;
}

- (void)abortCutUser {
    //destory JYnetEngine
    [[JYNetEngine sharedInstance] cancleAllRequest];
    // TODO: maybe one is enough
    [[SDWebImageManager sharedManager] cancelAll];
    [[SDWebImageDownloader sharedDownloader] cancelAllDownloads];
    
//    _userServices ? [_userServices abort] : nil;
    _fileServices ? [_fileServices abort] : nil;
    _assetServices ? [_assetServices abort] : nil;
    _netServices ? [_netServices abort] : nil;
    _dbServices ? [_dbServices abort] : nil;
    _photoUploadManager ? [_photoUploadManager destroy] : nil;
    
//    _userServices = nil;
//    _fileServices = nil;
//    _assetServices = nil;
//    _netServices = nil;
//    _dbServices = nil;
//    _photoUploadManager = nil;
    //cancel download
    
    [CSFileDownloadManager destroyAll];
    [FilesDataSourceManager destroyAll];
    [FLFIlesHelper destroyAll];
    [CSDownloadHelper destroyAll];
    [CSFilesOneDownloadManager destroyAll];
    [CSUploadHelper destroyAll];
    [CSFileUploadManager destroyAll];
    [FMCheckManager destroyAll];
}

- (void)abort {
    //destory JYnetEngine
    [[JYNetEngine sharedInstance] cancleAllRequest];
    // TODO: maybe one is enough
    [[SDWebImageManager sharedManager] cancelAll];
    [[SDWebImageDownloader sharedDownloader] cancelAllDownloads];
    
    _userServices ? [_userServices abort] : nil;
    _fileServices ? [_fileServices abort] : nil;
    _assetServices ? [_assetServices abort] : nil;
    _netServices ? [_netServices abort] : nil;
    _dbServices ? [_dbServices abort] : nil;
    _photoUploadManager ? [_photoUploadManager destroy] : nil;
    
    _userServices = nil;
    _fileServices = nil;
    _assetServices = nil;
    _netServices = nil;
    _dbServices = nil;
    _photoUploadManager = nil;
    //cancel download
    
    [CSFileDownloadManager destroyAll];
    [FilesDataSourceManager destroyAll];
    [FLFIlesHelper destroyAll];
    [CSDownloadHelper destroyAll];
    [CSFilesOneDownloadManager destroyAll];
    [CSUploadHelper destroyAll];
    [CSFileUploadManager destroyAll];
    [FMCheckManager destroyAll];
}

@end

/*
 * asset backup and calculate asset hash manager
 *
 */

@interface WBUploadManager ()<CLLocationManagerDelegate>
{
    BOOL _isdestroing;
    NSURL * _uploadURL;
    NSString * _token;
    NSInteger _lastNotifyCount;
    BOOL _shouldNotify;
    BOOL _needRetry;
    BOOL _isStartLocation;
}

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashwaitingQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashWorkingQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashFailQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *uploadPaddingQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadingQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadedQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadErrorQueue;

@property (nonatomic, strong) NSMutableArray<EntriesModel *> * uploadedNetQueue;

@property (nonatomic, strong) NSMutableSet<NSString *> * uploadedNetHashSet;

@property (nonatomic, strong) NSMutableSet<NSString *> *uploadedLocalHashSet;

@property (nonatomic)  AFHTTPSessionManager  *manager;

@property (nonatomic) dispatch_queue_t managerQueue;

@property (nonatomic) dispatch_queue_t workingQueue;

@end

@implementation WBUploadManager

- (void)dealloc{
    NSLog(@"WBUploadManager dealloc");
}

- (instancetype)init {
    if(self = [super init]) {
        _isdestroing = NO;
        _shouldUpload = NO;
        _shouldNotify = NO;
        _needRetry = YES;
        _isStartLocation = NO;
        _lastNotifyCount = 0;
        _hashLimitCount = 4;
        _uploadLimitCount = 4;
        [self workingQueue];
        [self managerQueue];
    }
    return self;
}

- (AFHTTPSessionManager *)manager  {
    if(!_manager) {
        NSString * bundleId = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
        NSString * identifier = [NSString stringWithFormat:@"%@.backgroundSession", bundleId];
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        
        config.allowsCellularAccess = NO;
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        _manager.attemptsToRecreateUploadTasksForBackgroundSessions = YES;
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        @weaky(self);
        [_manager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
            @strongy(self)
            dispatch_async(self.managerQueue, ^{
                [self schedule];
            });
        }];
    }
    return _manager;
}

//low等级线程
- (dispatch_queue_t)workingQueue {
    if(!_workingQueue){
        _workingQueue = dispatch_queue_create("com.wisnucbox.uploadmanager.working", DISPATCH_QUEUE_CONCURRENT);
        dispatch_set_target_queue(_workingQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    }
    return _workingQueue;
}

- (dispatch_queue_t)managerQueue{
    if(!_managerQueue){
        _managerQueue = dispatch_queue_create("com.wisnucbox.uploadmanager.main", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_managerQueue, dispatch_get_global_queue(1, 0));
    }
    return _managerQueue;
}

- (NSMutableSet<NSString *> *)uploadedNetHashSet{
    @synchronized (self) {
        if(!_uploadedNetHashSet){
            _uploadedNetHashSet = [NSMutableSet set];
        }
        return _uploadedNetHashSet;
    }
}

- (NSMutableSet<NSString *> *)uploadedLocalHashSet {
    @synchronized (self) {
        if(!_uploadedLocalHashSet){
            _uploadedLocalHashSet = [NSMutableSet set];
        }
        return _uploadedLocalHashSet;
    }
}

-(NSMutableArray<JYAsset *> *)hashwaitingQueue{
    @synchronized (self) {
        if (!_hashwaitingQueue) {
            _hashwaitingQueue= [NSMutableArray arrayWithCapacity:0];
        }
        return _hashwaitingQueue;
    }
}

- (NSMutableArray<JYAsset *> *)hashWorkingQueue{
    @synchronized (self) {
        if (!_hashWorkingQueue) {
            _hashWorkingQueue= [NSMutableArray<JYAsset *> arrayWithCapacity:0];
        }
        return _hashWorkingQueue;
    }
}

- (NSMutableArray *)uploadedNetQueue{
    @synchronized (self) {
        if (!_uploadedNetQueue) {
            _uploadedNetQueue= [NSMutableArray arrayWithCapacity:0];
        }
        return _uploadedNetQueue;
    }
}

- (NSMutableArray<WBUploadModel *> *)uploadingQueue{
    @synchronized (self) {
        if (!_uploadingQueue) {
            _uploadingQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
        }
        return _uploadingQueue;
    }
}

- (NSMutableArray<JYAsset *> *)uploadPaddingQueue{
    @synchronized (self) {
        if (!_uploadPaddingQueue) {
            _uploadPaddingQueue= [NSMutableArray<JYAsset *> arrayWithCapacity:0];
        }
        return _uploadPaddingQueue;
    }
}

- (NSMutableArray<WBUploadModel *> *)uploadedQueue{
    @synchronized (self) {
        if (!_uploadedQueue) {
            _uploadedQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
        }
        return _uploadedQueue;
    }
}
- (NSMutableArray<WBUploadModel *> *)uploadErrorQueue{
    @synchronized (self) {
        if (!_uploadErrorQueue) {
            _uploadErrorQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
        }
        return _uploadErrorQueue;
    }
}

- (void)addTask:(JYAsset *)asset {
    dispatch_async(self.managerQueue, ^{
        if(asset) {
            _shouldNotify = YES;
            _needRetry = YES;
            [self.hashwaitingQueue addObject:asset];
            [self schedule];
        }
    });
}

- (void)addTasks:(NSArray<JYAsset *> *)assets {
    dispatch_async(self.managerQueue, ^{
        if(assets.count){
            _shouldNotify = YES;
            _needRetry = YES;
            [self.hashwaitingQueue addObjectsFromArray:assets];
            [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
            [self schedule];
        }
    });
}

- (void)removeTask:(JYAsset *)rmAsset {
    dispatch_async(self.managerQueue, ^{
        NSString * assetId = rmAsset.asset.localIdentifier;
        __block JYAsset * asset;
        [self.hashwaitingQueue enumerateObjectsUsingBlock:^(JYAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.localIdentifier, assetId)){
                asset = obj;
                *stop = YES;
            }
        }];
        if(asset) [self.hashwaitingQueue removeObject:asset];
        asset = nil;
        
        [self.uploadPaddingQueue enumerateObjectsUsingBlock:^(JYAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.localIdentifier, assetId)){
                asset = obj;
                *stop = YES;
            }
        }];
        if(asset) [self.uploadPaddingQueue removeObject:asset];
        
        __block WBUploadModel * upModel;
        [self.uploadingQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.asset.localIdentifier, assetId)){
                obj.isRemoved = YES; // remove
                [obj cancel]; //  not to uploadErrorQueue or uploadedQueue if removed
                upModel = obj;
                *stop = YES;
            }
        }];
        if(upModel) {
            [self.uploadingQueue removeObject:upModel];
            [self.uploadErrorQueue removeObject:upModel];
        }
        upModel = nil;
        [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.asset.localIdentifier, assetId)){
                upModel = obj;
                *stop = YES;
            }
        }];
        if(upModel) [self.uploadErrorQueue removeObject:upModel];
        upModel = nil;
        [self.uploadedQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.asset.localIdentifier, assetId)){
                upModel = obj;
                *stop = YES;
            }
        }];
        if(upModel) [self.uploadedQueue removeObject:upModel];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
        upModel = nil;
    });
}

- (void)removeTasks:(NSArray<JYAsset *> *)assets {
    if(!assets || !assets.count)  return;
    [assets enumerateObjectsUsingBlock:^(JYAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTask:obj];
    }];
}

- (void)getAllCount:(void(^)(NSInteger allCount))callback {
    dispatch_async(self.managerQueue, ^{
        NSInteger allCount =  self.hashwaitingQueue.count + self.hashWorkingQueue.count + self.hashFailQueue.count
        + self.uploadPaddingQueue.count + self.uploadingQueue.count
        + self.uploadedQueue.count + self.uploadErrorQueue.count;
        callback(allCount);
    });
}

- (void)startWithLocalAssets:(NSArray<JYAsset *> *)localAssets andNetAssets:(NSArray<EntriesModel *> *)netAssets {
    dispatch_async(self.managerQueue, ^{
        _shouldNotify = YES;
        _needRetry = YES;
        [self.hashwaitingQueue addObjectsFromArray:localAssets];
        NSComparator cmptr = ^(JYAsset * photo1, JYAsset * photo2){
            NSDate * tempDate = [[photo1 asset].creationDate laterDate:[photo2 asset].creationDate];
            if ([tempDate isEqualToDate:[photo1 asset].creationDate]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([tempDate isEqualToDate:[photo2 asset].creationDate]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        [self.hashwaitingQueue sortUsingComparator:cmptr];
        [self.uploadedNetQueue addObjectsFromArray:netAssets];
        NSMutableSet * hashSet = [NSMutableSet set];
        [netAssets enumerateObjectsUsingBlock:^(EntriesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.type, @"file") || !IsNilString(obj.photoHash)){
                [hashSet addObject:obj.photoHash];
            }
        }];
        self.uploadedNetHashSet = hashSet;
        [self schedule];
    });
}

- (void)setNetAssets:(NSArray<EntriesModel *> *)netAssets {
    dispatch_async(self.managerQueue, ^{
        self.uploadedNetQueue = [NSMutableArray arrayWithArray: netAssets];
        NSMutableSet * hashSet = [NSMutableSet set];
        [netAssets enumerateObjectsUsingBlock:^(EntriesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.type, @"file") || !IsNilString(obj.photoHash)){
                [hashSet addObject:obj.photoHash];
            }
        }];
        self.uploadedNetHashSet = hashSet;
        [self schedule];
    });
}

// clean error queue
// insert to uploadpending queue for retry
- (void)startUpload {
    self.shouldUpload = NO;
    // notify for start
    [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
    dispatch_async(self.managerQueue, ^{
        [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.uploadPaddingQueue addObject:obj.asset];
        }];
        [self.uploadErrorQueue removeAllObjects]; //clean error queue
        self.shouldUpload = YES;
        _needRetry = YES;
        [self schedule];
    });
}

- (void)asset:(JYAsset *)asset getSha256:(void(^)(NSError *, NSString *))callback {
    WBLocalAsset * as = [[AppServices sharedService].assetServices getAssetWithLocalId:asset.asset.localIdentifier];
    if(as) {
        asset.digest = as.digest;
        callback(NULL, as.digest);
    }else
        [asset.asset getSha256:^(NSError *error, NSString *sha256) {
            if(error) return callback(error, NULL);
            //save sha256
            asset.digest = sha256;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [WB_AppServices.assetServices saveAssetWithLocalId:asset.asset.localIdentifier digest:sha256];
            });
            callback(NULL, sha256);
        }];
}

- (void)schedule {
    if(_isdestroing) return;
    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0) {
        if(_shouldNotify){
            _shouldNotify = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:HashCalculateFinishedNotify object:nil];
        }
        NSLog(@"hash calculate finish. uploadPaddingQueue:%lu", (unsigned long)self.uploadPaddingQueue.count);
    }
    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0 && self.uploadPaddingQueue.count == 0 && self.uploadingQueue.count == 0){
        NSLog(@"backup asset finish ----=======>>>><<<<<<<<====-----  errorCount:%lu  finishedCount:%lu", (unsigned long)_uploadErrorQueue.count, (unsigned long)_uploadedQueue.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].idleTimerDisabled = NO;
        });
        dispatch_async(self.managerQueue, ^{
            if(self.uploadErrorQueue.count) { // retry
                _needRetry = NO;
                [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.uploadPaddingQueue addObject:obj.asset];
                }];
                [self.uploadErrorQueue removeAllObjects];
                [self schedule];
            }
        });
    }
    dispatch_async(self.managerQueue, ^{
        while(self.hashWorkingQueue.count < self.hashLimitCount && self.hashwaitingQueue.count > 0) {
            JYAsset * asset = [self.hashwaitingQueue firstObject];
            [self.hashwaitingQueue removeObject:asset];
            [self.hashWorkingQueue addObject:asset];
            __weak typeof(self) weakSelf = self;
            dispatch_async([self workingQueue], ^{
                [self asset:asset getSha256:^(NSError *error, NSString *sha256) {
                    dispatch_async(self.managerQueue, ^{
                        if (error) {
                            [weakSelf.hashFailQueue addObject:asset];
                        }else {
                            asset.digest = sha256;
                            [weakSelf.uploadPaddingQueue addObject:asset];
                        }
                        [weakSelf.hashWorkingQueue removeObject:asset];
                        [weakSelf schedule];
                    });
                }];
            });
        }
        
        if(!_shouldUpload) return;
        while(self.uploadPaddingQueue.count > 0 && self.uploadingQueue.count < self.uploadLimitCount) {
            JYAsset * asset = [self.uploadPaddingQueue firstObject];
            [self.uploadPaddingQueue removeObject:asset];
            WBUploadModel * model = [WBUploadModel initWithAsset:asset andManager:self.manager];
            if([self.uploadedNetHashSet containsObject:asset.digest] || [self.uploadedLocalHashSet containsObject:asset.digest]) {
                [self.uploadedQueue addObject:model];
                NSLog(@"发现一个已上传的，直接跳过, error: %lu  finish:%lu", (unsigned long)_uploadErrorQueue.count, (unsigned long)_uploadedQueue.count);
                [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
                [self schedule];
                
            }else {
                [self.uploadingQueue addObject:model];
                dispatch_async(self.workingQueue, ^{
                    [self scheduleForUpload:model andUseTimeStamp:NO];
                });
            }
        }
    });
}

// retry if eexist
- (void)scheduleForUpload:(WBUploadModel *)model andUseTimeStamp:(BOOL)yesOrNo {
    __weak typeof(self) weakSelf = self;
    __weak typeof(WB_AppServices) weak_AppService = WB_AppServices;
    dispatch_async(self.workingQueue, ^{
        [model startUseTimeStamp:yesOrNo completeBlock:^(NSError *error, id response) {
            if(!weakSelf) return;
            dispatch_async(weakSelf.managerQueue, ^{
                if (error) {
                    if (error.wbCode == WBUploadDirNotFound) {
                        [weakSelf stop];   // stop
                        // need rebuild
                        [weakSelf destroy];
                        NSLog(@"文件上传目录丢失 开始重建");
                        [weak_AppService rebulidUploadManager];
                    }else if (error.wbCode == WBUploadFileExist) {
                        // rename then retry
                        NSLog(@"文件 EExist,  重命名 再次尝试！");
                        [weakSelf scheduleForUpload:model andUseTimeStamp:YES];
                    }else {
                        if(!model.isRemoved)
                            [weakSelf.uploadErrorQueue addObject:model];
                        [weakSelf.uploadingQueue removeObject:model];
                        NSLog(@"上传失败 , error: %lu  finish:%lu", (unsigned long)weakSelf.uploadErrorQueue.count, (unsigned long)weakSelf.uploadedQueue.count);
                    }
                }else{  // success
                    NSLog(@"上传成功 , error: %lu  finish:%lu", (unsigned long)weakSelf.uploadErrorQueue.count, (unsigned long)weakSelf.uploadedQueue.count);
                    [weakSelf.uploadingQueue removeObject:model];
                    [weakSelf.uploadedLocalHashSet addObject:model.asset.digest]; // record for skip equal-hash asset
                    if(![weakSelf.uploadedQueue containsObject:model]) {
                        if(!model.isRemoved)
                            [weakSelf.uploadedQueue addObject:model];
                        [weakSelf.uploadingQueue removeObject:model];
                        [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
                    }
                }
                [weakSelf schedule];
            });
        }];
    });
}

- (void)setShouldUpload:(BOOL)shouldUpload {
    _shouldUpload = shouldUpload;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = _shouldUpload;
    });
}

- (void)stop {
    self.shouldUpload = NO;
    //TODO: hash queue should stop?
    [self.uploadingQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    if([[UIDevice currentDevice].systemVersion floatValue] > 9.0)
        [self.manager.session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
            [tasks enumerateObjectsUsingBlock:^(__kindof NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj cancel];
            }];
        }];
}

- (void)destroy {
    _isdestroing = YES;
    [self.hashwaitingQueue removeAllObjects];
    // TODO: cancel working queue?
    [self.hashWorkingQueue removeAllObjects];
    [self.hashFailQueue removeAllObjects];
    
    [self.uploadPaddingQueue removeAllObjects];
    [self stop];
    [self.uploadingQueue removeAllObjects];
    [self.uploadedQueue removeAllObjects];
    [self.uploadErrorQueue removeAllObjects];
    [self.uploadedNetQueue removeAllObjects];
    [self.uploadedLocalHashSet removeAllObjects];
    [self.manager.session invalidateAndCancel];
    _isdestroing = NO;
}



@end

@implementation WBUploadModel {
    PHImageRequestID _requestFileID;
    AFHTTPSessionManager * _manager;
    BOOL _shouldStop;
}

+ (instancetype)initWithAsset:(JYAsset *)asset andManager:(AFHTTPSessionManager *)manager{
    WBUploadModel * model = [WBUploadModel new];
    model.asset = asset;
    model->_manager = manager;
    model->_shouldStop = NO;
    return model;
}

static NSArray * invaildChars;
- (void)startUseTimeStamp:(BOOL)yesOrNo completeBlock:(void(^)(NSError * , id))callback {
    self.callback = callback;
    invaildChars = [NSArray arrayWithObjects:@"/", @"?", @"<", @">", @"\\", @":", @"*", @"|", @"\"", nil];
    @weaky(self);
    _requestFileID =  [self.asset.asset getFile:^(NSError *error, NSString *filePath) {
        if(error)
            return callback(error, nil);
        if(_shouldStop) return callback([NSError errorWithDomain:@"cancel" code:20010 userInfo:nil], nil);
        NSLog(@"==========================开始上传==============================");
        NSString * hashString = weak_self.asset.digest;
        NSInteger sizeNumber = (NSInteger)[WB_FileService fileSizeAtPath:filePath];
        NSString * exestr = [filePath lastPathComponent];
        NSString * fileName = [PHAssetResource assetResourcesForAsset:weak_self.asset.asset].firstObject.originalFilename;
        if(IsNilString(fileName)) fileName = exestr;
        NSMutableString * tempFileName = [NSMutableString stringWithString:fileName];
        for (int i = 0; i < tempFileName.length; i++) {
            if([invaildChars containsObject: [fileName substringWithRange:NSMakeRange(i, 1)]]){
                [tempFileName replaceCharactersInRange:NSMakeRange(i, 1) withString:@"_"];
            }
        }
        fileName = tempFileName;
        if(yesOrNo) {
            fileName = [NSString stringWithFormat:@"%f_%@", [[NSDate date] timeIntervalSince1970], fileName];
//          NSString * fileNameDeletingPathExtension = [fileName stringByDeletingPathExtension];
//            // 获得文件的后缀名（不带'.'）
//          NSString * pathExtension = [filePath pathExtension];
//            fileName = [NSString stringWithFormat:@"%@_%f.%@", fileNameDeletingPathExtension, [[NSDate date] timeIntervalSince1970],pathExtension];

        }
        NSLog(@"filename : %@", fileName);
        NSString *urlString;
        NSMutableDictionary * mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
        if (WB_UserService.currentUser.isCloudLogin) {
            urlString = [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonPipeUrl];
            NSString *requestUrl = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries", WB_UserService.currentUser.userHome,  WB_UserService.currentUser.backUpDir];
            NSString *resource =[requestUrl base64EncodedString] ;
            NSMutableDictionary *manifestDic  = [NSMutableDictionary dictionaryWithCapacity:0];
            [manifestDic setObject:@"newfile" forKey:kCloudBodyOp];
            [manifestDic setObject:@"POST" forKey:kCloudBodyMethod];
            [manifestDic setObject:fileName forKey:kCloudBodyToName];
            [manifestDic setObject:resource forKey:kCloudBodyResource];
            [manifestDic setObject:hashString forKey:@"sha256"];
            [manifestDic setObject:@(sizeNumber) forKey:@"size"];
            NSData *josnData = [NSJSONSerialization dataWithJSONObject:manifestDic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *result = [[NSString alloc] initWithData:josnData  encoding:NSUTF8StringEncoding];
            [mutableDic setObject:result forKey:@"manifest"];
            [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", WB_UserService.currentUser.cloudToken] forHTTPHeaderField:@"Authorization"];
            _manager.requestSerializer.timeoutInterval = 60;
        }else {
            urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,WB_UserService.currentUser.userHome, WB_UserService.currentUser.backUpDir];
            mutableDic = nil;
            [_manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
        }
        NSString * requestTempPath = [NSString stringWithFormat:@"%@_temp", filePath];
        NSURL *requestFileTempPath = [NSURL fileURLWithPath:requestTempPath];
        
        
        NSMutableURLRequest *request = [_manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:mutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if(WB_UserService.currentUser.isCloudLogin) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:fileName mimeType:@"image/jpeg" error:nil];
            }else {
                NSDictionary *dic = @{@"size":@(sizeNumber),@"sha256":hashString};
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString =  [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:jsonString mimeType:@"image/jpeg" error:nil];
            }
        } error:nil];
        
        [_manager.requestSerializer requestWithMultipartFormRequest:request writingStreamContentsToFile:requestFileTempPath completionHandler:^(NSError * _Nullable error) {
            if(error) return callback(error, nil);
            if(_shouldStop) return callback([NSError errorWithDomain:@"cancel" code:20010 userInfo:nil], nil);
            request.HTTPBodyStream = nil;
            weak_self.dataTask = [_manager uploadTaskWithRequest:request fromFile:requestFileTempPath progress:^(NSProgress * _Nonnull uploadProgress) {
            } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if(!weak_self) return;
                if(_shouldStop) return callback([NSError errorWithDomain:@"cancel" code:20010 userInfo:nil], nil);
                if(!error) {
                    NSLog(@"Upload Success -->");
                    if(weak_self.callback) weak_self.callback(nil, responseObject);
                }else {
                    NSLog(@"Upload Failure ---> : %@", error);
                    NSLog(@"Upload Failure ---> : %@  ----> statusCode: %ld", fileName, (long)((NSHTTPURLResponse *)response).statusCode);
                    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                    if(errorData.length >0 && ((NSHTTPURLResponse *)response).statusCode == 403){
                        NSMutableArray *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                        NSLog(@"Upload Failure ---> :serializedData %@", serializedData);
                        if([serializedData isKindOfClass:[NSArray class]]) {
                            @try {
                                NSDictionary *errorRootDic = serializedData[0];
                                NSDictionary *errorDic = errorRootDic[@"error"];
                                NSString *code = errorDic[@"code"];
                                NSInteger status = [errorDic[@"status"] integerValue];
                                if ([code isEqualToString:@"EEXIST"])
                                    error.wbCode = WBUploadFileExist;
                                if(status == 404)
                                    error.wbCode = WBUploadDirNotFound;
                            } @catch (NSException *exception) {
                                NSLog(@"%@", exception);
                            }
                        }
                    }
                    weak_self.error = error;
                    if (weak_self.callback) weak_self.callback(error, nil);
                }
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:requestTempPath error:nil];
            }];
            [weak_self.dataTask resume];
        }];
    }];
}

- (void)cancel {
    self->_shouldStop = YES;
    if(_requestFileID) {
       [[PHImageManager defaultManager] cancelImageRequest:_requestFileID];
        _requestFileID = PHInvalidImageRequestID;
    }
    if(_dataTask) {
        [_dataTask cancel];
    }
}

@end
