//
//  FMUserSetting.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserSetting.h"
#import "FMUserSettingCell.h"
#import "FMUserAddVC.h"
#import "UserModel.h"
#import "WBgetStationInfoAPI.h"
#import "WBStationInfoModel.h"

@interface FMUserSetting ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLb;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@property (nonatomic) id navDelegate;

@property (nonatomic) NSMutableArray * dataSource;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userHeaderLabel;
@property (weak, nonatomic) IBOutlet UIButton *fabButton;

@end

@implementation FMUserSetting

- (void)dealloc{
    NSLog(@"----%s----", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = kStationManageUserMangeString;
    self.navigationController.navigationBar.translucent = NO;
    self.userHeaderLabel.text = WBLocalizedString(@"user", nil);
    [_backButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
  
    [self displayInfomation];
    [self registerTableView];
    [self setShadowforFabButton];
}
- (void)setShadowforFabButton{
    _fabButton.contentMode = UIViewContentModeScaleAspectFit;
    _fabButton.layer.cornerRadius =_fabButton.frame.size.width/2;
    _fabButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _fabButton.layer.shadowRadius = 2.f;
    _fabButton.layer.shadowOffset = CGSizeMake(0, 3);
    _fabButton.layer.shadowOpacity = 0.4f;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self getData];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)registerTableView{
    [self.usersTableView registerNib:[UINib nibWithNibName:NSStringFromClass([FMUserSettingCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FMUserSettingCell class])];
    self.usersTableView.tableFooterView = [UIView new];
}

- (void)displayInfomation{
//     WBUser *userInfo = ;
    _nameLabel.text = WB_UserService.currentUser.userName;
//    _typeLabel.text = WB_UserService.currentUser.bonjour_name;
    _urlLabel.text = WB_UserService.currentUser.sn_address;
}

- (void)getData{
    WBgetStationInfoAPI * stationApi = [WBgetStationInfoAPI apiWithServicePath:WB_UserService.currentUser.localAddr];
    [stationApi startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        //         NSLog(@"%@",request.responseJsonObject);
        WBStationInfoModel *model = [WBStationInfoModel yy_modelWithJSON:request.responseJsonObject];
        _typeLabel.text = model.name;
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
    
    FMAsyncUsersAPI * usersApi = [FMAsyncUsersAPI new];
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [usersApi startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * userArr = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"]
                                : request.responseJsonObject;
        NSLog(@"%@",request.responseJsonObject);
        NSMutableArray *tempDataSource = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in userArr) {
            UserModel * model = [UserModel yy_modelWithJSON:dic];
            [tempDataSource addObject:model];
        }
        self.dataSource = tempDataSource;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.usersTableView reloadData];
        });
        [SXLoadingView hideProgressHUD];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        [SXLoadingView showAlertHUD:WBLocalizedString(@"error", nil) duration:1];
        NSLog(@"%@",request.error);
        NSLog(@"FMAsyncUsersAPI 失败");
    }];
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (IBAction)addBtnClick:(id)sender {
    FMUserAddVC * addVC = [[FMUserAddVC alloc]init];
    [self.navigationController pushViewController:addVC animated:YES];
}

-(void)backbtnClick:(UIButton *)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FMUserSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMUserSettingCell class])];
    if (!cell) {
        cell = (FMUserSettingCell *) [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FMUserSettingCell class]) owner:self options:nil] lastObject];
    }
    UserModel * model = self.dataSource[indexPath.row];
//    if (model.global) {
//        cell.wxLabel.text = @"nil";
//    }else{
//        cell.wxLabel.text = @"微信未绑定";
//    }
    cell.userImageVIew.image = [UIImage imageForName:model.username size:cell.userImageVIew.bounds.size];
    cell.userNameLb.text = model.username;
    if ([model.isAdmin boolValue]&& [model.isFirstUser boolValue]) {
        cell.roleLb.text = WBLocalizedString(@"administrator", nil);
    }else{
        cell.roleLb.text = @"普通用户";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (IBAction)backButtonClick:(UIButton *)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
