//
//  JYBigImgCell.h
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PhotosUI/PhotosUI.h>

@class JYAsset;
@class PHAsset;
@class JYPreviewView;

@interface JYBigImgCell : UICollectionViewCell


@property (nonatomic, assign) BOOL showGif;
@property (nonatomic, assign) BOOL showLivePhoto;

@property (nonatomic, strong) JYPreviewView *previewView;
@property (nonatomic, strong) JYAsset *model;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);
@property (nonatomic, assign) BOOL willDisplaying;


/**
 界面停止滑动后，加载gif和livephoto，保持界面流畅
 */
- (void)reloadGifLivePhoto;

/**
 界面滑动时，停止播放gif、livephoto、video
 */
- (void)pausePlay;

@end


@class JYPreviewImageAndGif;
@class JYPreviewLivePhoto;
@class JYPreviewVideo;

//预览大图，image、gif、livephoto、video
@interface JYPreviewView : UIView

@property (nonatomic, assign) BOOL showGif;
@property (nonatomic, assign) BOOL showLivePhoto;

@property (nonatomic, strong) JYPreviewImageAndGif *imageGifView;
@property (nonatomic, strong) JYPreviewLivePhoto *livePhotoView;
@property (nonatomic, strong) JYPreviewVideo *videoView;
@property (nonatomic, strong) JYAsset *model;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);

/**
 界面每次即将显示时，重置scrollview缩放状态
 */
- (void)resetScale;

/**
 * 获取图片的frame
 */
- (CGRect)imageViewFrame;

/**
 处理划出界面后操作
 */
- (void)handlerEndDisplaying;

/**
 reload gif,livephoto,video
 */
- (void)reload;

- (void)resumePlay;

- (void)pausePlay;

- (UIImage *)image;

@end


//---------------base preview---------------
@interface JYBasePreviewView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);

- (void)singleTapAction;

- (void)loadNormalImage:(PHAsset *)asset;

- (void)resetScale;

- (UIImage *)image;

@end

//---------------image与gif---------------
@interface JYPreviewImageAndGif : JYBasePreviewView

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)loadGifImage:(PHAsset *)asset;
- (void)loadImage:(id)obj;

- (void)resumeGif;
- (void)pauseGif;

@end


//---------------livephoto---------------
@interface JYPreviewLivePhoto : JYBasePreviewView

@property (nonatomic, strong) PHLivePhotoView *lpView;

- (void)loadLivePhoto:(PHAsset *)asset;

- (void)stopPlayLivePhoto;

@end


//---------------video---------------
@interface JYPreviewVideo : JYBasePreviewView

@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UILabel *icloudLoadFailedLabel;
@property (nonatomic, strong) UIButton *playBtn;

- (BOOL)haveLoadVideo;

- (void)stopPlayVideo;

@end
