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

@interface AssetsServices ()

@property (readwrite) NSArray<JYAsset *> *allAssets;

@end

@implementation AssetsServices{
    PHFetchResult * _lastResult;
    BOOL _userAuth;
}

- (void)abort{
    
}

- (instancetype)init {
    if (self = [super init]) {
        [self checkAuth];
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
        _allAssets = [NSArray arrayWithArray:all];
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

@end
