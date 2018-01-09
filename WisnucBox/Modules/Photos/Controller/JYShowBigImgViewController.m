//
//  JYShowBigImgViewController.m
//  Photos
//
//  Created by JackYang on 2017/10/17.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYShowBigImgViewController.h"
#import <Photos/Photos.h>
#import "JYBigImgCell.h"
#import "JYConst.h"
#import "JYAsset.h"
#import "PHPhotoLibrary+JYEXT.h"
#import "PHAsset+JYEXT.h"

@interface JYShowBigImgViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    
    UIButton *_navRightBtn;
    
    //底部view
    UIView   *_bottomView;
    UIButton *_btnOriginalPhoto;
    UIButton *_btnDone;
    //编辑按钮
    UIButton *_btnEdit;
    
    //双击的scrollView
    UIScrollView *_selectScrollView;
    NSUInteger _currentPage;
    
    UIPanGestureRecognizer *_panGesture;
    
    BOOL _isFirstAppear;
    
    BOOL _hideNavBar;
    
    BOOL _isdraggingPhoto;
    
    //设备旋转前的index
    NSUInteger _indexBeforeRotation;
    UICollectionViewFlowLayout *_layout;
    
    id _currentModelForRecord;
    
    UIImageView *_rightImageView;
}

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) UIView *navView;

@property (strong, nonatomic) JYProcessView * pv;

@property (nonatomic, assign) BOOL isDownloading;

@property (nonatomic, copy) void(^downloadBlock)(BOOL success ,UIImage *image);

@end

@implementation JYShowBigImgViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"---- %s ", __FUNCTION__);
}

- (instancetype)init
{
    if(self = [super init]) {
        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
            self.automaticallyAdjustsScrollViewInsets = NO;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationCapturesStatusBarAppearance = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
//    NSLog(@"%@",phoneVersion);
    if([phoneVersion floatValue]>=11.0){
    if ([_collectionView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            if (@available(iOS 11.0, *)) {
                _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    self.view.alpha = 0.0f;
    _isFirstAppear = YES;
    _currentPage = self.selectIndex+1;
    _indexBeforeRotation = self.selectIndex;
    [self initCollectionView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [_panGesture setMinimumNumberOfTouches:1];
    [_panGesture setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:_panGesture];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
    [self.view addGestureRecognizer:longGesture];
    [self initNavBtns];

}

- (void)back:(id)btn
{
//    JYBigImgCell * cell = _collectionView.visibleCells.firstObject;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isFirstAppear) {
        return;
    }
    [_collectionView setContentOffset:CGPointMake((kViewWidth+kItemMargin)*_indexBeforeRotation, 0)];
    [self performPresentAnimation];
    WBApplication.statusBarStyle = UIStatusBarStyleLightContent;
}


- (void)viewDidAppear:(BOOL)animated
{
    if (!_isFirstAppear) {
        return;
    }
    _isFirstAppear = NO;
    [self reloadCurrentCell];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     WBApplication.statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_rightImageView) {
        if ([self getCurrentPageModel].type == JYAssetTypeImage && [self getCurrentPageModel].type != JYAssetTypeNetImage) {
            [_rightImageView setHidden:NO];
        }else if([self getCurrentPageModel].type == JYAssetTypeNetImage) {
            [_rightImageView setHidden:YES];
        }
    }
//    _layout.minimumLineSpacing = kItemMargin;
//    _layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
//    _layout.itemSize = self.view.bounds.size;
//    [_collectionView setCollectionViewLayout:_layout];
//
//    _collectionView.frame = CGRectMake(-kItemMargin/2, 0, kViewWidth+kItemMargin, kViewHeight);
//    // TODO: rotation
//    [_collectionView setContentOffset:CGPointMake((kViewWidth+kItemMargin)*_indexBeforeRotation, 0)];
    
//    CGRect frame = _hideNavBar?CGRectMake(0, kViewHeight, kViewWidth, 44):CGRectMake(0, kViewHeight-44, kViewWidth, 44);
//    _bottomView.frame = frame;
//    _btnEdit.frame = CGRectMake(kViewWidth/2-30, 7, 60, 30);
//    _btnDone.frame = CGRectMake(kViewWidth - 82, 7, 70, 30);
}

#pragma mark - panGesture Handler

- (void)panGestureRecognized:(id)sender {
    // Initial Setup
    UICollectionView *scrollView = _collectionView;
    
    static float firstX, firstY;
    
    float viewHeight = scrollView.frame.size.height;
    float viewHalfHeight = viewHeight/2;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    // Gesture Began
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
        
//        _senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
        
        _isdraggingPhoto = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(firstX, firstY+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    
    float newY = scrollView.center.y - viewHalfHeight;
    float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
    
    self.view.opaque = YES;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];;
    
    // Gesture Ended
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if(scrollView.center.y > viewHalfHeight+40 || scrollView.center.y < viewHalfHeight-40) // Automatic Dismiss View
        {
            if (_senderViewForAnimation) {
                [self performDismissAnimation];
                return;
            }
            
            CGFloat finalX = firstX, finalY;
            
            CGFloat windowsHeigt = [self.view frame].size.height;
            
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
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];
            [UIView commitAnimations];
            
            [self performSelector:@selector(back:) withObject:self afterDelay:animationDuration];
        }
        else // Continue Showing View
        {
            _isdraggingPhoto = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            
            CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
            
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

- (void)longGestureRecognized:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self readyToShare];
    }
}

- (void)readyToShare{
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:cancelTitle
                                                otherButtonTitleArray:@[WBLocalizedString(@"share", nil)]];
    actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
        if (buttonIndex == 1) {
            [self shareToOtherApp];
        }
    };
    actionSheet.scrolling          = YES;
    actionSheet.buttonHeight       = 60.0f;
    actionSheet.visibleButtonCount = 3.6f;
    [actionSheet show];
}

- (void)shareToOtherApp{
    //准备照片
    @weaky(self);
    [self clickDownloadWithShare:YES andCompleteBlock:^(NSArray *images) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
        //初始化回调方法
        UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError)
        {
            NSLog(@"activityType :%@", activityType);
            if (completed)
            {
                NSLog(@"share completed");
               
            }
            else
            {
                NSLog(@"share cancel");
            }
        };
        
        // 初始化completionHandler，当post结束之后（无论是done还是cancel）该blog都会被调用
        activityVC.completionWithItemsHandler = myBlock;
        
        //关闭系统的一些activity类型 UIActivityTypeAirDrop 屏蔽aridrop
        activityVC.excludedActivityTypes = @[];
        
        [weak_self presentViewController:activityVC animated:YES completion:nil];
    }];
}

- (void)clickDownloadWithShare:(BOOL)share andCompleteBlock:(void(^)(NSArray * images))block{
    NSArray * chooseItems = [NSArray arrayWithObject:[self getCurrentPageModel]];
    if (!_pv)
        _pv = [JYProcessView processViewWithType:ProcessTypeLine];
    _pv.descLb.text = share?WBLocalizedString(@"preparing_photos", nil):WBLocalizedString(@"downloading_file", nil);
    _pv.subDescLb.text = [NSString stringWithFormat:@"%lu个项目 ",(unsigned long)chooseItems.count];
    [_pv show];
    _isDownloading = YES;
    _pv.cancleBlock = ^(){
        _isDownloading = NO;
    };
    [self downloadItems:chooseItems withShare:share andCompleteBlock:block];

}

-(void)downloadItems:(NSArray *)items withShare:(BOOL)isShare andCompleteBlock:(void(^)(NSArray * images))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            __block float complete = 0.f;
            __block int successCount = 0;
            __block int finish = 0;
            __block NSUInteger allCount = items.count;
            @weaky(self);
            NSMutableArray * tempDownArr = [NSMutableArray arrayWithCapacity:0];
            self.downloadBlock = ^(BOOL success ,UIImage *image){
                complete ++;finish ++;
                if (successCount) successCount++;
                CGFloat progress =  complete/allCount;
                if (image && isShare) [tempDownArr addObject:image];
                [weak_self.pv setValueForProcess:progress];
                if (items.count > complete) {
                    if (weak_self.isDownloading) {
                        [weak_self downloadItem:items[finish] withShare:isShare withCompleteBlock: weak_self.downloadBlock];
                    }
                }else{
                    _isDownloading = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weak_self.pv dismiss];
                        if (!isShare)
                            [SXLoadingView showAlertHUD:WBLocalizedString(@"download_completed", nil) duration:1];
                        if (block) block([tempDownArr copy]);
                    });
                }
            };
            if (_isDownloading) {
                [self downloadItem:items[0] withShare:isShare withCompleteBlock:self.downloadBlock];
            }
        }
    });
}

-(void)downloadItem:(JYAsset *)item withShare:(BOOL)share withCompleteBlock:(void(^)(BOOL isSuccess,UIImage * image))block{
    if ([item isKindOfClass:[WBAsset class]]) {
        NSLog(@"%lu",(unsigned long)item.type);
        if (item.type == JYAssetTypeNetImage) {
            __block id<SDWebImageOperation> operation =  [WB_NetService getHighWebImageWithHash:[(WBAsset *)item fmhash] completeBlock:^(NSError *error, UIImage *img) {
                if (error) {
                    NSLog(@"%@",error);
                    // TODO: Load Error Image
                    block(NO,nil);
                } else {
                    if (img) {
                        if(!share){
                            [PHPhotoLibrary saveImageToAlbum:img completion:^(BOOL isSuccess, PHAsset * asset) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    block(isSuccess,img);
                                });
                            }];
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(YES,img);
                            });
                        }
                    }else
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(NO,nil);
                        });
                    NSLog(@"%@",img);
                }
                [operation cancel];
                operation = nil;
            }];
        }
    }else{
        NSLog(@"%@",item.asset) ;
        if (item.asset) {
            if (!share) {
                [item.asset getFile:^(NSError *error, NSString *filePath) {
                    if (item.type == JYAssetTypeImage || item.type == JYAssetTypeLivePhoto) {
                        UIImage * image;
                        if (filePath && (image = [UIImage imageWithContentsOfFile:filePath])) {
                            [PHPhotoLibrary saveImageToAlbum:image completion:^(BOOL isSuccess, PHAsset * asset) {
                                [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];//删除image
                                block(isSuccess,image);
                            }];
                        }else block(NO,nil);
                    }
                }];
            }else{
                if (item.type == JYAssetTypeImage || item.type == JYAssetTypeLivePhoto) {
                    [PHPhotoLibrary requestOriginalImageSyncForAsset:item.asset completion:^(NSError *error, UIImage *image, NSDictionary *dic) {
                        if(error) return block(NO, nil);
                        block(YES, image);
                    }];
                }
            }
        }else
            block(NO,nil);
    }
}


#pragma mark - 设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    //    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    _indexBeforeRotation = _currentPage - 1;
}

- (void)setModels:(NSArray<JYAsset *> *)models
{
    _models = models;
    //如果预览网络图片则返回
    if (models.firstObject.type == JYAssetTypeNetImage) {
        return;
    }
}

//- (void)rotateOrientation:(UIInterfaceOrientation)orientation {
//
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:YES];
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
//}

- (void)initNavBtns
{
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    effectView.frame = CGRectMake(0, 0, __kWidth, 64);
    UIView *naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 64)];
    naviView.backgroundColor = [UIColor clearColor];
    
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
//    UIVisualEffectView * btnEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    effectView.frame = CGRectMake(0, 0, __kWidth, 64);

    UIButton *leftNaviButton = [[UIButton alloc]init];
    [leftNaviButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftNaviButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

//    [naviView addSubview:btnEffectView];
    [naviView addSubview:leftNaviButton];

//    [btnEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(leftNaviButton);
//        make.size.mas_equalTo(CGSizeMake(30, 30));
//    }];
//    btnEffectView.layer.cornerRadius = 15;
//    btnEffectView.layer.masksToBounds = YES;

    [leftNaviButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(naviView.mas_centerY).offset(10);
        make.left.equalTo(naviView.mas_left).offset(16);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [leftNaviButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text =  [NSString stringWithFormat:@"%ld/%ld", _currentPage, self.models.count];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
//     UIVisualEffectView * titleEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    [naviView addSubview:titleEffectView];
    [naviView addSubview:_titleLabel];

    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(naviView.mas_centerX);
        make.centerY.equalTo(naviView.mas_centerY).offset(10);
    }];
    
//    [titleEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(_titleLabel);
//        make.height.equalTo(_titleLabel.mas_height).offset(5);
//        make.width.equalTo(_titleLabel.mas_width).offset(40);
//    }];
    
   
    UIButton *rightNaviButton = [[UIButton alloc]init];
    [rightNaviButton setImage:[UIImage imageNamed:@"more_white"] forState:UIControlStateNormal];
    [rightNaviButton addTarget:self action:@selector(readyToShare) forControlEvents:UIControlEventTouchUpInside];

    [naviView addSubview:rightNaviButton];

    [rightNaviButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_titleLabel.mas_centerY);
        make.right.equalTo(naviView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [rightNaviButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
    
    UIImageView *rightImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_cloud_off_white"]];
    [rightImageView setHidden:YES];
    [naviView addSubview:rightImageView];
    
    [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_titleLabel.mas_centerY);
        make.right.equalTo(rightNaviButton.mas_left).offset(-16);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
   
    
    if ([self getCurrentPageModel].type == JYAssetTypeImage && [self getCurrentPageModel].type != JYAssetTypeNetImage) {
       [rightImageView setHidden:NO];
    }
    
    _rightImageView = rightImageView;
    self.navView = naviView;

    [self.view addSubview:naviView];
}

- (void)doneButtonPressed:(UIButton *)btn {
    [self performDismissAnimation];
}

#pragma mark - 初始化CollectionView
- (void)initCollectionView
{
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [_collectionView registerClass:[JYBigImgCell class] forCellWithReuseIdentifier:@"JYBigImgCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    _layout.minimumLineSpacing = kItemMargin;
    _layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    _layout.itemSize = self.view.bounds.size;
    [_collectionView setCollectionViewLayout:_layout];
    
    _collectionView.frame = CGRectMake(-kItemMargin/2, 0, kViewWidth+kItemMargin, kViewHeight);
    // TODO: rotation
    [_collectionView setContentOffset:CGPointMake((kViewWidth+kItemMargin)*_indexBeforeRotation, 0)];
    [self.view addSubview:_collectionView];
}

- (void)initBottomView
{
    
}

- (BOOL)prefersStatusBarHidden {
    return _hideNavBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)handlerSingleTap
{
    _hideNavBar = !_hideNavBar;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    CGRect frame = _hideNavBar?CGRectMake(0, -64, kViewWidth, 64):CGRectMake(0, 0, kViewWidth, 64);
    [UIView animateWithDuration:0.3 animations:^{
        _navView.frame = frame;
    }];
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.models.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((JYBigImgCell *)cell).previewView resetScale];
    ((JYBigImgCell *)cell).willDisplaying = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((JYBigImgCell *)cell).previewView handlerEndDisplaying];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JYBigImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JYBigImgCell" forIndexPath:indexPath];
    JYAsset *model = self.models[indexPath.row];
    
    
    cell.showGif = YES;
    cell.showLivePhoto = YES;
    cell.model = model;
    jy_weakify(self);
    cell.singleTapCallBack = ^() {
        jy_strongify(weakSelf);
        [strongSelf handlerSingleTap];
    };
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == (UIScrollView *)_collectionView) {
        JYAsset *m = [self getCurrentPageModel];
        if (!m || _currentModelForRecord == m) return;
        _currentModelForRecord = m;
        //改变导航标题
        if(self.delegate && !_isFirstAppear)
           [self.delegate photoBrowser:self scrollToIndexPath:m.indexPath];
        //!!!!!: change Title
        _titleLabel.text = [NSString stringWithFormat:@"%lu/%ld", (unsigned long)_currentPage, (unsigned long)self.models.count];
        if (m.type == JYAssetTypeGIF ||
            m.type == JYAssetTypeLivePhoto ||
            m.type == JYAssetTypeVideo || m.type == JYAssetTypeNetVideo) {
            JYBigImgCell *cell = (JYBigImgCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
            [cell pausePlay];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    [self reloadCurrentCell];
}

- (void)reloadCurrentCell
{
    JYAsset *m = [self getCurrentPageModel];
    if (m.type == JYAssetTypeGIF ||
        m.type == JYAssetTypeLivePhoto) {
        JYBigImgCell *cell = (JYBigImgCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
        [cell reloadGifLivePhoto];
    }
}

- (JYAsset *)getCurrentPageModel
{
    CGPoint offset = _collectionView.contentOffset;
    
    CGFloat page = offset.x/(kViewWidth+kItemMargin);
    if (ceilf(page) >= self.models.count || page < 0) {
        return nil;
    }
    NSString *str = [NSString stringWithFormat:@"%.0f", page];
    _currentPage = str.integerValue + 1;
    JYAsset *model = self.models[_currentPage-1];
    return model;
}

- (CGRect)getCurrentPageRect
{
    CGRect frame;
    JYAsset * model = [self getCurrentPageModel];
    
    CGFloat w, h;
    if (model.asset) {
        w = [model.asset pixelWidth];
        h = [model.asset pixelHeight];
    } else if ([model isKindOfClass:[WBAsset class]]) {
        w = [(WBAsset *)model w];
        h = [(WBAsset *)model h];
    } else {
        w = kViewWidth;
        h = kViewHeight;
    }
    
    CGFloat width = MIN(kViewWidth, w);
    frame.origin = CGPointZero;
    frame.size.width = width;
    
    CGFloat imageScale = h/w;
    CGFloat screenScale = kViewHeight/kViewWidth;
    
    if (imageScale > screenScale) {
        frame.size.height = kViewHeight;
        frame.size.width = floorf(width * kViewHeight / h);
    } else {
        CGFloat height = floorf(width * imageScale);
        if (height < 1 || isnan(height)) {
            //iCloud图片height为NaN
            height = GetViewHeight(self.view);
        }
        frame.size.height = height;
    }
    frame.origin.x = (kViewWidth - frame.size.width)/2;
    frame.origin.y = (kViewHeight - frame.size.height)/2;
    
    return frame;
}

- (UIImage*)getImageFromView:(UIView *)view {
    if ([view isKindOfClass:[UIImageView class]]) {
        return ((UIImageView*)view).image;
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)performPresentAnimation {
    self.view.alpha = 0.0f;
    _collectionView.alpha = 0.0f;
    
    UIImage *imageFromView = _scaleImage ? _scaleImage : [self getImageFromView:_senderViewForAnimation];

    CGRect senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];

    UIView *fadeView = [[UIView alloc] initWithFrame:self.view.bounds];
    fadeView.backgroundColor = [UIColor clearColor];
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    [mainWindow addSubview:fadeView];
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    [mainWindow addSubview:resizableImageView];
    
//
//    //jy
//    //    _senderViewForAnimation.hidden = YES;
//    
    void (^completion)(void) = ^() {
        self.view.alpha = 1.0f;
        _collectionView.alpha = 1.0f;
        resizableImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
    };
    // FIXME: net video animation error!
    if([self getCurrentPageModel].type == JYAssetTypeNetVideo )
        return completion();
    
    [UIView animateWithDuration:0.3 animations:^{
        fadeView.backgroundColor =  [UIColor blackColor];
    } completion:nil];
    
    CGRect finalImageViewFrame = [self getCurrentPageRect];
    self.view.opaque = YES;
    [UIView animateWithDuration:0.3 animations:^{
        resizableImageView.frame = finalImageViewFrame;
    } completion:^(BOOL finished) {
        completion();
    }];
}

- (void)performDismissAnimation
{
    float fadeAlpha = 1 - fabs(_collectionView.frame.origin.y)/_collectionView.frame.size.height;

//    JYBigImgCell * cell = _collectionView.visibleCells[0];
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:_currentPage - 1 inSection:0];
    JYBigImgCell * cell = (JYBigImgCell *)[_collectionView cellForItemAtIndexPath:indexP];
    UIWindow * mainWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect rect = [cell.previewView convertRect:cell.previewView.imageViewFrame toView:self.view];
    
    _senderViewForAnimation = [_delegate photoBrowser:self willDismissAtIndexPath:cell.model.indexPath];
    UIImage * image = [self getImageFromView:_senderViewForAnimation];
    
    
    UIView *fadeView = [[UIView alloc] initWithFrame:mainWindow.bounds];
    fadeView.backgroundColor = [UIColor blackColor];
    fadeView.alpha = fadeAlpha;
    [mainWindow addSubview:fadeView];
    
    UIImageView *resizableImageView;
    
    resizableImageView  = [[UIImageView alloc] initWithImage:image];
    resizableImageView.frame = rect;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizableImageView.layer.masksToBounds = YES;
    [mainWindow addSubview:resizableImageView];
    self.view.hidden = YES;
    
    void (^completion)(void) = ^() {
        _senderViewForAnimation.hidden = NO;
        _senderViewForAnimation = nil;
        _scaleImage = nil;
        
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
        // Gesture
        [mainWindow removeGestureRecognizer:_panGesture];
        // Controls
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    
    CGRect senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
    [UIView animateWithDuration:0.4 animations:^{
        resizableImageView.frame = senderViewOriginalFrame;
        fadeView.alpha = 0;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        completion();
    }];
}



@end
