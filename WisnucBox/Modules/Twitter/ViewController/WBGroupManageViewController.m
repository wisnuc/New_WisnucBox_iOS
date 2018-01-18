//
//  WBGroupManageViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/18.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGroupManageViewController.h"

#define GeneralBottomHeight 30
#define UserNameLabelHeight 15
#define UserImageViewHeight 40

@interface WBGroupManageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic) NSMutableArray *userGroupArray;
@end

@implementation WBGroupManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"group_setting", nil);
    [self initView];
    NSArray *tmpArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    self.userGroupArray = [NSMutableArray arrayWithArray:tmpArray];
    [self.tableView reloadData];
//    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

- (void)initView{
    [self.view addSubview:self.tableView];
}

- (void)switchChanged:(UISwitch *)sender{
    
}

- (void)generalCellWithTabelViewCell:(UITableViewCell *)cell Title:(NSString *)title DetailText:(NSString *)detailText IsAccessoryDisclosureIndicator:(BOOL)isAccessoryDisclosureIndicator SwitchTag:(NSNumber *)switchTag{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = RGBACOLOR(0, 0, 0, 0.87f);
    cell.textLabel.text = title;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = RGBACOLOR(0, 0, 0, 0.54f);
    cell.detailTextLabel.text = detailText;
    if (isAccessoryDisclosureIndicator) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (switchTag) {
        UISwitch *settingSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(__kWidth - 16 - 50, 48/2 - 34/2, 50, 40)];
        settingSwitch.tag = [switchTag integerValue];
        [settingSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:settingSwitch];
    }
}

- (UIView *)generalHeaderViewWithTitle:(NSString *)title Message:(NSString *)message{
    UIView * headerView =  [[UIView alloc]init];
    headerView.backgroundColor  = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 48/2 - 14/2, 80, 14)];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = title;
    titleLabel.textColor = RGBACOLOR(0, 0, 0, 0.38f);
    [headerView addSubview:titleLabel];
    
    if (message && message.length >0) {
        UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, __kWidth - 80 *2 - 10 , 26)];
        messageLabel.center = CGPointMake(__kWidth/2, 48/2);
        messageLabel.font = [UIFont systemFontOfSize:14];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = kWhiteColor;
        messageLabel.text = message;
        messageLabel.backgroundColor = RGBACOLOR(0, 0, 0, 0.22f);
        messageLabel.layer.masksToBounds = YES;
        messageLabel.layer.cornerRadius = 2;
        [headerView addSubview:messageLabel];
    }
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            CGFloat rowHeight = kGeneralWidthHeight + (self.userGroupArray.count/4) *(UserNameLabelHeight + 40 + 12 + 20) + 10 + kGeneralWidthHeight + GeneralBottomHeight;
             return rowHeight;
        }
            break;
            
        default:
            return 48;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 47;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    switch (section) {
        case 3:
            return 80;
            break;
            
        default:
            return 1;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:{
            return [self generalHeaderViewWithTitle:@"群成员" Message:@"有2位新成员申请加入"];
        }
            break;
            
        case 1:{
            return [self generalHeaderViewWithTitle:@"属性" Message:nil];
        }
            break;
            
        case 2:{
            return [self generalHeaderViewWithTitle:@"消息通知" Message:nil];
        }
            break;
        case 3:{
            
            return [self generalHeaderViewWithTitle:@"群管理" Message:nil];
        }
            break;
            
        default:{
            UIView *headeView = [[UIView alloc]initWithFrame:CGRectZero];
            return headeView;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *identifer = @"groupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
    }
    switch (indexPath.section) {
        case 0:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 1:{
            switch (indexPath.row) {
                case 0:
                {
                    [self generalCellWithTabelViewCell:cell Title:@"群名称" DetailText:@"闻上大本营" IsAccessoryDisclosureIndicator:YES SwitchTag:nil];
                }
                    break;
                 case 1:
                {
                  
                    [self generalCellWithTabelViewCell:cell Title:@"设备信息" DetailText:@"WISNUC-HOME" IsAccessoryDisclosureIndicator:YES SwitchTag:nil];

                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2:{
            NSNumber *tagNumber = [NSNumber numberWithString:[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row]];
            [self generalCellWithTabelViewCell:cell Title:@"消息免打扰" DetailText:nil IsAccessoryDisclosureIndicator:NO SwitchTag:tagNumber];
        }
            break;
            
        case 3:{
            switch (indexPath.row) {
                case 0:{
                     NSNumber *tagNumber = [NSNumber numberWithString:[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row]];
                     [self generalCellWithTabelViewCell:cell Title:@"群邀请确认" DetailText:nil IsAccessoryDisclosureIndicator:NO SwitchTag:tagNumber];
                }

                    break;
                case 1:{
                    NSNumber *tagNumber = [NSNumber numberWithString:[NSString stringWithFormat:@"%d%d",indexPath.section,indexPath.row]];
                    [self generalCellWithTabelViewCell:cell Title:@"需要审核" DetailText:nil IsAccessoryDisclosureIndicator:NO SwitchTag:tagNumber];
                }
                    break;
                case 2:
                    [self generalCellWithTabelViewCell:cell Title:@"群转让" DetailText:nil IsAccessoryDisclosureIndicator:YES SwitchTag:nil];
                    break;
                    
                default:
                    break;
            }
          
        }
            break;
     
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = MainBackgroudColor;
    }
    return _tableView;
}

- (NSMutableArray *)userGroupArray{
    if (!_userGroupArray) {
        _userGroupArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _userGroupArray;
}

@end
