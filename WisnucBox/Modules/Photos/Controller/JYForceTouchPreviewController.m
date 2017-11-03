//
//  JYForveTouchPreviewController.m
//  Photos
//
//  Created by JackYang on 2017/10/17.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYForceTouchPreviewController.h"
#import "JYConst.h"
#import "PHPhotoLibrary+JYEXT.h"
#import "JYAsset.h"
#import <PhotosUI/PhotosUI.h>

@interface JYForceTouchPreviewController ()

@end

@implementation JYForceTouchPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
    
    switch (self.model.type) {
        case JYAssetTypeImage:
            [self loadNormalImage];
            break;
            
        case JYAssetTypeGIF:
            self.allowSelectGif ? [self loadGifImage] : [self loadNormalImage];
            break;
            
        case JYAssetTypeLivePhoto:
            self.allowSelectLivePhoto ? [self loadLivePhoto] : [self loadNormalImage];
            break;
            
        case JYAssetTypeVideo:
            [self loadVideo];
            break;
            
        default:
            break;
    }
}

#pragma mark - 加载静态图
- (void)loadNormalImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGSize size = [self getSize];
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [PHPhotoLibrary requestImageForAsset:self.model.asset size:CGSizeMake(size.width*2, size.height*2) completion:^(UIImage *img, NSDictionary *info) {
        imageView.image = img;
    }];
}

- (void)loadGifImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [PHPhotoLibrary requestOriginalImageDataForAsset:self.model.asset completion:^(NSData *data, NSDictionary *info) {
        imageView.image = [PHPhotoLibrary animatedGIFWithData:data];
    }];
}

- (void)loadLivePhoto
{
    PHLivePhotoView *lpView = [[PHLivePhotoView alloc] init];
    lpView.contentMode = UIViewContentModeScaleAspectFit;
    lpView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:lpView];
    
    [PHPhotoLibrary requestLivePhotoForAsset:self.model.asset completion:^(PHLivePhoto *lv, NSDictionary *info) {
        lpView.livePhoto = lv;
        [lpView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    }];
}

- (void)loadVideo
{
    AVPlayerLayer *playLayer = [[AVPlayerLayer alloc] init];
    playLayer.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view.layer addSublayer:playLayer];
    
    [PHPhotoLibrary requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            playLayer.player = player;
            [player play];
        });
    }];
}

- (CGSize)getSize
{
    CGFloat w = MIN(self.model.asset.pixelWidth, kViewWidth);
    CGFloat h = w * self.model.asset.pixelHeight / self.model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kViewHeight) {
        h = kViewHeight;
        w = h * self.model.asset.pixelWidth / self.model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
}

@end
