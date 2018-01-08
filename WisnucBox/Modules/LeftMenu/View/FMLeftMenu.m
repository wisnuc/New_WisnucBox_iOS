//
//  FMLeftMenu.m
//  MenuDemo
//
//  Created by 杨勇 on 16/7/1.
//  Copyright © 2016年 Lying. All rights reserved.
//

#import "FMLeftMenu.h"
#import "FMLeftMenuCell.h"
#import "FMLeftUserCell.h"
#import "FMLeftUserFooterView.h"
#import "FMUserLoginViewController.h"
//#import "FMUploadFileAPI.h"

@interface FMLeftMenu ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *versionLb;
@property (weak, nonatomic) IBOutlet UIButton *userBtn1;
@property (weak, nonatomic) IBOutlet UIButton *userBtn2;
@property (strong, nonatomic) WBUser *userInfo;
@property (strong, nonatomic) UIProgressView *backUpProgressView;
@property (strong, nonatomic) UILabel *progressLabel;

@end

@implementation FMLeftMenu

-(void)awakeFromNib{
   
    [super awakeFromNib];
    _settingTabelView.delegate = self;
    _settingTabelView.dataSource = self;
    
    _usersTableView.dataSource = self;
    _usersTableView.delegate = self;
    _isUserTableViewShow = NO;
    
    _settingTabelView.scrollEnabled = NO;
 

    _userBtn1.layer.cornerRadius = 20;
    _userBtn2.layer.cornerRadius = 20;
    
    
    self.userHeaderIV.userInteractionEnabled = YES;
    [self.userHeaderIV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeader:)]];
//    _backupLabel.text = WBLocalizedString(@"backup_closed", nil);
    _progressLabel = [[UILabel alloc]init];
    _progressLabel.text = @"         ";
    _progressLabel.textColor = [UIColor colorWithRed:236 green:236 blue:236 alpha:1];
    _progressLabel.font = [UIFont systemFontOfSize:12];
    _progressLabel.textAlignment = NSTextAlignmentRight;
    _progressLabel.preferredMaxLayoutWidth = (self.frame.size.width -10.0 * 2);
    [_progressLabel  setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:_progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-16);
        make.centerY.equalTo(_backupLabel.mas_centerY);
        make.height.equalTo(@40);
    }];
    
     _backUpProgressView = [[UIProgressView alloc]init];
    [self addSubview:_backUpProgressView];
    [_backUpProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backupLabel.mas_right).offset(16);
        make.height.equalTo(@2);
        make.centerY.equalTo(_backupLabel.mas_centerY);
        make.right.equalTo(_progressLabel.mas_left).offset(-16);
    }];
    _backUpProgressView.hidden = YES;
    
    [self getUserInfo];
    WBUser * currentUser = [AppServices sharedService].userServices.currentUser;
    if(!currentUser.autoBackUp)
        self.backupLabel.text = WBLocalizedString(@"backup_closed", nil);
    
    if (WB_UserService.currentUser.avaterURL) {
        self.nameLabel.text = _userInfo.userName;
        NSString *avatarUrl = currentUser.avaterURL;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:avatarUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.userHeaderIV.image = [self imageCirclewithImage:image];
             });
        }];
    }else{
        self.nameLabel.text = _userInfo.userName;
        self.userHeaderIV.image = [UIImage imageForName:self.nameLabel.text size:self.userHeaderIV.bounds.size];
    }
    
    [self.dropDownBtn setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
    
    if (WB_UserService.currentUser.isCloudLogin) {
        self.cloudImageView.hidden = NO;
        [self.dropDownBtn setHidden:YES];
    }else{
        self.cloudImageView.hidden = YES;
        [self.dropDownBtn setHidden:NO];
    }

//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/lookup?id=1132191394"];
//    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@", [AppServices sharedService].userServices.defaultToken] forHTTPHeaderField:@"Authorization"];
//    [manager POST:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSArray *array = responseObject[@"results"];
//        NSDictionary *dict = [array lastObject];
//        NSString *app_Version = dict[@"version"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versionLb.text = [NSString stringWithFormat:@"WISNUC %@",app_Version];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];

     dispatch_async(dispatch_get_main_queue(), ^{

         UILabel * progressLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, __kWidth, 15)];
         progressLb.font = [UIFont systemFontOfSize:12];
         progressLb.textAlignment = NSTextAlignmentCenter;
//         self.nameLabel.font = [UIFont fontWithName:DONGQING size:14];
     });
    
}

- (UIImage *)imageCirclewithImage:(UIImage *)image{
    UIImage *originImage = image;
    UIGraphicsBeginImageContext(originImage.size);
    UIBezierPath *path =[UIBezierPath bezierPathWithOvalInRect:CGRectMake( 0, 0, image.size.width, image.size.height)];
   
    [path addClip];

    [originImage drawAtPoint:CGPointZero];
    originImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return originImage;
}

- (IBAction)smallBtnClick:(id)sender {
    if (sender == _userBtn1) {
        [self.delegate LeftMenuViewClickUserTable:self.usersDatasource[_userBtn2.hidden?0:1]];
    }else{
        [self.delegate LeftMenuViewClickUserTable:self.usersDatasource[0]];
    }
}

-(void)setUsersDatasource:(NSMutableArray *)usersDatasource{
    
    _usersDatasource = usersDatasource;
    if (usersDatasource.count) {
        if (usersDatasource.count == 1) { //等于1
            _userBtn1.hidden = NO;
            _userBtn2.hidden = YES;
            [_userBtn1 setBackgroundImage:[UIImage imageForName:((WBUser *)usersDatasource[0]).userName size:_userBtn1.bounds.size] forState:UIControlStateNormal];
        }else{ // 大于 1
            _userBtn1.hidden = NO;
            _userBtn2.hidden = NO;
            [_userBtn1 setBackgroundImage:[UIImage imageForName:((WBUser *)usersDatasource[1]).userName size:_userBtn1.bounds.size] forState:UIControlStateNormal];
            [_userBtn2 setBackgroundImage:[UIImage imageForName:((WBUser *)usersDatasource[0]).userName size:_userBtn2.bounds.size] forState:UIControlStateNormal];
        }
    }else{
        _userBtn1.hidden = YES;
        _userBtn2.hidden = YES;
    }
}

-(void)checkToStart{
    if (_isUserTableViewShow) {
        [self dropDownBtnClick:_dropDownBtn];
    }
}


- (IBAction)dropDownBtnClick:(id)sender {
    _isUserTableViewShow = !_isUserTableViewShow;
    @weaky(self);
    if (_isUserTableViewShow) {
        ((UIButton *)sender).transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.3 animations:^{
            weak_self.usersTableView.alpha = 1;
            weak_self.userBtn1.alpha = 0;
            weak_self.userBtn2.alpha = 0;
            [weak_self.usersTableView reloadData];
        } completion:nil];
    }else{
        ((UIButton *)sender).transform = CGAffineTransformIdentity;
        NSMutableArray * tempArr = self.menus;
        self.menus = [NSMutableArray new];
        [_settingTabelView reloadData];
        self.menus = tempArr;
        [UIView animateWithDuration:0.3 animations:^{
            weak_self.usersTableView.alpha = 0;
            [weak_self.settingTabelView reloadData];
            weak_self.userBtn1.alpha = 1;
            weak_self.userBtn2.alpha = 1;
        } completion:^(BOOL finished) {
            NSMutableArray * tmpA = weak_self.usersDatasource;
            weak_self.usersDatasource = [NSMutableArray new];
            [weak_self.usersTableView reloadData];
            weak_self.usersDatasource = tmpA;
        }];
    }
}

- (void)tapHeader:(id)sender {
    if(WB_IS_DEBUG) {
        NSString * s = [NSString stringWithFormat:@"当前已上传：%ld张, 错误：%ld 张， 正在上传：%ld 张， 正在等待：%ld 张", WB_PhotoUploadManager.uploadedQueue.count, WB_PhotoUploadManager.uploadErrorQueue.count, WB_PhotoUploadManager.uploadingQueue.count, WB_PhotoUploadManager.uploadPaddingQueue.count];
        [SXLoadingView showAlertHUD:s duration:2];
    }
    if(self.delegate){
        [self.delegate LeftMenuViewClickSettingTable:10 andTitle:@"个人信息"];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self getUserInfo];
    self.bonjourLabel.text = _userInfo.bonjour_name;
//    if (![AppServices sharedService].userServices.currentUser.isCloudLogin) {
//        self.userHeaderIV.image = [UIImage imageForName:self.nameLabel.text size:self.userHeaderIV.bounds.size];
//    }
    self.nameLabel.text = [AppServices sharedService].userServices.currentUser.userName;
//    [cell.contentView addSubview:progressLb];
//    progressLb.hidden = !_displayProgress;

}
-(NSString *)notRounding:(float)price afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

- (void)updateProgressWithAllCount:(NSInteger)allcount currentCount:(NSInteger)currentCount  complete:(void(^)(void))callback{
    dispatch_async(dispatch_get_main_queue(), ^{
        _backUpProgressView.hidden = NO;
    });
    float progress =  (float)currentCount/(float)allcount;
    NSDecimalNumber *progressDecimalNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self notRounding:progress afterPoint:2]]];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:@"100"];
    
    NSDecimalNumber *mutiplyDecimal;
    if ([progressDecimalNumber compare:[NSDecimalNumber zero]] == NSOrderedSame || [[NSDecimalNumber notANumber] isEqualToNumber:progressDecimalNumber]) {
        mutiplyDecimal = [NSDecimalNumber zero];
    }else{
        mutiplyDecimal = [progressDecimalNumber decimalNumberByMultiplyingBy:decimalNumber];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backupLabel.text = [NSString stringWithFormat:@"%@%@%%",WBLocalizedString(@"already_upload_media_percent_text", nil),mutiplyDecimal];
        self.backUpProgressView.progress = progress;
        self.progressLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)currentCount, (unsigned long)allcount];
        NSLog(@"已上传：%@/本地照片总数:%lu",self.progressLabel.text, (unsigned long)allcount);
        callback();
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView == _settingTabelView)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _settingTabelView){
        if (section == 0) {
            return 1;
        }
        return self.menus.count - 1;
    }else
        return self.usersDatasource.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _settingTabelView) {
        FMLeftMenuCell *cell  = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMLeftMenuCell class])];
        if (!cell) {
         cell  = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FMLeftMenuCell class]) owner:self options:nil] lastObject];
        }
       
        if (indexPath.section == 0) {
            cell.leftLine.backgroundColor = [UIColor blackColor];
            [cell setData:_menus[indexPath.row] andImageName:_imageNames[indexPath.row]];
        }else{
            [cell setData:_menus[indexPath.row + 1] andImageName:_imageNames[indexPath.row + 1]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
         FMLeftUserCell *cell  = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMLeftUserCell class])];
        if (!cell) {
             cell =  [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FMLeftUserCell class]) owner:self options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        WBUser * info =  self.usersDatasource[indexPath.row];
        cell.userNameLb.text = info.userName;
        cell.deviceNameLb.text = info.bonjour_name;
        cell.userHeader.image = [UIImage imageForName:info.userName size:cell.userHeader.bounds.size];
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _settingTabelView){
        if(self.delegate){
            [self.delegate LeftMenuViewClickSettingTable:indexPath.section == 0? indexPath.row:indexPath.row+1 andTitle:indexPath.section == 0? self.menus[indexPath.row]:self.menus[indexPath.row+1]];
        }
    }else{
        if(self.delegate){
            [self.delegate LeftMenuViewClickUserTable:self.usersDatasource[indexPath.row]];
            [self checkToStart];
        }
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView;
    if (_settingTabelView == tableView) {
        footerView = [UIView new];
        footerView.backgroundColor = [UIColor whiteColor];
    }else{
    @weaky(self);
    footerView = [FMLeftUserFooterView footerViewWithTouchBlock:^{
        if(weak_self.delegate){
            [weak_self.delegate LeftMenuViewClickSettingTable:-1 andTitle:@"USER_FOOTERVIEW_CLICK"];
            [weak_self checkToStart];
        }
    }];
    }
    return footerView;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * headerView = [UIView new];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_settingTabelView == tableView) {
        if (section == 1) {
            return 8;
        }else{
            return 0;
        }
    }else{
        return 0.1;
    }
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_settingTabelView == tableView) {
        return 8;
    }else{
       return 64;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _settingTabelView){
        if(indexPath.section == 0 )
            return 72;
        return  [FMLeftMenuCell height];
    }else{
        return [FMLeftUserCell height];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    double delay = (indexPath.row*indexPath.row) * 0.004;  //Quadratic time function for progressive delay
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.95, 0.95);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0,(tableView == _settingTabelView?1:-1)*(indexPath.row+1)*CGRectGetHeight(cell.contentView.frame));
    cell.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    cell.alpha = 0.f;
    
    [UIView animateWithDuration:0.6/2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         cell.transform = CGAffineTransformIdentity;
         cell.alpha = 1.f;
         
     } completion:nil];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 64;
//         if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//             scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//         } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//             scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//         }
//}

- (void)getUserInfo{
   _userInfo = [AppServices sharedService].userServices.currentUser;
}

- (void)dealloc
{
    NSLog(@"FMLeftMenu dealloc");
}

- (UILabel *)backupLabel{
    if (!_backupLabel) {
        
    }
    return _backupLabel;
}


@end
