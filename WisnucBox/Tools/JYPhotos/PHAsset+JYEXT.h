//
//  PHAsset+JYEXT.h
//  Photos
//
//  Created by JackYang on 2017/9/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Photos/Photos.h>

#import "JYAsset.h"

@interface PHAsset (JYEXT)

- (BOOL)isGif;

- (BOOL)isLivePhoto;

- (BOOL)isVideo;

- (BOOL)isAudio;

- (BOOL)isImage;

- (BOOL)isLocal; // else iCloud image need download

- (JYAssetType)getJYAssetType;

- (NSString *)getDurationString;

- (PHImageRequestID) getSha256:(void(^)(NSError * error, NSString * sha256))callback;
@end
