//
//  WBChatListAddUserViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/29.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatListAddUserViewController.h"
#import "UserModel.h"
#import "WBChatListAddUserTableViewCell.h"
#import "WBGetBoxesAPI.h"
#import "WBUpdateBoxAPI.h"
#import "WBBoxUserAPI.h"

@interface WBChatListAddUserViewController ()<UITableViewDelegate,UITableViewDataSource,BEMCheckBoxDelegate>
@property (nonatomic)NSMutableArray *userArray;
@property (nonatomic)NSMutableArray *choosedUserArray;
@property (nonatomic)NSMutableArray *exsitDataArray;
@property (nonatomic)UITableView *tableView;
@end

@implementation WBChatListAddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarContent];
    [self setTitleText];
    if ((WB_UserService.currentUser.isAdmin || WB_UserService.currentUser.isFirstUser) && _type != WBUserAddressBookDelete) {
        [self getUserInfo];
    }else if ((WB_UserService.currentUser.isAdmin || WB_UserService.currentUser.isFirstUser) && _type == WBUserAddressBookDelete){
        [self getDeleteInfo];
    }
   
    [self.view addSubview:self.tableView];
}

- (void)setTitleText{
    switch (_type) {
        case WBUserAddressBookCreat:
            self.title = @"创建群";
            break;
        case WBUserAddressBookAdd:
            self.title = @"加入新成员";
            break;
        case WBUserAddressBookDelete:
            self.title = @"删除群成员";
            break;
        default:
            break;
    }
}

- (void)getUserInfo{
    @weaky(self)
    if (!WB_UserService.currentUser.cloudToken) {
        [SXLoadingView showProgressHUDText:@"本地连接暂无法使用" duration:1.2f];
        return;
    }
//    if (WB_UserService.currentUser.isCloudLogin) {
        NSMutableArray *tempDataSource = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *chooseUserSource = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *exsitDataSource = [NSMutableArray arrayWithCapacity:0];
        
        [[WBBoxUserAPI userApiWithGuid:WB_UserService.currentUser.guid]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSArray *array = request.responseJsonObject[@"data"];
            [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                WBBoxesUsersModel *model = [WBBoxesUsersModel modelWithDictionary:dic];
                [tempDataSource addObject:model];
                if(_type == WBUserAddressBookCreat || _type == WBUserAddressBookAdd){
                    if ([model.userId isEqualToString:WB_UserService.currentUser.guid]) {
                        [chooseUserSource addObject:model];
                        [exsitDataSource addObject:model];
                    }
                    [_boxModel.users enumerateObjectsUsingBlock:^(WBBoxesUsersModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if([obj.userId isEqualToString:model.userId]){
                            if (![chooseUserSource containsObject:model]) {
                                [chooseUserSource addObject:model];
                                [exsitDataSource addObject:model];
                            }
                        }
                    }];
                }
            }];
            self.userArray = tempDataSource;
            self.choosedUserArray = chooseUserSource;
            self.exsitDataArray = exsitDataSource;
            [weak_self reloadData];
            NSLog(@"%@",request.responseJsonObject);
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
            [weak_self reloadData];
        }];
//    }
//
//    else{
//    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
//        [[FMAsyncUsersAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//            NSLog(@"%@",request.responseJsonObject);
//            NSArray * userArr = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"]
//            : request.responseJsonObject;
//            NSLog(@"%@",request.responseJsonObject);
//            NSMutableArray *tempDataSource = [NSMutableArray arrayWithCapacity:0];
//            NSMutableArray *chooseUserSource = [NSMutableArray arrayWithCapacity:0];
//            NSMutableArray *exsitDataSource = [NSMutableArray arrayWithCapacity:0];
//
//            for (NSDictionary * dic in userArr) {
//                UserModel * model = [UserModel modelWithJSON:dic];
//                if (model.global) {
//                        [tempDataSource addObject:model];
//                    if(_type == WBUserAddressBookCreat || _type == WBUserAddressBookAdd){
//                    if ([model.uuid isEqualToString:WB_UserService.currentUser.uuid]) {
//                        [chooseUserSource addObject:model];
//                        [exsitDataSource addObject:model];
//                    }
//
//                    if([_boxModel.users containsObject:model.global.guid]){
//                        if (![chooseUserSource containsObject:model]) {
//                            [chooseUserSource addObject:model];
//                            [exsitDataSource addObject:model];
//                        }
//                    }
//                }
//            }
//        }
//            self.userArray = tempDataSource;
//            self.choosedUserArray = chooseUserSource;
//            self.exsitDataArray = exsitDataSource;
//            [weak_self reloadData];
//        } failure:^(__kindof JYBaseRequest *request) {
//             NSLog(@"%@",request.error);
//           [weak_self reloadData];
//        }];
//    }
}

- (void)getDeleteInfo{
    if (!WB_UserService.currentUser.cloudToken) {
        [SXLoadingView showProgressHUDText:@"本地连接暂无法使用" duration:1.2f];
        return;
    }
    NSMutableArray *tempDataSource = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *chooseUserSource = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *exsitDataSource = [NSMutableArray arrayWithCapacity:0];
    [_boxModel.users enumerateObjectsUsingBlock:^(WBBoxesUsersModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempDataSource addObject:obj];
    }];
    self.userArray = tempDataSource;
    self.choosedUserArray = chooseUserSource;
    self.exsitDataArray = exsitDataSource;
    [self reloadData];
}

- (void)reloadData{
    [self.tableView reloadData];
    [SXLoadingView hideProgressHUD];
}

- (void)setNavigationBarContent{
    UIButton * leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 24)];
    leftButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [leftButton setTitleColor:kTitleTextColor forState:UIControlStateNormal];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [leftButton setEnlargeEdgeWithTop:5 right:10 bottom:5 left:5];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    

    UIButton * rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 24)];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [rightButton setTitleColor:COR1 forState:UIControlStateNormal];
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton setEnlargeEdgeWithTop:5 right:10 bottom:5 left:5];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)leftButtonClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)rightButtonClick:(UIButton *)sender{
 
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    switch (_type) {
        case WBUserAddressBookCreat:{
            [self creatBoxAction];
        }
            break;
            
        case WBUserAddressBookAdd:{
            [self addUserAction];
        }
            break;
            
        case WBUserAddressBookDelete:{
            [self deleteUserAction];
        }
            break;
            
        default:
            break;
    }
}

- (void)deleteUserAction{
    if (self.choosedUserArray.count==0)return;
    @weaky(self)
    NSMutableArray *globalArray = [NSMutableArray arrayWithCapacity:0];
    [self.choosedUserArray enumerateObjectsUsingBlock:^(WBBoxesUsersModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [globalArray addObject:obj.userId];
    }];
    
    if (globalArray && globalArray.count>0) {
        NSArray *arr = [NSArray arrayWithArray:globalArray];
        [[WBUpdateBoxAPI updateApiWithBoxuuid:_boxModel.uuid Users:arr Option:@"delete"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.responseJsonObject);
            if (_endDelegate && [_endDelegate respondsToSelector:@selector(endAddUser)]) {
                [weak_self.endDelegate endAddUser];
            }
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
        }];
    }
}

- (void)addUserAction{
    
    if (self.exsitDataArray.count == self.choosedUserArray.count)return;
    @weaky(self)
    NSMutableArray *globalArray = [NSMutableArray arrayWithCapacity:0];
    [self.choosedUserArray enumerateObjectsUsingBlock:^(WBBoxesUsersModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [globalArray addObject:obj.userId];
    }];
    
    if (globalArray && globalArray.count>1) {
        NSArray *arr = [NSArray arrayWithArray:globalArray];
    [[WBUpdateBoxAPI updateApiWithBoxuuid:_boxModel.uuid Users:arr Option:@"add"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        if (_endDelegate && [_endDelegate respondsToSelector:@selector(endAddUser)]) {
            [weak_self.endDelegate endAddUser];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
    }
}

- (void)creatBoxAction{
    @weaky(self)

    if (self.choosedUserArray.count == 1 && [((WBBoxesUsersModel *)self.choosedUserArray[0]).userId isEqualToString:WB_UserService.currentUser.guid]) {
        [SXLoadingView showProgressHUDText:@"您尚未选择其他用户" duration:1.2f];
        return;
    }
    
    NSMutableArray *globalArray = [NSMutableArray arrayWithCapacity:0];
    [self.choosedUserArray enumerateObjectsUsingBlock:^(WBBoxesUsersModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [globalArray addObject:obj.userId];
    }];
    
    if (globalArray && globalArray.count>1) {
        NSArray *arr = [NSArray arrayWithArray:globalArray];
        [[WBGetBoxesAPI creatApiWithUsers:arr BoxName:nil] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.responseJsonObject);
            if (_endDelegate && [_endDelegate respondsToSelector:@selector(endAddUser)]) {
                [weak_self.endDelegate endAddUser];
            }
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
        }];
    }else{
        [SXLoadingView showProgressHUDText:@"创建群失败" duration:1.2f];
    }
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WBChatListAddUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBChatListAddUserTableViewCell class])];
    if (!cell) {
        cell = (WBChatListAddUserTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBChatListAddUserTableViewCell class]) owner:self options:nil]lastObject];
    }
    
    if (WB_UserService.currentUser.cloudToken) {
        WBBoxesUsersModel *model = self.userArray[indexPath.row];
        if (model.avatarUrl.length>0) {
            [cell.userImageView was_setCircleImageWithUrlString:model.avatarUrl placeholder:[UIImage imageForName:model.nickName size:cell.userImageView.bounds.size]];
        }else{
             cell.userImageView.image = [UIImage imageForName:model.nickName size:cell.userImageView.bounds.size];
        }
        
        cell.userNameLabel.text = model.nickName;
        cell.checkBox.delegate = self;
        switch (_type) {
            case WBUserAddressBookAdd:{
                [self.choosedUserArray enumerateObjectsUsingBlock:^(WBBoxesUsersModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //        NSLog(@"%@/%@",model.uuid ,obj.uuid);
                    if ([model.userId isEqualToString:obj.userId]) {
                        [cell.checkBox setOn:YES animated:NO];
                    }
                }];
            }
                break;
                
            case WBUserAddressBookDelete:{
                
            }
                break;
                
            case WBUserAddressBookCreat:{
                [self.choosedUserArray enumerateObjectsUsingBlock:^(WBBoxesUsersModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //        NSLog(@"%@/%@",model.uuid ,obj.uuid);
                    if ([model.userId isEqualToString:obj.userId]) {
                        [cell.checkBox setOn:YES animated:NO];
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (WB_UserService.currentUser.cloudToken) {
         WBBoxesUsersModel *model = self.userArray[indexPath.row];
        WBChatListAddUserTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
        switch (_type) {
            case WBUserAddressBookAdd:{
                if (!cell.checkBox.on) {
                    [cell.checkBox setOn:YES animated:YES];
                    if (model.userId.length >0) {
                        [self.choosedUserArray addObject:model];
                    }
                }else{
                    if ([model.userId isEqualToString:WB_UserService.currentUser.guid] || [_exsitDataArray containsObject:model]) {
                        [cell.checkBox setEnabled:NO];
                    }else{
                        [cell.checkBox setOn:NO animated:YES];
                        [self.choosedUserArray removeObject:model];
                    }
                }
            }
                break;
            case WBUserAddressBookDelete:{
                if (!cell.checkBox.on){
                    [cell.checkBox setOn:YES animated:YES];
                    [self.choosedUserArray addObject:model];
                }
                else
                {
                    [cell.checkBox setOn:NO animated:YES];
                    [self.choosedUserArray removeObject:model];
                }
            }
                break;
                
            case WBUserAddressBookCreat:{
                if (!cell.checkBox.on) {
                    [cell.checkBox setOn:YES animated:YES];
                    if (model.userId.length >0) {
                        [self.choosedUserArray addObject:model];
                    }
                }else{
                    if ([model.userId isEqualToString:WB_UserService.currentUser.guid] || [_exsitDataArray containsObject:model]) {
                        [cell.checkBox setEnabled:NO];
                    }else{
                        [cell.checkBox setOn:NO animated:YES];
                        [self.choosedUserArray removeObject:model];
                    }
                }
            }
                break;
                
                
            default:
                break;
        }
    }
}


- (NSMutableArray *)userArray{
    if (!_userArray) {
        _userArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _userArray;
}

- (NSMutableArray *)choosedUserArray{
    if (!_choosedUserArray) {
        _choosedUserArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _choosedUserArray;
}

- (NSMutableArray *)exsitDataArray{
    if (!_exsitDataArray) {
        _exsitDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _exsitDataArray;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

@end
