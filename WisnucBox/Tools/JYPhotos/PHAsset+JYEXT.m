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

- (PHImageRequestID) getSha256:(void(^)(NSError * error, NSString * sha256))callback
{
    return [PHPhotoLibrary requestHighImageDataSyncForAsset:self completion:^(NSError * error, NSData *imageData, NSDictionary *info) {
        if(imageData)
            return callback(nil, [CocoaSecurity sha256WithData:imageData].hex);
        else
            return callback(error, NULL);
    }];
}
@end
