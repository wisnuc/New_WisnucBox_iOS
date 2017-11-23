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
#import <YYDispatchQueuePool/YYDispatchQueuePool.h>
#import "FMAccountUsersAPI.h"
#import "CSFileDownloadManager.h"
#import "FilesDataSourceManager.h"
#import "FLFIlesHelper.h"
#import "CSDownloadHelper.h"
#import "NSError+WBCode.h"

@implementation AppServices {
    BOOL _isRebuildingPhotoUploader;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetReachabilityNotify) name:NETWORK_REACHABILITY_CHANGE_NOTIFY object:nil];
    [self assetServices];
    if(self.userServices.currentUser)
        [self netServices];
    [self bootStrap];
    return self;
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
- (void)handleNetReachabilityNotify {
    if(!WB_UserService.currentUser || !WB_UserService.currentUser.autoBackUp) return;
    AFNetworkReachabilityStatus status = self.netServices.status;
    if(status != AFNetworkReachabilityStatusReachableViaWiFi && !WB_UserService.currentUser.backUpInWWAN){
        [self.photoUploadManager stop];
    }
    else if(self.photoUploadManager.shouldUpload == NO) {
        [self startUploadAssets:nil];
    }
}

//need destroy photoUploadManager and rebulid if currentuser`s backupdir notfound,
- (void)rebulidUploadManager{
    if (_isRebuildingPhotoUploader)  return;
    _isRebuildingPhotoUploader = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_photoUploadManager)
            [_photoUploadManager destroy];
        _photoUploadManager = nil;
        NSLog(@"PhotoUploadManager destroy Success!");
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

- (void)rebulid {
    [self abort];
    [self assetServices];
    if(self.userServices.currentUser)
        [self netServices];
    [self bootStrap];
}

- (void)bootStrap {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(WB_AssetService.userAuth) {
            NSArray * allLocalAsset = [self.assetServices allAssets];
            [self.photoUploadManager startWithLocalAssets:allLocalAsset andNetAssets:@[]];
            if(WB_UserService.currentUser.autoBackUp) {
                [self startUploadAssets:nil];
            }
        }
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
- (void)loginWithBasic:(NSString *)basic userUUID:(NSString *)uuid name:(NSString *)userName addr:(NSString *)addr isWechat:(BOOL)isWechat completeBlock:(void(^)(NSError *error, WBUser *user))callback {
    @weaky(self);
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",basic] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@token",addr] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString * token = responseObject[@"token"];
        self.netServices = [[NetServices alloc]initWithLocalURL:addr andCloudURL:nil];
        WBUser *user = [WB_UserService createUserWithUserUUID:uuid];
        user.userName = userName;
        user.localAddr = addr;
        user.localToken = token;
        user.isFirstUser = NO;
        user.isAdmin = NO;
        user.isCloudLogin = NO;
        [WB_UserService setCurrentUser:user];
        [WB_UserService synchronizedCurrentUser];
        NSLog(@"GET Token Success");
        [WB_NetService getUserHome:^(NSError *error, NSString *userHome){
            if(error) return callback(({error.wbCode = 10002; error;}), user);
            user.userHome = userHome;
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"GET USER HOME SUCCESS");
            [WB_NetService getUserBackupDir:^(NSError *error, NSString *entryUUID) {
                if(error) return callback(({error.wbCode = 10003; error;}), user);
                user.backUpDir = entryUUID;
                [WB_UserService synchronizedCurrentUser];
                NSLog(@"GET BACKUP DIR SUCCESS");
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
                else if(user.autoBackUp)
                    [weak_self startUploadAssets:nil];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [weak_self updateCurrentUserInfoWithCompleteBlock:nil];
                });
                
                return callback(nil, user);
            }];
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        error.wbCode = 10001;
        callback(error, NULL);
    }];
}

- (void)wechatLoginWithUserModel:(CloudModelForUser *)cloudUserModel Token:(NSString *)cloudToken AvatarUrl:(NSString *)avatarUrl addr:(NSString *)addr completeBlock:(void(^)(NSError *error, WBUser *user))callback{
    @weaky(self);
    self.netServices = [[NetServices alloc]initWithLocalURL:nil andCloudURL:addr];
    WBUser *user = [WB_UserService createUserWithUserUUID:cloudUserModel.uuid];
    user.userName = cloudUserModel.username;
//    user.localAddr = nil;
    user.stationId = cloudUserModel.stationId;
    user.cloudToken = cloudToken;
//    user.localToken = nil;
    user.isFirstUser = [cloudUserModel.isFirstUser boolValue];
    user.isAdmin = [cloudUserModel.isAdmin boolValue];
    user.isCloudLogin = YES;
    user.avaterURL = avatarUrl;
    user.guid = cloudUserModel.global.guid;
    [WB_UserService setCurrentUser:user];
    [WB_UserService synchronizedCurrentUser];
    NSLog(@"GET Token Success");
    [WB_NetService getUserHome:^(NSError *error, NSString *userHome){
        if(error) return callback(({error.wbCode = 10002; error;}), user);
        user.userHome = userHome;
        [WB_UserService synchronizedCurrentUser];
        NSLog(@"GET USER HOME SUCCESS");
        [WB_NetService getUserBackupDir:^(NSError *error, NSString *entryUUID) {
            if(error) return callback(({error.wbCode = 10003; error;}), user);
            user.backUpDir = entryUUID;
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"GET BACKUP DIR SUCCESS");
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
            else if(user.autoBackUp)
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
        if (IsEquallString(dic[@"uuid"], WB_UserService.currentUser.uuid)) {
            WB_UserService.currentUser.isAdmin = [dic[@"isAdmin"] boolValue];
            WB_UserService.currentUser.isFirstUser = [dic[@"isFirstUser"] boolValue];
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
        [WB_NetService getUserBackupDir:^(NSError *error, NSString *entryUUID) {
            if(error) return callback(({error.wbCode = 10003; error;}), WB_UserService.currentUser);
            WB_UserService.currentUser.backUpDir = entryUUID;
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"GET BACKUP DIR SUCCESS");
            return callback(nil, WB_UserService.currentUser);
        }];
    }];
}

- (void)requestForBackupPhotos:(void(^)(BOOL shouldUpload))callback {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否自动备份该手机的照片至WISNUC服务器" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        WB_UserService.currentUser.autoBackUp = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:UserBackUpConfigChangeNotify object:@(0)];
        [WB_UserService synchronizedCurrentUser];
        callback(NO);
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"备份" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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

- (void)startUploadAssets:(void(^)(void))complete {
    @weaky(self);
    [self.netServices getEntriesInUserBackupDir:^(NSError *error, NSArray<EntriesModel *> *entries) {
        if(error) {
            if(error.wbCode == WBUploadDirNotFound)
                [weak_self rebulidUploadManager];
            return NSLog(@"Get BackupDir entries error");
        }
        NSLog(@"Start Upload ...");
        NSMutableArray * netEntries = [NSMutableArray arrayWithArray:entries];
        [self.photoUploadManager setNetAssets:netEntries];
        [self.photoUploadManager startUpload];
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

- (void)abort {
    //destory JYnetEngine
    [[JYNetEngine sharedInstance] cancleAllRequest];
    // TODO: maybe one is enough
    [[SDWebImageManager sharedManager] cancelAll];
    [[SDWebImageDownloader sharedDownloader] cancelAllDownloads];
    
    _userServices ? [_userServices abort] :
    _fileServices ? [_fileServices abort] :
    _assetServices ? [_assetServices abort] :
    _netServices ? [_netServices abort] :
    _dbServices ? [_dbServices abort] :
    _photoUploadManager? [_photoUploadManager destroy] : nil;
    
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
}

@end

/*
 * asset backup and calculate asset hash manager
 *
 */

@interface WBUploadManager ()
{
    BOOL _isdestroing;
    NSURL * _uploadURL;
    NSString * _token;
    NSInteger _lastNotifyCount;
    BOOL _shouldNotify;
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
        _lastNotifyCount = 0;
        _hashLimitCount = 4;
        _uploadLimitCount = 4;
        [self workingQueue];
        [self managerQueue];
    }
    return self;
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
            [self.hashwaitingQueue addObject:asset];
            [self schedule];
        }
    });
}

- (void)addTasks:(NSArray<JYAsset *> *)assets {
    dispatch_async(self.managerQueue, ^{
        if(assets.count){
            _shouldNotify = YES;
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
    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0 && self.uploadPaddingQueue.count == 0 && self.uploadingQueue.count == 0) NSLog(@"backup asset finish ----=======>>>><<<<<<<<====-----  errorCount:%lu  finishedCount:%lu", (unsigned long)_uploadErrorQueue.count, (unsigned long)_uploadedQueue.count);
    while(self.hashWorkingQueue.count < self.hashLimitCount && self.hashwaitingQueue.count > 0) {
        JYAsset * asset = [self.hashwaitingQueue lastObject];
        [self.hashwaitingQueue removeLastObject];
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
        JYAsset * asset = [self.uploadPaddingQueue lastObject];
        [self.uploadPaddingQueue removeLastObject];
        WBUploadModel * model = [WBUploadModel initWithAsset:asset];
        if([self.uploadedNetHashSet containsObject:asset.digest] || [self.uploadedLocalHashSet containsObject:asset.digest]) {
            dispatch_async(self.managerQueue, ^{
                [self.uploadedQueue addObject:model];
                NSLog(@"发现一个已上传的，直接跳过, error: %lu  finish:%lu", (unsigned long)_uploadErrorQueue.count, (unsigned long)_uploadedQueue.count);
                [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
                [self schedule];
            });
        }else {
            [self.uploadingQueue addObject:model];
            [self scheduleForUpload:model andUseTimeStamp:NO];
        }
    }
}

// retry if eexist
- (void)scheduleForUpload:(WBUploadModel *)model andUseTimeStamp:(BOOL)yesOrNo {
    __weak typeof(self) weakSelf = self;
    __weak typeof(WB_AppServices) weak_AppService = WB_AppServices;
    [model startUseTimeStamp:yesOrNo completeBlock:^(NSError *error, id response) {
        if(!weakSelf) return;
        dispatch_async(weakSelf.managerQueue, ^{
            if (error) {
                if (error.wbCode == WBUploadDirNotFound) {
                    [weakSelf stop];   // stop
                    // need rebuild
                    [weakSelf destroy];
                    [weak_AppService rebulidUploadManager];
                }else if (error.wbCode == WBUploadFileExist) {
                    // rename then retry
                    [weakSelf scheduleForUpload:model andUseTimeStamp:YES];
                }else {
                    if(!model.isRemoved)
                        [weakSelf.uploadErrorQueue addObject:model];
                    [weakSelf.uploadingQueue removeObject:model];
                    NSLog(@"上传失败 , error: %lu  finish:%lu", (unsigned long)weakSelf.uploadErrorQueue.count, (unsigned long)weakSelf.uploadedQueue.count);
                }
            }else{  // success
                if(!model.isRemoved)
                    [weakSelf.uploadedQueue addObject:model];
                [weakSelf.uploadingQueue removeObject:model];
                [weakSelf.uploadedLocalHashSet addObject:model.asset.digest]; // record for skip equal-hash asset
                [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
                NSLog(@"上传成功 , error: %lu  finish:%lu", (unsigned long)weakSelf.uploadErrorQueue.count, (unsigned long)weakSelf.uploadedQueue.count);
            }
            [weakSelf schedule];
        });
    }];
}

- (void)stop {
    self.shouldUpload = NO;
    //TODO: hash queue should stop?
    [self.uploadingQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
}

- (void)destroy {
    [self.hashwaitingQueue removeAllObjects];
    // TODO: cancel working queue?
    [self.hashWorkingQueue removeAllObjects];
    [self.hashFailQueue removeAllObjects];
    
    [self.uploadPaddingQueue removeAllObjects];
    [self.uploadingQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [self.uploadingQueue removeAllObjects];
    [self.uploadedQueue removeAllObjects];
    [self.uploadErrorQueue removeAllObjects];
    [self.uploadedNetQueue removeAllObjects];
    [self.uploadedLocalHashSet removeAllObjects];
}

@end

@implementation WBUploadModel {
    PHImageRequestID _requestFileID;
    NSURLSessionDataTask * _dataTask;
}

+ (instancetype)initWithAsset:(JYAsset *)asset {
    WBUploadModel * model = [WBUploadModel new];
    model.asset = asset;
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
        if(yesOrNo) fileName = [NSString stringWithFormat:@"%@_%f", fileName, [[NSDate date] timeIntervalSince1970]];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
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
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", WB_UserService.currentUser.cloudToken] forHTTPHeaderField:@"Authorization"];
            manager.requestSerializer.timeoutInterval = 60;
        }else {
            urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,WB_UserService.currentUser.userHome, WB_UserService.currentUser.backUpDir];
            mutableDic = nil;
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
        }
        _dataTask = [manager POST:urlString parameters:mutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if(WB_UserService.currentUser.isCloudLogin) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:fileName mimeType:@"image/jpeg" error:nil];
            }else {
                NSDictionary *dic = @{@"size":@(sizeNumber),@"sha256":hashString};
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString =  [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:jsonString mimeType:@"image/jpeg" error:nil];
            }
        }
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"Upload Success -->");
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            if(!weak_self) return;
            if(weak_self.callback) weak_self.callback(nil, responseObject);
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Upload Failure ---> : %@", error);
            NSLog(@"Upload Failure ---> : %@  ----> : %ld", fileName, (long)((NSHTTPURLResponse *)task.response).statusCode);
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            if(errorData.length >0 && ((NSHTTPURLResponse *)task.response).statusCode == 403){
                NSMutableArray *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                NSLog(@"Upload Failure ---> :serializedData %@", serializedData);
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
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil]; // remove tmpFile
            
            if (!weak_self) return;
            weak_self.error = error;
            if (weak_self.callback) weak_self.callback(error, nil);
        }];
    }];
}

- (void)cancel {
    if(_requestFileID) {
       [[PHImageManager defaultManager] cancelImageRequest:_requestFileID];
        _requestFileID = PHInvalidImageRequestID;
    }
    if(_dataTask) {
        [_dataTask cancel];
    }
}

@end
