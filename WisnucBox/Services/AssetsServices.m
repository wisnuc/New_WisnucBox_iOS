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
            [changeDic setObject:removes forKey:@"removeObjects"];
            if (detail && detail.insertedObjects){
                [detail.insertedObjects enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    JYAssetType type = [obj getJYAssetType];
                    NSString *duration = [obj getDurationString];
                    JYAsset * asset = [JYAsset modelWithAsset:obj type:type duration:duration];
                    [tmpDic setObject:asset forKey:obj.localIdentifier];
                    [inserts addObject:asset];
                }];
            }
            [changeDic setObject:inserts forKey:@"insertedObjects"];
            _lastResult = [detail fetchResultAfterChanges]; // record new fetchResult
        }
        
        self.allAssets = [tmpDic allValues];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ASSETS_UPDATE_NOTIFY object:0];
        if(_AssetChangeBlock)
            _AssetChangeBlock(changeDic[@"removeObjects"], changeDic[@"insertedObjects"]);
    }
}
@end

