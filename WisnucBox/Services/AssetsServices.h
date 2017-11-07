//
//  AssetsServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBLocalAsset+CoreDataClass.h"

#define ASSETS_UPDATE_NOTIFY @"ASSETS_UPDATE_NOTIFY"

@class JYAsset;
@interface AssetsServices : NSObject <ServiceProtocol>

@property (nonatomic, copy, readonly) NSArray<JYAsset *> * allAssets;

@property (nonatomic, copy) void(^AssetChangeBlock)(NSArray<JYAsset *> *removeObjs, NSArray<JYAsset *> *insertObjs);

- (void)saveAsset:(WBLocalAsset *)asset;

- (WBLocalAsset *)getAssetWithLocalId:(NSString *)localId;

@end

