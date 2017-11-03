//
//  JYAsset.h
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, JYAssetType) {
    JYAssetTypeImage,
    JYAssetTypeGIF,
    JYAssetTypeLivePhoto,
    JYAssetTypeVideo,
    JYAssetTypeAudio,
    JYAssetTypeNetImage,
    JYAssetTypeUnknown,
};

@interface JYAsset : NSObject

//asset对象
@property (nonatomic, strong) PHAsset *asset;
//asset类型
@property (nonatomic, assign) JYAssetType type;
//视频时长
@property (nonatomic, copy) NSString *duration;
//是否被选择
@property (nonatomic, assign, getter=isSelected) BOOL selected;

//网络/本地 图片url
@property (nonatomic, strong) NSURL *url;

//图片
@property (nonatomic, strong) UIImage *image;

/**初始化model对象*/
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(JYAssetType)type duration:(NSString *)duration;

@end

@interface JYAssetList : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isCameraRoll;

@property (nonatomic, strong) PHFetchResult *result;

@property (nonatomic, strong) NSArray<JYAsset *> *models;

@end
