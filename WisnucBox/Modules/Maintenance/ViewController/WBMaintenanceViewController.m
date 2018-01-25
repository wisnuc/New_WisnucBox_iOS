//
//  WBMaintenanceViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/26.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBMaintenanceViewController.h"
#import "WBMaintenanceTableViewCell.h"
#import "WBMaintenanceStorageInfoTableViewCell.h"
#import "WBStationManageStorageAPI.h"
#import "WBStationManageStorageModel.h"
#import "WBStationBootAPI.h"
#import "BootModel.h"
#import <CoreFoundation/CoreFoundation.h>
#import "WBInitializationViewController.h"
#import "AppDelegate.h"

@interface WBMaintenanceViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) NSMutableArray *rootDataSource;
@property (nonatomic) BootModel *bootModel;
@property (nonatomic) WBStationManageStorageModel *storageModel;
@end

@implementation WBMaintenanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"维护模式";
    [self getData];
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:COR1];
    
    //    self.navigationController.navigationBar.backgroundColor = UICOLOR_RGB(0x03a9f4);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    //   [self.navigationController.navigationBar setBarTintColor:COR1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor]}];
    //    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getData{
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];

    [[WBStationManageStorageAPI apiWithURLPath:_searchModel.path] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.responseJsonObject);
        WBStationManageStorageModel *storageModel = [WBStationManageStorageModel modelWithJSON:request.responseJsonObject];
        _storageModel = storageModel;
        [storageModel.volumes enumerateObjectsUsingBlock:^(WBStationManageVolumesModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.rootDataSource addObject:model];
        }];
        NSLog(@"%@",self.rootDataSource);
        [self.dataSource removeAllObjects];

        [self.dataSource addObjectsFromArray:self.rootDataSource];
    
        [self.tableView reloadData];
        [SXLoadingView hideProgressHUD];
    } failure:^(__kindof JYBaseRequest *request) {
        [self.tableView reloadData];
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"失败,%@",serializedData);
        }
        [SXLoadingView hideProgressHUD];
    }];
    
    [[WBStationBootAPI apiWithPath:_searchModel.path RequestMethod:@"GET"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
          NSLog(@"%@",request.responseJsonObject);
         BootModel *bootModel = [BootModel modelWithJSON:request.responseJsonObject];
        _bootModel = bootModel;
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        [self.tableView reloadData];
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"失败,%@",serializedData);
        }
        [SXLoadingView hideProgressHUD];
    }];
    
}

- (UIView *)headerView{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, __kWidth, 40)];
    lable.textColor = RGBACOLOR(0, 0, 0, 0.54f);
    lable.font = [UIFont systemFontOfSize:12];
    lable.textAlignment = NSTextAlignmentLeft;
    lable.text = @"自动检测";
    [view addSubview:lable];
    return view;
}

- (UIView *)footerLineView{
    UIView *view = [[UIView alloc]init];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 7.5, __kWidth, 0.5)];
    label.backgroundColor = RGBACOLOR(0, 0, 0, 0.12f);
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview:label];
    return view;
}

- (UIView *)footerLastViewWithSection:(NSInteger)section{
    UIView *view = [[UIView alloc]init];
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 7.5, __kWidth, 0.5)];
    lineLabel.backgroundColor = RGBACOLOR(0, 0, 0, 0.12f);
    view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, CGRectGetMaxY(lineLabel.frame), __kWidth, 40)];
    titleLabel.textColor = RGBACOLOR(0, 0, 0, 0.54f);
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"WISNUC 系统管理";
    
    UIButton *reInstallButton = [[UIButton alloc]initWithFrame:CGRectMake(72, CGRectGetMaxY(titleLabel.frame), __kWidth - 72, 48)];
    reInstallButton.tag = section;
    reInstallButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    reInstallButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [reInstallButton setTitle:@"重新安装WISNUC" forState:UIControlStateNormal];
    [reInstallButton setTitleColor:COR1 forState:UIControlStateNormal];
    [reInstallButton addTarget:self action:@selector(reInstallButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *restartButton = [[UIButton alloc]initWithFrame:CGRectMake(72, CGRectGetMaxY(reInstallButton.frame), __kWidth - 72, 48)];
    restartButton.tag = section;
    restartButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    restartButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [restartButton setTitle:@"强制启动" forState:UIControlStateNormal];
    [restartButton setTitleColor:COR1 forState:UIControlStateNormal];
    [restartButton addTarget:self action:@selector(restartButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *lineLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 136 + 7.5, __kWidth, 0.5)];
    lineLabel2.backgroundColor = RGBACOLOR(0, 0, 0, 0.12f);
    
    [view addSubview:lineLabel];
    [view addSubview:titleLabel];
    [view addSubview:reInstallButton];
    [view addSubview:restartButton];
    [view addSubview:lineLabel2];
    return view;
}


- (void)reInstallButtonClick:(UIButton *)sender{
    WBInitializationViewController *initializationVC = [[WBInitializationViewController alloc]init];
    if (_storageModel) {
         _searchModel.storageModel = _storageModel;
    }
    initializationVC.searchModel = _searchModel;
    [self.navigationController pushViewController:initializationVC animated:YES];
}

- (void)restartButtonClick:(UIButton *)sender{
    if (sender.tag == 1) {
        WBStationManageVolumesModel * volumesModel;
        if (self.dataSource.count >0) {
            volumesModel = self.dataSource[0];
        }
        [self restartActionWithUUID:volumesModel.uuid];
    }else{
         WBStationManageVolumesModel * volumesModel;
        if (self.dataSource.count >1) {
            volumesModel = self.dataSource[1];
        }
        [self restartActionWithUUID:volumesModel.uuid];
    }
    
}

- (void)restartActionWithUUID:(NSString *)uuid{
    [SXLoadingView showProgressHUD:@""];
    [[WBStationBootAPI apiWithPath:_searchModel.path RequestMethod:@"PATCH" UUID:uuid ]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate ;
        app.window.rootViewController = nil;
        [app.window resignKeyWindow];
        [app.window removeFromSuperview];
        [MyAppDelegate initRootVC];
        [SXLoadingView hideProgressHUD];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.5f];
        NSLog(@"%@",request.error);
    }];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WBMaintenanceStorageInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBMaintenanceStorageInfoTableViewCell class])];
        if (!cell) {
            cell = (WBMaintenanceStorageInfoTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBMaintenanceStorageInfoTableViewCell class]) owner:self options:nil]lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        WBStationManageVolumesModel * volumesModel;
        if (self.dataSource.count >0) {
            volumesModel = self.dataSource[0];
        }
         if ([volumesModel.isMounted boolValue] && ![volumesModel.isMissing boolValue] &&[volumesModel.uuid isEqualToString:_bootModel.last] && ([NSStringFromClass([volumesModel.users class]) containsString:@"Array"]|| ([NSStringFromClass([volumesModel.users class]) containsString:@"String"] &&  [(NSString *)volumesModel.users isEqualToString:@"EDATA"])) && [NSStringFromClass([volumesModel.users class]) containsString:@"Array"]) {
             [cell.startButton setHidden:NO];
         }else{
             [cell.startButton setHidden:YES];
         }
        cell.diskTitleLabel.text = [NSString stringWithFormat:@"磁盘阵列1"];
        cell.diskDetailInfoLabel.text = [NSString stringWithFormat:@"Btrfs   %@",volumesModel.usage.data[@"mode"]];
        cell.clickBlock = ^(UIButton *button) {
            if ([volumesModel.isMounted boolValue] && ![volumesModel.isMissing boolValue] &&[volumesModel.uuid isEqualToString:_bootModel.last] && ([NSStringFromClass([volumesModel.users class]) containsString:@"Array"]|| ([NSStringFromClass([volumesModel.users class]) containsString:@"String"] &&  [(NSString *)volumesModel.users isEqualToString:@"EDATA"])) && [NSStringFromClass([volumesModel.users class]) containsString:@"Array"]) {
                [self restartActionWithUUID:volumesModel.uuid];
            }
            
        };
        return cell;
    }else if (indexPath.section == 1) {
    WBMaintenanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBMaintenanceTableViewCell class])];
    if (!cell) {
        cell = (WBMaintenanceTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBMaintenanceTableViewCell class]) owner:self options:nil]lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WBStationManageVolumesModel *model;
    if (self.dataSource.count >0) {
        model = self.dataSource[0];
    }
        
    switch (indexPath.row) {
        case 0:
            cell.stateTitileLabel.text = @"是否挂载";
            if ([model.isMounted boolValue]) {
                cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
            }else{
                cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
            }
            break;
        case 1:
            cell.stateTitileLabel.text = @"磁盘阵列是否完整";
          
            if (![model.isMissing boolValue])  {
                cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
            }else{
                cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
            }
             break;
        case 2:
        {
            cell.stateTitileLabel.text = @"是否是上次启动的文件系统";
            
            if ([model.uuid isEqualToString:_bootModel.last]) {
                cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
            }else{
                cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
            }
        }
            break;
        case 3:
            cell.stateTitileLabel.text = @"是否存在WISNUC系统";
            if ([NSStringFromClass([model.users class]) containsString:@"Array"]|| ([NSStringFromClass([model.users class]) containsString:@"String"] &&  [(NSString *)model.users isEqualToString:@"EDATA"]))  {
                cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
            }else{
                cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
            }
            
            break;
        case 4:
            cell.stateTitileLabel.text = @"用户信息是否完整";
            if ([NSStringFromClass([model.users class]) containsString:@"Array"])  {
                cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
            }else{
                cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
            }
            
            break;
        default:
            break;
    }
    return cell;
        
    } if (indexPath.section == 2) {
        WBMaintenanceStorageInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBMaintenanceStorageInfoTableViewCell class])];
        if (!cell) {
            cell = (WBMaintenanceStorageInfoTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBMaintenanceStorageInfoTableViewCell class]) owner:self options:nil]lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        WBStationManageVolumesModel * volumesModel;
        if (self.dataSource.count >1) {
            volumesModel = self.dataSource[1];
        }
        
        if ([volumesModel.isMounted boolValue] && ![volumesModel.isMissing boolValue] &&[volumesModel.uuid isEqualToString:_bootModel.last] && ([NSStringFromClass([volumesModel.users class]) containsString:@"Array"]|| ([NSStringFromClass([volumesModel.users class]) containsString:@"String"] &&  [(NSString *)volumesModel.users isEqualToString:@"EDATA"])) && [NSStringFromClass([volumesModel.users class]) containsString:@"Array"]) {
            [cell.startButton setHidden:NO];
        }else{
            [cell.startButton setHidden:YES];

        }
        
        cell.diskTitleLabel.text = [NSString stringWithFormat:@"磁盘阵列2"];
        cell.diskDetailInfoLabel.text = [NSString stringWithFormat:@"Btrfs   %@",volumesModel.usage.data[@"mode"]];
        cell.clickBlock = ^(UIButton *button) {
        if ([volumesModel.isMounted boolValue] && ![volumesModel.isMissing boolValue] &&[volumesModel.uuid isEqualToString:_bootModel.last] && ([NSStringFromClass([volumesModel.users class]) containsString:@"Array"]|| ([NSStringFromClass([volumesModel.users class]) containsString:@"String"] &&  [(NSString *)volumesModel.users isEqualToString:@"EDATA"])) && [NSStringFromClass([volumesModel.users class]) containsString:@"Array"]) {
           [self restartActionWithUUID:volumesModel.uuid];
        }
        };
        return cell;
    }else {
        WBMaintenanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBMaintenanceTableViewCell class])];
        if (!cell) {
            cell = (WBMaintenanceTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBMaintenanceTableViewCell class]) owner:self options:nil]lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        WBStationManageVolumesModel *model;
        if (self.dataSource.count >1) {
            model = self.dataSource[1];
        }
        
        switch (indexPath.row) {
            case 0:
                cell.stateTitileLabel.text = @"是否挂载";
                if ([model.isMounted boolValue]) {
                    cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
                }else{
                    cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
                }
                break;
            case 1:
                cell.stateTitileLabel.text = @"磁盘阵列是否完整";
                
                if (![model.isMissing boolValue])  {
                    cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
                }else{
                    cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
                }
                break;
            case 2:
            {
                cell.stateTitileLabel.text = @"是否是上次启动的文件系统";
                
                if ([model.uuid isEqualToString:_bootModel.last]) {
                    cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
                }else{
                    cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
                }
            }
                break;
            case 3:
                cell.stateTitileLabel.text = @"是否存在WISNUC系统";
                if ([NSStringFromClass([model.users class]) containsString:@"Array"]|| ([NSStringFromClass([model.users class]) containsString:@"String"] &&  [(NSString *)model.users isEqualToString:@"EDATA"]))  {
                    cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
                }else{
                    cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
                }
                
                break;
            case 4:
                cell.stateTitileLabel.text = @"用户信息是否完整";
                if ([NSStringFromClass([model.users class]) containsString:@"Array"])  {
                    cell.leftImageView.image = [UIImage imageNamed:@"yes.png"];
                }else{
                    cell.leftImageView.image = [UIImage imageNamed:@"no.png"];
                }
                
                break;
            default:
                break;
        }
        return cell;
        
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (self.rootDataSource.count >1) {
        if (section == 0) {
            return 1;
        }else if (section == 1){
            return 5;
        }else if (section == 2){
            return 1;
        }else{
            return 5;
        }
//    }else{
//        if (section == 0) {
//            return 1;
//        }else{
//            return 5;
//        }
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.rootDataSource.count >1) {
       return 4;
    }else{
       return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.rootDataSource.count >1) {
        if (indexPath.section == 0) {
            return 64;
        }else if (indexPath.section == 1){
            return 48;
        }else if (indexPath.section == 2){
            return 64;
        }else{
            return 48;
        }
//    }else{
//        if (indexPath.section == 0) {
//            return 64;
//        }else{
//            return 48;
//        }
//    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return [self headerView];
    }else if(section == 3){
        return [self headerView];
    }else{
      return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else if (section == 1){
        return 40;
    }else if (section == 2){
        return 0.1;
    }else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.rootDataSource.count >1) {
        if (section == 0) {
            return 8;
        }else if (section == 1){
           return 136 + 8;
        }else if (section == 2){
            return 8;
        }else {
            return 136 + 8;
        }
    }else{
        if (section == 0) {
            return 8;
        }else{
            return 136 + 8;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.rootDataSource.count >1) {
        if (section == 0) {
            return [self footerLineView];
        }else if (section == 1){
            return [self footerLastViewWithSection:section];
        }else if (section == 2){
            return [self footerLineView];
        }else {
        return [self footerLastViewWithSection:section];
        }
    }else{
        if (section == 0) {
            return [self footerLineView];
        }else{
            return [self footerLastViewWithSection:section];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (NSMutableArray *)rootDataSource{
    if (!_rootDataSource) {
        _rootDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _rootDataSource;
}


@end
