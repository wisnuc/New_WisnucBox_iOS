//
//  WBTorrentDownloadViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBTorrentDownloadViewController.h"
#import "WBTorrentMagnetAlertViewController.h"
#import "WBDownloadMagnetAPI.h"
#import "WBGetDownloadAPI.h"
#import "WBGetDownloadModel.h"
#import "WBTorrentDownloadingTableViewCell.h"
#import "WBTorrentDownloadedTableViewCell.h"

@interface WBTorrentDownloadViewController ()
<TorrentMagnetAlertViewDelegate,
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic)MDCFloatingButton *addButton;
@property (nonatomic)NSTimer*timer;
@property (nonatomic)NSMutableArray *runningDataArray;
@property (nonatomic)NSMutableArray *finishDataArray;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation WBTorrentDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addButton];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.timer fire];
}

- (void)dealloc{
    
}

- (void)magnetDownload:(NSString *)magnetUrl {
    if (magnetUrl.length >0) {
        @weaky(self)
        [WB_NetService getDirUUIDWithDirName:@"download" BaseDir:^(NSError *error, NSString *dirUUID) {
            if (error) {
                NSLog(@"%@",error);
            }else{
                [[WBDownloadMagnetAPI apiWithDirUUID:dirUUID MagnetURL:magnetUrl]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                    NSLog(@"%@",request.responseJsonObject);
                    NSDictionary *dic = request.responseJsonObject;
                    NSString *torrentId = dic[@"torrentId"];
                    [weak_self startGetMagnetDownloadInfoWithTorrentId:torrentId];
                } failure:^(__kindof JYBaseRequest *request) {
                    NSLog(@"%@",request.error);
                    NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                    if(errorData.length >0){
                        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                        NSString *message = serializedData[@"message"];
                        [SXLoadingView showProgressHUDText:message duration:1.5f];
                        NSLog(@"%@",serializedData);
                    }
                }];
            }
        }];
    }
}

- (void)startGetMagnetDownloadInfoWithTorrentId:(NSString *)torrentId{
//    if (torrentId.length >0) {
//
//    }
    
    @weaky(self)
    [[WBGetDownloadAPI apiWithType:nil TorrentId:nil]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        WBGetDownloadModel *model = [WBGetDownloadModel yy_modelWithJSON:request.responseJsonObject];
        [self.runningDataArray removeAllObjects];
        [self.runningDataArray addObjectsFromArray:model.running];
        [self.finishDataArray removeAllObjects];
        [self.finishDataArray addObjectsFromArray:model.finish];
        [weak_self reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.error);
    }];
    
}

- (void)reloadData{
    [self.tableView reloadData];
}

- (void)refreshDownload{
     @weaky(self)
    [[WBGetDownloadAPI apiWithType:nil TorrentId:nil]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        WBGetDownloadModel *model = [WBGetDownloadModel yy_modelWithJSON:request.responseJsonObject];
        [self.runningDataArray removeAllObjects];
        [self.runningDataArray addObjectsFromArray:model.running];
        [self.finishDataArray removeAllObjects];
        [self.finishDataArray addObjectsFromArray:model.finish];
        [weak_self reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
}

- (void)didTapAdd:(UIButton *)sender{
    NSBundle *bundle = [NSBundle bundleForClass:[WBTorrentMagnetAlertViewController class]];
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:NSStringFromClass([WBTorrentMagnetAlertViewController class]) bundle:bundle];
    NSString *identifier = NSStringFromClass([WBTorrentMagnetAlertViewController class]);
    
    UIViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    viewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];
    WBTorrentMagnetAlertViewController *vc = (WBTorrentMagnetAlertViewController *)viewController;
    vc.delegate = self;
    [self presentViewController:viewController animated:YES completion:NULL];
}

#pragma UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (indexPath.section==0) {
        WBTorrentDownloadingTableViewCell *cell;
        cell = [tableView  dequeueReusableCellWithIdentifier:NSStringFromClass([WBTorrentDownloadingTableViewCell class])];
        if (!cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([WBTorrentDownloadingTableViewCell class]) owner:self options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        WBGetDownloadRunnngModel * model = self.runningDataArray[indexPath.row];
   
        if ([model.state isEqualToString:@"downloading"]) {
            cell.progressView.progress = [model.progress  floatValue];
            cell.nameLabel.text = model.name;
            cell.progressLabel.text = [NSString stringWithFormat:@"%.f%%",[model.progress floatValue] *100];
            cell.clickBlock = ^(WBTorrentDownloadingTableViewCell *cell) {
                NSLog(@"111111");
            };
        }else{
            [self reloadData];
        }
        return cell;
    }else{
        WBTorrentDownloadedTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBTorrentDownloadedTableViewCell class])];
        if (nil == cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([WBTorrentDownloadedTableViewCell class]) owner:self options:nil] lastObject];
        }
       
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return self.runningDataArray.count;
    }else{
        return self.finishDataArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return [NSString stringWithFormat:@"%@(%lu)",WBLocalizedString(@"incomplete", nil),(unsigned long)_runningDataArray.count];
    }
    else{
        return WBLocalizedString(@"completed", nil);
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

#pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 72;
    }else{
        return 56;
    }
}

- (MDCFloatingButton *)addButton{
    if (!_addButton) {
        _addButton = [[MDCFloatingButton alloc] initWithFrame:CGRectMake(__kWidth - 63 -16, __kHeight - 63 -16 -64, 63, 63) shape:MDCFloatingButtonShapeDefault];
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

- (NSTimer *)timer{
    if (!_timer) {
        _timer =  [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(refreshDownload) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (NSMutableArray *)runningDataArray{
    if (!_runningDataArray) {
        _runningDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _runningDataArray;
}

- (NSMutableArray *)finishDataArray{
    if (!_finishDataArray) {
        _finishDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _finishDataArray;
}
//lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _tableView;
}

@end
