//
//  WBUpgradeAppfiViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBUpgradeAppfiViewController.h"
#import "WBGetUpgradStateAPI.h"
#import "WBGetUpgradStateModel.h"
#import "WBInstallUpgradeAPI.h"
#import "WBUpgradeDownloadAPI.h"

@interface WBUpgradeAppfiViewController (){
    NSInteger _updateCount;
}
@property (nonatomic)UIImageView *firmwareNowleftImage;
@property (nonatomic)UILabel *firmwareNowTitleLabel;
@property (nonatomic)UILabel *firmwareNowStateLabel;

@property (nonatomic)UIView *firstLineView;

@property (nonatomic)UIImageView *firmwareUpdateleftImage;
@property (nonatomic)UILabel *firmwareUpdateTitleLabel;
@property (nonatomic)UILabel *firmwareUpdateStateLabel;
@property (nonatomic)UIButton *installUpdateButton;
@property (nonatomic)UILabel *releaseTimeLabel;

@property (nonatomic)UIView *secondLineView;

@property (nonatomic)NSString *tagName;

@property (nonatomic)NSTimer*timer;

@property (nonatomic)BOOL isFailed;

@property (nonatomic)MDCFlatButton *updateCheckButton;


@end

@implementation WBUpgradeAppfiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"固件升级";
    _isFailed = NO;
    [SXLoadingView showProgressHUD:@"检查更新中..."];
    _updateCount = 0;
    [self getData];
    [self.view addSubview:self.firmwareNowleftImage];
    [self.view addSubview:self.firmwareNowTitleLabel];
    [self.view addSubview:self.firmwareNowStateLabel];
//    [self.view addSubview:self.stopAppifiButton];
    [self.view addSubview:self.firstLineView];
    
    [self.view addSubview:self.firmwareUpdateleftImage];
    [self.view addSubview:self.firmwareUpdateTitleLabel];
    [self.view addSubview:self.firmwareUpdateStateLabel];
    [self.view addSubview:self.installUpdateButton];
    [self.view addSubview:self.releaseTimeLabel];
    [self.view addSubview:self.secondLineView];
    [self.view addSubview:self.updateCheckButton];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)dealloc{
    
}

- (void)getData{
    @weaky(self)
    NSString *urlString = [NSString stringWithFormat:@"%@",WB_UserService.currentUser.sn_address];
    NSLog(@"%@",urlString);
    if (!WB_UserService.currentUser.sn_address) {
        return;
    }
    [[WBGetUpgradStateAPI apiWithURLPath:urlString] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.responseJsonObject);
        WBGetUpgradStateModel *model = [WBGetUpgradStateModel modelWithJSON:request.responseJsonObject];
        if ([model.fetch.state isEqualToString:@"Pending"]) {
            [weak_self updateDataWithModel:model];
            NSLog(@"%@",model.appifi.tagName);
            [SXLoadingView showProgressHUDText:@"检查更新完毕" duration:1.2f];
        }else{
            _updateCount ++;
            if (_updateCount<=3) {
                [weak_self performSelector:@selector(getData) withObject:nil afterDelay:5];
            }else{
                [SXLoadingView showProgressHUDText:@"检查更新失败" duration:1.2f];
                [weak_self errorAction];
            }
        }
    } failure:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.error);
         [SXLoadingView showProgressHUDText:@"检查更新失败" duration:1.2f];
         [weak_self errorAction];
    }];
}

- (void)getStateData{
    @weaky(self)
    
    NSString *urlString = [NSString stringWithFormat:@"%@",WB_UserService.currentUser.sn_address];
    if (!WB_UserService.currentUser.sn_address) {
        return;
    }
    NSLog(@"%@",urlString);
    [[WBGetUpgradStateAPI apiWithURLPath:urlString] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        NSLog(@"%@",request.responseJsonObject);
        WBGetUpgradStateModel *model = [WBGetUpgradStateModel modelWithJSON:request.responseJsonObject];
        if ([model.fetch.state isEqualToString:@"Pending"]) {
            [weak_self updateDataWithModel:model];
            NSLog(@"%@",model.appifi.tagName);
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
       [weak_self errorAction];
    }];
}

- (void)errorAction{
   [self.firmwareNowStateLabel setHidden:YES];
   [self.firstLineView setHidden:YES];
    
   [self.firmwareUpdateleftImage setHidden:YES];
   [self.firmwareUpdateTitleLabel setHidden:YES];
   [self.firmwareUpdateStateLabel setHidden:YES];
   [self.installUpdateButton setHidden:YES];
   [self.releaseTimeLabel setHidden:YES];
   [self.secondLineView setHidden:YES];
  _updateCheckButton.frame = CGRectMake(CGRectGetMinX(_firmwareNowTitleLabel.frame), CGRectGetMaxY(_firmwareUpdateTitleLabel.frame) + 16, 100, 40);
    _firmwareNowTitleLabel.text = @"获取固件信息失败";
}


- (void)normalAction{
    [self.firmwareNowStateLabel setHidden:NO];
    [self.firstLineView setHidden:NO];
    
    [self.firmwareUpdateleftImage setHidden:NO];
    [self.firmwareUpdateTitleLabel setHidden:NO];
    [self.firmwareUpdateStateLabel setHidden:NO];
    [self.installUpdateButton setHidden:NO];
    [self.releaseTimeLabel setHidden:NO];
    [self.secondLineView setHidden:NO];
    _updateCheckButton.frame = CGRectMake(CGRectGetMinX(_firmwareNowTitleLabel.frame), CGRectGetMaxY(_secondLineView.frame), 100, 40);
    _firmwareNowTitleLabel.text = @"当前使用的固件版本:";
}

- (void)updateDataWithModel:(WBGetUpgradStateModel *)model{
    [self normalAction];
    _firmwareNowTitleLabel.text = [NSString stringWithFormat:@"当前使用的固件版本:%@",model.appifi.tagName];
    if ([model.appifi.state isEqualToString:@"Started"]) {
        _firmwareNowStateLabel.text = @"运行中";
      
    }else if ([model.appifi.state isEqualToString:@"Starting"]){
        _firmwareNowStateLabel.text = @"正在启动";
     
    }else if ([model.appifi.state isEqualToString:@"Stopping"]){
        _firmwareNowStateLabel.text = @"正在关闭";
    
    }else if ([model.appifi.state isEqualToString:@"Stopped"]){
         _firmwareNowStateLabel.text = @"已关闭";
    }
    
    
    NSLog(@"%@",model.releases);
    WBGetUpgradStateReleasesModel *releaseModel;
    if (model.releases.count >0) {
     releaseModel = model.releases [0];
    _installUpdateButton.frame = CGRectMake(CGRectGetMinX(_firmwareUpdateTitleLabel.frame), CGRectGetMaxY(_firmwareUpdateTitleLabel.frame) + 8, 60, 30);
        if ([releaseModel.state isEqualToString:@"Idle"]) {
            _firmwareUpdateStateLabel.text = @"已安装";
            _installUpdateButton.frame = CGRectMake(CGRectGetMinX(_firmwareUpdateTitleLabel.frame), CGRectGetMaxY(_firmwareUpdateTitleLabel.frame) + 8, __kWidth - CGRectGetMinX(_firmwareUpdateTitleLabel.frame) , 30);
            _installUpdateButton.enabled = NO;
        }else if ([releaseModel.state isEqualToString:@"Failed"]){
            _firmwareUpdateStateLabel.text = @"下载失败";
            _installUpdateButton.enabled = YES;
            [_installUpdateButton setTitle:@"重试" forState:UIControlStateNormal];
            _isFailed = YES;
        }else if ([releaseModel.state isEqualToString:@"Ready"]){
            _firmwareUpdateStateLabel.text = @"已下载";
            _installUpdateButton.enabled = YES;
        }else if ([releaseModel.state isEqualToString:@"Downloading"]){
            _firmwareUpdateStateLabel.text = @"正在下载";
            _installUpdateButton.enabled = YES;
            if (!_timer) {
                [self.timer fire];
            }
        }else if ([releaseModel.state isEqualToString:@"Repacking"]){
            _firmwareUpdateStateLabel.text = @"打包中";
            _installUpdateButton.enabled = YES;
        }else if ([releaseModel.state isEqualToString:@"Verifying"]){
            _firmwareUpdateStateLabel.text = @"验证中";
            _installUpdateButton.enabled = YES;
        }
    }
   
  
    if (releaseModel.remote) {
        NSLog(@"%f/%f",[model.appifi.tagName doubleValue],[releaseModel.remote.tag_name doubleValue]);
        
         if (![model.appifi.tagName isEqualToString:releaseModel.remote.tag_name]) {
        _firmwareUpdateTitleLabel.text = [NSString stringWithFormat:@"发现新版本:%@",releaseModel.remote.tag_name];
         _tagName = releaseModel.remote.tag_name;
        _releaseTimeLabel.text = [NSString stringWithFormat:@"发布日期:%@",[CSDateUtil getLocalDateFormateUTCDate:releaseModel.remote.published_at]];
         }else if ([model.appifi.tagName floatValue] ==[releaseModel.remote.tag_name floatValue]){
             [UIView animateWithDuration:0.3f animations:^{
                 _installUpdateButton.alpha = 0;
                 _firmwareUpdateStateLabel.alpha = 0;
                 _firmwareUpdateTitleLabel.text = @"已是最新稳定版";
                 _firmwareUpdateleftImage.image = [UIImage imageNamed:@"update_done.png"];
                 _secondLineView.alpha = 0;
                 _releaseTimeLabel.alpha = 0;
                 _updateCheckButton.frame = CGRectMake(CGRectGetMinX(_firmwareNowTitleLabel.frame), CGRectGetMaxY(_firmwareUpdateTitleLabel.frame) + 16, 100, 40);
             }];
         }
    }else{
        if (![model.appifi.tagName isEqualToString:releaseModel.remote.tag_name]) {
       _firmwareUpdateTitleLabel.text = [NSString stringWithFormat:@"发现新版本:%@",releaseModel.local.tag_name];
        _tagName = releaseModel.local.tag_name;
        _releaseTimeLabel.text = [NSString stringWithFormat:@"发布日期:%@",[CSDateUtil getLocalDateFormateUTCDate:releaseModel.local.published_at]];
        }if ([model.appifi.tagName floatValue] ==[releaseModel.local.tag_name floatValue]){
            [UIView animateWithDuration:0.3f animations:^{
                _installUpdateButton.alpha = 0;
                _firmwareUpdateStateLabel.alpha = 0;
                _firmwareUpdateTitleLabel.text = @"已是最新稳定版";
                _firmwareUpdateleftImage.image = [UIImage imageNamed:@"update_done.png"];
                _secondLineView.alpha = 0;
                _releaseTimeLabel.alpha = 0;
                
            }];
        }
    }
   
}

- (void)updateCheckButtonClick:(UIButton *)sender{
    [SXLoadingView showProgressHUD:@"正在检查更新"];
    [self getData];
}

//- (void)stopAppifiButtonClick:(MDCFlatButton *)sender{
//    [SXLoadingView showProgressHUD:@""];
//    [[WBInstallUpgradeAPI apiWithURLPath:WB_UserService.currentUser.sn_address RequestMethod:@"PATCH" State:@"Stopped"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//
//        NSLog(@"%@",request.responseJsonObject);
//
//        [SXLoadingView showProgressHUDText:@"已停止" duration:1.5f];
//    } failure:^(__kindof JYBaseRequest *request) {
//        NSLog(@"%@",request.error);
//        [SXLoadingView hideProgressHUD];
//    }];
//}

- (void)installUpdateButtonClick:(MDCFlatButton *)sender{
    [SXLoadingView showProgressHUD:@""];
    if ([sender.titleLabel.text containsString:@"重试"]) {
        [[WBUpgradeDownloadAPI apiWithURLPath:WB_UserService.currentUser.sn_address State:@"Ready" TagName:_tagName]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
            [SXLoadingView hideProgressHUD];
        }];
    }else if ([sender.titleLabel.text containsString:@"安装"]){
    [[WBInstallUpgradeAPI apiWithURLPath:WB_UserService.currentUser.sn_address RequestMethod:@"PUT" TagName:_tagName]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        
        NSLog(@"%@",request.responseJsonObject);
        if (!_timer) {
             [self.timer fire];
        }
        [SXLoadingView hideProgressHUD];
    } failure:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.error);
         [SXLoadingView hideProgressHUD];
    }];
    }
}

- (UIImageView *)firmwareNowleftImage{
    if (!_firmwareNowleftImage) {
        _firmwareNowleftImage = [[UIImageView alloc]initWithFrame:CGRectMake(16, 8+8, 24, 24)];
        _firmwareNowleftImage.image = [UIImage imageNamed:@"system_update.png"];
    }
    return _firmwareNowleftImage;
}

- (UILabel *)firmwareNowTitleLabel{
    if (!_firmwareNowTitleLabel) {
        _firmwareNowTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firmwareNowleftImage.frame) + 32, 8 +2 +8, 200, 20)];
        _firmwareNowTitleLabel.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        _firmwareNowTitleLabel.adjustsFontSizeToFitWidth = YES;
        _firmwareNowTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        _firmwareNowTitleLabel.text = @"当前使用的固件版本:";
//        _firmwareNowTitleLabel.backgroundColor = [UIColor orangeColor];
    }
    return _firmwareNowTitleLabel;
}

- (UILabel *)firmwareNowStateLabel{
    if (!_firmwareNowStateLabel) {
        _firmwareNowStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firmwareNowTitleLabel.frame) + 4,CGRectGetMinY(_firmwareNowTitleLabel.frame) , 44, 20)];
        _firmwareNowStateLabel.textColor = COR1;
        _firmwareNowStateLabel.adjustsFontSizeToFitWidth = YES;
        _firmwareNowStateLabel.textAlignment = NSTextAlignmentCenter;
        _firmwareNowStateLabel.font = [UIFont systemFontOfSize:14];
        _firmwareNowStateLabel.layer.masksToBounds = YES;
        _firmwareNowStateLabel.layer.borderWidth = 1;
        _firmwareNowStateLabel.layer.borderColor = COR1.CGColor;
    }
    return _firmwareNowStateLabel;
}


- (UIView *)firstLineView{
    if (!_firstLineView) {
        _firstLineView = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_firmwareNowStateLabel.frame) + 16, __kWidth, 0.5)];
        _firstLineView.backgroundColor = LINECOLOR;
    }
    return _firstLineView;
}

- (UIImageView *)firmwareUpdateleftImage{
    if (!_firmwareUpdateleftImage) {
        _firmwareUpdateleftImage = [[UIImageView alloc]initWithFrame:CGRectMake(16, CGRectGetMaxY(_firstLineView.frame)+8, 24, 24)];
        _firmwareUpdateleftImage.image = [UIImage imageNamed:@"new_releases.png"];
    }
    return _firmwareUpdateleftImage;
}

- (UILabel *)firmwareUpdateTitleLabel{
    if (!_firmwareUpdateTitleLabel) {
        _firmwareUpdateTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firmwareUpdateleftImage.frame) + 32, CGRectGetMaxY(_firstLineView.frame)+2 +8, 130, 20)];
        _firmwareUpdateTitleLabel.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        _firmwareUpdateTitleLabel.adjustsFontSizeToFitWidth = YES;
        _firmwareUpdateTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        _firmwareUpdateTitleLabel.text = @"发现新版本:";
        //        _firmwareNowTitleLabel.backgroundColor = [UIColor orangeColor];
    }
    return _firmwareUpdateTitleLabel;
}

- (UILabel *)firmwareUpdateStateLabel{
    if (!_firmwareUpdateStateLabel) {
        _firmwareUpdateStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firmwareUpdateTitleLabel.frame) + 4,CGRectGetMinY(_firmwareUpdateTitleLabel.frame) , 60, 20)];
        _firmwareUpdateStateLabel.textColor = COR1;
        _firmwareUpdateStateLabel.adjustsFontSizeToFitWidth = YES;
        _firmwareUpdateStateLabel.textAlignment = NSTextAlignmentCenter;
        _firmwareUpdateStateLabel.font = [UIFont systemFontOfSize:14];
        _firmwareUpdateStateLabel.layer.masksToBounds = YES;
        _firmwareUpdateStateLabel.layer.borderWidth = 1;
        _firmwareUpdateStateLabel.layer.borderColor = COR1.CGColor;
    }
    return _firmwareUpdateStateLabel;
}

- (UIButton *)installUpdateButton{
    if (!_installUpdateButton) {
        _installUpdateButton = [[MDCFlatButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firmwareUpdateTitleLabel.frame), CGRectGetMaxY(_firmwareUpdateTitleLabel.frame) + 8,60, 30)];
        [_installUpdateButton setTitle:@"安装" forState:UIControlStateNormal];
        [_installUpdateButton setTitleColor:COR1 forState:UIControlStateNormal];
        _installUpdateButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//        _installUpdateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_installUpdateButton addTarget:self action:@selector(installUpdateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _installUpdateButton;
}

- (UILabel *)releaseTimeLabel{
    if (!_releaseTimeLabel) {
        _releaseTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firmwareUpdateTitleLabel.frame), CGRectGetMaxY(_installUpdateButton.frame) + 16, __kWidth - CGRectGetMinX(_firmwareUpdateTitleLabel.frame), 20)];
        _releaseTimeLabel.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        _releaseTimeLabel.adjustsFontSizeToFitWidth = YES;
        _releaseTimeLabel.font = [UIFont systemFontOfSize:14];
        _releaseTimeLabel.text = @"发布日期:";
    }
    return _releaseTimeLabel;
}

- (UIView *)secondLineView{
    if (!_secondLineView) {
        _secondLineView = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_releaseTimeLabel.frame) + 16, __kWidth, 0.5)];
        _secondLineView.backgroundColor = LINECOLOR;
    }
    return _secondLineView;
}

- (MDCFlatButton *)updateCheckButton{
    if (!_updateCheckButton) {
        _updateCheckButton = [[MDCFlatButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firmwareNowTitleLabel.frame), CGRectGetMaxY(_secondLineView.frame), 100, 40)];
        [_updateCheckButton setTitle:@"检查更新" forState:UIControlStateNormal];
        [_updateCheckButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_updateCheckButton setBackgroundColor:COR1 forState:UIControlStateNormal];
        [_updateCheckButton addTarget:self action:@selector(updateCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateCheckButton;
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer =  [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getStateData) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end
