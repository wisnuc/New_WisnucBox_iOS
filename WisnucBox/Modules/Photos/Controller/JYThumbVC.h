//
//  JYThumbVC.h
//  Photos
//
//  Created by JackYang on 2017/9/25.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JYAsset;

@interface JYThumbVC : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) BOOL showIndicator;

- (instancetype)initWithDataSource:(NSArray<JYAsset *> *)assets;

@end
