//
//  WBChatViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/16.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatViewController.h"
#import "LHChatBarView.h"
#import "LHContentModel.h"
#import "WBTweetModel.h"
#import "LHIMDBManager.h"
#import "LHTools.h"
#import "WBChatViewNormalTableViewCell.h"
#import "LHChatTimeCell.h"
#import "SDImageCache.h"
#import "LHPhotoPreviewController.h"
#import "XSBrowserAnimateDelegate.h"
#import "WBGroupManageViewController.h"
#import "WBTweetAPI.h"
#import "WBTweetModel.h"
#import "WBChatViewNormalTableViewCell.h"
#import "VCFloatingActionButton.h"
#import "FirstFilesViewController.h"

NSString *const kTableViewOffset = @"contentOffset";
NSString *const kTableViewFrame = @"frame";

@interface WBChatViewController () <UITableViewDelegate, UITableViewDataSource,floatMenuDelegate> {
    NSArray *_imageKeys;
}

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) LHChatBarView *chatBarView;
// 满足刷新
@property (nonatomic, assign, getter=isMeetRefresh) BOOL meetRefresh;
// 正在刷新
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSCache *rowHeight;

// 消息时间
@property (nonatomic, strong) NSString *lastTime;
@property (nonatomic, assign) CGFloat tableViewOffSetY;
@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, strong) XSBrowserAnimateDelegate *browserAnimateDelegate;

@property (nonatomic, assign) BOOL isScrollBottom;
@property (nonatomic, strong)VCFloatingActionButton *addButton;


@end

@implementation WBChatViewController


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = YES;

    // 初始化
    self.isScrollBottom = NO;
    [self getData];
    [self createNavBtns];
    [self setupInit];
//    [self loadMessageWithId:nil];
//    dispatch_main_async_safe(^{
//         [self scrollToBottomAnimated:NO refresh:YES];
//    });
   
    [KDefaultNotificationCenter addObserver:self selector:@selector(dataChanged:) name:kDataChangedName object:nil];
    [KDefaultNotificationCenter addObserver:self selector:@selector(fileSelectChanged:) name:kBoxFileSelect object:nil];
}


- (void)createNavBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"%@",phoneVersion);
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    if([phoneVersion floatValue]>=11.0){
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0,0, -10);
    }
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setEnlargeEdgeWithTop:10 right:5 bottom:5 left:5];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightItem,negativeSpacer,nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)setupInit {
    if (!_boxModel.name || _boxModel.name.length==0) {
        self.title = [NSString stringWithFormat:@"群聊(%ld)",_boxModel.users.count];
    }
    self.view.backgroundColor = MainBackgroudColor;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addButton];
    [self.view addSubview:self.chatBarView];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.chatBarView action:@selector(hideKeyboard)];
//    [self.tableView addGestureRecognizer:tapGesture];
}


- (void)dealloc {
//    [self.tableView removeObserver:self forKeyPath:kTableViewFrame];
//    [self.tableView removeObserver:self forKeyPath:kTableViewOffset];
    [KDefaultNotificationCenter removeObserver:self name:kDataChangedName object:nil];
    [KDefaultNotificationCenter removeObserver:self name:kBoxFileSelect object:nil];
}

- (void)getData{
    if (_boxModel.uuid.length == 0)return;
    [[WBTweetAPI apiWithBoxuuid:_boxModel.uuid]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
       NSLog(@"%@",request.responseJsonObject);
//        if ([request.responseJsonObject isKindOfClass:[NSDictionary class]]) {
////            NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"]
////            : request.responseJsonObject;
//             [self.tableView reloadData];
//            return ;
//        }
        NSArray * array = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"]
        : request.responseJsonObject;
        if (![array isKindOfClass:[NSArray class]]) {
            return ;
        }
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
        [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WBTweetModel *model = [WBTweetModel modelWithDictionary:obj];
            model.boxuuid = _boxModel.uuid;
            [dataArray addObject:model];
        }];
        self.dataSource = dataArray;
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
}

- (void)dataChanged:(NSNotification *)noti{
    WBBoxesModel *boxModel = noti.object;
    _boxModel = boxModel;
}
#pragma mark - public
//刷新并滑动到底部
- (void)scrollToBottomAnimated:(BOOL)animated refresh:(BOOL)refresh {
    // 表格滑动到底部
    if (refresh) [self.tableView reloadData];
    if (!self.dataSource.count) return;
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

#pragma mark - private

- (void)rightBtnClick:(UIButton *)sender{
    WBGroupManageViewController *groupManageVC = [[WBGroupManageViewController alloc]init];
    groupManageVC.boxModel = _boxModel;
    [self.navigationController pushViewController:groupManageVC animated:YES];
}

- (void)fileSelectChanged:(NSNotification *)noti{
    NSDictionary *dataDic = noti.userInfo;
    long long date = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    __block WBTweetModel *messageModel = [WBTweetModel new];
    messageModel.isSender = YES;
    messageModel.isRead = YES;
    messageModel.status = MessageDeliveryState_Delivering;
    messageModel.ctime = date;
    messageModel.messageBodytype = MessageBodyType_File;
    
    NSString *time = [LHTools processingTimeWithDate:messageModel.ctime];
    if ([time isEqualToString:self.lastTime]) {
        [self insertNewMessageOrTime:time];
        self.lastTime = time;
    }
    
    NSIndexPath *index = [self insertNewMessageOrTime:messageModel];
    WBChatViewNormalTableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    //    [self.messages addObject:messageModel];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self sendFileMessageToNetSeverWithDataDic:dataDic TableViewCell:cell];
}

- (void)sendFileMessageToNetSeverWithDataDic:(NSDictionary *)dic TableViewCell:(WBChatViewNormalTableViewCell *)cell{
    [WB_BoxService sendTweetWithFilesDic:dic Boxuuid:_boxModel.uuid Complete:^(WBTweetModel *tweetModel, NSError *error) {
        if (!error) {
        }else{
            
        }
    }];
}
//- (void)dropDownLoadDataWithScrollView:(UIScrollView *)scrollView {
//    if ([scrollView isMemberOfClass:[UITableView class]]) {
//        if (!self.isHeaderRefreshing) return;
//
//        WBTweetModel *model = self.messages.firstObject;
//        self.tableViewOffSetY = (self.tableView.contentSize.height - self.tableView.contentOffset.y);
////        [self loadMessageWithId:[NSString stringWithFormat:@"%lld",model.ctime]];
//        [self.tableView reloadData];
//        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableViewOffSetY)];
//        self.headerRefreshing = NO;
//    }
//}


- (void)loadMessageWithId:(NSString *)Id {
        NSArray *messages = [[LHIMDBManager shareManager] searchModelArr:[WBTweetModel class] byKey:Id];
    
        self.meetRefresh = messages.count == kMessageCount;
    
        [messages enumerateObjectsUsingBlock:^(WBTweetModel *messageModel, NSUInteger idx, BOOL * stop) {
            [self.dataSource insertObject:messageModel atIndex:0];
            [self.messages insertObject:messageModel atIndex:0];
    
            NSString *time = [LHTools processingTimeWithDate:messageModel.ctime];
            if (![self.lastTime isEqualToString:time]) {
                [self.dataSource insertObject:time atIndex:0];
                self.lastTime = time;
            }
        }];
    
        NSUInteger index = [self.dataSource indexOfObject:self.lastTime];
        if (index) {
            [self.dataSource removeObjectAtIndex:index];
            [self.dataSource insertObject:self.lastTime atIndex:0];
        }
}

- (NSIndexPath *)insertNewMessageOrTime:(id)NewMessage {
    NSIndexPath *index = [NSIndexPath indexPathForRow:self.dataSource.count inSection:0];
    [self.dataSource addObject:NewMessage];
    [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    return index;
}

- (void)sendFilesAction{
    FirstFilesViewController *filesVC = [[FirstFilesViewController alloc]init];
    filesVC.selectType = WBFilesFirstBoxSelectType;
    NavViewController *nav = [[NavViewController alloc] initWithRootViewController:filesVC];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)sendMessage:(LHContentModel *)content {
    
    if (content.words && content.words.length) {
        // 文字类型
        [self seavMessage:content.words type:MessageBodyType_Text];
    }
    if (!content.photos && !content.photos.photos.count) return;
    // 图片类型
//    [content.photos.photos enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * stop) {
//
        [self seavMessage:content type:MessageBodyType_Image];
//    }];

}

- (void)sendMessageToNetSeverWith:(LHContentModel *)content TableViewCell:(WBChatViewNormalTableViewCell *)tabelViewCell{
#warning upload;
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
    [content.photos.assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [imageArray addObject:obj];
    }];
        [WB_BoxService sendTweetWithImageArray:imageArray Boxuuid:_boxModel.uuid Complete:^(WBTweetModel *tweetModel, NSError *error) {
            if (!error) {
                [content.photos.photos enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
                    [SDImageCache.sharedImageCache storeImage:image forKey:[NSString stringWithFormat:@"%@%lld%ld",tweetModel.uuid,tweetModel.ctime,idx] toDisk:YES completion:nil];
                }];
                dispatch_main_async_safe(^{
                tabelViewCell.messageModel.status = MessageDeliveryState_Delivered;
                [tabelViewCell layoutSubviews];
                });
            }else{
                  dispatch_main_async_safe(^{
                tabelViewCell.messageModel.status = MessageDeliveryState_Failure;
                [tabelViewCell layoutSubviews];
                });
            }
        }];

}


- (void)seavMessage:(id)content type:(MessageBodyType)type {
    LHContentModel *contentModel;
    if ([content isKindOfClass:[LHContentModel class]]) {
       contentModel =(LHContentModel *)content;
    }
    
    long long date = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    __block WBTweetModel *messageModel = [WBTweetModel new];
    messageModel.isSender = YES;
    messageModel.isRead = YES;
    messageModel.status = MessageDeliveryState_Delivering;
    messageModel.ctime = date;
    messageModel.messageBodytype = MessageBodyType_Image;
    messageModel.localImageArray = contentModel.photos.localImageModelArray;
    switch (type) {
        case MessageBodyType_Text: {
            messageModel.comment = content;
            break;
        }
        case MessageBodyType_Image: {
            break;
        }
        default:
            break;
    }
    
    
    NSString *time = [LHTools processingTimeWithDate:messageModel.ctime];
    if ([time isEqualToString:self.lastTime]) {
        [self insertNewMessageOrTime:time];
        self.lastTime = time;
    }
    
    NSIndexPath *index = [self insertNewMessageOrTime:messageModel];
    WBChatViewNormalTableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
//    [self.messages addObject:messageModel];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
//    {
//        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
//        [self.tableView setContentOffset:offset animated:NO];
//    }
    [self sendMessageToNetSeverWith:(LHContentModel *)content TableViewCell:cell];
#warning
//    // 模仿延迟发送
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        messageModel.status = MessageDeliveryState_Delivered;
//        WBTweetModel *dbMessageModel = [[LHIMDBManager shareManager] searchModel:[WBTweetModel class] keyValues:@{@"date" : [NSString stringWithFormat:@"%lld",date], @"status" : @(MessageDeliveryState_Delivering)}];
//        NSLog(@"%@",dbMessageModel);
//        dbMessageModel.status = MessageDeliveryState_Delivered;
//        NSArray *cells = [self.tableView visibleCells];
//        [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[WBChatViewNormalTableViewCell class]]) {
//                WBChatViewNormalTableViewCell *messagecell = (WBChatViewNormalTableViewCell *)obj;
//                if (messagecell.messageModel.ctime == dbMessageModel.ctime) {
//                    [messagecell layoutSubviews];
//                    [[LHIMDBManager shareManager] insertModel:dbMessageModel];
//                    *stop = YES;
//                }
//            }
//        }];

        // 模仿消息回复
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            dbMessageModel.isSender = NO;
//            dbMessageModel.uuid = nil;
//            [[LHIMDBManager shareManager] insertModel:dbMessageModel];
//            NSIndexPath *index = [self insertNewMessageOrTime:dbMessageModel];
//            [self.messages addObject:dbMessageModel];
//            [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        });
//    });
}

#pragma mark - 事件监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:kTableViewFrame]) {
//        UITableView *tableView = (UITableView *)object;
//        CGRect newValue = [change[NSKeyValueChangeNewKey] CGRectValue];
//        CGRect oldValue = [change[NSKeyValueChangeOldKey] CGRectValue];
//        if (newValue.size.height != oldValue.size.height &&
//            tableView.contentSize.height > newValue.size.height) {
//
//            [tableView setContentOffset:CGPointMake(0, tableView.contentSize.height - newValue.size.height) animated:YES];
//        }
//        return;
//    }
    
    //    UITableView *tableView = (UITableView *)object;
//    CGPoint newValue = [change[NSKeyValueChangeNewKey] CGPointValue];
//    CGPoint oldValue = [change[NSKeyValueChangeOldKey] CGPointValue];
//    if (!self.headerRefreshing) self.headerRefreshing = newValue.y < 40 && self.isMeetRefresh;
    //    DLog(@"newValue = %f, oldValue = %f", newValue.y, oldValue.y);
}

#pragma mark  cell事件处理
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    WBTweetModel *model = [userInfo objectForKey:kMessageKey];
    UIImageView *imageView = [userInfo objectForKey:kMessageImageKey];
    if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]) {
        //点击图片
//        [self chatImageCellBubblePressed:model ImageViewTag:imageView.tag];
    }else if ([eventName isEqualToString:kRouterEventChatResendEventName]){
         WBChatViewNormalTableViewCell *cell = [userInfo objectForKey:kMessageKey];
//         [self sendMessageToNetSeverWith:(LHContentModel *)content TableViewCell:cell];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataSource objectAtIndex:indexPath.row];
      WBTweetModel *messageModel = (WBTweetModel *)obj;
//    NSLog(@"%@",self.dataSource);
    
    NSString *cellIdentifier = [WBChatViewNormalTableViewCell cellIdentifierForMessageModel:messageModel];
    WBChatViewNormalTableViewCell *messageCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!messageCell) {
        messageCell = [[WBChatViewNormalTableViewCell alloc] initWithMessageModel:messageModel reuseIdentifier:cellIdentifier];
    }
    messageCell.boxModel = _boxModel;
    messageCell.messageModel = messageModel;
    
    [messageCell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    return messageCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
    //    }
    
    if (self.isScrollBottom == NO) {
//        id obj = [self.dataSource objectAtIndex:indexPath.row];
//        WBTweetModel *messageModel = (WBTweetModel *)obj;
//        ((WBChatViewNormalTableViewCell *)cell).messageModel = messageModel;
        if (self.tableView.contentSize.height > self.tableView.frame.size.height)
        {
            CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:offset animated:NO];
        }
   
        if (indexPath.row == self.dataSource.count-1) {
            
            self.isScrollBottom = YES;
        }
        
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 31;
    } else {
        WBTweetModel *model = (WBTweetModel *)obj;
        CGFloat height = [[self.rowHeight objectForKey:model.uuid] floatValue];
        if (height) {
            return height;
        }
        height = [WBChatViewNormalTableViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:model];
        [self.rowHeight setObject:@(height) forKey:model.uuid];
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (self.isMeetRefresh) {
//        return 40;
//    }
//    return 20;
    return 16;
}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (!self.isMeetRefresh) return nil;
//    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, __kWidth, 40)];
//    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((__kWidth - 15) * 0.5, (20 - 15) * 0.5, 15, 15)];
//    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    [activityIndicatorView startAnimating];
//    [refreshView addSubview:activityIndicatorView];
//    return refreshView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DLog(@" scrollViewDidEndDecelerating == %.2f", scrollView.contentOffset.y);
//    [self dropDownLoadDataWithScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        DLog(@"scrollView停止滚动，完全静止");
//        [self dropDownLoadDataWithScrollView:scrollView];
    } else {
        DLog(@"用户停止拖拽，但是scrollView由于惯性，会继续滚动，并且减速");
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.chatBarView hideKeyboard];
}

- (void)didSelectMenuOptionAtIndex:(NSInteger)row{
    if (row == 0) {
        [self.chatBarView moreViewPhotoAction:nil];
    }else{
        [self sendFilesAction];
    }
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight-64) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = MainBackgroudColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        [_tableView addObserver:self forKeyPath:kTableViewOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//        [_tableView addObserver:self forKeyPath:kTableViewFrame options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _tableView;
}

- (LHChatBarView *)chatBarView{
    if (!_chatBarView) {
        @weaky(self);
        _chatBarView = [[LHChatBarView alloc] initWithFrame:CGRectMake(0, __kHeight - kChatBarHeight - kNavBarHeight, __kWidth, kChatBarHeight)];
        _chatBarView.backgroundColor = [UIColor lh_colorWithHex:0xf8f8fa];
        _chatBarView.tableView = self.tableView;
        _chatBarView.sendContent = ^(LHContentModel *content) {
            [weak_self sendMessage:content];
        };
        _chatBarView.hidden = YES;
    }
    return _chatBarView;
}

- (VCFloatingActionButton *)addButton{
    if(!_addButton){
        CGRect floatFrame = CGRectMake(__kWidth - 56 - 16 , __kHeight - 64 - 56 - 16, 56, 56);
        _addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"add_album"] andPressedImage:[UIImage imageNamed:@"icon_close"] withScrollview:self.tableView];
        _addButton.automaticallyInsets = YES;
        _addButton.imageArray = @[@"download",@"fab_share"];
        _addButton.labelArray = @[@"",@""];
        _addButton.delegate = self;
    }
    return _addButton;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = @[].mutableCopy;
    }
    return _messages;
}

- (NSCache *)rowHeight {
    if (!_rowHeight) {
        _rowHeight = [NSCache new];
    }
    return _rowHeight;
}

- (XSBrowserAnimateDelegate *)browserAnimateDelegate {
    if (!_browserAnimateDelegate) {
        _browserAnimateDelegate = [XSBrowserAnimateDelegate shareInstance];
    }
    return _browserAnimateDelegate;
}

@end

