//
//  WBGroupManageViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/18.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGroupManageViewController.h"
#import "WBGroupSettingUserTableViewCell.h"
#import "WBChatListViewController.h"
#import "WBChatListAddUserViewController.h"
#import "WBStationManageRenameViewController.h"
#import "WBUpdateBoxAPI.h"
#import "WBGetBoxTokenAPI.h"
#import "WBGetOneBoxAPI.h"
#import "WBDeleteBoxAPI.h"

#define GeneralBottomHeight 30
#define UserNameLabelHeight 15
#define UserImageViewHeight 40

@interface WBGroupManageViewController ()<UITableViewDelegate,UITableViewDataSource,ReNameDelegate,ChatListAddUserEndDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic) NSMutableArray *userGroupArray;
@end

@implementation WBGroupManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"group_setting", nil);
    [self initView];
    [self getUserData];
   
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    GroupUserModel *model1 = [GroupUserModel new];
//    model1.userName = @"离开家";
//    model1.imageURL = @"http://www.mf08s.com/y/q/UploadFiles_q/20121005/2012100507413841.jpg";
//
//    GroupUserModel *model2 = [GroupUserModel new];
//    model2.userName = @"adgshja";
//    model2.imageURL = @"http://www.mf08s.com/y/q/UploadFiles_q/20121005/2012100507413803.jpg";
//
//    GroupUserModel *model3 = [GroupUserModel new];
//    model3.userName = @"科技爱好大的";
//    model3.imageURL = @"http://pic.qqtn.com/up/2018-1/2018011815282654933.jpg";
//
//    GroupUserModel *model4 = [GroupUserModel new];
//    model4.userName = @"打撒撒多";
//    model4.imageURL = @"http://www.qqzhi.com/uploadpic/2014-09-06/195035112.jpg";
//
//    GroupUserModel *model5 = [GroupUserModel new];
//    model5.userName = @"坎坎坷坷";
//    model5.imageURL = @"http://www.qqzhi.com/uploadpic/2014-09-06/195035637.jpg";
//
//    GroupUserModel *model6 = [GroupUserModel new];
//    model6.userName = @"呃呃呃";
//    model6.imageURL = @"http://www.qqzhi.com/uploadpic/2014-09-06/195034891.jpg";
//
//    GroupUserModel *model7 = [GroupUserModel new];
//    model7.userName = @"辣鸡";
//    model7.imageURL = @"http://www.qqzhi.com/uploadpic/2014-09-06/195035561.jpg";
//
//    GroupUserModel *model8 = [GroupUserModel new];
//    model8.userName = @"通天塔";
//    model8.imageURL = @"http://up.qqjia.com/z/19/tu21104_4.jpg";
//
//
////    NSArray *tmpArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
//    self.userGroupArray = [NSMutableArray arrayWithObjects:model1,model2,model3,model4,model5,model6,model7,model8,nil];
//
//    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

- (void)getUserData{
    NSMutableArray *userGroupArray = [NSMutableArray arrayWithCapacity:0];
    [_boxModel.users enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GroupUserModel *model = [GroupUserModel new];
        model.userName = obj;
        [userGroupArray addObject:model];
    }];
    self.userGroupArray = userGroupArray;
    [self.tableView reloadData];
}

- (void)initView{
    UIButton * rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 24)];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [rightButton setTitleColor:COR1 forState:UIControlStateNormal];
    [rightButton setTitle:@"退出" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton setEnlargeEdgeWithTop:5 right:10 bottom:5 left:5];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.view addSubview:self.tableView];
}

- (void)rightButtonClick:(UIButton *)sender{
    [[WBDeleteBoxAPI deleteBoxApiWithBoxuuid:_boxModel.uuid]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
         [SXLoadingView showProgressHUDText:@"该群已解散" duration:1.2f];
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[WBChatListViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
        
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        [SXLoadingView showProgressHUDText:@"退出群失败" duration:1.2f];
    }];
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
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

-(void)endAddUser{
    [self reNameComplete];
}

- (void)reNameComplete{
    if (_boxModel.uuid.length==0 ||!_boxModel.uuid) {
        return;
    }
    @weaky(self)
    [[WBGetOneBoxAPI getBoxApiWithBoxuuid:_boxModel.uuid] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         NSDictionary * responseDic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
         WBBoxesModel *model = [WBBoxesModel modelWithDictionary:responseDic];
        _boxModel = model;
        [weak_self getUserData];
        [KDefaultNotificationCenter postNotificationName:kDataChangedName object:model];
        NSLog(@"%@",request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            NSInteger addLine = 0;
            NSInteger index = self.userGroupArray.count % 4;
            if (index >= 3) {
                addLine = 1;
            }else if(index == 0){
                addLine = 1;
            }
            
            CGFloat rowHeight = kGeneralWidthHeight + (ceil(self.userGroupArray.count/4.0) + addLine) *(UserNameLabelHeight + 40 + 12 + 20) + 10 + kGeneralWidthHeight + GeneralBottomHeight;
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
    switch (indexPath.section) {
        case 1:
            {
                switch (indexPath.row) {
                    case 0:{
                        WBStationManageRenameViewController *renameVC = [[WBStationManageRenameViewController alloc]init];
                        renameVC.vcType = WBRenameVCTypeBoxName;
                        if (_boxModel.name && _boxModel.name.length>0) {
                            renameVC.stationName = _boxModel.name;
                        }
                        renameVC.boxuuid = _boxModel.uuid;
                        renameVC.delegate = self;
                        [self.navigationController.navigationBar setBarTintColor:COR1];
                        [self.navigationController pushViewController:renameVC animated:YES];
                      
                        
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            break;
            
        default:
            break;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *identifer = @"groupCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
    }
    @weaky(self)
    switch (indexPath.section) {
        case 0:{
            WBGroupSettingUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBGroupSettingUserTableViewCell class])];
            if (!cell) {
                cell = (WBGroupSettingUserTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBGroupSettingUserTableViewCell class]) owner:self options:nil]lastObject];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userArray =  _userGroupArray;
            cell.clickBlock = ^(NSInteger imageTag) {
#warning push
               NSLog(@"%ld",imageTag);
           
                
            };
            cell.addUserClickBlock = ^(WBGroupSettingUserTableViewCell *groupSettingUsercell) {
                WBChatListAddUserViewController *addUserViewController = [[WBChatListAddUserViewController alloc]init];
                addUserViewController.endDelegate = self;
                addUserViewController.type = WBUserAddressBookAdd;
                addUserViewController.boxModel = _boxModel;
                NavViewController *navi = [[NavViewController alloc]initWithRootViewController:addUserViewController];
                [self presentViewController:navi animated:YES completion:^{
                    
                }];
            };
            
            cell.removeUserClickBlock = ^(WBGroupSettingUserTableViewCell *groupSettingUsercell) {
                
            };
            return cell;
        }
            break;
            
        case 1:{
            switch (indexPath.row) {
                case 0:
                {
                    if (!_boxModel.name ||_boxModel.name.length==0) {
                     [self generalCellWithTabelViewCell:cell Title:@"群名称" DetailText:@"未设置" IsAccessoryDisclosureIndicator:YES SwitchTag:nil];
                    }else{
                      [self generalCellWithTabelViewCell:cell Title:@"群名称" DetailText:_boxModel.name IsAccessoryDisclosureIndicator:YES SwitchTag:nil];
                    }
                   
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
            NSNumber *tagNumber = [NSNumber numberWithString:[NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,indexPath.row]];
            [self generalCellWithTabelViewCell:cell Title:@"消息免打扰" DetailText:nil IsAccessoryDisclosureIndicator:NO SwitchTag:tagNumber];
        }
            break;
            
        case 3:{
            switch (indexPath.row) {
                case 0:{
                    NSNumber *tagNumber = [NSNumber numberWithString:[NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row]];
                     [self generalCellWithTabelViewCell:cell Title:@"群邀请确认" DetailText:nil IsAccessoryDisclosureIndicator:NO SwitchTag:tagNumber];
                }

                    break;
                case 1:{
                    NSNumber *tagNumber = [NSNumber numberWithString:[NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row]];
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
        if (CYL_IS_IOS_11) {
            _tableView.frame = CGRectMake(0, 0, __kWidth, __kHeight - 64);
        }
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
