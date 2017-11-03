//
//  JYThumbVC.m
//  Photos
//
//  Created by JackYang on 2017/9/25.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYThumbVC.h"
#import "PHPhotoLibrary+JYEXT.h"
#import <Photos/Photos.h>
#import "JYConst.h"
#import "JYProgressHUD.h"
#import "JYAsset.h"
#import "JYCollectionViewCell.h"
#import "JYForceTouchPreviewController.h"
#import "JYShowBigImgViewController.h"
#import "FMHeadView.h"
#import "UIScrollView+IndicatorExt.h"
#import "TYDecorationSectionLayout.h"

@interface JYThumbVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerPreviewingDelegate> {
    NSInteger _currentScale;
}

@property (nonatomic, strong) NSMutableArray<JYAsset *> *arrDataSourcesBackup;

@property (nonatomic, strong) NSMutableArray<JYAsset *> *arrDataSources;

@property (nonatomic, strong) NSMutableArray<NSString *> *timesArr;

@end

@implementation JYThumbVC

- (JYAssetList *)albumListModel
{
    if (!_albumListModel) {
        _albumListModel = [PHPhotoLibrary getCameraRollAlbumList:YES allowSelectImage:YES];
    }
    return _albumListModel;
}

- (NSMutableArray<JYAsset *> *)arrDataSources
{
    if (!_arrDataSources) {
        JYProgressHUD *hud = [[JYProgressHUD alloc] init];
        [hud show];
        _arrDataSources = [NSMutableArray arrayWithArray:self.albumListModel.models];
        _arrDataSourcesBackup = [_arrDataSources copy];
        [self sort];
        [hud hide];
    }
    return _arrDataSources;
}

-(void)sort
{
    NSComparator cmptr = ^(JYAsset * photo1, JYAsset * photo2){
        NSDate * tempDate = [[photo1 asset].creationDate laterDate:[photo2 asset].creationDate];
        if ([tempDate isEqualToDate:[photo1 asset].creationDate]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([tempDate isEqualToDate:[photo2 asset].creationDate]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    [self.arrDataSources sortUsingComparator:cmptr];
    NSMutableArray * tArr = [NSMutableArray array];//时间组
    NSMutableArray * pGroupArr = [NSMutableArray array];//照片组数组
    if (_arrDataSources.count>0) {
        JYAsset * photo = _arrDataSources[0];
        NSMutableArray * photoDateGroup1 = [NSMutableArray array];//第一组照片
        [photoDateGroup1 addObject:photo];
        [pGroupArr addObject:photoDateGroup1];
        [tArr addObject:photo.asset.creationDate];
        
        NSMutableArray * photoDateGroup2 = photoDateGroup1;//最近的一组
        for (int i = 1 ; i < _arrDataSources.count; i++) {
            @autoreleasepool {
                JYAsset * photo1 =  _arrDataSources[i];
                JYAsset * photo2 = _arrDataSources[i-1];
                if ([self isSameDay:[photo1 asset].creationDate date2:[photo2 asset].creationDate]) {
                    [photoDateGroup2 addObject:photo1];
                }
                else{
                    [tArr addObject:[photo1 asset].creationDate];
                    photoDateGroup2 = nil;
                    photoDateGroup2 = [NSMutableArray array];
                    [photoDateGroup2 addObject:photo1];
                    [pGroupArr addObject:photoDateGroup2];
                }
            }
        }
    }
    self.arrDataSources = pGroupArr;
    self.timesArr = tArr;
}

- (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2

{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    
    return (([comp1 day] == [comp2 day]) && ([comp1 month] == [comp2 month]) && ([comp1 year] == [comp2 year]));
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.albumListModel.title;
    self.showIndicator = YES;

    [self initNavBtn];
    [self initCollectionView];
    [self addPinchGesture];
}

//增加捏合手势
-(void)addPinchGesture{
    UIPinchGestureRecognizer * pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.collectionView addGestureRecognizer:pin];
}

//捏合响应
-(void)handlePinch:(UIPinchGestureRecognizer *)pin{
    if (pin.state == UIGestureRecognizerStateBegan) {
        BOOL isSmall = pin.scale > 1.0f;
        [self changeFlowLayoutIsBeSmall:!isSmall];
        [self.collectionView reloadData];
    }
}

-(void)changeFlowLayoutIsBeSmall:(BOOL)isSmall{
    if ((!isSmall && _currentScale == 1) || (isSmall && _currentScale == 6))
        return;
    TYDecorationSectionLayout *layout = [[TYDecorationSectionLayout alloc]init];
    //layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.alternateDecorationViews = YES;
    // costom xib names
    layout.decorationViewOfKinds = @[@"FMHeadView"];
    layout.scrollDirection=UICollectionViewScrollDirectionVertical;
    //    layout.sectionInset = UIEdgeInsetsMake(0, 0, 20, 0);
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
//    if(kSystemVersion >= 9.0)
    layout.sectionHeadersPinToVisibleBounds = NO;
    _currentScale = isSmall ? _currentScale + 1 : _currentScale - 1;
    
    layout.itemSize = CGSizeMake((kViewWidth- 2*(_currentScale-1))/_currentScale, (kViewWidth- 2*(_currentScale-1))/_currentScale);
    [self.collectionView setCollectionViewLayout:layout animated:YES];
}


-(void)deviceOrientationChanged:(UIDeviceOrientation)ori
{
    
}

- (void)initCollectionView
{
    _currentScale = 3;
    TYDecorationSectionLayout *_fmCollectionViewLayout = [[TYDecorationSectionLayout alloc]init];
    _fmCollectionViewLayout.alternateDecorationViews = YES;
    _fmCollectionViewLayout.decorationViewOfKinds = @[@"FMHeadView"];
    _fmCollectionViewLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    _fmCollectionViewLayout.minimumLineSpacing = 2;
    _fmCollectionViewLayout.minimumInteritemSpacing = 2;
    _fmCollectionViewLayout.itemSize = CGSizeMake((kViewWidth- 2*(_currentScale-1))/_currentScale, (kViewWidth- 2*(_currentScale-1))/_currentScale);

    
    self.collectionView.collectionViewLayout = _fmCollectionViewLayout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[FMHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
    
    [self.collectionView registerClass:NSClassFromString(@"JYCollectionViewCell") forCellWithReuseIdentifier:@"JYCollectionViewCell"];
    //注册3d touch
    if ([self forceTouchAvailable])
        [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
    [self.collectionView reloadData];
    
    if(_showIndicator) [self initIndicator];
}

- (void)initIndicator{
    [self.collectionView registerILSIndicator];
    [self.collectionView.indicator.slider addObserver:self forKeyPath:@"sliderState" options:0x01 context:nil];
    self.collectionView.indicator.frame = CGRectMake(self.collectionView.indicator.frame.origin.x, self.collectionView.indicator.frame.origin.y, self.collectionView.frame.size.width, CGRectGetHeight(self.collectionView.frame) - 2 * kILSDefaultSliderMargin);
}

- (BOOL)forceTouchAvailable
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    } else {
        return NO;
    }
}

- (void)initNavBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = 40; //
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:kNavBar_tintColor forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (UIViewController *)getBigImageVCWithData:(NSArray<JYAsset *> *)data index:(NSInteger)index
{
    JYShowBigImgViewController *vc = [[JYShowBigImgViewController alloc] init];
    vc.models = data.copy;
    vc.selectIndex = index;
    JYCollectionViewCell * cell = (JYCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[_collectionView indexPathsForSelectedItems].firstObject];
    vc.senderViewForAnimation = cell;
    vc.scaleImage = cell.imageView.image;
//    weakify(self);
    [vc setBtnBackBlock:^(NSArray<JYAsset *> *selectedModels, BOOL isOriginal) {
//        strongify(weakSelf);
//        [strongSelf.collectionView reloadData];
    }];
    return vc;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.arrDataSources.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ((NSArray *)self.arrDataSources[section]).count;
}

//head的高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size = { kViewWidth, 42 };
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JYCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JYCollectionViewCell" forIndexPath:indexPath];
    
    JYAsset *model;
    model = ((NSMutableArray *)self.arrDataSources[indexPath.section])[indexPath.row];
    
//    weakify(self);
//    __weak typeof(cell) weakCell = cell;
    
    cell.selectedBlock = ^(BOOL selected) {
//        strongify(weakSelf);
//        __strong typeof(weakCell) strongCell = weakCell;
        
    };
    if (collectionView.indicator) {
        collectionView.indicator.slider.timeLabel.text = [self getMouthDateStringWithPhoto:model.asset.creationDate];
    }
    
    cell.allSelectGif = YES;
    cell.allSelectLivePhoto = YES;
    cell.showSelectBtn = NO;
    cell.cornerRadio = 0;
    cell.showMask = NO;
    cell.maskColor = [UIColor blackColor];
    cell.model = model;
    
    return cell;
}

//headView
- (FMHeadView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    FMHeadView * headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
    headView.headTitle = [self getDateStringWithPhoto: ((JYAsset *)((NSMutableArray *)_arrDataSources[indexPath.section])[indexPath.row]).asset.creationDate];
    headView.fmIndexPath = indexPath;
//    headView.fmDelegate = self;
    return headView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JYAsset *model = ((NSMutableArray *)self.arrDataSources[indexPath.section])[indexPath.row];
    
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) [self presentViewController:vc animated:YES completion:nil];
    
}

- (UIViewController *)getMatchVCWithModel:(JYAsset *)model
{
    
    NSArray *arr = [PHPhotoLibrary getPhotoInResult:self.albumListModel.result allowSelectVideo:YES allowSelectImage:YES allowSelectGif:YES allowSelectLivePhoto:YES];
    int i = 0;
    for (JYAsset *m in arr) {
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier])
            break;
        i++;
    }
    return [self getBigImageVCWithData:arr index:i];
}
#pragma mark - UIViewControllerPreviewingDelegate
//!!!!: 3D Touch
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if (!indexPath) {
        return nil;
    }
    
//    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
#warning
    // 判断cell是否不可3dtouch
    
    //设置突出区域
    previewingContext.sourceRect = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    JYForceTouchPreviewController *vc = [[JYForceTouchPreviewController alloc] init];
    JYAsset *model = ((NSMutableArray *)self.arrDataSources[indexPath.section])[indexPath.row];
    vc.model = model;
    vc.allowSelectGif = YES;
    vc.allowSelectLivePhoto = YES;
    vc.preferredContentSize = [self getSize:model];
    
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    JYAsset *model = [(JYForceTouchPreviewController *)viewControllerToCommit model];
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (CGSize)getSize:(JYAsset *)model
{
    CGFloat w = MIN(model.asset.pixelWidth, kViewWidth);
    CGFloat h = w * model.asset.pixelHeight / model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kViewHeight || isnan(h)) {
        h = kViewHeight;
        w = h * model.asset.pixelWidth / model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
}

#pragma mark - util

-(NSString *)getDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}

-(NSString *)getMouthDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    //    NSLog(@"%@",dateString);
    if ([dateString isEqualToString: @"1970年01月"]) {
        dateString = @"未知时间";
    }
    return dateString;
}


#pragma mark - Add Indicator

bool isAnimation = NO;
bool isDecelerating = NO;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    isDecelerating = YES;
    
    if (self.showIndicator) {
        if (!self.collectionView.indicator) {
            //导航按钮
            [self.collectionView registerILSIndicator];
            [self.collectionView.indicator.slider addObserver:self forKeyPath:@"sliderState" options:0x01 context:nil];
        }else {
            if (!isAnimation) {
                self.collectionView.indicator.transform = CGAffineTransformIdentity;
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.collectionView.indicator.transform = CGAffineTransformIdentity;
                });
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self hiddenIndicator];
}

-(void)hiddenIndicator{
    if (self.showIndicator) {
        if (self.collectionView.indicator.slider.sliderState == UIControlStateNormal && CGAffineTransformIsIdentity(self.collectionView.indicator.transform)) {
            isDecelerating = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(!isDecelerating){
                    isAnimation = YES;
                    [UIView animateWithDuration:0.5 animations:^{
                        self.collectionView.indicator.transform = CGAffineTransformMakeTranslation(40, 0);
                    }completion:^(BOOL finished) {
                        isAnimation = NO;
                        isDecelerating = NO;
                    }];
                    
                }
            });
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate) [self hiddenIndicator];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self hiddenIndicator];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (self.showIndicator) {
        if ([keyPath isEqualToString:@"sliderState"]) {
            if (self.collectionView.indicator.slider.sliderState == UIControlStateNormal && CGAffineTransformIsIdentity(self.collectionView.indicator.transform)) {
                isDecelerating = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(!isDecelerating){
                        isAnimation = YES;
                        [UIView animateWithDuration:0.5 animations:^{
                            self.collectionView.indicator.transform = CGAffineTransformMakeTranslation(40, 0);
                        }completion:^(BOOL finished) {
                            isAnimation = NO;
                            isDecelerating = NO;
                        }];
                    }
                });
            }else
                isDecelerating = YES;
        }
    }
}

-(void)dealloc{
    if (self.collectionView.indicator) {
        [self.collectionView.indicator.slider removeObserver:self forKeyPath:@"sliderState"];
        [self removeObserver:self.collectionView.indicator forKeyPath:@"contentOffset"];
    }
}

@end
