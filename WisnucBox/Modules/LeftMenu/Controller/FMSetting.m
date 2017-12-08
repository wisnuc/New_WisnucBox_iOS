//
//  FMSetting.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSetting.h"
#import "LCActionSheet.h"

@interface FMSetting ()<UITableViewDelegate,UITableViewDataSource,LCActionSheetDelegate>
@property (nonatomic) BOOL displayProgress;

@property (nonatomic,strong)UISwitch * switchBtn;

@property (nonatomic,assign)BOOL switchOn;
@end

@implementation FMSetting

- (void)dealloc{
    NSLog(@"FMSetting delloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LeftMenuSettingString;
    self.view.backgroundColor = [UIColor whiteColor];
   //    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.settingTableView.tableFooterView = [UIView new];
    self.displayProgress = NO;
    [self setSwitch];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.displayProgress = NO;
    [self.settingTableView reloadData];

}

- (void)setSwitch{
    if(WB_UserService.currentUser)
        _switchOn = [AppServices sharedService].userServices.currentUser.autoBackUp;
}

- (instancetype)initPrivate {
    self  = [super init];
    return self;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    if (indexPath.row == 0) {
        UILabel * titleLb = [[UILabel alloc] initWithFrame:CGRectMake(16, 23, 200, 17)];
        titleLb.text = WBLocalizedString(@"photo_auto_upload_setting_text", nil);
        titleLb.font = [UIFont systemFontOfSize:17];
        
        [cell.contentView addSubview:titleLb];
        cell.contentView.layer.masksToBounds = YES;
        UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(__kWidth - 70, 16, 50, 40)];
        switchBtn.on = _switchOn;
        [switchBtn addTarget:self  action:@selector(switchBtnHandleForSync:) forControlEvents:UIControlEventValueChanged];
        if(!WB_UserService.isUserLogin) switchBtn.enabled = NO;
        [cell.contentView addSubview:switchBtn];
    }
    else if(indexPath.row == 1){
        UILabel * titleLb = [[UILabel alloc] initWithFrame:CGRectMake(16, 23, 200, 17)];
        titleLb.text = WBLocalizedString(@"clear_cache", nil);
        titleLb.font = [UIFont systemFontOfSize:17];
        [cell.contentView addSubview:titleLb];
        
        UIButton * cleanBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 40)];
        cleanBtn.userInteractionEnabled = NO;
        [cleanBtn setTitle:WBLocalizedString(@"calculating", nil) forState:UIControlStateNormal];
        cleanBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cleanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSUInteger  i = [SDImageCache sharedImageCache].getSize;
            NSLog(@"%ld",(long)[[YYImageCache sharedCache].diskCache totalCost]);
            i = i + [[YYImageCache sharedCache].diskCache totalCost];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cleanBtn setTitle:[NSString stringWithFormat:@"%luM",(unsigned long)i/(1024*1024)] forState:UIControlStateNormal];
            });
        });        
        cell.accessoryView = cleanBtn;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        
        NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
        NSString *clearTitle = WBLocalizedString(@"clear", nil);
        NSString *confirmTitle = WBLocalizedString(@"confirm_clear_cache", nil);
        
        NSUInteger  i = [SDImageCache sharedImageCache].getSize;
       i = i + [[YYImageCache sharedCache].diskCache totalCost];
        if(i>0){
            LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:confirmTitle
                                                                     delegate:self
                                                            cancelButtonTitle:cancelTitle
                                                        otherButtonTitleArray:@[clearTitle]];
            actionSheet.scrolling          = YES;
            actionSheet.buttonHeight       = 60.0f;
            actionSheet.visibleButtonCount = 3.6f;
            [actionSheet show];
        }
    }
}

//实现下面的代理方法即可
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}


- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [SXLoadingView showProgressHUD:WBLocalizedString(@"clearing_cache", nil)];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[SDImageCache sharedImageCache] cleanDisk];
            [[SDImageCache sharedImageCache] clearDisk];
            [[YYImageCache sharedCache].diskCache removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SXLoadingView hideProgressHUD];
                [SXLoadingView showAlertHUD:WBLocalizedString(@"clear_completed", nil) duration:0.5];
                [self.settingTableView reloadData];
            });
        });
    }
}

-(void)switchBtnHandleForSync:(UISwitch *)switchBtn{
    WB_UserService.currentUser.autoBackUp = switchBtn.isOn;
    [WB_UserService synchronizedCurrentUser];
    _switchOn = switchBtn.isOn;
    if(_switchOn) {
        [SXLoadingView showProgressHUD:@" "];
        [WB_AppServices startUploadAssets:^{
            [SXLoadingView hideProgressHUD];
        }];
    } else
        [WB_AppServices.photoUploadManager stop];
}

- (IBAction)cleanBtnClick:(id)sender {
   
}

-(void)backbtnClick:(UIButton *)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
