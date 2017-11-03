//
//  PHPhotoLibrary+JYEXT.h
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Photos/Photos.h>
#import "JYAsset.h"

@interface PHPhotoLibrary (JYEXT)

/*
 * get asset use localId
 */
+ (PHAsset *)getAssetFromlocalIdentifier:(NSString *)localIdentifier;

/*
 * save image to assetLibrary
 */
+ (void)saveImageToAlbum:(UIImage *)image completion:(void(^)(BOOL, PHAsset *))completion;



/*
 * get gif with data
 */
+ (UIImage *)animatedGIFWithData:(NSData *)data;

/**
 * @brief 获取相机胶卷相册列表对象
 */
+ (JYAssetList *)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage;
+ (JYAssetList *)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage sortAscend:(BOOL)sortAscending;

+ (NSArray<JYAsset *> *)getPhotoInResult:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;
#pragma mark - request image

/**
 *  get high image binary data sync
 */
+ (PHImageRequestID)requestHighImageDataSyncForAsset:(PHAsset *)asset completion:(void (^)(NSError * error, NSData *, NSDictionary *))completion;

/**
 * get image binary data
 */
+ (PHImageRequestID)requestOriginalImageDataForAsset:(PHAsset *)asset completion:(void (^)(NSData *, NSDictionary *))completion;

/**
 * get full screen image or original image
 */
+ (PHImageRequestID)requestSelectedImageForAsset:(JYAsset *)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^)(UIImage *, NSDictionary *))completion;

/**
 * 获取原图
 */
+ (PHImageRequestID)requestOriginalImageForAsset:(PHAsset *)asset completion:(void (^)(UIImage *, NSDictionary *))completion;

/**
 * 获取 size 大小的图
 */
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *))completion;
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion;

/**
 * get live photo
 */
+ (PHImageRequestID)requestLivePhotoForAsset:(PHAsset *)asset completion:(void (^)(PHLivePhoto *, NSDictionary *))completion;

/**
 * get video
 */
+ (PHImageRequestID)requestVideoForAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem *, NSDictionary *))completion;

#pragma mark - video

/**
 解析视频，获取每秒对应的一帧图片
 
 @param size 图片size
 */
+ (void)analysisEverySecondsImageForAsset:(PHAsset *)asset interval:(NSTimeInterval)interval size:(CGSize)size complete:(void (^)(AVAsset *avAsset, NSArray<UIImage *> *images))complete;

/**
 导出视频并保存到相册
 
 @param range 需要到处的视频间隔
 */
+ (void)exportEditVideoForAsset:(AVAsset *)asset range:(CMTimeRange)range complete:(void (^)(BOOL isSuc, PHAsset *asset))complete;

@end
