//
//  JYCollectionViewCell.m
//  Photos
//
//  Created by JackYang on 2017/9/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYCollectionViewCell.h"
#import "JYAsset.h"
#import "PHPhotoLibrary+JYEXT.h"
#import "JYConst.h"
#import "UIImage+imageWithColor.h"

@interface JYCollectionViewCell ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, weak) id<SDWebImageOperation> thumbnailRequestOperation;
@end

@implementation JYCollectionViewCell

- (void)dealloc{
//    NSLog(@"---- %s ", __FUNCTION__);
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.imageView.backgroundColor = UICOLOR_RGB(0xf5f5f5);
    self.imageView.image = [UIImage imageNamed:@"F5F5F5.png"];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]) {
        UILongPressGestureRecognizer * longGesture =
        [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongGesture:)];
        longGesture.minimumPressDuration = 0.5f;
        [self.contentView addGestureRecognizer:longGesture];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)handleLongGesture:(UILongPressGestureRecognizer * )gesture{
    if (gesture.state == UIGestureRecognizerStateBegan && _longPressBlock) _longPressBlock();
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    _btnSelect.frame = CGRectMake(GetViewWidth(self.contentView)-26, 5, 23, 23);
    self.contentView.backgroundColor = UICOLOR_RGB(0xf5f5f5);

    _videoBottomView.frame = CGRectMake(0, GetViewHeight(self.contentView)-20, GetViewWidth(self.contentView), 20);
    [self.videoBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.top.mas_equalTo(self.contentView.mas_bottom).offset(-20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.videoBottomView.mas_left).offset(5);
        make.top.mas_equalTo(self.videoBottomView.mas_top).offset(2);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    _timeLabel.frame = CGRectMake(30, 4, GetViewWidth(self.contentView)-35, 12);
    _liveImageView.frame = CGRectMake(5, 2, 16, 16);
//    if (self.showMask) {
//        self.topView.frame = self.bounds;
//    }
//    self.videoBottomView.frame = CGRectMake(0, GetViewHeight(self)-15, GetViewWidth(self), 15);
//    self.videoImageView.frame = CGRectMake(5, 1, 16, 12);
//    self.liveImageView.frame = CGRectMake(5, -1, 15, 15);
//    self.timeLabel.frame = CGRectMake(30, 1, GetViewWidth(self)-35, 12);
//    [self.contentView sendSubviewToBack:self.imageView];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.image = [UIImage imageNamed:@"F5F5F5.png"];
        self.contentView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
//        [self.contentView bringSubviewToFront:_topView];
        [self.contentView bringSubviewToFront:self.videoBottomView];
        [self.contentView bringSubviewToFront:self.btnSelect];
    }
    return _imageView;
}

- (UIButton *)btnSelect
{
    if (!_btnSelect) {
        _btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSelect.frame = CGRectMake(GetViewWidth(self.contentView)-26, 5, 23, 23);
        [_btnSelect setBackgroundImage:ImageWithName(@"select.png") forState:UIControlStateNormal];
        [_btnSelect addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        //扩大点击区域
//        [_btnSelect setEnlargeEdgeWithTop:0 right:0 bottom:20 left:20];
        [self.contentView addSubview:self.btnSelect];
    }
    return _btnSelect;
}

- (UIImageView *)videoBottomView
{
    if (!_videoBottomView) {
        _videoBottomView = [[UIImageView alloc] initWithImage:nil];
        _videoBottomView.frame = CGRectMake(0, GetViewHeight(self)-20, GetViewWidth(self), 20);
        [self.contentView addSubview:_videoBottomView];
    }
    return _videoBottomView;
}

- (UIImageView *)videoImageView
{
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2, 16, 16)];
        _videoImageView.image = [UIImage imageNamed:@"ic_play"];
        [self.videoBottomView addSubview:_videoImageView];
    }
    return _videoImageView;
}

- (UIImageView *)liveImageView
{
    if (!_liveImageView) {
        _liveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2, 16, 16)];
        _liveImageView.image = [UIImage imageNamed:@"livePhoto"];
        [self.videoBottomView addSubview:_liveImageView];
    }
    return _liveImageView;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 4, GetViewWidth(self)-35, 12)];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor whiteColor];
        [self.videoBottomView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.userInteractionEnabled = NO;
        _topView.hidden = YES;
        [self.contentView addSubview:_topView];
    }
    return _topView;
}

- (void)setModel:(JYAsset *)model
{
    _model = model;
    
    if (model.type == JYAssetTypeVideo) {
        self.videoBottomView.hidden = NO;
        self.videoImageView.hidden = NO;
        self.liveImageView.hidden = YES;
        self.timeLabel.text = model.duration;
    }
    else if(model.type == JYAssetTypeNetVideo) {
        self.videoBottomView.hidden = NO;
        self.videoImageView.hidden = NO;
        self.liveImageView.hidden = YES;
        self.timeLabel.text = model.duration;
    }else if (model.type == JYAssetTypeLivePhoto) {
        self.videoBottomView.hidden = NO;
        self.videoImageView.hidden = YES;
        self.liveImageView.hidden = NO;
        self.timeLabel.text = @"Live";
    } else{
        self.videoImageView.hidden = YES;
        self.videoBottomView.hidden = YES;
        self.liveImageView.hidden = YES;
    }
//    else if (model.type == JYMediaTypeGif) {
//        self.videoBottomView.hidden = !self.allSelectGif;
//        self.videoImageView.hidden = YES;
//        self.liveImageView.hidden = YES;
//        self.timeLabel.text = @"GIF";
//    } else if (model.type == JYMediaTypeLivePhoto) {
//        self.videoBottomView.hidden = !self.allSelectLivePhoto;
//        self.videoImageView.hidden = YES;
//        self.liveImageView.hidden = NO;
//        self.timeLabel.text = @"Live";
//    } else {
//        self.videoBottomView.hidden = YES;
//    }
    
//    if (self.showMask) {
//        self.topView.backgroundColor = [self.maskColor colorWithAlphaComponent:.2];
//        self.topView.hidden = !model.isSelected;
//    }
    
    CGSize size;
    size.width = GetViewWidth(self) * 1.7 ;
    size.height = GetViewHeight(self) * 1.7;
    
    jy_weakify(self);
    if (self.imageRequestID >= PHInvalidImageRequestID) [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    
    if (self.thumbnailRequestOperation)
        [self.thumbnailRequestOperation cancel];
    self.thumbnailRequestOperation = nil;
    
    if(model.asset)
        self.identifier = model.asset.localIdentifier;
    else
        self.identifier = [(WBAsset *)model fmhash];
    self.imageView.image = nil;
    if(model.asset)
        self.imageRequestID = [PHPhotoLibrary requestImageForAsset:model.asset size:size completion:^(UIImage *image, NSDictionary *info) {
            if ([weakSelf.identifier isEqualToString:model.asset.localIdentifier]) {
                weakSelf.imageView.image = image;
            }
            if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                weakSelf.imageRequestID = -1;
            }
        }];
    else {
        id <SDWebImageOperation> thumbnailRequestOperation = [WB_NetService getThumbnailWithHash:[(WBAsset *)model fmhash] complete:^(NSError *error, UIImage *img) {
            if (!error && [weakSelf.identifier isEqualToString:[(WBAsset *)model fmhash]]) {
                weakSelf.imageView.image = img;
            }else
                NSLog(@"get thumbnail error ---> : %@", error);
            weakSelf.thumbnailRequestOperation = nil;
        }];
        self.thumbnailRequestOperation = thumbnailRequestOperation;
    }
}

- (void)setIsSelect:(BOOL)isSelect animation:(BOOL)animat {
    _isSelect = isSelect;
    self.btnSelect.hidden = !_isSelect;
    if (_isSelect) {
        if(animat) {
            [self.btnSelect.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        }
            self.imageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }else{
        self.imageView.transform = CGAffineTransformIdentity;
    }
    
}

- (void)btnSelectClick:(UIButton *)sender {
    if(!self.isSelectMode) return;
    [self setIsSelect:!_isSelect animation:YES];
    if(_selectedBlock) _selectedBlock(_isSelect);
}

@end
