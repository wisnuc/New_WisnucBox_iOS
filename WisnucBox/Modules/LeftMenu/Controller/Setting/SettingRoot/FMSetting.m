//
//  FMSetting.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSetting.h"
#import "LCActionSheet.h"
#import "WBServiceSettingViewController.h"
#import "WBUpgradeAppfiViewController.h"


@interface FMSetting ()<UITableViewDelegate,UITableViewDataSource,LCActionSheetDelegate,SettingSelectBTAlertViewDelegate>
@property (nonatomic) BOOL displayProgress;

@property (nonatomic,strong)UISwitch * switchBtn;

@property (nonatomic,assign)BOOL switchOn;

@property (nonatomic,assign)BOOL btSwitchOn;
@property (nonatomic,assign)BOOL sambaSwitchOn;
@property (nonatomic,assign)BOOL miniDlnaSwitchOn;
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
//    [self getBTData];
    [self.settingTableView reloadData];

}

- (void)getBTData{
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [[WBTorrentDownloadSwitchAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary *dic = request.responseJsonObject;
        NSNumber *number = dic[@"switch"];
        BOOL swichOn = [number boolValue];
        _btSwitchOn = swichOn;
        [self.settingTableView reloadData];
        [SXLoadingView hideProgressHUD];
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        [SXLoadingView hideProgressHUD];
    }];
    
    [[WBFeaturesDlnaStatusAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary *dic = request.responseJsonObject;
        NSString *status = dic[@"status"];
        BOOL swichOn;
        if ([status isEqualToString:@"active"]) {
            swichOn = YES;
        }else{
            swichOn = NO;
        }
    
        _miniDlnaSwitchOn = swichOn;
        [self.settingTableView reloadData];
       
    } failure:^(__kindof JYBaseRequest *request) {
      
    }];
    
    [[WBFeaturesSambaStatusAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary *dic = request.responseJsonObject;
        NSString *status = dic[@"status"];
        BOOL swichOn;
        if ([status isEqualToString:@"active"]) {
            swichOn = YES;
        }else{
            swichOn = NO;
        }
        
        _sambaSwitchOn = swichOn;
       [self.settingTableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
 
    }];
    
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
    if (WB_UserService.currentUser.isAdmin) {
        return 4;
    }else{
        return 3;
    }
   
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"123"];
    switch (indexPath.row) {
        case 0:{
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
            
            break;
        case 1:{
            cell.textLabel.text = WBLocalizedString(@"clear_cache", nil);
            NSUInteger  i = [SDImageCache sharedImageCache].getSize;
           
            i = i + [[YYImageCache sharedCache].diskCache totalCost];
             NSLog(@"%ld",(long)[[YYImageCache sharedCache].diskCache totalCost]);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[NSString transformedValue:[NSNumber numberWithUnsignedInteger:i]]];
        }
            
            break;
//        case 2:{
//             cell.textLabel.text =  @"如何处理来自第三方应用的BT文件";
//        }
//
//            break;
        case 2:{
            
            cell.textLabel.text = @"服务管理";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
             break;
        case 3:{
            
            cell.textLabel.text = @"固件升级";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
             break;
           

        default:
            break;
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
//    else if (indexPath.row == 2){
//        NSBundle *bundle = [NSBundle bundleForClass:[WBSettingSelectBTAlertViewController class]];
//        UIStoryboard *storyboard =
//        [UIStoryboard storyboardWithName:NSStringFromClass([WBSettingSelectBTAlertViewController class]) bundle:bundle];
//        NSString *identifier = NSStringFromClass([WBSettingSelectBTAlertViewController class]);
//
//        UIViewController *viewController =
//        [storyboard instantiateViewControllerWithIdentifier:identifier];
//
//        viewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];
//        WBSettingSelectBTAlertViewController *vc = (WBSettingSelectBTAlertViewController *)viewController;
//        vc.typeString = [NSString stringWithFormat:@"%@",GetUserDefaultForKey(kTorrentType)];
//        vc.delegate = self;
//        [self presentViewController:viewController animated:YES completion:NULL];
//    }
else if (indexPath.row == 2){
        WBServiceSettingViewController *vc = [[WBServiceSettingViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if (!WB_UserService.currentUser.isCloudLogin) {
            WBUpgradeAppfiViewController *vc = [[WBUpgradeAppfiViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
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

-(void)sambaSwitchChanged:(UISwitch *)paramSender{
    BOOL isOn = paramSender.on;
    if (isOn) {
        [[WBFeaturesChangeAPI apiWithType:@"samba" Action:@"start"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _sambaSwitchOn = YES;
            [self.settingTableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _sambaSwitchOn = NO;
            [self.settingTableView reloadData];
        }];
    }else{
        [[WBFeaturesChangeAPI apiWithType:@"samba" Action:@"stop"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _sambaSwitchOn = NO;
            [self.settingTableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _sambaSwitchOn = YES;
            [self.settingTableView reloadData];
        }];
    }
}

-(void)btSwitchChanged:(UISwitch *)paramSender{
    BOOL isOn = paramSender.on;
    if (isOn) {
        [[WBTorrentDownloadSwitchAPI apiWithRequestMethod:@"PATCH" Option:@"start"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _btSwitchOn = YES;
            [self.settingTableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _btSwitchOn = NO;
            [self.settingTableView reloadData];
            NSLog(@"%@",request.error);
        }];
    }else{
        [[WBTorrentDownloadSwitchAPI apiWithRequestMethod:@"PATCH" Option:@"close"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _btSwitchOn = NO;
            [self.settingTableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _btSwitchOn = YES;
            [self.settingTableView reloadData];
              NSLog(@"%@",request.error);
        }];
    }
}

-(void)miniDLNASwitchChanged:(UISwitch *)paramSender{
    BOOL isOn = paramSender.on;
    if (isOn) {
        [[WBFeaturesChangeAPI apiWithType:@"dlna" Action:@"start"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _miniDlnaSwitchOn = YES;
            [self.settingTableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _miniDlnaSwitchOn = NO;
            [self.settingTableView reloadData];
        }];
    }else{
        [[WBFeaturesChangeAPI apiWithType:@"dlna" Action:@"stop"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _miniDlnaSwitchOn = NO;
            [self.settingTableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _miniDlnaSwitchOn = YES;
            [self.settingTableView reloadData];
        }];
    }
}

- (IBAction)cleanBtnClick:(id)sender {
   
}

-(void)backbtnClick:(UIButton *)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmWithTypeString:(NSString *)typeString {
    if ([typeString containsString:@"询问"]) {
        SaveToUserDefault(kTorrentType, [NSNumber numberWithInt: TorrentTypeAskAllTime]);
       
    }else if ([typeString containsString:@"新建"]){
        SaveToUserDefault(kTorrentType, [NSNumber numberWithInt:TorrentTypeCreatNewTask]);
       
    } else if ([typeString containsString:@"上传"]){
        SaveToUserDefault(kTorrentType, [NSNumber numberWithInt:TorrentTypeUpload]);
    }
}

@end
