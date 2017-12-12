//
//  WBStationManageRootViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageRootViewController.h"
#import "WBStationManageRootTableViewCell.h"
#import "WBStationManageTimeViewController.h"
#import "WBStationManageNetworkViewController.h"
#import "WBStatioManageEquipmentViewController.h"
#import "WBStationManageRebotViewController.h"
#import "FMUserSetting.h"

#define DefaultRowCount 5

@interface WBStationManageRootViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic) UITableView *tableView;
@end

@implementation WBStationManageRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LeftMenuEquipmentManageString;
    [self.view addSubview:self.tableView];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
}

- (void)dealloc{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UICOLOR_RGB(0x03a9f4)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = UICOLOR_RGB(0x03a9f4);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    [self.navigationController.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"back"]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma tableViewDelegate;

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WBStationManageRootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBStationManageRootTableViewCell class])];
    if (!cell) {
        cell = (WBStationManageRootTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBStationManageRootTableViewCell class]) owner:self options:nil]lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
            cell.leftImageView.image = [UIImage imageNamed:@"ic_person_add"];
            cell.nameLabel.text = kStationManageUserMangeString;
            break;
        case 1:
            cell.leftImageView.image = [UIImage imageNamed:@"ic_dns"];
            cell.nameLabel.text = kStationManageEquipmentString;
            break;
        case 2:
            cell.leftImageView.image = [UIImage imageNamed:@"ic_network"];
            cell.nameLabel.text = kStationManageNetworkString;
            break;
        case 3:
            cell.leftImageView.image = [UIImage imageNamed:@"ic_access_time"];
            cell.nameLabel.text = kStationManageTimeString;
            break;
        case 4:
            cell.leftImageView.image = [UIImage imageNamed:@"ic_power_settings"];
            cell.nameLabel.text = kStationManageRebootShutdownString;
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            FMUserSetting *settingVC = [[FMUserSetting alloc]init];
            [self.navigationController pushViewController:settingVC animated:YES];
        }
            break;
        case 1:
        {
             WBStatioManageEquipmentViewController *equipmentVC = [[ WBStatioManageEquipmentViewController alloc]init];
            [self.navigationController pushViewController:equipmentVC animated:YES];
        }
            break;
        case 2:
        {
            WBStationManageNetworkViewController *networkVC = [[WBStationManageNetworkViewController alloc]init];
            [self.navigationController pushViewController:networkVC animated:YES];
        }
            break;
        case 3:
        {
            WBStationManageTimeViewController *timeVC = [[WBStationManageTimeViewController alloc]init];
            [self.navigationController pushViewController:timeVC animated:YES];
        }
            break;
        case 4:
        {
            WBStationManageRebotViewController *rebotViewController = [[WBStationManageRebotViewController alloc]init];
             [self.navigationController pushViewController:rebotViewController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DefaultRowCount;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellAccessoryNone;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
    }
    return _tableView;
}
@end
