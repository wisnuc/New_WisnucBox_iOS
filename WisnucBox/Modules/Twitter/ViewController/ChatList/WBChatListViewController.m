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

@interface WBChatListViewController () <UITableViewDataSource,UITableViewDelegate,ChatListAddUserEndDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic)MDCFloatingButton *addButton;
@property (nonatomic)NSMutableArray *boxDataArray;
@end

@implementation WBChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addButton];
 
    [self initMjFreshHeader];
 
//    [self initMjFreshFooter];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getBoxesListData];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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

- (void)getBoxesListData{
    if (!WB_UserService.currentUser.cloudToken) {
        [SXLoadingView showProgressHUDText:@"非微信远程登录暂无法使用" duration:1.2f];
        return ;
    }
    [[WBGetBoxesAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSArray * array = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"]
        : request.responseJsonObject;
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
        [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
           WBBoxesModel *model = [WBBoxesModel modelWithDictionary:obj];
            [dataArray addObject:model];
        }];
        self.boxDataArray = dataArray;
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
        self.boxDataArray = dataArray;
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)didTapAdd:(MDCFloatingButton *)sender{
    if (!WB_UserService.currentUser.cloudToken) {
        [SXLoadingView showProgressHUDText:@"非微信远程登录暂无法使用" duration:1.2f];
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
    cell.nameLabel.text = boxesModel.name;
    if (boxesModel.tweet) {
       
        if (boxesModel.tweet.list.count>0) {
            cell.detailLabel.text = @"[图片]";
            [boxesModel.tweet.list enumerateObjectsUsingBlock:^(WBTweetlistModel *listModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!listModel.metadata) {
                    cell.detailLabel.text = @"[文件]";
                    *stop = YES;
                }
            }];
            long long tweetTime = [boxesModel.tweet.ctime longLongValue];

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.S"];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:tweetTime];
            
            NSString *formattedDateString = [dateFormatter stringFromDate:date];
            NSLog(@"formattedDateString: %@", formattedDateString);
   
            cell.timeLable.text = [self getReleaseTime:tweetTime];
        }
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

- (NSString *)getReleaseTime:(long long)releaseTime
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //dateFormat时间样式属性,传入格式必须按这个
//    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.S";
    
    //locale："区域；场所"
    formatter.locale = [NSLocale currentLocale];
    
    //发布时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(releaseTime/1000.0)];
    
    //现在时间
    NSDate *now = [NSDate date];
    
    //发布时间到现在间隔多长时间，用timeIntervalSinceDate
    NSTimeInterval interval = [now timeIntervalSinceDate:date];
    
    NSString *format;
    
    if (interval <= 60) {
        
        format = @"刚刚";
        
    } else if(interval <= 60*60){
        
        format = [NSString stringWithFormat:@"%.f分钟前",interval/60];
        
    } else if(interval <= 60*60*24){
        
        format = [NSString stringWithFormat:@"%.f小时前",interval/3600];
        
    } else if (interval <= 60*60*24*7){
        
        format = [NSString stringWithFormat:@"%d天前",
                  (int)interval/(60*60*24)];
        
    } else if (interval > 60*60*24*7 & interval <= 60*60*24*30 ){
        
        format = [NSString stringWithFormat:@"%d周前",
                  (int)interval/(60*60*24*7)];
        
    }else if(interval > 60*60*24*30 ){
        
        format = [NSString stringWithFormat:@"%d月前",
                  (int)interval/(60*60*24*30)];
        
    }
    
    return format;
    
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
