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
    });
    return appServices;
}
- (instancetype)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserAuthChange) name:ASSETS_AUTH_CHANGE_NOTIFY object:nil];
    [self assetServices];
    if(self.userServices.currentUser)
        [self netServices];
    [self bootStrap];
    return self;
}

- (void)delloc {
    NSLog(@"AppServices delloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Notification Handle
- (void)handleUserAuthChange {
    if(WB_AssetService.userAuth){
        NSArray * allLocalAsset = [self.assetServices allAssets];
        [self.photoUploadManager startWithLocalAssets:allLocalAsset andNetAssets:@[]];
    }
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
            if(error) return callback(error, user);
            user.userHome = userHome;
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"GET USER HOME SUCCESS");
            [WB_NetService getUserBackupDir:^(NSError *error, NSString *entryUUID) {
                if(error) return callback(error, user);
                user.backUpDir = entryUUID;
                [WB_UserService synchronizedCurrentUser];
                NSLog(@"GET BACKUP DIR SUCCESS");
                if(!user.askForBackup)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weak_self requestForBackupPhotos:^(BOOL shouldUpload) {
                            user.askForBackup = YES;
                            [WB_UserService synchronizedCurrentUser];
                            if(shouldUpload) {
                                [weak_self startUploadAssets:nil];
                            }
                        }];
                    });
                else
                    [weak_self startUploadAssets:nil];
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

- (void)startUploadAssets:(void(^)())complete {
    [self.netServices getEntriesInUserBackupDir:^(NSError *error, NSArray<EntriesModel *> *entries) {
        if(error) return NSLog(@"Get BackupDir entries error");
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

@property (nonatomic) dispatch_queue_t managerQueue;

@property (nonatomic) dispatch_queue_t workingQueue;

@end

@implementation WBUploadManager

- (void)dealloc{
    NSLog(@"WBUploadManager delloc");
}

- (instancetype)init {
    if(self = [super init]) {
        _isdestroing = NO;
        _shouldUpload = NO;
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
        [self.hashwaitingQueue addObject:asset];
        [self schedule];
    });
}

- (void)addTasks:(NSArray<JYAsset *> *)assets {
    dispatch_async(self.managerQueue, ^{
        [self.hashwaitingQueue addObjectsFromArray:assets];
        [self schedule];
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
        [self.uploadErrorQueue enumerateObjectsUsingBlock:^(WBUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(IsEquallString(obj.asset.asset.localIdentifier, assetId)){
                upModel = obj;
                *stop = YES;
            }
        }];
        if(upModel) [self.uploadErrorQueue removeObject:upModel];
        upModel = nil;
    });
}

- (void)removeTasks:(NSArray<JYAsset *> *)assets {
    if(!assets || !assets.count)  return;
    [assets enumerateObjectsUsingBlock:^(JYAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTask:obj];
    }];
}

- (void)startWithLocalAssets:(NSArray<JYAsset *> *)localAssets andNetAssets:(NSArray<EntriesModel *> *)netAssets {
    dispatch_async(self.managerQueue, ^{
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

- (void)startUpload {
    self.shouldUpload = YES;
    // notify for start
    [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
    dispatch_async(self.managerQueue, ^{
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
        if([self.uploadedNetHashSet containsObject:asset.digest]) {
            [self.uploadedQueue addObject:model];
            [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
            [self schedule];
        }else {
            [self.uploadingQueue addObject:model];
            __weak typeof(self) weakSelf = self;
            [model startWithCompleteBlock:^(NSError *error, id response) {
                dispatch_async(self.managerQueue, ^{
                    if (error) {
                        [weakSelf.uploadErrorQueue addObject:model];
                        [weakSelf.uploadingQueue removeObject:model];
                    }else{
                        [weakSelf.uploadingQueue removeObject:model];
                        [weakSelf.uploadedQueue addObject:model];
                        [[NSNotificationCenter defaultCenter] postNotificationName:WBBackupCountChangeNotify object:nil];
                    }
                    [weakSelf schedule];
                });
            }];
        }
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
    [self.uploadedNetQueue removeAllObjects];
    
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

- (void)startWithCompleteBlock:(void(^)(NSError * , id))callback {
    self.callback = callback;
    _requestFileID =  [self.asset.asset getFile:^(NSError *error, NSString *filePath) {
        NSLog(@"==========================开始上传==============================");
        NSString * hashString = self.asset.digest;
        NSInteger sizeNumber = (NSInteger)[WB_FileService fileSizeAtPath:filePath];
        NSString * exestr = [filePath lastPathComponent];
        NSString * fileName = [PHAssetResource assetResourcesForAsset:self.asset.asset].firstObject.originalFilename;
        if(IsNilString(fileName)) fileName = exestr;
        NSLog (@"上传照片POST请求:\n上传照片照片名======>%@\n Hash======>%@\n",exestr,hashString);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        NSString *urlString;
        NSMutableDictionary * mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
        urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,WB_UserService.currentUser.userHome, WB_UserService.currentUser.backUpDir];
        mutableDic = nil;
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
        _dataTask = [manager POST:urlString parameters:mutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSDictionary *dic = @{@"size":@(sizeNumber),@"sha256":hashString};
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString =  [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:jsonString mimeType:@"image/jpeg" error:nil];
        }
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"Upload Success -->");
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            callback(nil, responseObject);
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Upload Failure ---> : %@", error);
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil]; // remove tmpFile
            callback(error, nil);
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



//            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//            if(errorData.length >0){
//                NSMutableArray *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//                NSDictionary *errorRootDic = serializedData[0];
//                NSDictionary *errorDic = errorRootDic[@"error"];
//                NSString *code = errorDic[@"code"];
//                if ([code isEqualToString:@"EEXIST"]) {
//                    NSString *formatString = [filePath pathExtension];
//                    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
//                    NSTimeInterval a=[date timeIntervalSince1970];
//                    NSString *fileNameString =[NSString stringWithFormat:@"%0.f", a];
//                    NSString *uploadName = [NSString stringWithFormat:@"%@.%@",fileNameString,formatString];
//                    NSLog(@"%@",uploadName);
//                }else{
//
//
//                }
//            }else{
//
//            }
@end
