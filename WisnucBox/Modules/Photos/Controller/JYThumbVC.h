//
//  JYThumbVC.h
//  Photos
//
//  Created by JackYang on 2017/9/25.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMBaseFirstVC.h"

@class JYAsset;

@interface JYThumbVC : FMBaseFirstVC

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) BOOL showIndicator;

- (instancetype)initWithLocalDataSource:(NSArray<JYAsset *> *)assets;

- (void)addNetAssets:(NSArray<WBAsset *> *)assetsArr;
@end
