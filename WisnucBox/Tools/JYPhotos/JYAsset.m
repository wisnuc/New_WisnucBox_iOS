//
//  JYAsset.m
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYAsset.h"

@implementation JYAsset

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(JYAssetType)type duration:(NSString *)duration
{
    JYAsset *model = [[[self class] alloc] init];
    model.asset = asset;
    model.type = type;
    model.duration = duration;
    model.selected = NO;
    return model;
}

@end

@implementation JYAssetList


@end
