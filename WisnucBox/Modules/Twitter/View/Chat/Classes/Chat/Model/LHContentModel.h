//
//  LHContentModel.h
//  LHChatUI
//
//  Created by lenhart on 2016/12/23.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYAsset.h"
#import "WBTweetModel.h"

@interface LHPhotosModel : NSObject

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, strong) NSArray<WBTweetlocalImageModel *> *localImageModelArray;
@property (nonatomic, assign, getter=isOriginalPhoto) BOOL originalPhoto;

- (instancetype)initWitiPhotos:(NSArray *)photos originalPhoto:(BOOL)originalPhoto;
+ (instancetype)photosModelWitiPhotos:(NSArray *)photos originalPhoto:(BOOL)originalPhoto;
+ (instancetype)photosModelWitiPhotos:(NSArray *)photos Assets:(NSArray *)assets LocalImageModelArray:(NSArray *)localImageModelArray originalPhoto:(BOOL)originalPhoto;

@end

@interface LHContentModel : NSObject

@property (nonatomic, strong) LHPhotosModel *photos;
@property (nonatomic, strong) NSString *words;

- (instancetype)initWitiPhotos:(LHPhotosModel *)photos words:(NSString *)words;
+ (instancetype)contentModelWitiPhotos:(LHPhotosModel *)photos words:(NSString *)words;

@end
