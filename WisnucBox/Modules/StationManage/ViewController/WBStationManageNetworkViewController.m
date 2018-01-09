//
//  WBStationManageNetworkViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageNetworkViewController.h"
#import "WBStationManageTableViewCell.h"
#import "WBStationManageNetInterfacesModel.h"
#import "WBStationManageTableViewCell.h"
#import "WBStationManageNetInterfaceAPI.h"

@interface WBStationManageNetworkViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIImageView *timeImageView;
@property (nonatomic) NSMutableArray *dataArray;
@end


@implementation WBStationManageNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = kStationManageNetworkString;
    [self getData];
    [self.view addSubview:self.timeImageView];
    [self.view addSubview:self.tableView];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:COR1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)getData{
    WBStationManageNetInterfaceAPI *api = [[WBStationManageNetInterfaceAPI alloc]init];
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);

        NSArray * responseArr = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSDictionary * responseDic  = responseArr[0];
        if (responseArr.count >0) {
           responseDic  = responseArr[0];
        }
        WBStationManageNetInterfacesModel *model = [WBStationManageNetInterfacesModel yy_modelWithDictionary:responseDic];
        [model.ipAddresses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *objDic = obj;
            IpAddressesModel *ipModel  = [IpAddressesModel yy_modelWithDictionary:objDic];
            [ipModel setName:model.name];
            [ipModel setSpeed:model.speed];
            if (![ipModel.internal boolValue] && [ipModel.family isEqualToString: @"IPv4"]) {
            
                [self.dataArray addObject:ipModel];
            }
        }];
     
        [SXLoadingView hideProgressHUD];
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"失败,%@",serializedData);
        }
        [self.tableView reloadData];
    }];
}

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma tableViewDelegate;

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WBStationManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBStationManageTableViewCell class])];
    if (!cell) {
        cell =  [[WBStationManageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([WBStationManageTableViewCell class])];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    IpAddressesModel*model;
    if (self.dataArray.count >0) {
        model = self.dataArray[0];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.normalLabel.text = model.name;
            cell.detailLabel.text = WBLocalizedString(@"nic_name", nil);;
            break;
        case 1:
            cell.normalLabel.text = [NSString stringWithFormat:@"%@M",model.speed];
            cell.detailLabel.text = WBLocalizedString(@"bandwidth", nil);
            break;
        case 2:
            cell.normalLabel.text = @"IPv4";
            cell.detailLabel.text = WBLocalizedString(@"type", nil);
            break;
        case 3:
            cell.normalLabel.text = model.address;
            cell.detailLabel.text = WBLocalizedString(@"network_address", nil);
            break;
        case 4:
            cell.normalLabel.text = model.netmask;
            cell.detailLabel.text = WBLocalizedString(@"subnet_mask", nil);
            break;
        case 5:
            cell.normalLabel.text = model.mac;
            cell.detailLabel.text = WBLocalizedString(@"nic_mac_address", nil);
            break;
        case 6:
            cell.normalLabel.text = WB_UserService.currentUser.isCloudLogin?WBLocalizedString(@"remote_connection", nil) :WBLocalizedString(@"local_station_connection", nil);
            cell.detailLabel.text = WBLocalizedString(@"network_connection_type", nil);
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            
            break;
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;
            
        default:
            break;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.timeImageView.frame) + 32, 0, __kWidth - 16 - 24 - 32, __kHeight - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellAccessoryNone;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (UIImageView *)timeImageView{
    if (!_timeImageView) {
        _timeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(16, 16, 24, 24)];
        _timeImageView.image = [UIImage imageNamed:@"ic_network"];
    }
    return _timeImageView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}
@end

