//
//  SDPhotoBrowser.m
//  photobrowser
//
//  Created by aier on 15-2-3.
//  Copyright (c) 2015年 aier. All rights reserved.
//

#import "SDPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "SDBrowserImageView.h"
#import "PHPhotoLibrary+JYEXT.h"

 
//  ============在这里方便配置样式相关设置===========

//                      ||
//                      ||
//                      ||
//                     \\//
//                      \/

#import "SDPhotoBrowserConfig.h"

//  =============================================

@implementation SDPhotoBrowser 
{
    UIScrollView *_scrollView;
    BOOL _hasShowedFistView;
    UILabel *_indexLabel;
    UIButton *_saveButton;
    UIActivityIndicatorView *_indicatorView;
    BOOL _willDisappear;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = SDPhotoBrowserBackgrounColor;
   
    }
    return self;
}


- (void)didMoveToSuperview
{
    [self setupScrollView];
    
    [self setupToolbars];
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}

- (void)setupToolbars
{
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
    indexLabel.clipsToBounds = YES;
    if (self.imageCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
    }else{
        indexLabel.text = @"1/1";
    }
    _indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
    // 2.保存按钮
//    UIButton *saveButton = [[UIButton alloc] init];
//    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
//    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
//    saveButton.layer.cornerRadius = 5;
//    saveButton.clipsToBounds = YES;
//    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
//    _saveButton = saveButton;
//    [self addSubview:saveButton];
}

- (void)saveImage
{
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    UIImageView *currentImageView = _scrollView.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = SDPhotoBrowserSaveImageFailText;
    }   else {
        label.text = SDPhotoBrowserSaveImageSuccessText;
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)setupScrollView
{
    
  
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
//    _scrollView.maximumZoomScale = 3.0;
//    _scrollView.minimumZoomScale = 1.0;
//    _scrollView.multipleTouchEnabled = YES;
    [self addSubview:_scrollView];
    NSLog(@"%ld",(long)self.imageCount);
    for (int i = 0; i < self.imageCount; i++) {
        SDBrowserImageView *imageView = [[SDBrowserImageView alloc] init];
        imageView.tag = i;

        // 单击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        
        // 双击放大图片
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
//        UISwipeGestureRecognizer *recognizer;
//
//        recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//        [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
//        //        recognizer.delegate = self;
//        [self addGestureRecognizer:recognizer];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
       
        
        [imageView addGestureRecognizer:singleTap];
//        [imageView addGestureRecognizer:recognizer];
        [imageView addGestureRecognizer:doubleTap];
        [self addGestureRecognizer:panGesture];
        [_scrollView addSubview:imageView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}

// 加载图片
// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{

    self.imageView = _scrollView.subviews[index];
    self.currentImageIndex = index;
    
    if (self.imageView.hasLoadedImage) return;
    //    if ([self highQualityImageURLForIndex:index]) {
    
    //        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    //    } else {
    //        imageView.image = [self placeholderImageForIndex:index];
    //    }
    @weaky(self)
    
    if ([self highQualityImageBoxInfoForIndex:index]) {
        NSDictionary *dic = [self highQualityImageBoxInfoForIndex:index];
        NSLog(@"%@",dic);
        self.imageView.image = [self placeholderImageForIndex:self.currentImageIndex];
        if (dic[kMessageImageBoxLocalAsset]) {
            if ([dic[kMessageImageBoxLocalAsset] isKindOfClass:[WBAsset class]]) {
                //                [SXLoadingView showProgressHUD:@""];
                WBAsset*asset = dic[kMessageImageBoxLocalAsset];
                [WB_NetService getHighWebImageWithHash:asset.fmhash completeBlock:^(NSError *error, UIImage *netImage) {
                    dispatch_main_async_safe(^{
                        if (!error &&netImage) {
                            self.imageView.image = netImage;
                        }else{
                            self.imageView.image = [self placeholderImageForIndex:index];
                        }
                           self.imageView.hasLoadedImage = YES;
                        
                    });
                }];
//                return;
            }else{
                JYAsset *jyasset = dic[kMessageImageBoxLocalAsset];
                CGFloat scale = [UIScreen mainScreen].scale;
                CGFloat width = MIN(kViewWidth, kMaxImageWidth);
                CGSize size = CGSizeZero;
                if(jyasset.asset){
                    size = CGSizeMake(width*scale, width*scale*jyasset.asset.pixelHeight/jyasset.asset.pixelWidth);
                }else{
                    if ( jyasset.assetLocalIdentifier) {
                       PHAsset *asset = [PHPhotoLibrary getAssetFromlocalIdentifier:jyasset.assetLocalIdentifier];
                        jyasset.asset = asset;
                        size = CGSizeMake(width*scale, width*scale*jyasset.asset.pixelHeight/jyasset.asset.pixelWidth);
                    }
                }
                
                [PHPhotoLibrary requestImageForAsset:jyasset.asset size:size completion:^(UIImage *localImage, NSDictionary *info) {
                    dispatch_main_async_safe(^{
                        if (localImage) {
                            self.imageView.image = localImage;
                        }else{
                            self.imageView.image = [self placeholderImageForIndex:index];
                        }
                           self.imageView.hasLoadedImage = YES;
                    });
                }];
            }
        }else{
            //            [SXLoadingView showProgressHUD:@""];
            [WB_NetService getTweeethighQualityImageWithHash:dic[kMessageImageBoxNetImageHash] BoxUUID:dic[kMessageImageBoxUUID] complete:^(NSError *error, UIImage *netImage) {
                dispatch_main_async_safe(^{
                    if (!error &&netImage) {
//                        self.imageView.image = [UIImage imageWithColor:[UIColor cyanColor]];
                        self.imageView.image = netImage;
                    }else{
                        self.imageView.image = [self placeholderImageForIndex:index];
                    }
                       self.imageView.hasLoadedImage = YES;
                });
            }];
        }
    }else{
        self.imageView.image = [self placeholderImageForIndex:index];
    }
 
}

#pragma mark - panGesture Handler

- (void)panGestureRecognized:(id)sender {
    // Initial Setup
    UIScrollView *scrollView = _scrollView;
    
    static float firstX, firstY;
    
    float viewHeight = scrollView.frame.size.height;
    float viewHalfHeight = viewHeight/2;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    
    // Gesture Began
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
        
        //        _senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
        
//        _isdraggingPhoto = YES;
//        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(firstX, firstY+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    
    float newY = scrollView.center.y - viewHalfHeight;
    float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
    
    self.opaque = YES;
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];;
    
    // Gesture Ended
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if(scrollView.center.y > viewHalfHeight+40 || scrollView.center.y < viewHalfHeight-40) // Automatic Dismiss View
        {
            if (self.imageView) {
                [self photoClick:nil];
                return;
            }
            
            CGFloat finalX = firstX, finalY;
            
            CGFloat windowsHeigt = [self frame].size.height;
            
            if(scrollView.center.y > viewHalfHeight+30) // swipe down
                finalY = windowsHeigt*2;
            else // swipe up
                finalY = -viewHalfHeight;
            
            CGFloat animationDuration = 0.35;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];
            [UIView commitAnimations];
            
//            [self performSelector:@selector(back:) withObject:self afterDelay:animationDuration];
        }
        else // Continue Showing View
        {
//            _isdraggingPhoto = NO;
//            [self setNeedsStatusBarAppearanceUpdate];
            
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            
            CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self].y);
            
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            
            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            [UIView commitAnimations];
        }
    }
}

//- (void)performDismissAnimation
//{
//    float fadeAlpha = 1 - fabs(_scrollView.frame.origin.y)/_scrollView.frame.size.height;
//
//    //    JYBigImgCell * cell = _collectionView.visibleCells[0];
//    NSIndexPath *indexP = [NSIndexPath indexPathForRow:_currentPage - 1 inSection:0];
//    JYBigImgCell * cell = (JYBigImgCell *)[_collectionView cellForItemAtIndexPath:indexP];
//    UIWindow * mainWindow = [UIApplication sharedApplication].keyWindow;
//
//    CGRect rect = [cell.previewView convertRect:cell.previewView.imageViewFrame toView:self.view];
//
////    self.imageView = [_delegate photoBrowser:self willDismissAtIndexPath:cell.model.indexPath];
//    UIImage * image = [self getImageFromView:_senderViewForAnimation];
//
//
//    UIView *fadeView = [[UIView alloc] initWithFrame:mainWindow.bounds];
//    fadeView.backgroundColor = [UIColor blackColor];
//    fadeView.alpha = fadeAlpha;
//    [mainWindow addSubview:fadeView];
//
//    UIImageView *resizableImageView;
//
//    resizableImageView  = [[UIImageView alloc] initWithImage:image];
//    resizableImageView.frame = rect;
//    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
//    resizableImageView.backgroundColor = [UIColor clearColor];
//    resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
//    resizableImageView.layer.masksToBounds = YES;
//    [mainWindow addSubview:resizableImageView];
//    self.view.hidden = YES;
//
//    void (^completion)(void) = ^() {
//        _senderViewForAnimation.hidden = NO;
//        _senderViewForAnimation = nil;
//        _scaleImage = nil;
//
//        [fadeView removeFromSuperview];
//        [resizableImageView removeFromSuperview];
//
//        // Gesture
//        [mainWindow removeGestureRecognizer:_panGesture];
//        // Controls
//        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//
//        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [self dismissViewControllerAnimated:NO completion:nil];
//    };
//
//    CGRect senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
//    [UIView animateWithDuration:0.4 animations:^{
//        resizableImageView.frame = senderViewOriginalFrame;
//        fadeView.alpha = 0;
//        self.view.backgroundColor = [UIColor clearColor];
//    } completion:^(BOOL finished) {
//        completion();
//    }];
//}


- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    _scrollView.hidden = YES;
    _willDisappear = YES;
    
    SDBrowserImageView *currentImageView = (SDBrowserImageView *)recognizer.view;
    NSInteger currentIndex = currentImageView.tag;
    
    UIView *sourceView = nil;
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:currentIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
    }else {
        sourceView = self.sourceImagesContainerView.subviews[currentIndex];
    }
    
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = currentImageView.image;
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    
    if (!currentImageView.image) { // 防止 因imageview的image加载失败 导致 崩溃
        h = self.bounds.size.height;
    }
    
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    
    [self addSubview:tempView];

    _saveButton.hidden = YES;
    
    [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
        _indexLabel.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        
//        NSLog(@"swipe down");
        //执行程序
        _scrollView.hidden = YES;
        _willDisappear = YES;
    
        
        SDBrowserImageView *currentImageView = (SDBrowserImageView *)recognizer.view;
        NSInteger currentIndex = currentImageView.tag;
        
        UIView *sourceView = nil;
        if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
            UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
            NSIndexPath *path = [NSIndexPath indexPathForItem:currentIndex inSection:0];
            sourceView = [view cellForItemAtIndexPath:path];
        }else {
            sourceView = self.sourceImagesContainerView.subviews[currentIndex];
        }
        
        CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
        
        UIImageView *tempView = [[UIImageView alloc] init];
        tempView.contentMode = sourceView.contentMode;
        tempView.clipsToBounds = YES;
        tempView.image = currentImageView.image;
        CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
        
        if (!currentImageView.image) { // 防止 因imageview的image加载失败 导致 崩溃
            h = self.bounds.size.height;
        }
        
        tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
        tempView.center = self.center;
        
        [self addSubview:tempView];
        
        _saveButton.hidden = YES;
        
        [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
            tempView.frame = targetTemp;
            self.backgroundColor = [UIColor clearColor];
            _indexLabel.alpha = 0.1;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}


- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer
{
    SDBrowserImageView *imageView = (SDBrowserImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    
    SDBrowserImageView *view = (SDBrowserImageView *)recognizer.view;

    [view doubleTapToZommWithScale:scale];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += SDPhotoBrowserImageViewMargin * 2;
    
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - SDPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    
    
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(SDBrowserImageView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = SDPhotoBrowserImageViewMargin + idx * (SDPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    
    if (!_hasShowedFistView) {
        [self showFirstImage];
    }
    
    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 35);
    _saveButton.frame = CGRectMake(30, self.bounds.size.height - 70, 50, 25);
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
        SDBrowserImageView *currentImageView = _scrollView.subviews[_currentImageIndex];
        if ([currentImageView isKindOfClass:[SDBrowserImageView class]]) {
            [currentImageView clear];
        }
    }
}

- (void)showFirstImage
{
    UIView *sourceView = nil;
    
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentImageIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
    }else {
        sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    }
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self addSubview:tempView];
    
    CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];
    
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    
    [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
    }];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

- (NSDictionary *)highQualityImageBoxInfoForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageBoxInfoForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageBoxInfoForIndex:index];
    }
    return nil;
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    // 有过缩放的图片在拖动一定距离后清除缩放
    CGFloat margin = 150;
    CGFloat x = scrollView.contentOffset.x;
    if ((x - index * self.bounds.size.width) > margin || (x - index * self.bounds.size.width) < - margin) {
        SDBrowserImageView *imageView = _scrollView.subviews[index];
        if (imageView.isScaled) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [imageView eliminateScale];
            }];
        }
    }
    
    
    if (!_willDisappear) {
        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    }
    NSLog(@"😋%f",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x>__kWidth/2 - 60) {
        [self setupImageOfImageViewForIndex:index];
    }
}


//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    SDBrowserImageView *imageView = _scrollView.subviews[self.currentImageIndex];
//    CGFloat offsetX = (GetViewWidth(scrollView) > scrollView.contentSize.width) ? (GetViewWidth(scrollView) - scrollView.contentSize.width) * 0.5 : 0.0;
//    CGFloat offsetY = (GetViewHeight(scrollView) > scrollView.contentSize.height) ? (GetViewHeight(scrollView) - scrollView.contentSize.height) * 0.5 : 0.0;
//    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
////    imageView.isScaled = YES;
//}
//
//
//
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return _scrollView.subviews[self.currentImageIndex];
//}

- (SDBrowserImageView *)imageView{
    if (!_imageView) {
        _imageView = [[SDBrowserImageView alloc]init];
    }
    return _imageView;
}
@end
