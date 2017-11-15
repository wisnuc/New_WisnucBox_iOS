//
//  PHAsset+JYEXT.m
//  Photos
//
//  Created by JackYang on 2017/9/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "PHAsset+JYEXT.h"
#import "PHPhotoLibrary+JYEXT.h"
#import "CocoaSecurity.h"
#import "FileHash.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+WBUUID.h"

#define JY_TMP_Folder [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"JYTMP"]

@implementation PHAsset (JYEXT)

- (BOOL)isGif
{
    return (self.mediaType == PHAssetMediaTypeImage) && [[self valueForKey:@"filename"] hasSuffix:@"GIF"];
}

- (BOOL)isLivePhoto
{
    return (self.mediaType == PHAssetMediaTypeImage) && (self.mediaSubtypes == PHAssetMediaSubtypePhotoLive || self.mediaSubtypes == 10);
}

- (BOOL)isVideo
{
    return self.mediaType == PHAssetMediaTypeVideo;
}

- (BOOL)isAudio
{
    return self.mediaType == PHAssetMediaTypeAudio;
}

- (BOOL)isImage{
    return (self.mediaType == PHAssetMediaTypeImage) && ![self isGif] && ![self isLivePhoto];
}

- (BOOL)isLocal
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAblum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
    }];
    return isInLocalAblum;
}

- (JYAssetType)getJYAssetType
{
    return [self isGif] ? JYAssetTypeGIF
                        : [self isLivePhoto] ? JYAssetTypeLivePhoto
                        : [self isVideo] ? JYAssetTypeVideo
                        : [self isAudio] ? JYAssetTypeAudio
                        : [self isImage] ? JYAssetTypeImage
                        : JYAssetTypeUnknown;
}

-(NSString *)getDurationString
{
    if (self.mediaType != PHAssetMediaTypeVideo) return nil;
    
    NSInteger duration = (NSInteger)round(self.duration);
    
    if (duration < 60) return [NSString stringWithFormat:@"00:%02ld", duration];
    
    else if (duration < 3600) return [NSString stringWithFormat:@"%02ld:%02ld", duration / 60, duration % 60];
    
        NSInteger h = duration / 3600;
        NSInteger m = (duration % 3600) / 60;
        NSInteger s = duration % 60;
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", h, m, s];
    
}

- (NSString *)getTmpPath {
    NSFileManager * mgr = [NSFileManager defaultManager];
    NSString * tmp = JY_TMP_Folder;
    if (![mgr fileExistsAtPath:tmp])
        [mgr createDirectoryAtPath:tmp withIntermediateDirectories:YES attributes:nil error:NULL];
    return tmp;
}

- (PHImageRequestID) getSha256:(void(^)(NSError * error, NSString * sha256))callback
{
    return [self getFile:^(NSError *error, NSString *filePath) {
        if(error) return callback(error, NULL);
        NSString * hashStr = [FileHash sha256HashOfFileAtPath:filePath];
        if(!hashStr || !hashStr.length) return callback([NSError errorWithDomain:@"FILE HASH ERROR" code:666 userInfo:nil], NULL);
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        return callback(nil, hashStr);
    }];
}

- (PHImageRequestID)getFile:(void(^)(NSError *error, NSString *filePath))callback {
    NSString *fileName = [NSString stringWithFormat:@"tmp_%ld_%@", (long)[[NSDate date] timeIntervalSince1970], [NSString WB_UUID]];
    NSString * filePath = [[self getTmpPath] stringByAppendingPathComponent:fileName];
    //TODO: do something for livephoto
    
    if(!self.isVideo) {
        return [PHPhotoLibrary requestHighImageDataSyncForAsset:self completion:^(NSError * error, NSData *imageData, NSDictionary *info) {
            if(imageData) {
                [imageData writeToFile:filePath atomically:YES];
                return callback(nil, filePath);
            }
            else
                return callback(error, NULL);
        }];
    } else { // video
        // less then iOS9
        if([[[UIDevice currentDevice] systemVersion]  floatValue] < 9.0) {
            PHVideoRequestOptions * opt = [[PHVideoRequestOptions alloc] init];
            opt.networkAccessAllowed = NO; // TODO ??
            opt.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
            //        opt.progressHandler
            return [[PHImageManager defaultManager] requestExportSessionForVideo:self options:opt exportPreset:AVAssetExportPresetHighestQuality resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                if(!exportSession)
                    return callback([[NSError alloc] initWithDomain:@"not found avasset" code:404 userInfo:nil], NULL);
                else{
                    //输出URL
                    exportSession.outputURL = [NSURL fileURLWithPath:filePath];
                    //优化网络
                    exportSession.shouldOptimizeForNetworkUse = true;
                    //                //转换后的格式
                    //                exportSession.outputFileType = AVFileTypeMPEG4;
                    //异步导出
                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                        if(exportSession.error) {
                            return callback(exportSession.error, NULL);
                        }
                        if(exportSession.status == AVAssetExportSessionStatusFailed) {
                            return callback([[NSError alloc] initWithDomain:@"AVAssetExportSessionStatusFailed" code:400 userInfo:nil], NULL);
                        }
                        if(exportSession.status == AVAssetExportSessionStatusCancelled) {
                            return callback([[NSError alloc] initWithDomain:@"AVAssetExportSessionStatusCancelled" code:400 userInfo:nil], NULL);
                        }
                        // 如果导出的状态为完成
                        if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                            //                        [self saveVideo:[NSURL fileURLWithPath:path]];
                            NSLog(@"压缩完毕,压缩后大小 %f MB",[self fileSize:[NSURL fileURLWithPath:filePath]]);
                            return callback(nil, filePath);
                        }else{
                            NSLog(@"当前压缩进度:%f",exportSession.progress);
                        }
                    }];
                }
            }];
        }else {
            [PHPhotoLibrary requestVideoPathFromPHAsset:self filePath:filePath Complete:^(NSError *error, NSString *filePath) {
                if(error) return callback(error, NULL);
                return callback(NULL, filePath);
            }];
            return false;
        }
    }
    return false;
}

- (void)saveVideo:(NSURL *)outputFileURL
{
    //ALAssetsLibrary提供了我们对iOS设备中的相片、视频的访问。
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (error) {
//            NSLog(@"保存视频失败:%@",error);
//        } else {
//            NSLog(@"保存视频到相册成功");
//        }
//    }];
}

- (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}

@end
