//
//  JYBigImgCell.m
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBigImgCell.h"
#import "PHPhotoLibrary+JYEXT.h"
#import <Photos/Photos.h>
#import "JYAsset.h"
#import "JYConst.h"
#import "PHAsset+JYEXT.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation JYBigImgCell

- (void)dealloc{
    NSLog(@"JYBigImgCell delloc");
}

- (JYPreviewView *)previewView
{
    if (!_previewView) {
        _previewView = [[JYPreviewView alloc] initWithFrame:self.bounds];
        _previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _previewView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.previewView];
        jy_weakify(self);
        self.previewView.singleTapCallBack = ^() {
            jy_strongify(weakSelf);
            if (strongSelf.singleTapCallBack) strongSelf.singleTapCallBack();
        };
    }
    return self;
}

- (void)setModel:(JYAsset *)model
{
    _model = model;
    self.previewView.showGif = self.showGif;
    self.previewView.showLivePhoto = self.showLivePhoto;
    self.previewView.model = model;
}

- (void)resetCellStatus
{
    [self.previewView resetScale];
}

- (void)reloadGifLivePhoto
{
    if (self.willDisplaying) {
        self.willDisplaying = NO;
        [self.previewView reload];
    } else {
        [self.previewView resumePlay];
    }
}

- (void)pausePlay
{
    [self.previewView pausePlay];
}

@end

@implementation JYPreviewView

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.model.type == JYAssetTypeImage ||
        self.model.type == JYAssetTypeGIF ||
        (self.model.type == JYAssetTypeLivePhoto && !self.showLivePhoto) ||
        self.model.type == JYAssetTypeNetImage) {
        self.imageGifView.frame = self.bounds;
    } else if (self.model.type == JYAssetTypeLivePhoto) {
        self.livePhotoView.frame = self.bounds;
    } else if (self.model.type == JYAssetTypeVideo || self.model.type == JYAssetTypeNetVideo) {
        self.videoView.frame = self.bounds;
    }
}

- (CGRect)imageViewFrame
{
    if (self.model.type == JYAssetTypeImage ||
       self.model.type == JYAssetTypeGIF ||
       (self.model.type == JYAssetTypeLivePhoto && !self.showLivePhoto) ||
       self.model.type == JYAssetTypeNetImage) {
        return self.imageGifView.containerView.frame;
    } else if (self.model.type == JYAssetTypeLivePhoto) {
        return self.livePhotoView.lpView.frame;
    } else if (self.model.type == JYAssetTypeVideo || self.model.type == JYAssetTypeNetVideo) {
        return self.videoView.playLayer.frame;
    }
    return CGRectZero;
}

- (JYPreviewImageAndGif *)imageGifView
{
    if (!_imageGifView) {
        _imageGifView = [[JYPreviewImageAndGif alloc] initWithFrame:self.bounds];
        _imageGifView.singleTapCallBack = self.singleTapCallBack;
    }
    return _imageGifView;
}

- (JYPreviewLivePhoto *)livePhotoView
{
    if (!_livePhotoView) {
        _livePhotoView = [[JYPreviewLivePhoto alloc] initWithFrame:self.bounds];
        _livePhotoView.singleTapCallBack = self.singleTapCallBack;
    }
    return _livePhotoView;
}

- (JYPreviewVideo *)videoView
{
    if (!_videoView) {
        _videoView = [[JYPreviewVideo alloc] initWithFrame:self.bounds];
        _videoView.singleTapCallBack = self.singleTapCallBack;
    }
    return _videoView;
}

- (void)setModel:(JYAsset *)model
{
    _model = model;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    switch (model.type) {
        case JYAssetTypeImage: {
            [self addSubview:self.imageGifView];
            [self.imageGifView loadNormalImage:model];
        }
            break;
        case JYAssetTypeGIF: {
            [self addSubview:self.imageGifView];
            [self.imageGifView loadNormalImage:model];
        }
            break;
        case JYAssetTypeLivePhoto: {
            if (self.showLivePhoto) {
                [self addSubview:self.livePhotoView];
                [self.livePhotoView loadNormalImage:model];
            } else {
                [self addSubview:self.imageGifView];
                [self.imageGifView loadNormalImage:model];
            }
        }
            break;
        case JYAssetTypeVideo: {
            [self addSubview:self.videoView];
            [self.videoView loadNormalImage:model];
        }
            break;
        case JYAssetTypeNetImage: {
            [self addSubview:self.imageGifView];
            [self.imageGifView loadImage:model];
        }
            break;
        case JYAssetTypeNetVideo : {
            [self addSubview:self.videoView];
            [(JYPreviewVideo *)self.videoView loadNetNormalImage:model];
            //TODO: load net video
            
//            self.videoView loadNormalImage:<#(PHAsset *)#>
        }
            break;
        default:
            break;
    }
}

- (void)reload
{
    if (self.showGif &&
        self.model.type == JYAssetTypeGIF) {
        [self.imageGifView loadGifImage:self.model];
    } else if (self.showLivePhoto &&
               self.model.type == JYAssetTypeLivePhoto) {
        [self.livePhotoView loadLivePhoto:self.model];
    }
}

- (void)resumePlay
{
    if (self.model.type == JYAssetTypeGIF) {
        [self.imageGifView resumeGif];
    }
}

- (void)pausePlay
{
    if (self.model.type == JYAssetTypeGIF) {
        [self.imageGifView pauseGif];
    } else if (self.model.type == JYAssetTypeLivePhoto) {
        [self.livePhotoView stopPlayLivePhoto];
    } else if (self.model.type == JYAssetTypeVideo) {
        [self.videoView stopPlayVideo];
    }
}

- (void)handlerEndDisplaying
{
    if (self.model.type == JYAssetTypeGIF) {
        if ([self.imageGifView.imageView.image isKindOfClass:NSClassFromString(@"_UIAnimatedImage")]) {
            [self.imageGifView loadNormalImage:self.model];
        }
    } else if (self.model.type == JYAssetTypeVideo) {
        if ([self.videoView haveLoadVideo]) {
            [self.videoView loadNormalImage:self.model];
        }
    }
}

- (void)resetScale
{
    [self.imageGifView resetScale];
}

- (UIImage *)image
{
    if (self.model.type == JYAssetTypeImage) {
        return self.imageGifView.imageView.image;
    }
    return nil;
}

@end

@implementation JYBasePreviewView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicator.center = self.center;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = self.center;
    }
    return _indicator;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        //        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        [self addGestureRecognizer:self.singleTap];
    }
    return self;
}

- (void)singleTapAction
{
    if (self.singleTapCallBack) self.singleTapCallBack();
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)loadNormalImage:(JYAsset *)asset
{
    //子类重写
}

- (void)resetScale
{
    //子类重写
}

//- (UIView *)containerView
//{
//    if (!_containerView) {
//        _containerView = [[UIView alloc] init];
//    }
//    return _containerView;
//}

@end


//PreviewImageAndGif
@interface JYPreviewImageAndGif () <UIScrollViewDelegate>
{
    BOOL _loadOK;
}
@end

@implementation JYPreviewImageAndGif

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    [self.scrollView setZoomScale:1.0];
    if (_loadOK) {
        [self resetSubviewSize:self.jyAsset.asset?self.jyAsset.asset:self.imageView.image];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.imageView];
    [self addSubview:self.indicator];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [self.singleTap requireGestureRecognizerToFail:doubleTap];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.bounds;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        //        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
    }
    return _scrollView;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (void)resetScale
{
    self.scrollView.zoomScale = 1;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)resumeGif
{
    CALayer *layer = self.imageView.layer;
    if (layer.speed != 0) return;
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)pauseGif
{
    CALayer *layer = self.imageView.layer;
    if (layer.speed == .0) return;
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (void)loadGifImage:(JYAsset *)asset
{
    [self.indicator startAnimating];
    jy_weakify(self);
    
    [PHPhotoLibrary requestOriginalImageDataForAsset:asset.asset completion:^(NSData *data, NSDictionary *info) {
        jy_strongify(weakSelf);
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            strongSelf.imageView.image = [PHPhotoLibrary animatedGIFWithData:data];
            [strongSelf resumeGif];
            [strongSelf resetSubviewSize:asset];
            [strongSelf.indicator stopAnimating];
        }
    }];
}

- (void)loadNormalImage:(JYAsset *)asset
{
    if (self.jyAsset.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    if(self.operation){
        [self.operation cancel];
        self.operation = nil;
    }
    self.jyAsset = asset;
    
    [self.indicator startAnimating];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeZero;
    if(self.jyAsset.asset)
        size = CGSizeMake(width*scale, width*scale*asset.asset.pixelHeight/asset.asset.pixelWidth);
    jy_weakify(self);
    self.imageRequestID = [PHPhotoLibrary requestImageForAsset:asset.asset size:size completion:^(UIImage *image, NSDictionary *info) {
//        NSLog(@"%@", info);
        jy_strongify(weakSelf);
        strongSelf.imageView.image = image;
        [strongSelf resetSubviewSize:asset];
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [strongSelf.indicator stopAnimating];
            strongSelf->_loadOK = YES;
        }
    }];
}

/**
 @param obj UIImage/fmhash
 */
- (void)loadImage:(JYAsset *)asset
{
    self.imageView.image = nil;
    if (self.jyAsset.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    if(self.operation){
        [self.operation cancel];
        self.operation = nil;
    }
    self.jyAsset = asset;
    [self.indicator startAnimating];
    jy_weakify(self);
    self.operation =  [WB_NetService getHighWebImageWithHash:[(WBAsset *)asset fmhash] completeBlock:^(NSError *error, UIImage *img) {
        [weakSelf.indicator stopAnimating];
        jy_strongify(weakSelf);
        if(!strongSelf) return;
        if (error) {
            // TODO: Load Error Image
        } else {
            strongSelf->_loadOK = YES;
            strongSelf.imageView.image = img;
            [strongSelf resetSubviewSize:img];
        }
        strongSelf.operation = nil;
    }];
    
}

- (void)resetSubviewSize:(id)obj
{
    self.containerView.frame = CGRectMake(0, 0, kViewWidth, 0);
    
    CGRect frame;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    CGFloat w, h;
    if ([obj isKindOfClass:JYAsset.class]) {
        w = [((JYAsset *)obj).asset pixelWidth];
        h = [((JYAsset *)obj).asset pixelHeight];
    } else {
        w = ((UIImage *)obj).size.width;
        h = ((UIImage *)obj).size.height;
    }
    
    CGFloat width = MIN(kViewWidth, w);
    BOOL orientationIsUpOrDown = YES;
    if (orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight) {
        orientationIsUpOrDown = NO;
        CGFloat height = MIN(kViewHeight, h);
        frame.origin = CGPointZero;
        frame.size.height = height;
        UIImage *image = self.imageView.image;
        
        CGFloat imageScale = image.size.width/image.size.height;
        CGFloat screenScale = kViewWidth/kViewHeight;
        
        if (imageScale > screenScale) {
            frame.size.width = floorf(height * imageScale);
            if (frame.size.width > kViewWidth) {
                frame.size.width = kViewWidth;
                frame.size.height = kViewWidth / imageScale;
            }
        } else {
            CGFloat width = floorf(height * imageScale);
            if (width < 1 || isnan(width)) {
                //iCloud图片height为NaN
                width = GetViewWidth(self);
            }
            frame.size.width = width;
        }
    } else {
        frame.origin = CGPointZero;
        frame.size.width = width;
        UIImage *image = self.imageView.image;
        
        CGFloat imageScale = image.size.height/image.size.width;
        CGFloat screenScale = kViewHeight/kViewWidth;
        
        if (imageScale > screenScale) {
//            frame.size.height = floorf(width * imageScale);
            frame.size.height = kViewHeight;
            frame.size.width = floorf(width * kViewHeight / h);
        } else {
            CGFloat height = floorf(width * imageScale);
            if (height < 1 || isnan(height)) {
                //iCloud图片height为NaN
                height = GetViewHeight(self);
            }
            frame.size.height = height;
        }
    }
    
    self.containerView.frame = frame;
    
    
    CGSize contentSize;
    if (orientationIsUpOrDown) {
        contentSize = CGSizeMake(width, MAX(kViewHeight, frame.size.height));
        if (frame.size.height < GetViewHeight(self)) {
            self.containerView.center = CGPointMake(GetViewWidth(self)/2, GetViewHeight(self)/2);
        } else {
            self.containerView.frame = (CGRect){CGPointMake((GetViewWidth(self)-frame.size.width)/2, 0), frame.size};
        }
    } else {
        contentSize = frame.size;
        if (frame.size.width < GetViewWidth(self) ||
            frame.size.height < GetViewHeight(self)) {
            self.containerView.center = CGPointMake(GetViewWidth(self)/2, GetViewHeight(self)/2);
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollView.contentSize = contentSize;
        
        self.imageView.frame = self.containerView.bounds;
        
        [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    });
}

#pragma mark - 手势点击事件
- (void)doubleTapAction:(UITapGestureRecognizer *)tap
{
    UIScrollView *scrollView = self.scrollView;
    
    CGFloat scale = 1;
    if (scrollView.zoomScale != 3.0) {
        scale = 3;
    } else {
        scale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:[tap locationInView:tap.view]];
    [scrollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return scrollView.subviews[0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (GetViewWidth(scrollView) > scrollView.contentSize.width) ? (GetViewWidth(scrollView) - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (GetViewHeight(scrollView) > scrollView.contentSize.height) ? (GetViewHeight(scrollView) - scrollView.contentSize.height) * 0.5 : 0.0;
    self.containerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resumeGif];
}

@end



//PreviewLivePhoto
@implementation JYPreviewLivePhoto

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    _lpView.frame = self.bounds;
}

- (PHLivePhotoView *)lpView
{
    if (!_lpView) {
        _lpView = [[PHLivePhotoView alloc] initWithFrame:self.bounds];
        _lpView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_lpView];
    }
    return _lpView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.imageView];
    [self addSubview:self.lpView];
    [self addSubview:self.indicator];
}

- (void)loadNormalImage:(JYAsset *)asset
{
    if (self.jyAsset.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.jyAsset = asset;
    
    if (_lpView) {
        [_lpView removeFromSuperview];
        _lpView = nil;
    }
    
    [self.indicator startAnimating];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*asset.asset.pixelHeight/asset.asset.pixelWidth);
    jy_weakify(self);
    self.imageRequestID = [PHPhotoLibrary requestImageForAsset:asset.asset size:size completion:^(UIImage *image, NSDictionary *info) {
        jy_strongify(weakSelf);
        strongSelf.imageView.image = image;
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [strongSelf.indicator stopAnimating];
        }
    }];
}

- (void)loadLivePhoto:(JYAsset *)asset
{
    jy_weakify(self);
    [PHPhotoLibrary requestLivePhotoForAsset:asset.asset completion:^(PHLivePhoto *lv, NSDictionary *info) {
        jy_strongify(weakSelf);
//        NSLog(@"%@", info);
        if (lv) {
            strongSelf.lpView.livePhoto = lv;
            [strongSelf.lpView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    }];
}

- (void)stopPlayLivePhoto
{
    [self.lpView stopPlayback];
}

@end


//PreviewVideo
@implementation JYPreviewVideo {
    BOOL _hasObserverStatus;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(_playLayer && _playLayer.player)
        [_playLayer removeObserver:self forKeyPath:@"status"];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    _playLayer.frame = self.bounds;
    self.playBtn.center = self.center;
}

- (AVPlayerLayer *)playLayer
{
    if (!_playLayer) {
        _playLayer = [[AVPlayerLayer alloc] init];
        _playLayer.frame = self.bounds;
    }
    return _playLayer;
}

- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        _playBtn.frame = CGRectMake(0, 0, 80, 80);
        _playBtn.center = self.center;
        [_playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [self bringSubviewToFront:_playBtn];
    return _playBtn;
}

- (UILabel *)icloudLoadFailedLabel
{
    if (!_icloudLoadFailedLabel) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        //创建图片附件
        NSTextAttachment *attach = [[NSTextAttachment alloc]init];
//        attach.image = GetImageWithName(@"videoLoadFailed");
        attach.bounds = CGRectMake(0, -10, 30, 30);
        //创建属性字符串 通过图片附件
        NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:attach];
        //把NSAttributedString添加到NSMutableAttributedString里面
        [str appendAttributedString:attrStr];
        
        _icloudLoadFailedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 70, 200, 35)];
        _icloudLoadFailedLabel.font = [UIFont systemFontOfSize:12];
        _icloudLoadFailedLabel.attributedText = str;
        _icloudLoadFailedLabel.textColor = [UIColor whiteColor];
        [self addSubview:_icloudLoadFailedLabel];
    }
    return _icloudLoadFailedLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    _hasObserverStatus = NO;
    [self addSubview:self.imageView];
    [self addSubview:self.playBtn];
    [self addSubview:self.indicator];
}

- (void)loadNormalImage:(JYAsset *)asset
{
    if (self.jyAsset.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.jyAsset = asset;
    
    if (_playLayer) {
        _playLayer.player = nil;
        [_playLayer removeFromSuperlayer];
        [_playLayer removeObserver:self forKeyPath:@"status"];
        _hasObserverStatus = NO;
        _playLayer = nil;
    }
    
    self.imageView.image = nil;
    
    if (![asset.asset isLocal]) {
        [self initVideoLoadFailedFromiCloudUI];
        return;
    }
    
    self.playBtn.enabled = YES;
    self.icloudLoadFailedLabel.hidden = YES;
    self.imageView.hidden = NO;
    
    [self.indicator startAnimating];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*asset.asset.pixelHeight/asset.asset.pixelWidth);
    jy_weakify(self);
    self.imageRequestID = [PHPhotoLibrary requestImageForAsset:asset.asset size:size completion:^(UIImage *image, NSDictionary *info) {
        jy_strongify(weakSelf);
        strongSelf.imageView.image = image;
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [strongSelf.indicator stopAnimating];
        }
    }];
}

- (void)loadNetNormalImage:(JYAsset *)asset
{
    if (self.jyAsset.asset && self.imageRequestID >= 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.jyAsset = asset;
    if (_playLayer) {
        _playLayer.player = nil;
        [_playLayer removeFromSuperlayer];
        [_playLayer removeObserver:self forKeyPath:@"status"];
        _hasObserverStatus = NO;
        _playLayer = nil;
    }
    
    self.imageView.image = nil;
    
    self.playBtn.enabled = YES;
    self.icloudLoadFailedLabel.hidden = YES;
    self.imageView.hidden = NO;
    
    [self.indicator startAnimating];
    
    jy_weakify(self);
    [[FMMediaRamdomKeyAPI apiWithHash:[(WBAsset *)self.jyAsset fmhash]] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/random/%@", [JYRequestConfig sharedConfig].baseURL, request.responseJsonObject[@"key"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            jy_strongify(weakSelf);
            if (!request.responseJsonObject) {
                [strongSelf initVideoLoadFailedFromiCloudUI];
                return;
            }
            AVPlayer *player = [AVPlayer playerWithURL:url];
            [strongSelf.layer addSublayer:strongSelf.playLayer];
            strongSelf.playLayer.player = player;
            [strongSelf switchVideoStatus];
            [strongSelf.playLayer addObserver:strongSelf forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            _hasObserverStatus = YES;
            [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
            [strongSelf.indicator stopAnimating];
        });
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView showAlertHUD:@"播放失败" duration:1];
        [weakSelf.indicator stopAnimating];
    }];
}

- (void)initVideoLoadFailedFromiCloudUI
{
    self.icloudLoadFailedLabel.hidden = NO;
    self.playBtn.enabled = NO;
}

- (BOOL)haveLoadVideo
{
    return _playLayer ? YES : NO;
}

- (void)stopPlayVideo
{
    if (!_playLayer) {
        return;
    }
    AVPlayer *player = self.playLayer.player;
    
    if (player.rate != .0) {
        [player pause];
        self.playBtn.hidden = NO;
    }
}

- (void)singleTapAction
{
    [super singleTapAction];
    if (!_playLayer) {
        if(self.jyAsset.type == JYAssetTypeVideo){
            jy_weakify(self);
            [PHPhotoLibrary requestVideoForAsset:self.jyAsset.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    jy_strongify(weakSelf);
                    if (!item) {
                        [strongSelf initVideoLoadFailedFromiCloudUI];
                        return;
                    }
                    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
                    [strongSelf.layer addSublayer:strongSelf.playLayer];
                    strongSelf.playLayer.player = player;
                    [strongSelf switchVideoStatus];
                    [strongSelf.playLayer addObserver:strongSelf forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                    _hasObserverStatus = YES;
                    [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
                });
            }];
        }else
            return;
    } else {
        [self switchVideoStatus];
    }
}

- (void)playBtnClick
{
    [self singleTapAction];
}

- (void)switchVideoStatus
{
    AVPlayer *player = self.playLayer.player;
    CMTime stop = player.currentItem.currentTime;
    CMTime duration = player.currentItem.duration;
    if (player.rate == .0) {
        self.playBtn.hidden = YES;
        if (stop.value == duration.value) {
            [player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [player play];
    } else {
        self.playBtn.hidden = NO;
        [player pause];
    }
}

- (void)playFinished:(AVPlayerItem *)item
{
    [super singleTapAction];
    self.playBtn.hidden = NO;
    self.imageView.hidden = NO;
    [self.playLayer.player seekToTime:kCMTimeZero];
}

//监听获得消息
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            //status 有三种状态
            self.imageView.hidden = YES;
        }
    }
}

@end
