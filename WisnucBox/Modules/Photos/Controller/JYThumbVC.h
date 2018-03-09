//
//  JYThumbVC.h
//  Photos
//
//  Created by JackYang on 2017/9/25.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMBaseFirstVC.h"
#import "WBTweetModel.h"

@class JYAsset;

@protocol JYThumbVCDelegate <NSObject>
- (void)imagePickerDidFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets LocalImageModelArray:(NSArray *)localImageModelArray isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;
@end

@interface JYThumbVC : FMBaseFirstVC

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) BOOL showIndicator;

@property (nonatomic, weak) id<JYThumbVCDelegate> delegate;

- (instancetype)initWithLocalDataSource:(NSArray<JYAsset *> *)assets;

- (instancetype)initWithLocalDataSource:(NSArray<JYAsset *> *)assets IsBoxSelectType:(BOOL)isBoxSelectType;

- (void)addNetAssets:(NSArray<WBAsset *> *)assetsArr;

- (void)mergeDataSource;
@end
