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

@implementation AppServices

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
        [appServices assetServices];
        if(appServices.userServices.currentUser)
           [appServices netServices];
        [appServices bootStrap];
    });
    return appServices;
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
        NSArray * allLocalAsset = [self.assetServices allAssets];
        [self.photoUploadManager startWithLocalAssets:allLocalAsset andNetAssets:@[]];
        if(self.userServices.isUserLogin) {
            
        }
    });
}


// get token
// create userSession
// isFirstUser ?
// config address
// userHome
// backupDir
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
        user.autoBackUp = NO;
        user.backUpInWWAN = NO;
        [WB_UserService setCurrentUser:user];
        [WB_UserService synchronizedCurrentUser];
        NSLog(@"GET Token Success");
        [WB_NetService getUserHome:^(NSError *error, NSString *userHome){
            if(error) return callback(error, user);
            user.userHome = userHome;
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"GET USER HOME SUCCESS");
            [WB_NetService getUserBackupDir:^(NSError *error, NSString *entryUUID) {
                if(error) return callback(error, user);
                user.backUpDir = entryUUID;
                [WB_UserService synchronizedCurrentUser];
                NSLog(@"GET BACKUP DIR SUCCESS");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weak_self requestForBackupPhotos:^(BOOL shouldUpload) {
                        if(shouldUpload) {
                            
                        }
                    }];
                });
                return callback(nil, user);
            }];
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(error, NULL);
    }];
    
}

- (void)updateCurrentUserInfoWithCompleteBlock:(void(^)(NSError *, BOOL success))callback {
    [[FMAccountUsersAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = request.responseJsonObject;
        if (IsEquallString(dic[@"uuid"], WB_UserService.currentUser.uuid)) {
            WB_UserService.currentUser.isAdmin = [dic[@"isAdmin"] boolValue];
            WB_UserService.currentUser.isFirstUser = [dic[@"isFirstUser"] boolValue];
            [WB_UserService synchronizedCurrentUser];
            //notify
            [[NSNotificationCenter defaultCenter] postNotificationName:UserInfoChangedNotify object:nil];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"Update user info error : %@", request.error);
        callback(request.error, NO);
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
            _netServices = [[NetServices alloc] init];
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
}

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashwaitingQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashWorkingQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashFailQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *uploadPaddingQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadingQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadedQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadErrorQueue;

@property (nonatomic, strong) NSMutableArray<JYAsset *> * uploadedNetQueue;

@property (nonatomic) dispatch_queue_t managerQueue;

@property (nonatomic) dispatch_queue_t workingQueue;

@end

@implementation WBUploadManager

- (void)dealloc{
    
}

- (instancetype)init {
    if(self = [super init]) {
        _isdestroing = NO;
        _shouldUpload = NO;
        _hashLimitCount = 4;
        _uploadLimitCount = 1;
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



-(NSMutableArray<JYAsset *> *)hashwaitingQueue{
    if (!_hashwaitingQueue) {
        _hashwaitingQueue= [NSMutableArray arrayWithCapacity:0];
    }
    return _hashwaitingQueue;
}

- (NSMutableArray<JYAsset *> *)hashWorkingQueue{
    if (!_hashWorkingQueue) {
        _hashWorkingQueue= [NSMutableArray<JYAsset *> arrayWithCapacity:0];
    }
    return _hashWorkingQueue;
}

- (NSMutableArray *)uploadedNetQueue{
    if (!_uploadedNetQueue) {
        _uploadedNetQueue= [NSMutableArray arrayWithCapacity:0];
    }
    return _uploadedNetQueue;
}

- (NSMutableArray<WBUploadModel *> *)uploadingQueue{
    if (!_uploadingQueue) {
        _uploadingQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
    }
    return _uploadingQueue;
}

- (NSMutableArray<JYAsset *> *)uploadPaddingQueue{
    if (!_uploadPaddingQueue) {
        _uploadPaddingQueue= [NSMutableArray<JYAsset *> arrayWithCapacity:0];
    }
    return _uploadPaddingQueue;
}



- (NSMutableArray<WBUploadModel *> *)uploadedQueue{
    if (!_uploadedQueue) {
        _uploadedQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
    }
    return _uploadedQueue;
}
- (NSMutableArray<WBUploadModel *> *)uploadErrorQueue{
    if (!_uploadErrorQueue) {
        _uploadErrorQueue= [NSMutableArray<WBUploadModel *> arrayWithCapacity:0];
    }
    return _uploadErrorQueue;
}

- (void)addTask:(JYAsset *)asset {
    [self.hashwaitingQueue addObject:asset];
    [self schedule];
}

- (void)addTasks:(NSArray<JYAsset *> *)assets {
    [self.hashwaitingQueue addObjectsFromArray:assets];
    [self schedule];
}

- (void)removeTask:(JYAsset *)rmAsset {
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
    [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(IsEquallString(obj.asset.asset.localIdentifier, assetId)){
            upModel = obj;
            *stop = YES;
        }
    }];
    if(upModel) [self.uploadErrorQueue removeObject:upModel];
    upModel = nil;
}

- (void)removeTasks:(NSArray<JYAsset *> *)assets {
    if(!assets || !assets.count)  return;
    [assets enumerateObjectsUsingBlock:^(JYAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTask:obj];
    }];
}

- (void)startWithLocalAssets:(NSArray<JYAsset *> *)localAssets andNetAssets:(NSArray<JYAsset *> *)netAssets {
    [self.hashwaitingQueue addObjectsFromArray:localAssets];
    [self.uploadedNetQueue addObjectsFromArray:netAssets];
    [self schedule];
    
}

- (void)setNetAssets:(NSArray<JYAsset *> *)netAssets {
    [self.uploadedNetQueue addObjectsFromArray:netAssets];
    [self schedule];
}

- (void)startUploadWithUrl:(NSURL *)url AndToken:(NSString *)token {
    _uploadURL = url;
    _token = token;
    self.shouldUpload = YES;
    [self schedule];
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
    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0) NSLog(@"hash calculate finish");
    if(self.hashwaitingQueue.count == 0 && self.hashWorkingQueue.count == 0 && self.uploadPaddingQueue.count == 0 && self.uploadingQueue.count == 0) NSLog(@"backup asset finish");
    while(self.hashWorkingQueue.count < self.hashLimitCount && self.hashwaitingQueue.count > 0) {
        JYAsset * asset = [self.hashwaitingQueue lastObject];
        [self.hashwaitingQueue removeLastObject];
        [self.hashWorkingQueue addObject:asset];
        __weak typeof(self) weakSelf = self;
        dispatch_async([self workingQueue], ^{
            [self asset:asset getSha256:^(NSError *error, NSString *sha256) {
                NSLog(@"%ld, %ld", self.hashwaitingQueue.count, self.hashWorkingQueue.count);
                dispatch_async(self.managerQueue, ^{
                    NSLog(@"...Success");
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
        [self.uploadingQueue addObject:model];
        __weak typeof(self) weakSelf = self;
        [model startWithCompleteBlock:^(NSError *error, id response) {
            if (error) {
                [weakSelf.uploadErrorQueue addObject:model];
                [weakSelf.uploadingQueue removeObject:model];
            }else {
                [weakSelf.uploadedQueue addObject:model];
            }
            dispatch_async(self.managerQueue, ^{
                [weakSelf schedule];
            });
        }];
    }
}

- (void)stop {
    self.shouldUpload = NO;
    //TODO: hash queue should stop?
    [self.uploadedQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
}

@end

@implementation WBUploadModel

+ (instancetype)initWithAsset:(JYAsset *)asset {
    WBUploadModel * model = [WBUploadModel new];
    model.asset = asset;
    return model;
}

- (void)startWithCompleteBlock:(void(^)(NSError * , id))callback {
    self.callback = callback;
}

- (void)cancel {
    
}

@end
