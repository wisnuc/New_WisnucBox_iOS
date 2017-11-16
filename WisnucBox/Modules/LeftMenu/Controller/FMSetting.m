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
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
   //    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.settingTableView.tableFooterView = [UIView new];
    self.displayProgress = NO;
    [self setSwitch];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.displayProgress = NO;
    [self.settingTableView reloadData];

}

- (void)setSwitch{
    if(WB_UserService.currentUser)
        _switchOn = [AppServices sharedService].userServices.currentUser.autoBackUp;
}

-(void)anySwitch{
#warning start stop backup
    if (_switchOn) {
//            [[FMPhotoManager defaultManager] start];
    }else{
//            [[FMPhotoManager defaultManager] stop];
    }
    
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
        titleLb.text = @"照片自动备份:";
        titleLb.font = [UIFont systemFontOfSize:17];
        
        [cell.contentView addSubview:titleLb];
        cell.contentView.layer.masksToBounds = YES;
        UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(__kWidth - 70, 16, 50, 40)];
        switchBtn.on = _switchOn;
        [switchBtn addTarget:self  action:@selector(switchBtnHandleForSync:) forControlEvents:UIControlEventValueChanged];
        if(!WB_UserService.isUserLogin) switchBtn.enabled = NO;
        [cell.contentView addSubview:switchBtn];
    }
    else
        if(indexPath.row == 1){
        UILabel * titleLb = [[UILabel alloc] initWithFrame:CGRectMake(16, 23, 200, 17)];
        titleLb.text = @"清除缓存";
        titleLb.font = [UIFont systemFontOfSize:17];
        [cell.contentView addSubview:titleLb];
        
        UIButton * cleanBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 40)];
        cleanBtn.userInteractionEnabled = NO;
        [cleanBtn setTitle:@"正在计算..." forState:UIControlStateNormal];
        cleanBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cleanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSUInteger  i = [SDImageCache sharedImageCache].getSize;
            NSLog(@"%ld",[[YYImageCache sharedCache].diskCache totalCost]);
            i = i + [[YYImageCache sharedCache].diskCache totalCost];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cleanBtn setTitle:[NSString stringWithFormat:@"%luM",i/(1024*1024)] forState:UIControlStateNormal];
            });
        });        
        cell.accessoryView = cleanBtn;
   }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        NSUInteger  i = [SDImageCache sharedImageCache].getSize;
       i = i + [[YYImageCache sharedCache].diskCache totalCost];
        if(i>0){
            LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:@"确认清除缓存"
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                        otherButtonTitleArray:@[@"清除"]];
            actionSheet.scrolling          = YES;
            actionSheet.buttonHeight       = 60.0f;
            actionSheet.visibleButtonCount = 3.6f;
            [actionSheet show];
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}


- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [SXLoadingView showProgressHUD:@"正在清除缓存"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[SDImageCache sharedImageCache] cleanDisk];
            [[SDImageCache sharedImageCache] clearDisk];
            [[YYImageCache sharedCache].diskCache removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SXLoadingView hideProgressHUD];
                [SXLoadingView showAlertHUD:@"清除完成" duration:0.5];
                [self.settingTableView reloadData];
            });
        });
    }
}

-(void)switchBtnHandleForWWNN:(UISwitch *)switchBtn{
    [AppServices sharedService].userServices.currentUser.backUpInWWAN = switchBtn.isOn;
    [[AppServices sharedService].userServices synchronizedCurrentUser];
#warning open close backup WWAN
//    if([PhotoManager shareManager].netStatus == FMNetStatusWWAN ){
//        if (switchBtn.isOn) {
//            MyNSLog(@"备份开关开启");
//                [[FMPhotoManager defaultManager] start];
//        }else{
//            MyNSLog(@"备份开关关闭");
//                [[FMPhotoManager defaultManager] stop];
//        }
//    }
}

-(void)switchBtnHandleForSync:(UISwitch *)switchBtn{
    WB_UserService.currentUser.autoBackUp = switchBtn.isOn;
    [WB_UserService synchronizedCurrentUser];
    _switchOn = switchBtn.isOn;
    if(_switchOn)
       [WB_AppServices startUploadAssets:nil];
    else
        [WB_AppServices.photoUploadManager stop];
}

- (IBAction)cleanBtnClick:(id)sender {
   
}

-(void)backbtnClick:(UIButton *)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
