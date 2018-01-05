//
//  WBServiceSettingViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBServiceSettingViewController.h"
#import "FMSetting.h"

@interface WBServiceSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic)BOOL miniDlnaSwitchOn;
@property (nonatomic)BOOL sambaSwitchOn;
@end

@implementation WBServiceSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务管理";
    self.tableView.delegate =self;
    self.tableView.dataSource =self;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    [self getData];
    [self.tableView reloadData];
    
}

- (void)getData{
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [[WBFeaturesDlnaStatusAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
       NSDictionary * responseDic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSString *status = responseDic[@"status"];
        BOOL swichOn;
        if ([status isEqualToString:@"active"]) {
            swichOn = YES;
        }else{
            swichOn = NO;
        }
        
        _miniDlnaSwitchOn = swichOn;
        [self.tableView reloadData];
        [SXLoadingView hideProgressHUD];
        
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
    }];
    
    [[WBFeaturesSambaStatusAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         NSDictionary * responseDic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSString *status = responseDic[@"status"];
        BOOL swichOn;
        if ([status isEqualToString:@"active"]) {
            swichOn = YES;
        }else{
            swichOn = NO;
        }
        [SXLoadingView hideProgressHUD];
        _sambaSwitchOn = swichOn;
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
    }];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"123"];
    switch (indexPath.row) {

        case 0:{
            cell.textLabel.text =  WBLocalizedString(@"samba_service", nil);
            cell.imageView.image = [UIImage imageNamed:@"samba_switch.png"];
            cell.contentView.layer.masksToBounds = YES;
            UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(__kWidth - 70, 16, 50, 40)];
            [switchBtn addTarget:self  action:@selector(sambaSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [switchBtn setOn:_sambaSwitchOn];
            if(!WB_UserService.isUserLogin) switchBtn.enabled = NO;
            if(WB_UserService.currentUser.isCloudLogin)
            {
                switchBtn.enabled = NO;
            }
            [cell.contentView addSubview:switchBtn];
        }
            
            break;
        case 1:{
            cell.textLabel.text =  WBLocalizedString(@"miniDLNA_service", nil);
            cell.imageView.image = [UIImage imageNamed:@"dlna_switch.png"];
            UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(__kWidth - 70, 16, 50, 40)];
            [switchBtn addTarget:self  action:@selector(miniDLNASwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [switchBtn setOn:_miniDlnaSwitchOn];
            if(!WB_UserService.isUserLogin) switchBtn.enabled = NO;
            if(WB_UserService.currentUser.isCloudLogin){
             switchBtn.enabled = NO;
            }
            [cell.contentView addSubview:switchBtn];
        }
            
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

-(void)sambaSwitchChanged:(UISwitch *)paramSender{
    BOOL isOn = paramSender.on;
    if (isOn) {
        [[WBFeaturesChangeAPI apiWithType:@"samba" Action:@"start"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _sambaSwitchOn = YES;
            [self.tableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
            _sambaSwitchOn = NO;
            [self.tableView reloadData];
        }];
    }else{
        [[WBFeaturesChangeAPI apiWithType:@"samba" Action:@"stop"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _sambaSwitchOn = NO;
            [self.tableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _sambaSwitchOn = YES;
            [self.tableView reloadData];
        }];
    }
}


-(void)miniDLNASwitchChanged:(UISwitch *)paramSender{
    BOOL isOn = paramSender.on;
    if (isOn) {
        [[WBFeaturesChangeAPI apiWithType:@"dlna" Action:@"start"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _miniDlnaSwitchOn = YES;
            [self.tableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _miniDlnaSwitchOn = NO;
            [self.tableView reloadData];
        }];
    }else{
        [[WBFeaturesChangeAPI apiWithType:@"dlna" Action:@"stop"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _miniDlnaSwitchOn = NO;
            [self.tableView reloadData];
        } failure:^(__kindof JYBaseRequest *request) {
            _miniDlnaSwitchOn = YES;
            [self.tableView reloadData];
        }];
    }
}



@end
