
//
//  WBInviteWechatViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/1.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInviteWechatViewController.h"
#import "WBInviteWechatTableViewCell.h"
#import "WBStationTicketsAPI.h"
#import "TicketUserModel.h"
#import "WBStationTicketsAPI.h"
#import "WBStationTicketsWechatAPI.h"

@interface WBInviteWechatViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *dataArray;
@property (nonatomic) UIButton *inviteButton;
@property (nonatomic) NSString *ticketId;

@end

@implementation WBInviteWechatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LeftMenuInvitationString;
    [self initMjRefresh];
//    [self getData];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inviteButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)initMjRefresh{
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (self.dataArray.count >0) {
            [self.dataArray removeAllObjects];
        }
        [weakSelf getData];
    }];
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = KDefaultOffset;
    //    [self.tableView.mj_header beginRefreshing];
}

- (void)getData{
    @weaky(self);
    [self.dataArray removeAllObjects];
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [[WBStationTicketsAPI apiWithRequestMethodString:@"GET" Type:nil] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.responseJsonObject);
        NSArray *arr = request.responseJsonObject;
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            TicketStationModel *model = [TicketStationModel yy_modelWithDictionary:dic];
            [model.users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TicketUserModel *usersModel = obj;
                [usersModel setCreatedAt:model.createdAt];
                [usersModel setTicketId:model.ticketId];
//                NSLog(@"%@",obj);
                if (usersModel) {
                    [self.dataArray addObject:usersModel];
                }
            }];
        }];
        [weak_self sequenceDataSource];
        [weak_self endLoadData];
    } failure:^(__kindof JYBaseRequest *request) {
        [weak_self endLoadData];
        NSLog(@"%@",request.error);
    }];
}

- (void)sequenceDataSource{
    NSMutableArray *isPendingArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *isNotPendingArr = [NSMutableArray arrayWithCapacity:0];
    for (TicketUserModel * model  in self.dataArray) {
        if ([model.type isEqualToString:@"pending"]) {
            [isPendingArr addObject: model];
        }
        else{
            [isNotPendingArr addObject: model];
        }
    }
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:isPendingArr];
    [self.dataArray addObjectsFromArray:isNotPendingArr];
}

- (void)endLoadData{
    [SXLoadingView hideProgressHUD];
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

- (void)inviteButtonClick:(UIButton *)sender{
    @weaky(self);
    [SXLoadingView showProgressHUD:@""];
    [[WBStationTicketsAPI apiWithRequestMethodString:@"POST" Type:@"invite"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSDictionary *requestDic = request.responseJsonObject;
        NSString *urlString = requestDic[@"url"];
        NSString * ticketId = [urlString substringFromIndex:12];
        NSLog(@"%@",ticketId);
        [weak_self invitWechatWithTicketId:ticketId];
    } failure:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.error);
         [SXLoadingView hideProgressHUD];
         [SXLoadingView showProgressHUDText:WBLocalizedString(@"sharing_failed", nil) duration:1.3];
    }];
}

- (void)invitWechatWithTicketId:(NSString *)ticketId{
    _ticketId = ticketId;
    [SXLoadingView hideProgressHUD];
    WXMiniProgramObject *wxMiniProgram = [WXMiniProgramObject object];
    wxMiniProgram.webpageUrl = @"https://open.weixin.qq.com";
    wxMiniProgram.userName = WX_MiniProgram_OriginID;
    wxMiniProgram.path = [NSString stringWithFormat:@"pages/login/login?ticket=%@",ticketId];
    UIImage *image = [UIImage   imageNamed:@"invite_miniProgram.png"];
    NSData *imageData = UIImagePNGRepresentation(image);
    wxMiniProgram.hdImageData = imageData;
    
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.title = @"邀请您成为Wisnuc用户";
    mediaMessage.mediaObject = wxMiniProgram;
    mediaMessage.thumbData = nil;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.message = mediaMessage;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

#pragma tableViewDelegate;

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    @weaky(self);
    WBInviteWechatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBInviteWechatTableViewCell class])];
    if (!cell) {
        cell =  (WBInviteWechatTableViewCell *) [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([WBInviteWechatTableViewCell class]) owner:self options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TicketUserModel *usersModel = self.dataArray[indexPath.row];
    if ([usersModel.type isEqualToString:@"resolved"]) {
        cell.stateTypeLabel.text = WBLocalizedString(@"accepted", nil);
    }else if([usersModel.type isEqualToString:@"rejected"])
    {
        cell.stateTypeLabel.text = WBLocalizedString(@"refused", nil);
    }else if([usersModel.type isEqualToString:@"pending"])
    {
        [cell.rejectedButton setHidden:NO];
        [cell.resolvedButton setHidden:NO];
        [cell.stateTypeLabel setHidden:YES];
    }
    cell.nameLabel.text = usersModel.nickName;
    cell.timeLabel.text =  usersModel.createdAt;
    SDWebImageManager *manager = [SDWebImageManager sharedManager] ;
    [manager downloadImageWithURL:[NSURL URLWithString:usersModel.avatarUrl] options:0 progress:^(NSInteger   receivedSize, NSInteger expectedSize) {
        // progression tracking code
    }  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,   BOOL finished, NSURL *imageURL) {
        if (image) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *cellImage = [UIImage imageCirclewithImage:image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.leftImageView.image = cellImage;
                });
            });
        }
    }];

    cell.resolvedClickBlock = ^(WBInviteWechatTableViewCell *inviteCell){
        [SXLoadingView showProgressHUD:@""];
        [[WBStationTicketsWechatAPI apiWithTicketId:usersModel.ticketId Guid:usersModel.userId Isbind:YES] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.responseJsonObject);
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"accepted", nil) duration:1.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weak_self getData];
            });
           
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weak_self getData];
            });
        }];
    };
    
    cell.rejectedClickBlock = ^(WBInviteWechatTableViewCell *inviteCell) {
    
        [SXLoadingView showProgressHUD:@""];
        [[WBStationTicketsWechatAPI apiWithTicketId:usersModel.ticketId Guid:usersModel.userId Isbind:NO]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         [SXLoadingView hideProgressHUD];
         [SXLoadingView showProgressHUDText:WBLocalizedString(@"refused", nil) duration:1.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weak_self getData];
            });
            NSLog(@"%@",request.responseJsonObject);
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weak_self getData];
            });
            NSLog(@"%@",request.error);
        }];;
    } ;
//    [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:usersModel.avatarUrl] placeholderImage:[UIImage imageWithColor:[UIColor groupTableViewBackgroundColor]] options:SDWebImageRefreshCached];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//        _tableView.separatorStyle = UITableViewCellAccessoryNone;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
    }
    return _tableView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (UIButton *)inviteButton{
    if (!_inviteButton) {
        _inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inviteButton setImage:[UIImage imageNamed:@"add_invite"] forState:UIControlStateNormal];
        [_inviteButton addTarget:self action:@selector(inviteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _inviteButton.frame = CGRectMake(__kWidth - 20 -63, __kHeight - 100 -63-64, 63, 63);
    }
    return _inviteButton;
}

@end
