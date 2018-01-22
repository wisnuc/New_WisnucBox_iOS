//
//  FMUserLoginSettingVC.m
//  FruitMix
//
//  Created by JackYang on 2017/2/23.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMUserLoginSettingVC.h"
#import "FMUsersLoginMangeCell.h"
#import "FMUserLoginHeaderView.h"
#import "AppDelegate.h"
#import "FMLoginViewController.h"

@interface FMUserLoginSettingVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *usersLoginTable;
@property (weak, nonatomic) IBOutlet MDCFloatingButton *fabButton;

@property (nonatomic) NSMutableArray * dataSource;

@end

@implementation FMUserLoginSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账户管理";
    [self.usersLoginTable registerNib:[UINib nibWithNibName:@"FMUsersLoginMangeCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FMUsersLoginMangeCell class])];
    // Do any additional setup after loading the view from its nib.

    UIImage *plusImage = [UIImage imageNamed:@"ic_add_white"];
    [_fabButton setMaximumSize:CGSizeMake(63, 63) forShape:MDCFloatingButtonShapeDefault inMode:MDCFloatingButtonModeNormal];
    [_fabButton setImage:plusImage forState:UIControlStateNormal];
    [_fabButton setBackgroundColor:COR1];
}

- (void)dealloc{
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.cyl_tabBarController.tabBar setHidden:YES];
    [self getDataSource];
    [self.usersLoginTable reloadData];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)getDataSource{
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[[AppServices sharedService].userServices getAllLoginUser]];
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    for (WBUser * info in arr) {
        if(!info.bonjour_name)info.bonjour_name = @"未知设备";
        if ([[dic allKeys] containsObject:info.bonjour_name]) {
            NSMutableArray * temp = dic[info.bonjour_name];
            [temp addObject:info];
        }else{
            NSMutableArray * temp2 = [NSMutableArray arrayWithCapacity:0];
            [temp2 addObject:info];
            [dic setObject:temp2 forKey:info.bonjour_name];
        }
    }
    
    self.dataSource =  [NSMutableArray arrayWithArray:[dic allValues]];
}

- (IBAction)fabButtonClick:(MDCFloatingButton *)sender {
    FMLoginViewController *loginController = [[FMLoginViewController alloc]init];
    [self.navigationController pushViewController:loginController animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSMutableArray *)self.dataSource[section]).count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FMUsersLoginMangeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMUsersLoginMangeCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userHeaderIV.image = [UIImage imageForName:((WBUser *)(_dataSource[indexPath.section][indexPath.row])).userName size:cell.userHeaderIV.bounds.size];
    cell.userNameLb.text = ((WBUser *)(_dataSource[indexPath.section][indexPath.row])).userName;
    @weaky(MyAppDelegate);
    @weaky(self);
    cell.deleteBtnClick = ^(UIButton * btn){
       WBUser * info =  (WBUser *)(_dataSource[indexPath.section][indexPath.row]);
        if (IsEquallString(info.uuid, WB_UserService.currentUser.uuid)) {
            [SXLoadingView showProgressHUDText:@"无法删除当前登录用户" duration:1.2f];
            return ;
        }
         [SXLoadingView showProgressHUD:@"正在删除数据"];
        [[AppServices sharedService].userServices deleteUserWithUserId:info.uuid];//删除数据
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weak_self getDataSource];
            [_usersLoginTable reloadData];
            [SXLoadingView hideProgressHUD];
#warning user delete should logout
     
//                [PhotoManager shareManager].canUpload = NO;//停止上传
//                FMConfigInstance.userToken = @"";
//                [weak_MyAppDelegate resetDatasource];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [SXLoadingView hideProgressHUD];
//                    [weak_MyAppDelegate skipToLogin];
//                });
//            }else{
//                [weak_self getDataSource];
//                [tableView reloadData];

            [weak_MyAppDelegate leftMenuReloadData];
            
        });
    };
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 8;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString * str = ((WBUser *)(_dataSource[section][0])).bonjour_name;
    NSLog(@"%@",str);
    if(str){
        return [FMUserLoginHeaderView headerViewWithDeviceName:str DeviceSN:@""];
    }else{
        return [FMUserLoginHeaderView headerViewWithDeviceName:@"未知" DeviceSN:@""];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 8)];
}

@end
