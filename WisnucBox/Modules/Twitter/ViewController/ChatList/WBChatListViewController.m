//
//  WBChatListViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/16.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatListViewController.h"
#import "WBChatListTableViewCell.h"
#import "WBChatViewController.h"
#import "WBGetBoxesAPI.h"
#import "WBBoxesModel.h"
#import "WBChatListAddUserViewController.h"
#import "MQTTClientManagerDelegate.h"
#import "MQTTClientManager.h"

@interface WBChatListViewController () <UITableViewDataSource,UITableViewDelegate,ChatListAddUserEndDelegate,MQTTClientManagerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic)MDCFloatingButton *addButton;
@property (nonatomic)NSMutableArray *boxDataArray;

@end

@implementation WBChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    if (!WB_UserService.currentUser.cloudToken) {
        [SXLoadingView showProgressHUDText:@"本地连接暂不能使用私友群功能" duration:1.2f];
        return ;
    }
    //    [self.view addSubview:self.addButton];
    
    [self initMjFreshHeader];
    
    //    [self initMjFreshFooter];
    if (WB_UserService.currentUser.guid.length>0) {
        [self didMQTTServerJoinIn];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self createNavBtns];
    [self getBoxesListData];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)createNavBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    [rightBtn setImage:[UIImage imageNamed:@"creat_box"] forState:UIControlStateNormal];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"%@",phoneVersion);
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    if([phoneVersion floatValue]>=11.0){
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0,0, -10);
    }
    [rightBtn addTarget:self action:@selector(didTapAdd:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setEnlargeEdgeWithTop:10 right:5 bottom:5 left:5];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightItem,negativeSpacer,nil];
}


- (void)initMjFreshHeader{
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getBoxesListData];
        [self.tableView.mj_header endRefreshing];
    }];
    
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = KDefaultOffset;
    
}

- (void)initMjFreshFooter{
    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
        
    }];
}

- (void)didMQTTServerJoinIn{
    NSString *topic = [NSString stringWithFormat:@"client/user/%@/box",WB_UserService.currentUser.guid];
    [[MQTTClientManager shareInstance]registerDelegate:self];
    [[MQTTClientManager shareInstance]loginWithIp:KMQTTHOST port:KMQTTPORT userName:nil password:nil topic:topic];
}

- (void)getBoxesListData{
    if (!WB_UserService.currentUser.cloudToken) {
        //        [SXLoadingView showProgressHUDText:@"非微信登录暂不能使用私友群功能" duration:1.2f];
        return;
    }
    @weaky(self)
    [[WBGetBoxesAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSArray * array = WB_UserService.currentUser.cloudToken ? request.responseJsonObject[@"data"]
        : request.responseJsonObject;
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
        [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WBBoxesModel *model = [WBBoxesModel modelWithDictionary:obj];
            [dataArray addObject:model];
        }];
        self.boxDataArray = dataArray;
        [self.tableView.mj_header endRefreshing];
        [weak_self sortDataSouce];
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"失败,%@",serializedData);
        }
        [SXLoadingView showProgressHUDText:@"获取聊天列表失败，请重新刷新" duration:1.2f];
//        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
//        self.boxDataArray = dataArray;
//        [self.tableView.mj_header endRefreshing];
//        [self.tableView reloadData];
    }];
}

- (void)sortDataSouce{
    NSComparator cmptr = ^(WBBoxesModel * model1, WBBoxesModel * model2){
        //        if (model1.tweet.ctime  < model2.tweet.ctime) {
        //            return (NSComparisonResult)NSOrderedDescending;
        //        }
        if (model1.tweet.ctime < model2.tweet.ctime) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    [self.boxDataArray sortUsingComparator:cmptr];
    NSMutableArray *ctimeArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *ctimeNoArray = [NSMutableArray arrayWithCapacity:0];
    [self.boxDataArray enumerateObjectsUsingBlock:^(WBBoxesModel * model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (!model.tweet.ctime ||model.tweet.ctime == 0) {
            [ctimeNoArray addObject:model];
        }else{
            [ctimeArray addObject:model];
        }
    }];
    [self.boxDataArray removeAllObjects];
    [self.boxDataArray addObjectsFromArray:ctimeArray];
    [self.boxDataArray addObjectsFromArray:ctimeNoArray];
    [self.tableView reloadData];
}

- (void)didTapAdd:(UIButton *)sender{
    if (!WB_UserService.currentUser.cloudToken) {
        [SXLoadingView showProgressHUDText:@"本地连接暂无法使用" duration:1.2f];
        return;
    }
    WBChatListAddUserViewController *addUserViewController = [[WBChatListAddUserViewController alloc]init];
    addUserViewController.type = WBUserAddressBookCreat;
    addUserViewController.endDelegate = self;
    NavViewController *navi = [[NavViewController alloc]initWithRootViewController:addUserViewController];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (void)endAddUser{
    [self getBoxesListData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.boxDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WBChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBChatListTableViewCell class])];
    if (!cell) {
        cell = (WBChatListTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBChatListTableViewCell class]) owner:self options:nil]lastObject];
    }
    
    WBBoxesModel *boxesModel = self.boxDataArray[indexPath.row];
    NSInteger n = MIN(boxesModel.users.count, 5);
    float r = 20 * n / (2.5 * n - 1.5);
    [boxesModel.users enumerateObjectsUsingBlock:^(WBBoxesUsersModel *userModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx<= n - 1){
            float deg =  M_PI * ((float)idx * 2 / n - 1 / 4);
            float top = (1 - cosf(deg)) * (20 - r);
            float left = (1 + sinf(deg)) * (20 - r);
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, top, r *2, r*2)];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = r;
            imageView.layer.borderWidth = 0.5f;
            imageView.layer.borderColor = [UIColor whiteColor].CGColor;
            [imageView was_setCircleImageWithUrlString:userModel.avatarUrl placeholder:[UIImage imageWithColor:RGBACOLOR(0, 0, 0, 0.37)]];
            [cell.leftImageView addSubview:imageView];
        }
    }];
    
    cell.nameLabel.text = boxesModel.name;
    NSMutableDictionary *userDefaultsDic = [kUserDefaults objectForKey:WB_UserService.currentUser.guid];
    NSNumber *unreadMessageNumber =userDefaultsDic[boxesModel.uuid];
    if (unreadMessageNumber) {
        [self updateTableViewCell:cell forCount:[unreadMessageNumber unsignedIntegerValue]];
    }
    
    if (boxesModel.tweet) {
        if (boxesModel.tweet.list.count>0) {
            cell.detailLabel.text = @"[图片]";
            [boxesModel.tweet.list enumerateObjectsUsingBlock:^(WBTweetlistModel *listModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!listModel.metadata) {
                    cell.detailLabel.text = @"[文件]";
                    *stop = YES;
                }
            }];
        }
    }
    
    long long tweetTime = boxesModel.tweet.ctime;
    cell.timeLable.text = [NSString getReleaseTime:tweetTime];
    if (![boxesModel.station.isOnline boolValue]) {
        cell.timeLable.text = @"已离线";
    }
    if (boxesModel.name.length == 0|| !boxesModel.name){
        cell.nameLabel.text = [NSString stringWithFormat:@"群聊(%ld)",(unsigned long)boxesModel.users.count];
        
        switch (boxesModel.users.count) {
            case 0:
                break;
            case 1:
                cell.nameLabel.text = [NSString stringWithFormat:@"%@",((WBBoxesUsersModel *)boxesModel.users[0]).nickName];
                break;
            case 2:
                cell.nameLabel.text = [NSString stringWithFormat:@"%@、%@",((WBBoxesUsersModel *)boxesModel.users[0]).nickName,((WBBoxesUsersModel *)boxesModel.users[1]).nickName];
                break;
            case 3:
                cell.nameLabel.text = [NSString stringWithFormat:@"%@、%@、%@",((WBBoxesUsersModel *)boxesModel.users[0]).nickName,((WBBoxesUsersModel *)boxesModel.users[1]).nickName,((WBBoxesUsersModel *)boxesModel.users[2]).nickName];
                break;
            case 4:
                cell.nameLabel.text = [NSString stringWithFormat:@"%@、%@、%@、%@",((WBBoxesUsersModel *)boxesModel.users[0]).nickName,((WBBoxesUsersModel *)boxesModel.users[1]).nickName,((WBBoxesUsersModel *)boxesModel.users[2]).nickName,((WBBoxesUsersModel *)boxesModel.users[3]).nickName];
                break;
            case 5:
                cell.nameLabel.text = [NSString stringWithFormat:@"%@、%@、%@、%@、%@...",((WBBoxesUsersModel *)boxesModel.users[0]).nickName,((WBBoxesUsersModel *)boxesModel.users[1]).nickName,((WBBoxesUsersModel *)boxesModel.users[2]).nickName,((WBBoxesUsersModel *)boxesModel.users[3]).nickName,((WBBoxesUsersModel *)boxesModel.users[4]).nickName];
                break;
            default:
                cell.nameLabel.text = [NSString stringWithFormat:@"%@、%@、%@、%@、%@...",((WBBoxesUsersModel *)boxesModel.users[0]).nickName,((WBBoxesUsersModel *)boxesModel.users[1]).nickName,((WBBoxesUsersModel *)boxesModel.users[2]).nickName,((WBBoxesUsersModel *)boxesModel.users[3]).nickName,((WBBoxesUsersModel *)boxesModel.users[4]).nickName];
                break;
        }
        
    }
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WBBoxesModel *model = self.boxDataArray[indexPath.row];
    WBChatListTableViewCell * cell = (WBChatListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    WBChatViewController *chatVC = [[WBChatViewController alloc]init];
    chatVC.title = cell.nameLabel.text;
    chatVC.boxModel = model;
    [self.navigationController pushViewController:chatVC animated:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *userDefaultsDic = [kUserDefaults objectForKey:WB_UserService.currentUser.guid];
        if (!userDefaultsDic) {
            return ;
        }
        NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionaryWithDictionary:userDefaultsDic];
        NSNumber *unreadMessageNumber = userDefaultsDic[model.uuid];
        if (unreadMessageNumber) {
            NSNumber *unreadNumber = @0;
            [resultDictionary setObject:unreadNumber forKey:model.uuid];
        }
        [kUserDefaults setObject:resultDictionary forKey:WB_UserService.currentUser.guid];
        [kUserDefaults synchronize];
    });
}

- (void)messageTopic:(NSString *)topic jsonStr:(NSString *)jsonStr{
    [KDefaultNotificationCenter postNotificationName:kBoxMQTTFresh object:jsonStr];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",array);
    NSMutableArray *uuidArray = [NSMutableArray arrayWithCapacity:0];
    
    __block NSMutableDictionary *userDefaultsDic = [kUserDefaults objectForKey:WB_UserService.currentUser.guid];
    if (!userDefaultsDic) {
        userDefaultsDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:userDefaultsDic];
    @weaky(self)
    __block NSUInteger unreadIntager = 0;
    
    [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull rootStop) {
        WBBoxesModel *model = [WBBoxesModel modelWithDictionary:obj];
        [self.boxDataArray enumerateObjectsUsingBlock:^(WBBoxesModel *boxModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([boxModel.uuid isEqualToString:model.uuid]) {
                [weak_self.boxDataArray removeObjectAtIndex:idx];
                [weak_self.boxDataArray insertObject:model atIndex:0];
                __block BOOL isSelfSender = NO;
//                if ([model.tweet.tweeter.tweeterId isKindOfClass:[NSString class]]) {
//                    NSString *tweeterId = (NSString *)model.tweet.tweeter;
                    if ([model.tweet.tweeter.tweeterId isEqualToString:WB_UserService.currentUser.guid]) {
                        [weak_self.tableView reloadData];
                        *stop = YES;
//                        *rootStop = YES;
                        isSelfSender = YES;
                    }
//                }
                if (!isSelfSender) {
                NSNumber *unreadMessageNumber =userDefaultsDic[model.uuid];
                NSLog(@"😁%@",unreadMessageNumber);
                if (unreadMessageNumber) {
                    unreadIntager = [unreadMessageNumber unsignedIntegerValue];
                }
                unreadIntager ++;
                NSNumber *unreadNumber = [NSNumber numberWithUnsignedInteger:unreadIntager];
                NSLog(@"%@",userDefaultsDic);
                [resultDic setObject:unreadNumber forKey:model.uuid];
                [weak_self.tableView reloadData];
                }
            }
            [uuidArray addObject:boxModel.uuid];
        }];
        
        if (![uuidArray containsObject:model.uuid]) {
            NSNumber *unreadMessageNumber =userDefaultsDic[model.uuid];
            NSLog(@"😁%@",unreadMessageNumber);
            if (unreadMessageNumber) {
                unreadIntager = [unreadMessageNumber unsignedIntegerValue];
            }
            unreadIntager ++;
            NSNumber *unreadNumber = [NSNumber numberWithUnsignedInteger:unreadIntager] ;
            NSLog(@"%@",userDefaultsDic);
            [resultDic setObject:unreadNumber forKey:model.uuid];
            [weak_self.boxDataArray insertObject:model atIndex:0];
            [weak_self.tableView reloadData];
        }
    }];
    [kUserDefaults setObject:resultDic forKey:WB_UserService.currentUser.guid];
    [kUserDefaults synchronize];
}

- (void)saveUnreadMessageIndex{
    
}

- (void)updateTableViewCell:(WBChatListTableViewCell *)cell forCount:(NSUInteger)count
{
    // Count > 0, show count
    if (count > 0) {
        
        // Create label
        CGFloat fontSize = 14;
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor redColor];
        
        // Add count to label and size to fit
        label.text = [NSString stringWithFormat:@"%@", @(count)];
        [label sizeToFit];
        
        //         Adjust frame to be square for single digits or elliptical for numbers > 9
        CGRect frame = label.frame;
        frame.size.height += (int)(0.4*fontSize);
        frame.size.width = (count <= 9) ? frame.size.height : frame.size.width + (int)fontSize;
        frame.origin.x = 0;
        frame.origin.y = 0;
        label.frame = frame;
        
        //         Set radius and clip to bounds
        label.layer.cornerRadius = frame.size.height/2.0;
        label.clipsToBounds = true;
        //        NSLog(@"%@",NSStringFromCGRect(label.frame));
        // Show label in accessory view and remove disclosure
        [cell.badgeLabel addSubview:label];
        //        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Count = 0, show disclosure
    //    else {
    //        cell.accessoryView = nil;
    //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64 - 48) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (MDCFloatingButton *)addButton{
    if (!_addButton) {
        _addButton = [[MDCFloatingButton alloc] initWithFrame:CGRectMake(__kWidth - 63 -16, __kHeight - 63 -16 -64 -44, 63, 63) shape:MDCFloatingButtonShapeDefault];
        _addButton.mode = MDCFloatingButtonModeNormal;
        [_addButton setTitle:nil forState:UIControlStateNormal];
        [_addButton addTarget:self
                       action:@selector(didTapAdd:)
             forControlEvents:UIControlEventTouchUpInside];
        UIImage *plusImage = [UIImage imageNamed:@"ic_add_white"];
        [_addButton setImage:plusImage forState:UIControlStateNormal];
        [_addButton setBackgroundColor:COR1];
    }
    return _addButton;
}

- (NSMutableArray *)boxDataArray{
    if (!_boxDataArray) {
        _boxDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _boxDataArray;
}

@end

