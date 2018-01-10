//
//  JYCollectionViewCell.h
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JYAsset;
@interface JYCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *btnSelect;
@property (nonatomic, strong) UIImageView *videoBottomView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIImageView *liveImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *topView;

@property (nonatomic, assign) BOOL allSelectGif;
@property (nonatomic, assign) BOOL allSelectLivePhoto;
@property (nonatomic, assign) BOOL showSelectBtn;
@property (nonatomic, assign) CGFloat cornerRadio;
@property (nonatomic, strong) JYAsset *model;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) BOOL showMask;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, weak) id<SDWebImageOperation> thumbnailRequestOperation;

@property (nonatomic, copy) void (^selectedBlock)(BOOL);
@property (nonatomic, copy) void (^longPressBlock)(void);

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, assign) BOOL isSelectMode;

- (void)setIsSelect:(BOOL)isSelect animation:(BOOL)animat;

- (void)btnSelectClick:(UIButton *)sender;
@end
