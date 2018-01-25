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
#import "FMMediaAPI.h"

@interface AssetsServices ()<PHPhotoLibraryChangeObserver>

@property (readwrite) NSArray<JYAsset *> *allAssets;

@property (nonatomic) NSManagedObjectContext * saveContext;

@property (nonatomic, readwrite) BOOL userAuth;

@property (nonatomic) dispatch_semaphore_t fetchNetAssetLock;

@end

@implementation AssetsServices{
    PHFetchResult * _lastResult;
}

- (void)abort{
    self.allNetAssets = nil;
}

- (void)dealloc {
    if(_userAuth)
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    NSLog(@"AssetsServices delloc");
}

- (instancetype)init {
    if (self = [super init]) {
        [self checkAuthWithComplete:^(BOOL userAuth) {
            if (_userAuth) [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }];
        _saveContext = [NSManagedObjectContext MR_newMainQueueContext];
        _fetchNetAssetLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)checkAuthWithComplete:(void(^)(BOOL userAuth))callback {
    _userAuth = NO;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted){
        NSLog(@"用户拒绝");
        _userAuth = NO;
        callback(_userAuth);
    } else if (status == PHAuthorizationStatusAuthorized) {
        NSLog(@"已取得用户授权");
        _userAuth = YES;
        callback(_userAuth);
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            _userAuth = status == PHAuthorizationStatusAuthorized ? YES : NO;
            if(_userAuth) [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:ASSETS_AUTH_CHANGE_NOTIFY object:@(status)];
            callback(_userAuth);
        }];
    }
}

- (NSArray *)allAssets {
    @synchronized (self) {
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
}

- (WBLocalAsset *)getAssetWithLocalId:(NSString *)localId {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"localId = %@", localId];
    WBLocalAsset * asset = [WBLocalAsset MR_findFirstWithPredicate:predicate];
    return asset;
}

- (NSArray<WBLocalAsset *> *)getAllHashedAsset {
    return [WBLocalAsset MR_findAll];
}

- (void)saveAssetWithLocalId:(NSString *)localId digest:(NSString *)digest{
    __block WBLocalAsset * oldAsset = [self getAssetWithLocalId:localId];
    dispatch_async(WB_AppServices.dbServices.saveQueue, ^{
        if(!oldAsset) {
            NSManagedObjectContext * context = [NSManagedObjectContext MR_defaultContext];
            [context performBlock:^{
                oldAsset = [WBLocalAsset MR_createEntityInContext:context];
                oldAsset.localId = localId;
                oldAsset.digest = digest;
                [context MR_saveToPersistentStoreAndWait];
            }];
        }else {
            oldAsset.digest = digest;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    });
}

- (void)getNetAssets:(void(^)(NSError *, NSArray<WBAsset *> *))callback {
//    dispatch_semaphore_wait(self.fetchNetAssetLock, DISPATCH_TIME_FOREVER);
    @weaky(self);
    BOOL isCloudRequest  = WB_UserService.currentUser.isCloudLogin;
    [[FMMediaAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * medias = isCloudRequest ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableArray *photoArr = [NSMutableArray arrayWithCapacity:0];
            [medias enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [photoArr addObject:[WBAsset modelWithJSON:obj]];
            }];
            weak_self.allNetAssets = photoArr;
            callback(nil, photoArr);
//            dispatch_semaphore_signal(weak_self.fetchNetAssetLock);
        });
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"get net assets error: %@" , request.error);
        callback(request.error, NULL);
//        dispatch_semaphore_signal(weak_self.fetchNetAssetLock);
    }];
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
            if(!detail || (!detail.removedObjects.count && !detail.insertedObjects.count)) return;
            NSMutableArray * removes = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray * inserts = [NSMutableArray arrayWithCapacity:0];
            if (detail && detail.removedObjects){
                [detail.removedObjects enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([tmpDic.allKeys containsObject:obj.localIdentifier]){
                        [removes addObject:tmpDic[obj.localIdentifier]];
                        [tmpDic removeObjectForKey:obj.localIdentifier];
                    }
                }];
            }
            [changeDic setObject:removes forKey:ASSETS_REMOVEED_KEY];
            if (detail && detail.insertedObjects){
                [detail.insertedObjects enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    JYAssetType type = [obj getJYAssetType];
                    NSString *duration = [obj getDurationString];
                    JYAsset * asset = [JYAsset modelWithAsset:obj type:type duration:duration];
                    [tmpDic setObject:asset forKey:obj.localIdentifier];
                    [inserts addObject:asset];
                }];
            }
            [changeDic setObject:inserts forKey:ASSETS_INSERTSED_KEY];
            
            if([detail fetchResultAfterChanges]) // record new fetchResult
            {
                _lastResult = [detail fetchResultAfterChanges];
            }
        }
        
        self.allAssets = [tmpDic allValues];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ASSETS_UPDATE_NOTIFY object:changeDic];
        if(_AssetChangeBlock)
            _AssetChangeBlock(changeDic[ASSETS_REMOVEED_KEY], changeDic[ASSETS_INSERTSED_KEY]);
    }
}
@end

