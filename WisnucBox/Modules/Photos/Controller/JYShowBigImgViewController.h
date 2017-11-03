//
//  JYShowBigImgViewController.h
//  Photos
//
//  Created by JackYang on 2017/10/17.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class JYAsset;
@interface JYShowBigImgViewController : UIViewController

@property (nonatomic, strong) NSArray<JYAsset *> *models;

@property (nonatomic, assign) NSInteger selectIndex; //选中的图片下标

@property (nonatomic, copy) void (^btnBackBlock)(NSArray<JYAsset *> *selectedModels, BOOL isOriginal);


//点击选择后的图片预览数组，预览相册图片时为 UIImage，预览网络图片时候为UIImage/NSUrl
@property (nonatomic, strong) NSMutableArray *arrSelPhotos;

//预览相册图片回调
@property (nonatomic, copy) void (^btnDonePreviewBlock)(NSArray<UIImage *> *, NSArray<PHAsset *> *);

//预览网络图片回调
@property (nonatomic, copy) void (^previewNetImageBlock)(NSArray *photos);

@property (nonatomic) UIImage *scaleImage;

@property (nonatomic) UIView *senderViewForAnimation;

@end
