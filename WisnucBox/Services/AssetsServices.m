//
//  AssetsServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "AssetsServices.h"
#import "PHPhotoLibrary+JYEXT.h"
#import "PHAsset+JYEXT.h"
#import <Photos/Photos.h>
#import "WBLocalAsset+CoreDataClass.h"

@interface AssetsServices ()<PHPhotoLibraryChangeObserver>

@property (readwrite) NSArray<JYAsset *> *allAssets;

@end

@implementation AssetsServices{
    PHFetchResult * _lastResult;
    BOOL _userAuth;
}

- (void)abort{
    
}

- (void)dealloc {
    if(_userAuth)
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        [self checkAuth];
        if(_userAuth)
           [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

- (void)checkAuth {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted){
        NSLog(@"用户拒绝");
        _userAuth = NO;
    } else if (status == PHAuthorizationStatusAuthorized) {
        NSLog(@"已取得用户授权");
        _userAuth = YES;
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
           if(status == PHAuthorizationStatusAuthorized)
                _userAuth = YES;
            else
                _userAuth = NO;
        }];
    }
}

- (NSArray *)allAssets {
    if (!_allAssets && _userAuth) {
        NSMutableArray * all = [NSMutableArray arrayWithCapacity:0];
        [PHPhotoLibrary getAllAsset:^(PHFetchResult<PHAsset *> *result, NSArray<PHAsset *> *assets) {
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                JYAssetType type = [obj getJYAssetType];
                NSString *duration = [obj getDurationString];
                [all addObject:[JYAsset modelWithAsset:obj type:type duration:duration]];
            }];
            _lastResult = result;
        }];
        _allAssets = all;
    }
    return _allAssets;
}

- (WBLocalAsset *)getAssetWithLocalId:(NSString *)localId {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"localId = %@", localId];
    WBLocalAsset * asset = [WBLocalAsset MR_findFirstWithPredicate:predicate];
    return asset;
}

- (void)saveAsset:(WBLocalAsset *)asset {
    WBLocalAsset * oldAsset = [self getAssetWithLocalId:asset.localId];
    if(!oldAsset)
        oldAsset = [WBLocalAsset MR_createEntityInContext:[NSManagedObjectContext MR_context]];
    oldAsset.digest = asset.digest;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark - photolibrary change delegate

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    @autoreleasepool {
        PHFetchResult* currentAssets = _lastResult;
        NSMutableDictionary * tmpDic = [NSMutableDictionary dictionaryWithCapacity:0];
        for (JYAsset * asset in _allAssets) {
            [tmpDic setObject:asset forKey:asset.asset.localIdentifier];
        }
        
        NSMutableDictionary * changeDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        if (_lastResult){
            PHFetchResultChangeDetails* detail = [changeInstance changeDetailsForFetchResult:currentAssets];
            if (detail && detail.removedObjects){
                [changeDic setObject:detail.removedObjects forKey:@"removeObjects"];
                [detail.removedObjects enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([tmpDic.allKeys containsObject:obj.localIdentifier])
                        [tmpDic removeObjectForKey:obj.localIdentifier];
                }];
            }
            if (detail && detail.insertedObjects){
                [changeDic setObject:detail.insertedObjects forKey:@"insertedObjects"];
                [detail.insertedObjects enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    JYAssetType type = [obj getJYAssetType];
                    NSString *duration = [obj getDurationString];
                    [tmpDic setObject:[JYAsset modelWithAsset:obj type:type duration:duration] forKey:obj.localIdentifier];
                }];
            }
            
            _lastResult = [detail fetchResultAfterChanges]; // record new fetchResult
        }
        
        self.allAssets = [tmpDic allValues];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ASSETS_UPDATE_NOTIFY object:changeDic];
    }
}
@end

@interface WBUploadManager ()
{
    BOOL _isdestroing;
}

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashwaitingQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashWorkingQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *hashFailQueue;

@property (nonatomic, readwrite) NSMutableArray<JYAsset *> *uploadPaddingQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadingQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadedQueue;

@property (nonatomic, readwrite) NSMutableArray<WBUploadModel *> *uploadErrorQueue;

@property (nonatomic, strong) NSMutableArray<JYAsset *> *hashwaitingNetQueue;

@property (nonatomic, readwrite) BOOL isStoped;

@property (nonatomic, readwrite) BOOL isReady;

@end

@implementation WBUploadManager

- (void)dealloc{
    
}

- (instancetype)init {
    if(self = [super init]) {
        _isdestroing = NO;
        _shouldUpload = NO;
        _hashLimitCount = 2;
        _uploadLimitCount = 1;
    }
    return self;
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

- (NSMutableArray *)hashwaitingNetQueue{
    if (!_hashwaitingNetQueue) {
        _hashwaitingNetQueue= [NSMutableArray arrayWithCapacity:0];
    }
    return _hashwaitingNetQueue;
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

- (void)startWithLocalAssets:(NSArray<JYAsset *> *)localAssets andNetAssets:(NSArray<JYAsset *> *)netAssets {
    [self.hashwaitingQueue addObjectsFromArray:localAssets];
    [self.hashwaitingNetQueue addObjectsFromArray:netAssets];
    
}

- (void)schedule {
    if(_isdestroing) return;
    while(self.hashWorkingQueue.count < self.hashLimitCount && self.hashwaitingQueue.count > 0) {
        JYAsset * asset = [self.hashwaitingQueue lastObject];
        [self.hashwaitingQueue removeLastObject];
        [self.hashWorkingQueue addObject:asset];
        [asset.asset getSha256:^(NSError *error, NSString *sha256) {
            if (error) {
                [self.hashFailQueue addObject:asset];
                [self.hashWorkingQueue removeObject:asset];
            }else {
                asset.digest = sha256;
                [self.uploadPaddingQueue addObject:asset];
            }
            [self schedule];
        }];
    }
    
    if(!_shouldUpload) return;
    
    while(self.uploadPaddingQueue.count > 0 && self.uploadingQueue.count < self.uploadLimitCount) {
        JYAsset * asset = [self.uploadPaddingQueue lastObject];
        [self.uploadPaddingQueue removeLastObject];
        WBUploadModel * model = [WBUploadModel initWithAsset:asset];
        [self.uploadingQueue addObject:model];
        [model startWithCompleteBlock:^(NSError *error, id response) {
            if (error) {
                [self.uploadErrorQueue addObject:model];
                [self.uploadingQueue removeObject:model];
            }else {
                [self.uploadedQueue addObject:model];
            }
            [self schedule];
        }];
    }
}

- (void)stop {
    
}

- (void)destroy {
    
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

@end

