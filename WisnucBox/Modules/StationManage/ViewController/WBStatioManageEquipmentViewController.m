//
//  WBStatioManageEquipmentViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStatioManageEquipmentViewController.h"
#import "WBStationManageEquipmentTableViewCell.h"
#import "WBGetSystemInformationAPI.h"
#import "WBStationManageEquipmentModel.h"
#import "WBStationManageStorageAPI.h"
#import "WBStationManageStorageModel.h"
#import "WBgetStationInfoAPI.h"
#import "WBStationInfoModel.h"
#import "WBStationManageRenameViewController.h"

@interface WBStatioManageEquipmentViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
ReNameDelegate
>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIImageView *timeImageView;
@property (nonatomic) NSMutableArray *dataStationInfoArray;
@property (nonatomic) NSMutableArray *dataRootArray;
@property (nonatomic) NSMutableArray *dataCpuInfoArray;
@property (nonatomic) NSMutableArray *dataStorageArray;
@end

@implementation WBStatioManageEquipmentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = kStationManageEquipmentString;
    [self getData];
    [self.view addSubview:self.timeImageView];
    [self.view addSubview:self.tableView];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//UIScrollView也适用
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UICOLOR_RGB(0x03a9f4)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkTextColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)getData{
    [self.dataStationInfoArray removeAllObjects];
    [self.dataRootArray removeAllObjects];
    [self.dataCpuInfoArray removeAllObjects];
    [self.dataStorageArray removeAllObjects];
    
    WBgetStationInfoAPI * stationApi = [WBgetStationInfoAPI apiWithServicePath:WB_UserService.currentUser.localAddr];
    [stationApi startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//         NSLog(@"%@",request.responseJsonObject);
        WBStationInfoModel *model = [WBStationInfoModel yy_modelWithJSON:request.responseJsonObject];
        [self.dataStationInfoArray addObject:model];
        NSString *stationName = model.name;
        WB_UserService.currentUser.bonjour_name =  stationName;
        [WB_UserService synchronizedCurrentUser];
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.error);
    }];
    
    WBGetSystemInformationAPI *api = [WBGetSystemInformationAPI apiWithServicePath:WB_UserService.currentUser.localAddr];
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        NSLog(@"%@",request.responseJsonObject);
        WBStationManageEquipmentModel *model = [WBStationManageEquipmentModel yy_modelWithJSON:request.responseJsonObject];
        [self.dataRootArray addObject:model];
        [model.cpuInfo enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.dataCpuInfoArray addObject:obj];
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
    
    WBStationManageStorageAPI *storageAPI = [[WBStationManageStorageAPI alloc]init];
    [storageAPI startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        NSLog(@"%@",request.responseJsonObject);
        WBStationManageStorageModel *storageModel = [WBStationManageStorageModel yy_modelWithJSON:request.responseJsonObject];
        [self.dataStorageArray addObject:storageModel];
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        [self.tableView reloadData];
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"失败,%@",serializedData);
        }
    }];
}

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)editButtonClick:(UIButton *)sender{
    WBStationManageRenameViewController *renameVC = [[WBStationManageRenameViewController alloc]init];
    WBStationInfoModel *model = self.dataStationInfoArray[0];
    renameVC.stationName = model.name;
    renameVC.delegate = self;
    [self.navigationController pushViewController:renameVC animated:YES];
}

- (void)reNameComplete{
    [self getData];
    [SXLoadingView showProgressHUDText:WBLocalizedString(@"device_name_modified_successfully", nil) duration:1.5];
    [self.tableView reloadData];

}



#pragma tableViewDelegate;

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WBStationManageEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBStationManageEquipmentTableViewCell class])];
    if (!cell) {
        cell =  (WBStationManageEquipmentTableViewCell *) [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([WBStationManageEquipmentTableViewCell class]) owner:self options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WBStationInfoModel *stationInfoModel;
    if (self.dataStationInfoArray.count > 0) {
        stationInfoModel = self.dataStationInfoArray[0];
    }
    
    WBStationManageEquipmentModel *model;
    if (self.dataRootArray.count > 0) {
        model = self.dataRootArray[0];
    }
    WBStationManageCpuInfoModel *cupModel;
     if (self.dataCpuInfoArray.count > 0) {
        cupModel = self.dataCpuInfoArray[0];
     }
    WBStationManageStorageModel *storageModel;
    if (self.dataStorageArray.count > 0) {
        storageModel = self.dataStorageArray[0];
    }
    __block WBStationManageVolumesModel * volumesModel;
    [storageModel.volumes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        volumesModel =obj;
    }];
  
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.normalLabel.text = stationInfoModel.name;
                    cell.detailLabel.text = WBLocalizedString(@"equipment_label", nil);
                    cell.leftImageView.image = [UIImage imageNamed:@"ic_tv"];
                    [cell.editButton setHidden:NO];
                    [cell.editButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
                    [cell.editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (model.ws215i) {
                switch (indexPath.row) {
                    case 0:
                    {
                        cell.normalLabel.text = @"WS215i";
                        cell.detailLabel.text = WBLocalizedString(@"equipment_type", nil);
                        cell.leftImageView.image = [UIImage imageNamed:@"ic_dns"];
                    }
                        break;
                    case 1:
                    {
                        cell.normalLabel.text = model.ws215i.serial;
                        cell.detailLabel.text = WBLocalizedString(@"hardware_serial_number", nil);
                    }
                        break;
                    case 2:
                    {
                        cell.normalLabel.text = model.ws215i.mac;
                        cell.detailLabel.text = WBLocalizedString(@"mac_address", nil);
                    }
                        break;
                    default:
                        break;
                }
            }else{
                switch (indexPath.row) {
                    case 0:
                    {
                        NSString *memTotal = [model.memInfo.memTotal substringToIndex:model.memInfo.memTotal.length-3];
                        cell.normalLabel.text = [NSString transformedValue:[NSNumber numberWithFloat:[memTotal floatValue] *1024]];
                        cell.detailLabel.text = WBLocalizedString(@"total_memory_size", nil);
                        cell.leftImageView.image = [UIImage imageNamed:@"ic_sd_storage"];
                    }
                        break;
                    case 1:
                    {
                        NSString *memFree = [model.memInfo.memFree substringToIndex:model.memInfo.memFree.length-3];
                        cell.normalLabel.text = [NSString transformedValue:[NSNumber numberWithFloat:[memFree floatValue]*1024]];
                        cell.detailLabel.text = WBLocalizedString(@"free_memory_size", nil);
                    }
                        break;
                    case 2:
                    {
                        NSString *memAvailable = [model.memInfo.memAvailable substringToIndex:model.memInfo.memAvailable.length-3];
                        cell.normalLabel.text = [NSString transformedValue:[NSNumber numberWithFloat:[memAvailable floatValue]*1024]];
                        cell.detailLabel.text = WBLocalizedString(@"available_memory_size", nil);
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case 2:
        {
            if (model.ws215i) {
                switch (indexPath.row) {
                    case 0:
                    {
                        NSString *memTotal = [model.memInfo.memTotal substringToIndex:model.memInfo.memTotal.length-3];
                        cell.normalLabel.text = [NSString transformedValue:[NSNumber numberWithFloat:[memTotal floatValue]*1024]];
                        cell.detailLabel.text = WBLocalizedString(@"total_memory_size", nil);;
                        cell.leftImageView.image = [UIImage imageNamed:@"ic_sd_storage"];
                    }
                        break;
                    case 1:
                    {
                        NSString *memFree = [model.memInfo.memFree substringToIndex:model.memInfo.memFree.length-3];
                        cell.normalLabel.text = [NSString transformedValue:[NSNumber numberWithFloat: [memFree floatValue]*1024]];
                        cell.detailLabel.text = WBLocalizedString(@"free_memory_size", nil);
                    }
                        break;
                    case 2:
                    {
                        NSString *memAvailable = [model.memInfo.memAvailable substringToIndex:model.memInfo.memAvailable.length-3];
                        cell.normalLabel.text = [NSString transformedValue:[NSNumber numberWithFloat:[memAvailable floatValue]*1024]];
                        cell.detailLabel.text = WBLocalizedString(@"available_memory_size", nil);
                    }
                        break;
                    default:
                        break;
                }
            }else{
                switch (indexPath.row) {
                    case 0:
                    {
                        cell.normalLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.cpuInfo.count];
                        cell.detailLabel.text = WBLocalizedString(@"cpu_core_number", nil);
                        cell.leftImageView.image = [UIImage imageNamed:@"ic_memory"];
                    }
                        break;
                    case 1:
                    {
                        cell.normalLabel.text = cupModel.modelName;
                        cell.detailLabel.text = WBLocalizedString(@"cpu_type", nil);
                    }
                        break;
                    case 2:
                    {
                        cell.normalLabel.text = cupModel.cacheSize;
                        cell.detailLabel.text = WBLocalizedString(@"cpu_cache_size", nil);
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case 3:
        {
            if (model.ws215i) {
                switch (indexPath.row) {
                    case 0:
                    {
                        cell.normalLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.cpuInfo.count];
                        cell.detailLabel.text = WBLocalizedString(@"cpu_core_number", nil);
                        cell.leftImageView.image = [UIImage imageNamed:@"ic_memory"];
                    }
                        break;
                    case 1:
                    {
                        cell.normalLabel.text = cupModel.modelName;
                        cell.detailLabel.text = WBLocalizedString(@"cpu_type", nil);
                    }
                        break;
                    case 2:
                    {
                        cell.normalLabel.text = cupModel.cacheSize;
                        cell.detailLabel.text = WBLocalizedString(@"cpu_cache_size", nil);
                    }
                        break;
                    default:
                        break;
                }
            }else{
                switch (indexPath.row) {
                    case 0:
                    {
                        cell.normalLabel.text = @"Btrfs";
                        cell.detailLabel.text = WBLocalizedString(@"file_system_type", nil);
                        cell.leftImageView.image = [UIImage imageNamed:@"brtfs"];
                    }
                        break;
                    case 1:
                    {
                        cell.normalLabel.text = [NSString stringWithFormat:@"%@",volumesModel.total];
                        cell.detailLabel.text = WBLocalizedString(@"disk_count", nil);
                    }
                        break;
                    case 2:
                    {
                        cell.normalLabel.text = volumesModel.usage.data[@"mode"];
                        cell.detailLabel.text = WBLocalizedString(@"disk_array_mode", nil);
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case 4:
          if (model.ws215i) {
              switch (indexPath.row) {
                  case 0:
                  {
                      cell.normalLabel.text = @"Btrfs";
                      cell.detailLabel.text = WBLocalizedString(@"file_system_type", nil);
                      cell.leftImageView.image = [UIImage imageNamed:@"brtfs"];
                  }
                      break;
                  case 1:
                  {
                      cell.normalLabel.text = [NSString stringWithFormat:@"%@",volumesModel.total];
                      cell.detailLabel.text = WBLocalizedString(@"disk_count", nil);
                  }
                      break;
                  case 2:
                  {
                      cell.normalLabel.text = volumesModel.usage.data[@"mode"];
                      cell.detailLabel.text = WBLocalizedString(@"disk_array_mode", nil);
                  }
                      break;
                  default:
                      break;
              }
          }else{
              switch (indexPath.row) {
                  case 0:
                  {
                      cell.normalLabel.text = [NSString transformedValue:volumesModel.usage.overall[@"deviceSize"]];
                      cell.detailLabel.text = WBLocalizedString(@"total_space", nil);
                      cell.leftImageView.image = [UIImage imageNamed:@"ic_storage"];
                  }
                      break;
                  case 1:
                  {
                      cell.normalLabel.text = [NSString transformedValue:volumesModel.usage.data[@"size"]];
                      cell.detailLabel.text = WBLocalizedString(@"user_data_space", nil);
                  }
                      break;
                  case 2:
                  {
                      cell.normalLabel.text =  cell.normalLabel.text = [NSString transformedValue: volumesModel.usage.overall[@"free"]];
                      cell.detailLabel.text = WBLocalizedString(@"available_space", nil);
                  }
                      break;
                  default:
                      break;
              }
          }
            break;
        case 5:
            switch (indexPath.row) {
                case 0:
                {
                    cell.normalLabel.text = [NSString transformedValue:volumesModel.usage.overall[@"deviceSize"]];
                    cell.detailLabel.text = WBLocalizedString(@"total_space", nil);
                    cell.leftImageView.image = [UIImage imageNamed:@"ic_storage"];
                }
                    break;
                case 1:
                {
                    cell.normalLabel.text = [NSString transformedValue:volumesModel.usage.data[@"size"]];
                    cell.detailLabel.text = WBLocalizedString(@"user_data_space", nil);
                }
                    break;
                case 2:
                {
                    cell.normalLabel.text =  cell.normalLabel.text = [NSString transformedValue:volumesModel.usage.overall[@"free"]];
                    cell.detailLabel.text = WBLocalizedString(@"available_space", nil);
                }
                    break;
                default:
                    break;
            }
    }
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [UIView new];
    footerView.backgroundColor = [UIColor whiteColor];
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 7.5, __kWidth, 0.5)];
    lineLabel.backgroundColor = [UIColor blackColor];
    lineLabel.alpha = .12;
    [footerView addSubview:lineLabel];
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
 
    return 8;

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
    switch (section) {
        case 0:
            return 1;
            break;
            
        default:
            return 3;
            break;
    }
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    WBStationManageEquipmentModel *model;
    if (self.dataRootArray.count > 0) {
        model = self.dataRootArray[0];
    }
    return model.ws215i?6:5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellAccessoryNone;
//        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
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

- (NSMutableArray *)dataRootArray{
    if (!_dataRootArray) {
        _dataRootArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataRootArray;
}

- (NSMutableArray *)dataCpuInfoArray{
    if (!_dataCpuInfoArray) {
        _dataCpuInfoArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataCpuInfoArray;
}

- (NSMutableArray *)dataStorageArray{
    if (!_dataStorageArray) {
        _dataStorageArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataStorageArray;
}

- (NSMutableArray *)dataStationInfoArray{
    if (!_dataStationInfoArray) {
        _dataStationInfoArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataStationInfoArray;
}
@end
