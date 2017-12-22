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
#import "WBTorrentDownloadActionAPI.h"
#import "CSDateUtil.h"
#import "WBTorrentDownloadSwitchAPI.h"

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
@property (nonatomic) BOOL switchOn;
@end

@implementation WBTorrentDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"download_manage", nil);
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addButton];
}



- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkSwitch];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UICOLOR_RGB(0x03a9f4)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = UICOLOR_RGB(0x03a9f4);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //    [self.navigationController.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"back"]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
}

- (void)checkSwitch{
    [SXLoadingView showProgressHUD:@""];
    [[WBTorrentDownloadSwitchAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary *dic = request.responseJsonObject;
        NSNumber *number = dic[@"switch"];
        BOOL swichOn = [number boolValue];
        _switchOn = swichOn;
        if (swichOn) {
           [self.timer fire];
        }else{
            UILabel *label =  [[UILabel alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 80)];
            label.text = @"BT下载服务已关闭";
            label.textColor = COR1;
            label.textAlignment = NSTextAlignmentCenter;
            self.tableView.tableFooterView =label;
        }
         [SXLoadingView hideProgressHUD];
    } failure:^(__kindof JYBaseRequest *request) {
         [SXLoadingView hideProgressHUD];
    }];
}

- (void)dealloc{
    
}

- (void)magnetDownload:(NSString *)magnetUrl {
    if (magnetUrl.length >0) {
        @weaky(self)
        [WB_NetService getDirUUIDWithDirName:BackUpTorrentDirName BaseDir:^(NSError *error, NSString *dirUUID) {
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

- (void)runningAllClearButtonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    [SXLoadingView showProgressHUD:@""];
    if (sender.selected) {
        
        [_runningDataArray enumerateObjectsUsingBlock:^(WBGetDownloadRunnngModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj.isPause boolValue]) {
                [[WBTorrentDownloadActionAPI apiWithTorrentId:obj.infoHash Option:@"pause"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                     [SXLoadingView hideProgressHUD];
                    NSLog(@"%@",request.responseJsonObject);
                } failure:^(__kindof JYBaseRequest *request) {
                    NSLog(@"%@",request.error);
                     [SXLoadingView hideProgressHUD];
                }];
            }
        }];
        
    }else{
          [_runningDataArray enumerateObjectsUsingBlock:^(WBGetDownloadRunnngModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if ([obj.isPause boolValue]) {
        [[WBTorrentDownloadActionAPI apiWithTorrentId:obj.infoHash Option:@"resume"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
             [SXLoadingView hideProgressHUD];
            NSLog(@"%@",request.responseJsonObject);
        } failure:^(__kindof JYBaseRequest *request) {
             [SXLoadingView hideProgressHUD];
            NSLog(@"%@",request.error);
        }];
         }
    }];
    }
}

- (void)fnishAllClearButtonClick:(UIButton *)sender{
    [SXLoadingView showProgressHUD:@""];
    [_finishDataArray enumerateObjectsUsingBlock:^(WBGetDownloadFinishModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[WBTorrentDownloadActionAPI apiWithTorrentId:obj.infoHash Option:@"destroy"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [SXLoadingView hideProgressHUD];
            NSLog(@"%@",request.responseJsonObject);
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
            [SXLoadingView hideProgressHUD];
        }];
    }];
   
}

#pragma UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    @weaky(self)
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
            NSNumber *allSizeNumber = [NSNumber numberWithDouble:[model.downloaded doubleValue] / [model.progress doubleValue]];
            if ([model.downloaded doubleValue] == 0.0000000000) {
                allSizeNumber = [NSNumber numberWithInt:0];
            }
//            NSNumber *allSizeNumber = [NSNumber numberWithLongLong:[number longLongValue]];
            cell.sizeLabel.text = [NSString stringWithFormat:@"%@/%@",[NSString transformedValue: model.downloaded],[NSString transformedValue:allSizeNumber]];
            if ([model.isPause boolValue]) {
                cell.speedLabel.text = WBLocalizedString(@"paused", nil);
            }else{
                cell.speedLabel.text = [NSString stringWithFormat:@"%@/S",[NSString transformedValue:model.downloadSpeed]];
            }
            
            cell.clickBlock = ^(WBTorrentDownloadingTableViewCell *cell) {
                NSLog(@"111111");
                NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
                NSString *actionTitle ;
                NSLog(@"%@",model.state);
                if ([model.isPause boolValue]) {
                    actionTitle = WBLocalizedString(@"resume", nil);
                }else{
                     actionTitle = WBLocalizedString(@"pause", nil);
                }
                LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                         delegate:nil
                                                                cancelButtonTitle:cancelTitle
                                                            otherButtonTitleArray:@[actionTitle,WBLocalizedString(@"delete_task", nil)]];
                actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
                     if (buttonIndex == 0) {

                     }else
                    if (buttonIndex == 1) {
//                        [weak_self suspendActionsWith];
                        if (self.runningDataArray.count == 0) {
                            [actionSheet setHidden:YES];
                            return ;
                        }
                        if (indexPath.row > self.runningDataArray.count -1 && self.runningDataArray.count -1 > 0) {
                            return;
                        }
                        if ([model.isPause boolValue]) {
                            [SXLoadingView showProgressHUD:@""];
                            [[WBTorrentDownloadActionAPI apiWithTorrentId:model.infoHash Option:@"resume"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                                [SXLoadingView hideProgressHUD];
                                NSLog(@"%@",request.responseJsonObject);
                            } failure:^(__kindof JYBaseRequest *request) {
                                NSLog(@"%@",request.error);
                                [SXLoadingView hideProgressHUD];
                            }];
                        }else{
                            [SXLoadingView showProgressHUD:@""];
                            [[WBTorrentDownloadActionAPI apiWithTorrentId:model.infoHash Option:@"pause"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                                [SXLoadingView hideProgressHUD];
                                NSLog(@"%@",request.responseJsonObject);
                            } failure:^(__kindof JYBaseRequest *request) {
                                [SXLoadingView hideProgressHUD];
                                NSLog(@"%@",request.error);
                            }];
                        }
                        
//                        [self.transmitingArray removeObjectAtIndex:[indexPath row]];
//                        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                        [_tableView reloadData];
                    }if (buttonIndex == 2){
                        [SXLoadingView showProgressHUD:@""];
                        [[WBTorrentDownloadActionAPI apiWithTorrentId:model.infoHash Option:@"destroy"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                            [SXLoadingView hideProgressHUD];
                            NSLog(@"%@",request.responseJsonObject);
                        } failure:^(__kindof JYBaseRequest *request) {
                            [SXLoadingView hideProgressHUD];
                            NSLog(@"%@",request.error);
                        }];
                    }
                };
                actionSheet.scrolling          = YES;
                actionSheet.buttonHeight       = 60.0f;
                actionSheet.visibleButtonCount = 3.6f;
                [actionSheet show];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
         WBGetDownloadFinishModel * model = self.finishDataArray[indexPath.row];
        cell.nameLabel.text = model.name;
       
        cell.timeLabel.text = [self getTimeWithTime:[model.finishTime longLongValue]];
        
        cell.sizeLabel.text = [NSString transformedValue:model.downloaded];
        
        cell.clickBlock = ^(WBTorrentDownloadedTableViewCell *cell) {
            NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
            NSString *actionTitle = WBLocalizedString(@"delete_file", nil);
            LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                     delegate:nil
                                                            cancelButtonTitle:cancelTitle
                                                        otherButtonTitleArray:@[actionTitle]];
            actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
                if (buttonIndex == 0) {
                    
                }else
                    if (buttonIndex == 1) {
                        //                        [weak_self suspendActionsWith];
                        if (self.finishDataArray.count == 0) {
                            [actionSheet setHidden:YES];
                            return ;
                        }
                        if (indexPath.row > self.finishDataArray.count -1 && self.finishDataArray.count -1 > 0) {
                            return;
                        }
                        [[WBTorrentDownloadActionAPI apiWithTorrentId:model.infoHash Option:@"destroy"]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                            NSLog(@"%@",request.responseJsonObject);
                        } failure:^(__kindof JYBaseRequest *request) {
                            NSLog(@"%@",request.error);
                        }];
                        
                        //                        [self.transmitingArray removeObjectAtIndex:[indexPath row]];
                        //                        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        //                        [_tableView reloadData];
                    }
            };
            actionSheet.scrolling          = YES;
            actionSheet.buttonHeight       = 60.0f;
            actionSheet.visibleButtonCount = 3.6f;
            [actionSheet show];
        };
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if(section == 0){
//        return [NSString stringWithFormat:@"%@(%lu)",WBLocalizedString(@"downloading", nil),(unsigned long)self.runningDataArray.count];
//    }
//    else{
//        return [NSString stringWithFormat:@"%@(%lu)",WBLocalizedString(@"completed", nil),(unsigned long)self.finishDataArray.count];
//    }
//}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        __block long long speed = 0;
        [self.runningDataArray enumerateObjectsUsingBlock:^(WBGetDownloadRunnngModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            speed += [obj.downloadSpeed longLongValue];
            
        }];
        
        UIView *headerView  = [[UIView alloc]init];
        headerView.backgroundColor = UICOLOR_RGB(0xfafafa);
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 80, 48)];
//        NSLog(@"%@",NSStringFromCGRect(titleLabel.frame));
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.text = [NSString stringWithFormat:@"%@(%lu)",WBLocalizedString(@"downloading", nil),(unsigned long)self.runningDataArray.count];
        titleLabel.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        [headerView addSubview:titleLabel];
        UILabel *speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 16, 0, 100, 48)];
        speedLabel.adjustsFontSizeToFitWidth = YES;
        speedLabel.font = [UIFont boldSystemFontOfSize:14];
        speedLabel.textColor = RGBACOLOR(0, 0, 0, 0.54f);
        NSNumber *speedNumber = [NSNumber numberWithLongLong:speed];
        speedLabel.text = [NSString stringWithFormat:@"%@/S",[NSString transformedValue:speedNumber]];
        if (self.runningDataArray.count >0) {
            [headerView addSubview:speedLabel];
        }
        
        UIButton *clearButton =  [[UIButton alloc]initWithFrame:CGRectMake(__kWidth - 16 - 80, 0, 80, 48)];
        [clearButton setTitle:@"全部暂停" forState:UIControlStateNormal];
        [clearButton setTitle:@"全部继续" forState:UIControlStateSelected];
        [clearButton setTitleColor:COR1 forState:UIControlStateNormal];
        clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        clearButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [clearButton addTarget:self action:@selector(runningAllClearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.runningDataArray enumerateObjectsUsingBlock:^(WBGetDownloadRunnngModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.isPause boolValue]) {
                *stop = YES;
                 [clearButton setSelected:YES];
            }
        
        }];
        [headerView addSubview:clearButton];
        return headerView;
    }
    else{
        UIView *headerView  = [[UIView alloc]init];
        headerView.backgroundColor = UICOLOR_RGB(0xfafafa);
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 80, 48)];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        titleLabel.text = [NSString stringWithFormat:@"%@(%lu)",WBLocalizedString(@"completed", nil),(unsigned long)self.finishDataArray.count];
        [headerView addSubview:titleLabel];
        UIButton *clearButton =  [[UIButton alloc]initWithFrame:CGRectMake(__kWidth - 16 - 80, 0, 80, 48)];
        [clearButton setTitle:@"清除记录" forState:UIControlStateNormal];
        [clearButton setTitleColor:COR1 forState:UIControlStateNormal];
        clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        clearButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [clearButton addTarget:self action:@selector(fnishAllClearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.runningDataArray enumerateObjectsUsingBlock:^(WBGetDownloadRunnngModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.isPause boolValue]) {
                *stop = YES;
                [clearButton setSelected:YES];
            }
            
        }];
        [headerView addSubview:clearButton];
          return headerView;
    }
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

- (NSString *)getTimeWithTime:(long long)time{
    NSTimeInterval second = time/1000.0;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter * formater = [NSDateFormatter new];
    formater.dateFormat = @"yyyy.MM.dd";
    NSString * dateString = [formater stringFromDate:date];
    return dateString;
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
        _timer =  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refreshDownload) userInfo:nil repeats:YES];
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
