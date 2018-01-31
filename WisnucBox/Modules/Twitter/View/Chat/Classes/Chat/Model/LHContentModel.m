//
//  LHContentModel.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/23.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHContentModel.h"

@implementation LHPhotosModel

- (instancetype)initWitiPhotos:(NSArray *)photos originalPhoto:(BOOL)originalPhoto {
    if (self = [super init]) {
        self.photos = photos;
        self.originalPhoto = originalPhoto;
    }
    return self;
}

- (instancetype)initWitiPhotos:(NSArray *)photos originalPhoto:(BOOL)originalPhoto Assets:(NSArray *)assets{
    if (self = [super init]) {
        self.photos = photos;
        self.originalPhoto = originalPhoto;
        self.assets = assets;
    }
    return self;
}

+ (instancetype)photosModelWitiPhotos:(NSArray *)photos originalPhoto:(BOOL)originalPhoto {
    return [[self alloc] initWitiPhotos:photos originalPhoto:originalPhoto];
}

+ (instancetype)photosModelWitiPhotos:(NSArray *)photos Assets:(NSArray *)assets originalPhoto:(BOOL)originalPhoto {
    return [[self alloc] initWitiPhotos:photos originalPhoto:originalPhoto Assets:assets];
}
@end

@implementation LHContentModel

- (instancetype)initWitiPhotos:(LHPhotosModel *)photos words:(NSString *)words {
    if (self = [super init]) {
        self.photos = photos;
        self.words = words;
    }
    return self;
}

+ (instancetype)contentModelWitiPhotos:(LHPhotosModel *)photos words:(NSString *)words {
    return [[self alloc] initWitiPhotos:photos words:words];
}

@end
