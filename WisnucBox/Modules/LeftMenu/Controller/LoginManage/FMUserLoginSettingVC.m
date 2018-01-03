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

@interface FMUserLoginSettingVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *usersLoginTable;

@property (nonatomic) NSMutableArray * dataSource;

@end

@implementation FMUserLoginSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.usersLoginTable registerNib:[UINib nibWithNibName:@"FMUsersLoginMangeCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FMUsersLoginMangeCell class])];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.cyl_tabBarController.tabBar setHidden:YES];
    [self getDataSource];
    [self.usersLoginTable reloadData];
}

-(void)getDataSource{
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[[AppServices sharedService].userServices getAllLoginUser]];
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    for (WBUser * info in arr) {
        if(!info.bonjour_name)info.bonjour_name = @"未知设备,请删除后重新添加";
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSMutableArray *)self.dataSource[section]).count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FMUsersLoginMangeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMUsersLoginMangeCell class]) forIndexPath:indexPath];
    cell.userHeaderIV.image = [UIImage imageForName:((WBUser *)(_dataSource[indexPath.section][indexPath.row])).userName size:cell.userHeaderIV.bounds.size];
    cell.userNameLb.text = ((WBUser *)(_dataSource[indexPath.section][indexPath.row])).userName;
//    @weaky(MyAppDelegate);
//    @weaky(self);
    cell.deleteBtnClick = ^(UIButton * btn){
       WBUser * info =  (WBUser *)(_dataSource[indexPath.section][indexPath.row]);
        [SXLoadingView showProgressHUD:@"正在删除数据"];
        [[AppServices sharedService].userServices deleteUserWithUserId:info.uuid];//删除数据
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SXLoadingView hideProgressHUD];
#warning user delete should logout
//            if (IsEquallString(info.uuid, DEF_UUID)) {
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
//            }
//            [weak_MyAppDelegate reloadLeftUsers];
        });
    };
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 64;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 8;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString * str = ((WBUser *)(_dataSource[section][0])).bonjour_name;
    NSArray * tempArr = [str componentsSeparatedByString:@"."];
    if(tempArr.count > 2){
        NSString * str2 = tempArr[0];
        NSArray * tmp2 = [str2 componentsSeparatedByString:@"-"];
        NSString * name = tmp2[1];
        NSString * sn = tmp2[2];
        return [FMUserLoginHeaderView headerViewWithDeviceName:name DeviceSN:sn];
    }else
        return [FMUserLoginHeaderView headerViewWithDeviceName:str DeviceSN:@"未知"];
    
    
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 8)];
}

@end
