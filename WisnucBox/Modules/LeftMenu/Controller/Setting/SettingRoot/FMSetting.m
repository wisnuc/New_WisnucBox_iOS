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
#import "WBSettingUpgradeSelectViewController.h"

@interface FMSetting ()<UITableViewDelegate,UITableViewDataSource,LCActionSheetDelegate,SettingUpgradeSelectAlertViewDelegate,SettingSelectPpgAlertViewDelegate>
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
    if (WB_UserService.currentUser.isAdmin) {
        return 6;
    }else{
        return 4;
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
            
        case 2:{
            
            cell.textLabel.text = @"服务管理";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
            break;
        case 3:{
             cell.textLabel.text =  @"如何处理使用WISNUC打开的文件";
        }

            break;
         
        case 4:{
            
            cell.textLabel.text = @"固件升级";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
             break;
        case 5:{
            cell.textLabel.text =  @"应用启动时是否检查设备系统更新？";
        }
            break;

        default:
            break;
    }
  
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
        }
            break;
        case 1:{
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
            break;
        case 2:{
            WBServiceSettingViewController *vc = [[WBServiceSettingViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 3:{
                NSBundle *bundle = [NSBundle bundleForClass:[WBSettingSelectPpgAlertViewController class]];
                UIStoryboard *storyboard =
                [UIStoryboard storyboardWithName:NSStringFromClass([WBSettingSelectPpgAlertViewController class]) bundle:bundle];
                NSString *identifier = NSStringFromClass([WBSettingSelectPpgAlertViewController class]);
        
                UIViewController *viewController =
                [storyboard instantiateViewControllerWithIdentifier:identifier];
        
                viewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];
                WBSettingSelectPpgAlertViewController *vc = (WBSettingSelectPpgAlertViewController *)viewController;
                vc.typeString = [NSString stringWithFormat:@"%@",WB_UserService.currentUser.ppgSelectType];
                vc.delegate = self;
                [self presentViewController:viewController animated:YES completion:NULL];
    
        }
            break;
        case 4:{
            if (!WB_UserService.currentUser.isCloudLogin) {
                WBUpgradeAppfiViewController *vc = [[WBUpgradeAppfiViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
            
        case 5:{
            NSBundle *bundle = [NSBundle bundleForClass:[WBSettingUpgradeSelectViewController class]];
            UIStoryboard *storyboard =
            [UIStoryboard storyboardWithName:NSStringFromClass([WBSettingUpgradeSelectViewController class]) bundle:bundle];
            NSString *identifier = NSStringFromClass([WBSettingUpgradeSelectViewController class]);
            
            UIViewController *viewController =
            [storyboard instantiateViewControllerWithIdentifier:identifier];
            
            viewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];
            WBSettingUpgradeSelectViewController *vc = (WBSettingUpgradeSelectViewController *)viewController;
            if (!WB_UserService.currentUser.isIgnoreUpgradeCheck) {
                vc.typeString =  @"是";
            }else{
                vc.typeString =  @"否";
            }
            vc.delegate = self;
            [self presentViewController:viewController animated:YES completion:NULL];
        }
            break;
        default:
            break;
    }

}

-(void)confirmUpgradWithTypeString:(NSString *)typeString{
    if ([typeString isEqualToString:@"是"]) {
       WB_UserService.currentUser.isIgnoreUpgradeCheck = NO;
    }else{
        WB_UserService.currentUser.isIgnoreUpgradeCheck = YES;
    }
    [WB_UserService synchronizedCurrentUser];
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

- (void)confirmWithTypeString:(NSString *)typeString {
    if ([typeString containsString:@"询问"]) {
        WB_UserService.currentUser.ppgSelectType = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:PpgTypeAskAllTime]];
        
    }else if ([typeString containsString:@"新建"]){
        WB_UserService.currentUser.ppgSelectType = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:PpgTypeCreatNewTask]];
        
    } else if ([typeString containsString:@"上传"]){
       WB_UserService.currentUser.ppgSelectType = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:PpgTypeUpload]];
    }
    [WB_UserService synchronizedCurrentUser];
}

@end
