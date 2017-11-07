//
//  AppServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "AppServices.h"
#import "PHAsset+JYEXT.h"
#import <YYDispatchQueuePool/YYDispatchQueuePool.h>

@implementation AppServices

+ (instancetype)sharedService {
    static AppServices * appServices;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appServices = [[AppServices alloc] init];
        [appServices bootStrap];
    });
    return appServices;
}

- (void)bootStrap {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray * allLocalAsset = [self.assetServices allAssets];
        [self.photoUploadManager startWithLocalAssets:allLocalAsset andNetAssets:@[]];
        if(self.userServices.isUserLogin) {
            //        NSString * userToken = self.userServices.defaultToken;
            //        self.photoUploadManager setNetAssets:
            //        self.photoUploadManager startUploadWithUrl:<#(NSURL *)#> AndToken:<#(NSString *)#>
        }
    });
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
    _dbServices ? [_dbServices abort] : nil;
    
    _userServices = nil;
    _fileServices = nil;
    _assetServices = nil;
    _netServices = nil;
    _dbServices = nil;
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
    }
    return self;
}

//low等级线程
+ (dispatch_queue_t)workingQueue {
    static YYDispatchQueuePool * pool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[YYDispatchQueuePool alloc]initWithName:@"com.winsun.fruitmix.backgroundUpload" queueCount:3 qos:NSQualityOfServiceUtility];
    });
    return [pool queue];
}

- (dispatch_queue_t)managerQueue{
    if(!_managerQueue){
        _managerQueue = dispatch_queue_create("com.winsun.fruitmix.hot", DISPATCH_QUEUE_SERIAL);
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

- (void)removeTaskWithLocalId:(NSString *)assetId {
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

- (void)removeTasks:(NSArray<NSString *> *)assetIds {
    [assetIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTaskWithLocalId:obj];
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
    if(as)
        callback(NULL, as.digest);
    else
        [asset.asset getSha256:^(NSError *error, NSString *sha256) {
            if(error) return callback(error, NULL);
            //save sha256
            WBLocalAsset * ass = [WBLocalAsset MR_createEntity];
            ass.localId = asset.asset.localIdentifier;
            ass.digest = sha256;
            [[AppServices sharedService].assetServices saveAsset:ass];
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
        dispatch_async([[self class] workingQueue], ^{
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
