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

#define ShareViewHeight 131.0
#define Width_Space      40.0f      // 2个按钮之间的横间距
#define Height_Space     0     // 竖间距
#define Button_Height   55.0f    // 高
#define Button_Width    40.0f    // 宽
#define Start_X          16.0f   // 第一个按钮的X坐标
#define Start_Y          16.0f     // 第一个按钮的Y坐标

@implementation SDPhotoBrowser 
{
    UIScrollView *_scrollView;
    BOOL _hasShowedFistView;
    UILabel *_indexLabel;
    UIButton *_saveButton;
    UIActivityIndicatorView *_indicatorView;
    BOOL _willDisappear;
    UIView *_shareView;
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
    _shareView = [[UIView alloc]initWithFrame:CGRectMake(0, __kHeight, __kWidth, ShareViewHeight)];
    _shareView.backgroundColor = [UIColor whiteColor];
    UIToolbar *shareToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, ShareViewHeight - 44, __kWidth, 44)];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareToOther)];
    UIBarButtonItem* flexItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    flexItem.width = 16;
    [shareToolbar setItems:@[flexItem,barButtonItem]];
    
 
    [_shareView addSubview:shareToolbar];
    [self addSubview:_shareView];
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
       
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewlongGesture:)];
        
        [imageView addGestureRecognizer:singleTap];
//        [imageView addGestureRecognizer:recognizer];
        [imageView addGestureRecognizer:doubleTap];
        [self addGestureRecognizer:panGesture];
        [imageView addGestureRecognizer:longGesture];
        [_scrollView addSubview:imageView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}

// 加载图片
// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{

    SDBrowserImageView *imageView = _scrollView.subviews[index];
    self.currentImageIndex = index;
    
    if (imageView.hasLoadedImage) return;
    //    if ([self highQualityImageURLForIndex:index]) {
    
    //        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    //    } else {
    //        imageView.image = [self placeholderImageForIndex:index];
    //    }
//    @weaky(self)
    
    if ([self highQualityImageBoxInfoForIndex:index]) {
        NSDictionary *dic = [self highQualityImageBoxInfoForIndex:index];
        
        imageView.image = [self placeholderImageForIndex:self.currentImageIndex];
        if (dic[kMessageImageBoxLocalAsset]) {
            if ([dic[kMessageImageBoxLocalAsset] isKindOfClass:[WBAsset class]]) {
                //                [SXLoadingView showProgressHUD:@""];
                WBAsset*asset = dic[kMessageImageBoxLocalAsset];
                [WB_NetService getHighWebImageWithHash:asset.fmhash completeBlock:^(NSError *error, UIImage *netImage) {
                    dispatch_main_async_safe(^{
                        if (!error &&netImage) {
                            imageView.image = netImage;
                        }else{
                            imageView.image = [self placeholderImageForIndex:index];
                        }
                            imageView.hasLoadedImage = YES;
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
                               imageView.image = localImage;
                        }else{
                               imageView.image = [self placeholderImageForIndex:index];
                        }
                               imageView.hasLoadedImage = YES;
                    });
                }];
            }
        }else{
            //            [SXLoadingView showProgressHUD:@""];
            [WB_NetService getTweeethighQualityImageWithHash:dic[kMessageImageBoxNetImageHash] BoxUUID:dic[kMessageImageBoxUUID] complete:^(NSError *error, UIImage *netImage) {
                dispatch_main_async_safe(^{
                    if (!error &&netImage) {
//                        self.imageView.image = [UIImage imageWithColor:[UIColor cyanColor]];
                          imageView.image = netImage;
                    }else{
                          imageView.image = [self placeholderImageForIndex:index];
                    }
                          imageView.hasLoadedImage = YES;
                });
            }];
        }
    }else{
         imageView.image = [self placeholderImageForIndex:index];
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
    CGPoint translatedPointForAnimation = [(UIPanGestureRecognizer*)sender translationInView:self];
//    NSLog(@"😈😈😈😈😈😈😈%@",NSStringFromCGPoint(translatedPoint));
    // Gesture Began
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
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
            if (_scrollView.subviews[_currentImageIndex]) {
                [self performDismissAnimationWithTranslatedPoint:translatedPointForAnimation];
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
        }
        else // Continue Showing View
        {
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

- (void)performDismissAnimationWithTranslatedPoint:(CGPoint)translatedPoint
{
    float fadeAlpha = 1 - fabs(_scrollView.frame.origin.y)/_scrollView.frame.size.height;

    UIWindow * mainWindow = [UIApplication sharedApplication].keyWindow;
    //    得到当前视图的frame
    
    CGSize selfSize = self.frame.size;
    
    //    得到image的frame
    
    CGSize imageSize = ((UIImageView *)_scrollView.subviews[_currentImageIndex]).image.size;
    
    //    得到imageView 的frame
    
    CGRect imageVRect = _scrollView.subviews[_currentImageIndex].frame;
    
    //    确定imageView 的宽度
    
    imageVRect.size.width = selfSize.width;
    
    //    根据宽度计算imageView 的高度
    
    imageVRect.size.height = imageVRect.size.width*imageSize.height/imageSize.width;
    
    //计算x，y
    
    imageVRect.origin.x = 0;
    
    imageVRect.origin.y = translatedPoint.y;
    
    CGRect rect = [_scrollView.subviews[_currentImageIndex] convertRect:imageVRect toView:self];
    NSLog(@"%@",NSStringFromCGSize(((UIImageView *)_scrollView.subviews[_currentImageIndex]).image.size));
    UIView *senderViewForAnimation = [_delegate photoBrowser:self willDismissAtIndex:_currentImageIndex];
    UIImage * image = ((UIImageView *)senderViewForAnimation).image;


    UIView *fadeView = [[UIView alloc] initWithFrame:mainWindow.bounds];
    fadeView.backgroundColor = [UIColor blackColor];
    fadeView.alpha = fadeAlpha;
    [mainWindow addSubview:fadeView];

    UIImageView *resizableImageView;

    resizableImageView  = [[UIImageView alloc] initWithImage:image];
    resizableImageView.frame = rect;
    resizableImageView.backgroundColor = [UIColor clearColor];
    resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizableImageView.layer.masksToBounds = YES;
    [mainWindow addSubview:resizableImageView];
    self.hidden = YES;

    void (^completion)(void) = ^() {
        senderViewForAnimation.hidden = NO;
//        senderViewForAnimation = nil;

        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];

        // Gesture
        [NSObject cancelPreviousPerformRequestsWithTarget:self];

    };

    CGRect senderViewOriginalFrame = [senderViewForAnimation.superview convertRect:senderViewForAnimation.frame toView:nil];
    [UIView animateWithDuration:0.4 animations:^{
        resizableImageView.frame = senderViewOriginalFrame;
        fadeView.alpha = 0;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        completion();
    }];
}

- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    if (_shareView && _shareView.frame.origin.y == __kHeight - ShareViewHeight) {
        [UIView animateWithDuration:.5f animations:^{
            _shareView.frame = CGRectMake(0, __kHeight, __kWidth, ShareViewHeight);
        } completion:^(BOOL finished) {
            [_shareView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[UIScrollView class]]) {
                    [obj removeFromSuperview];
                }
            }];
        }];
        return;
    }
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

- (void)imageViewlongGesture:(UILongPressGestureRecognizer*)gesture{
    if ( _shareView.frame.origin.y == __kHeight - ShareViewHeight) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self shareScrollViewInit];
    }
}

- (void)shareScrollViewInit{
    [UIView  animateWithDuration:.5f animations:^{
        _shareView.frame = CGRectMake(0, __kHeight - ShareViewHeight, __kWidth, ShareViewHeight);
    } completion:^(BOOL finished) {
        __block UIActivityIndicatorView *activtiy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activtiy.backgroundColor = [UIColor clearColor];
        activtiy.frame = CGRectMake(0, 0, 30, 30);
        activtiy.center = CGPointMake(_shareView.width/2, (_shareView.height - 44)/2);
        [_shareView addSubview:activtiy];
        [activtiy  startAnimating];
        [WB_BoxService getBoxListCallBack:^(NSArray *boxesModelArr, NSError *error) {
            [activtiy stopAnimating];
            [activtiy removeFromSuperview];
            if (!error) {
                UIScrollView *scrollView = [[UIScrollView alloc]init];
                scrollView.frame = CGRectMake(0, 0, __kWidth, ShareViewHeight - 44);
                NSMutableArray *boxArray = [NSMutableArray arrayWithArray:boxesModelArr];
//                [boxesModelArr enumerateObjectsUsingBlock:^(WBBoxesModel *boxesModel, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if ([boxesModel.uuid isEqualToString:[weak_self boxModel].uuid]) {
//                        [boxArray removeObject:boxesModel];
//                    }
//                }];
                
                self.boxesDataArray = boxArray;
                [boxArray enumerateObjectsUsingBlock:^(WBBoxesModel *boxesModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    UIButton *boxView = [[UIButton alloc]initWithFrame:CGRectMake(idx *(Button_Width + Width_Space) + Start_X,Start_Y, Button_Width, Button_Height)];
                    //                        boxView.backgroundColor = [UIColor redColor];
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, Button_Height - 15, Button_Width, 15)];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.font = [UIFont systemFontOfSize:12];
                    label.text = boxesModel.name;
                    //                        NSLog(@"%@",boxesModel.name);
                    //                        label.backgroundColor = [UIColor cyanColor];
                    __block NSMutableString *userName = [NSMutableString stringWithCapacity:0];
                    NSInteger n = MIN(boxesModel.users.count, 5);
                    float r = 20 * n / (2.5 * n - 1.5);
                    [boxesModel.users enumerateObjectsUsingBlock:^(WBBoxesUsersModel *userModel, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (idx<= n - 1){
                            float deg =  M_PI * ((float)idx * 2 / n - 1 / 4);
                            float top = (1 - cosf(deg)) * (20 - r);
                            float left = (1 + sinf(deg)) * (20 - r);
                            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, top, r *2, r*2)];
                            imageView.layer.masksToBounds = YES;
                            imageView.layer.cornerRadius = r;
                            imageView.layer.borderWidth = 0.5f;
                            imageView.layer.borderColor = [UIColor whiteColor].CGColor;
                            [imageView was_setCircleImageWithUrlString:userModel.avatarUrl placeholder:[UIImage imageWithColor:RGBACOLOR(0, 0, 0, 0.37)]];
                            [boxView addSubview:imageView];
                            if (boxesModel.name.length ==0) {
                                [userName  appendFormat:@"%@,",userModel.nickName];
                                label.text = userName;
                            }
                        }
                    }];
                    
                    [boxView addSubview:label];
                    boxView.tag = idx;
                    [boxView addTarget:self action:@selector(boxShareClick:) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:boxView];
                }];
                scrollView.contentSize = CGSizeMake(boxesModelArr.count*(Button_Width+Width_Space)+16*2 - Width_Space,scrollView.height );
                [_shareView addSubview:scrollView];
            }else{
                [SXLoadingView showAlertHUD:@"获取群列表失败" duration:1.2f];
            }
        }];
    }];
}

- (void)boxShareClick:(UIButton *)sender{
    [SXLoadingView showProgressHUD:@"正在分享"];
    [WB_BoxService sendTweetWithImageArray:[NSArray arrayWithObject:_scrollView.subviews[self.currentImageIndex]] BoxModel:self.boxesDataArray[sender.tag] Complete:^(WBTweetModel *tweetModel, NSError *error) {
        if (!error) {
            [SXLoadingView showAlertHUD:@"分享成功" duration:1.2f];
        }else{
            NSLog(@"%@",error);
             [SXLoadingView showAlertHUD:@"分享失败" duration:1.2f];
        }
    }];
    [self photoClick:nil];
}

- (void)shareToOther{
    @weaky(self)
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[((UIImageView *)(_scrollView.subviews[self.currentImageIndex])).image] applicationActivities:nil];
    //初始化回调方法
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError)
    {
        NSLog(@"activityType :%@", activityType);
        if (completed)
        {
            NSLog(@"share completed");
            if (activityType == UIActivityTypeSaveToCameraRoll) {
                [SXLoadingView showProgressHUDText:@"已存入相册" duration:1.2f];
            }else{
                [SXLoadingView showProgressHUDText:@"分享完成" duration:1.2f];
            }
        }
        else
        {
            NSLog(@"share cancel");
        }
        [weak_self photoClick:nil];
    };
    
    // 初始化completionHandler，当post结束之后（无论是done还是cancel）该blog都会被调用
    activityVC.completionWithItemsHandler = myBlock;
    
    //关闭系统的一些activity类型 UIActivityTypeAirDrop 屏蔽aridrop
    activityVC.excludedActivityTypes = @[];
    
    [[UIViewController getCurrentVC] presentViewController:activityVC animated:YES completion:nil];
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

- (WBBoxesModel *)boxModel{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:)]) {
        return [self.delegate photoBrowser:self];
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
//    NSLog(@"😋%f",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x>__kWidth/2 - 60) {
        [self setupImageOfImageViewForIndex:index];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
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

//- (SDBrowserImageView *)imageView{
//    if (!_imageView) {
//        _imageView = [[SDBrowserImageView alloc]init];
//    }
//    return _imageView;
//}
@end
