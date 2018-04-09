//
//  FilesNextViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FilesNextViewController.h"
#import "FilesViewController.h"
#import "FLFilesCell.h"
#import "CSDownloadHelper.h"
#import "VCFloatingActionButton.h"
#import "FLFIlesHelper.h"
#import "LocalDownloadViewController.h"
#import "CSFileUtil.h"
#import "JYProcessView.h"
#import "FilesDataSourceManager.h"
#import "CSFilesOneDownloadManager.h"
#import "WBFilesAndTransmitProtocal.h"
#import "FMMediaRamdomKeyAPI.h"
#import "NSArray+NormalTool.h"
#import "MRVLCPlayer.h"

@interface FilesNextViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
floatMenuDelegate,
LCActionSheetDelegate,
UIDocumentInteractionControllerDelegate,
FLDataSourceDelegate,
FilesHelperOpenFilesDelegate,
VLCMediaPlayerDelegate
>
{
    UIButton * _leftBtn;
    UILabel * _countLb;
    VLCMediaPlayer *_mediaPlay;
    UIView *_videoView;
    UIView *_videoControlView;
    UIButton *_playButton;
    UIButton *_closeButton;
}

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataSouceArray;

@property (strong, nonatomic) UIView * chooseHeadView;

@property (strong, nonatomic) VCFloatingActionButton * addButton;

@property (strong, nonatomic) UIDocumentInteractionController *documentController;

@property (nonatomic) FLFliesCellStatus cellStatus;

@property (nonatomic, assign) BOOL isSelect;

@property (strong, nonatomic) JYProcessView * progressView;

@end

@implementation FilesNextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBtns];
    [self loadData];
    [self initView];
    [self registerNotifacationAndDelegate];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_selectType == WBFilesFirstNormalType) {
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            [self actionForNormalStatus];
        }
    }
    if (!self.chooseHeadView.hidden) {
        [self.chooseHeadView setHidden:YES];
    }
    [self.chooseHeadView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_selectType == WBFilesFirstBoxSelectType) {
        self.navigationItem.rightBarButtonItem = nil;
        self.cellStatus = FLFliesCellStatusCanChoose;
        [self createNavBtns];
    }else{
        [self.navigationController.view addSubview:self.chooseHeadView];
    }
}

- (void)dealloc{
    [KDefaultNotificationCenter removeObserver:self];
}

-(void)createNavBtns{
    if (_selectType == WBFilesFirstBoxBrowseType) {
        self.title = @"文件查看";
        return;
    }
    self.title = _name;
    //    self.navigationItem.rightBarButtonItem = nil;
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    if (_selectType == WBFilesFirstBoxSelectType) {
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        [rightBtn setTitleColor:COR1 forState:UIControlStateNormal];
        rightBtn.frame = CGRectMake(0, 0, 100, 24);
        rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }else{
        [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    }
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
    //    UIBarButtonItem * rightItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBtnClick:) nomalImage:[UIImage imageNamed:@"more"]  higeLightedImage:[UIImage imageNamed:@"more_highlight"]  imageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    //     UIBarButtonItem * rightItemfixSpace = [UIBarButtonItem fixedSpaceWithWidth:100];
    //    self.navigationItem.rightBarButtonItems = @[rightItem,rightItemfixSpace];
    
    //    self.navigationItem.rightBarButtonItem = [UIBarButtonItem fixedSpaceWithWidth:10];
}

- (void)initView{
    [self.view addSubview:self.tableView];
    if (_selectType == WBFilesFirstNormalType
        
        
        ) {
        [self initMjRefresh];
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.addButton];
}

- (void)loadData{
    if (_selectType == WBFilesFirstBoxBrowseType) {
        [self.tweetModel.list enumerateObjectsUsingBlock:^(WBTweetlistModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntriesModel *model = [[EntriesModel alloc]init];
            model.name = obj.filename;
            model.size = [obj.size longLongValue];
            model.photoHash = obj.sha256;
            model.type = @"file";
            model.mtime = self.tweetModel.ctime;
            model.driveUUID = obj.dirUUID;
            model.parentUUID = obj.parentUUID;
            model.uuid = obj.fileuuid;
            [self.dataSouceArray addObject:model];
        }];
        [self.tableView reloadData];
        return;
    }
    
    [FilesDataSourceManager manager].delegate = self;
    [[FilesDataSourceManager manager] getFilesWithDriveUUID:_driveUUID DirUUID:_parentUUID];
    _cellStatus = FLFliesCellStatusNormal;
    [self.tableView reloadData];
}

- (void)initMjRefresh{
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = KDefaultOffset;
    //    [self.tableView.mj_header beginRefreshing];
}

- (void)registerNotifacationAndDelegate{
    if (_selectType != WBFilesFirstBoxSelectType) {
        [KDefaultNotificationCenter addObserver:self selector:@selector(handlerStatusChangeNotify:) name:FLFilesStatusChangeNotify object:nil];
    }
    
    [FLFIlesHelper helper].openFilesdelegate = self;
}

- (void)leftBtnClick:(id)sender{
    for (EntriesModel * model in self.dataSouceArray) {
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            [[FLFIlesHelper helper] removeChooseFile:model];
            [self.tableView reloadData];
        }
    }
}

- (void)rightBtnClick:(UIButton *)btn{
    if (_selectType == WBFilesFirstBoxSelectType) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:[FLFIlesHelper helper].chooseFiles forKey:@"filesModel"];
        [dic setObject:_parentUUID forKey:@"dirUUID"];
        [dic setObject:_driveUUID forKey:@"driveUUID"];
        
        NSArray *array = [NSArray arrayWithArray:dic[@"filesModel"]];
        if (array.count==0) {
            [SXLoadingView showProgressHUDText:@"您尚未选择文件" duration:1.2f];
            return;
        }
        
        [KDefaultNotificationCenter postNotificationName:kBoxFileSelect object:nil userInfo:dic];
        [self dismissViewControllerAnimated:YES completion:^{
            [[FLFIlesHelper helper] removeAllChooseFile];
            [self actionForNormalStatus];
            [self.tableView reloadData];
        }];
        return;
    }
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    NSString *selectTitle = WBLocalizedString(@"select_file", nil);
    if (self.cellStatus != FLFliesCellStatusCanChoose) {
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:cancelTitle clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self actionForChooseStatus];
            }
        } otherButtonTitles:selectTitle, nil] show];
    }else{
    }
}

- (void)playButtonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_mediaPlay play];
    }else{
        [_mediaPlay pause];
    }
}

- (void)playControlViewTap:(UIGestureRecognizer *)gesture{
    if (_playButton.hidden == YES) {
        [UIView animateWithDuration:.5f animations:^{
            _playButton.hidden = NO;
            _closeButton.hidden = NO;
            _playButton.userInteractionEnabled = YES;
            _closeButton.userInteractionEnabled = YES;
        }completion:^(BOOL finished) {
            
        }];
    }else {
        [UIView animateWithDuration:.5f animations:^{
            _playButton.hidden = YES;
            _closeButton.hidden = YES;
            _playButton.userInteractionEnabled = NO;
            _closeButton.userInteractionEnabled = NO;
        }completion:^(BOOL finished) {
            
        }];
    }
}

- (void)playCloseButtonClick:(UIButton *)sender{
    [_videoView removeFromSuperview];
    [_videoControlView removeFromSuperview];
    _videoView = nil;
    _mediaPlay = nil;
    _videoControlView = nil;
}

- (void)sequenceDataSource{
    NSMutableArray *isFilesArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *isNotFilesArr = [NSMutableArray arrayWithCapacity:0];
    for (EntriesModel * model  in [FilesDataSourceManager manager].dataArray) {
        if (![model.type isEqualToString:@"file"]) {
            [isNotFilesArr addObject: model];
        }
        else{
            [isFilesArr addObject: model];
        }
    }
    [[FilesDataSourceManager manager].dataArray removeAllObjects];
    [self.dataSouceArray removeAllObjects];
    [self.dataSouceArray addObjectsFromArray:isNotFilesArr];
    [self.dataSouceArray addObjectsFromArray:isFilesArr];
}

- (void)presentOptionsMenu
{
    BOOL canOpen = [self.documentController presentPreviewAnimated:YES];
    if (!canOpen) {
        [SXLoadingView showProgressHUDText:WBLocalizedString(@"file_preview_failed", nil) duration:1];
        [_documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }
}

- (void)actionForChooseStatus{
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
        return;
    }
    if (self.dataSouceArray.count == 0) {
        [SXLoadingView showAlertHUD:WBLocalizedString(@"nofile_choose", nil) duration:2];
        return;
    }
    [self.chooseHeadView setHidden:NO];
    [self.tableView.mj_header setHidden:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.chooseHeadView.transform = CGAffineTransformTranslate(self.chooseHeadView.transform, 0, 64);
    }completion:^(BOOL finished) {
        
        _addButton.hidden = NO;
    }];
    
    //    self.tabBarController.tabBar.hidden = YES;
    self.cellStatus = FLFliesCellStatusCanChoose;
    _countLb.text = [NSString stringWithFormat:WBLocalizedString(@"select_count", nil),(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
    [self.tableView reloadData];
    //     }
}

- (void)actionForNormalStatus{
    if (self.cellStatus == FLFliesCellStatusNormal) {
        return;
    }
    
    [self.tableView.mj_header setHidden:NO];
    if ([FLFIlesHelper helper].chooseFiles.count >0) {
        [[FLFIlesHelper helper] removeAllChooseFile];
    }
    //    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    self.cellStatus = FLFliesCellStatusNormal;
    _countLb.text = [NSString stringWithFormat:WBLocalizedString(@"select_count", nil),1];
    [self.tableView reloadData];
    
    if (_selectType == WBFilesFirstBoxSelectType) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.chooseHeadView.transform = CGAffineTransformTranslate(self.chooseHeadView.transform, 0, -64);
    } completion:^(BOOL finished) {
        [self.chooseHeadView setHidden:YES];
        _addButton.hidden = YES;
    }];
    
    
}

- (void)handlerStatusChangeNotify:(NSNotification *)notify{
    if (![notify.object boolValue]) {
        dispatch_main_async_safe(^{
            [self actionForNormalStatus];
        });
    }else{
        if (self.cellStatus != FLFliesCellStatusCanChoose) {
            dispatch_main_async_safe(^{
                [self actionForChooseStatus];
            });
        }
    }
}

#pragma mark - FilesHelperOpenFilesDelegate

- (void)openTheFileWithFilePath:(NSString *)filePath{
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    _documentController.delegate = self;
    [self presentOptionsMenu];
}

#pragma mark - FLDataSourceDelegate

- (void)datasource:(FilesDataSourceManager *)datasource finishLoading:(BOOL)finish{
    if (datasource == [FilesDataSourceManager manager] && finish) {
        [self sequenceDataSource];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView displayWithMsg:WBLocalizedString(@"no_files", nil) withRowCount:self.dataSouceArray.count andIsNoData:YES  andTableViewFrame:self.view.bounds
                         andTouchBlock:nil];
    }else{
        [self.tableView.mj_header endRefreshing];
    }
}

#pragma mark - floatMenuDelegate

- (void)didSelectMenuOptionAtIndex:(NSInteger)row{
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
        if (row == 0) {
            if ([FLFIlesHelper helper].chooseFiles.count == 0) {
                [SXLoadingView showAlertHUD:WBLocalizedString(@"please_select_the_file", nil) duration:1];
            }else{
                
                [[FLFIlesHelper helper] downloadChooseFilesParentUUID:_parentUUID RootUUID:_driveUUID];
                LocalDownloadViewController  *downloadVC = [[LocalDownloadViewController alloc]init];
                [self.navigationController pushViewController:downloadVC animated:YES];
                [self actionForNormalStatus];
            }
        }else{
            //            [self shareFiles];
        }
    }
}

- (void)repeatDelay{
    self.isSelect = false;
}

#pragma  TableView DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLFilesCell *cell  = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FLFilesCell class])];
    if (nil == cell) {
        cell= (FLFilesCell *)[[[NSBundle  mainBundle] loadNibNamed:NSStringFromClass([FLFilesCell class]) owner:self options:nil]  lastObject];
    }
    EntriesModel *dataModel = _dataSouceArray[indexPath.row];
    cell.selectType = _selectType;
    [[FLFIlesHelper helper] configCells:cell withModel:dataModel cellStatus:self.cellStatus viewController:self parentUUID:_parentUUID RootUUID:_driveUUID BoxUUID:_tweetModel.boxuuid];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSouceArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    if (self.isSelect == false) {
    //        self.isSelect = true;
    [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5f];
    EntriesModel * model = self.dataSouceArray[indexPath.row];
    if (![model.type isEqualToString:@"file"]){
        FilesNextViewController * vc = [FilesNextViewController new];
        vc.parentUUID = model.uuid;
        vc.driveUUID = _driveUUID;
        vc.name = model.name;
        if (_selectType == WBFilesFirstBoxSelectType) {
            vc.selectType = WBFilesFirstBoxSelectType;
            [[FilesDataSourceManager manager].dataArray removeAllObjects];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        if (self.cellStatus == FLFliesCellStatusNormal) {
            [[FilesDataSourceManager manager].dataArray removeAllObjects];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        EntriesModel *model = _dataSouceArray[indexPath.row];
        
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            if ([[FLFIlesHelper helper].chooseFiles containsObject:model]) {
                [[FLFIlesHelper helper] removeChooseFile:model];
            }else
                [[FLFIlesHelper helper] addChooseFile:model];
            _countLb.text = [NSString stringWithFormat:WBLocalizedString(@"select_count", nil),(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
            [self.tableView reloadData];
        }else{
            if ([self videoPlayerResultWithModel:model]){
                return;
            }
            NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
            //            NSString* suffixName = model.uuid;
            NSString *fileName = model.name;
            //            NSString *extensionstring = [fileName pathExtension];
            NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
            NSLog(@"文件位置%@",saveFile);
            if ([[NSFileManager defaultManager] fileExistsAtPath:saveFile]) {
                _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:saveFile]];
                _documentController.delegate = self;
                [self presentOptionsMenu];
            }else{
                if (_selectType == WBFilesFirstBoxBrowseType && _tweetModel.boxuuid.length>0) {
                    self.progressView.descLb.text =@"正在下载文件";
                    self.progressView.subDescLb.text = [NSString stringWithFormat:@"1个项目 "];
                    self.progressView.cancleBlock = ^(){
                        [[CSFilesOneDownloadManager shareManager] cancelAllDownloadTask];
                    };
                    [_progressView show];
                    [[CSDownloadHelper shareManager] downloadOneFileWithFileModel:model BoxUUID:_tweetModel.boxuuid FileHash:model.photoHash IsDownloading:^(BOOL isDownloading) {
                        if (isDownloading){
                            [_progressView dismiss];
                            if (self.cellStatus == FLFliesCellStatusCanChoose) {
                                [self actionForNormalStatus];
                            }
                            LocalDownloadViewController *localDownloadViewController = [[LocalDownloadViewController alloc] init];
                            [self.navigationController pushViewController:localDownloadViewController animated:YES];
                        }
                    } begin:^{
                        
                    } progress:^(NSProgress *downloadProgress) {
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            CGFloat downloadProgressFloat = (float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (WB_UserService.currentUser.isCloudLogin) {
                                    
                                    [_progressView setValueForProcess:downloadProgressFloat];
                                    //                                NSLog(@"%lld",downloadProgress.completedUnitCount);
                                }else{
                                    [_progressView setValueForProcess:downloadProgress.fractionCompleted];
                                }
                            });
                        });
                    } complete:^(CSOneDowloadTask *downloadTask,NSError *error) {
                        [_progressView dismiss];
                        if (!error) {
                            _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:downloadTask.downloadFileModel.downloadFileSavePath]];
                            _documentController.delegate = self;
                            [self presentOptionsMenu];
                        }else{
                            //                            [SXLoadingView showProgressHUDText:@"下载失败,请重试" duration:1.5];
                        }
                    }];
                }else{
                    self.progressView.descLb.text =@"正在下载文件";
                    self.progressView.subDescLb.text = [NSString stringWithFormat:@"1个项目 "];
                    self.progressView.cancleBlock = ^(){
                        [[CSFilesOneDownloadManager shareManager] cancelAllDownloadTask];
                    };
                    [_progressView show];
                    NSString *rootUUID = _driveUUID;
                    if (!rootUUID) {
                        rootUUID = model.driveUUID;
                    }
                    NSString *parentUUUID = _parentUUID;
                    if (!parentUUUID) {
                        parentUUUID = model.parentUUID;
                    }
                    
                    [[CSDownloadHelper shareManager] downloadOneFileWithFileModel:model RootUUID:rootUUID  UUID:parentUUUID IsDownloading:^(BOOL isDownloading) {
                        if (isDownloading){
                            [_progressView dismiss];
                            if (self.cellStatus == FLFliesCellStatusCanChoose) {
                                [self actionForNormalStatus];
                            }
                            LocalDownloadViewController *localDownloadViewController = [[LocalDownloadViewController alloc] init];
                            [self.navigationController pushViewController:localDownloadViewController animated:YES];
                        }
                    } begin:^{
                        
                    } progress:^(NSProgress *downloadProgress) {
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            CGFloat downloadProgressFloat = (float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (WB_UserService.currentUser.isCloudLogin) {
                                    [_progressView setValueForProcess:downloadProgressFloat];
                                    //                                NSLog(@"%lld",downloadProgress.completedUnitCount);
                                }else{
                                    [_progressView setValueForProcess:downloadProgress.fractionCompleted];
                                }
                            });
                        });
                    } complete:^(CSOneDowloadTask *downloadTask,NSError *error) {
                        [_progressView dismiss];
                        if (!error) {
                            _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:downloadTask.downloadFileModel.downloadFileSavePath]];
                            _documentController.delegate = self;
                            [self presentOptionsMenu];
                        }else{
                            //                            [SXLoadingView showProgressHUDText:@"下载失败,请重试" duration:1.5];
                        }
                    }];
                }
            }
        }
    }
}


- (BOOL)videoPlayerResultWithModel:(EntriesModel*)model{
    NSString *pathExtension = [model.name pathExtension];
    NSMutableArray *vidioArr = [NSMutableArray arrayWithArray:[NSArray vidioFormatArray]];
    __block BOOL result;
    [vidioArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        result = [obj compare:pathExtension
                      options:NSCaseInsensitiveSearch | NSNumericSearch] == NSOrderedSame;
        if (result) {
            *stop = YES;
        }
    }];
    
    if (result) {
        
        //        NSString *loaclFormUrl = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/%@?name=%@",[JYRequestConfig sharedConfig].baseURL,_driveUUID,_parentUUID,model.uuid,model.name];
        ////        NSLog(@"%@",loaclFormUrl);
        //        NSURL *url = [NSURL URLWithString:[loaclFormUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]]];
        [[FMMediaRamdomKeyAPI  apiWithHash:model.photoHash] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            _videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight)];
            _videoView.backgroundColor = [UIColor blackColor];
            UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
            [window addSubview:_videoView];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/random/%@", [JYRequestConfig sharedConfig].baseURL, request.responseJsonObject[@"key"]]];
//
//            MRVLCPlayer *player = [[MRVLCPlayer alloc] init];
//
//            player.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 16 * 9);
//            player.center = self.view.center;
//            player.mediaURL = url;
//            [player showInView:self.view.window];
            //            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            
            VLCMediaPlayer *mediaPlay = [[VLCMediaPlayer alloc]init];
            VLCMedia *media = [VLCMedia mediaWithURL:url];
            //             [dic setValue:WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forKey:@"Authorization"];
            //
            //             [media addOptions:dic];
//
            _videoControlView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight)];
            _videoControlView.backgroundColor = [UIColor clearColor];

            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playControlViewTap:)];
            [_videoControlView addGestureRecognizer:tapGesture];

            [window addSubview:_videoControlView];

            _playButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
            _playButton.center =CGPointMake(__kWidth/2, __kHeight/2);
            [_playButton setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
            [_playButton setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateSelected];
            [_playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [_playButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
            [_videoControlView addSubview:_playButton];

            _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(__kWidth - 24 - 16, 20 + 44/2-28/2 +5, 24, 24)];
            [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
            [_closeButton addTarget:self action:@selector(playCloseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            _closeButton.alpha = 0.5f;
            [_closeButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
            [_videoControlView addSubview:_closeButton];

            mediaPlay.media = media;
            mediaPlay.delegate = self;
            mediaPlay.drawable = _videoView;
            _mediaPlay = mediaPlay;
        } failure:^(__kindof JYBaseRequest *request) {
            [SXLoadingView showAlertHUD:WBLocalizedString(@"play_failed", nil) duration:1];
            result = NO;
        }];
    }
    if (result) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark UIDocumentInteractionControllerDelegate


- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
    NSLog(@"%@",aNotification);
    VLCMediaPlayer *play = aNotification.object;
    //    NSLog(@"😁%ld",(long)play.time);
//    NSString *dateString = [CSDateUtil stringWithDate:[NSDate dateWithTimeIntervalSince1970:(long)play.time] withFormat:@"mm:ss"];
//    NSLog(@"😁%@",dateString);
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    NSLog(@"%@",aNotification);
    VLCMediaPlayer *play = aNotification.object;
    NSLog(@"%ld",(long)play.state);
    if (play.state == VLCMediaPlayerStateError) {
        [SXLoadingView showProgressHUDText:@"视频播发失败或暂不支持该格式" duration:1.2];
    }else if (play.state == VLCMediaPlayerStatePlaying){
        [UIView animateWithDuration:0.5f animations:^{
            _playButton.hidden = YES;
            _closeButton.hidden = YES;
            _playButton.userInteractionEnabled = NO;
            _closeButton.userInteractionEnabled = NO;
        }];
    }else if (play.state == VLCMediaPlayerStateEnded){
        if (_playButton.hidden) {
            _playButton.hidden = NO;
            _closeButton.hidden = NO;
            _playButton.userInteractionEnabled = YES;
            _closeButton.userInteractionEnabled = YES;
        }
        _playButton.selected = NO;
        [_mediaPlay stop];
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
        _tableView.noDataImageName = @"no_file";
    }
    return _tableView;
}

- (NSMutableArray *)dataSouceArray{
    if (!_dataSouceArray) {
        _dataSouceArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSouceArray;
}

- (UIView *)chooseHeadView{
    if (!_chooseHeadView) {
        _chooseHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, __kWidth, 64)];
        _chooseHeadView.backgroundColor = UICOLOR_RGB(0x03a9f4);
        UIButton * leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 16, 48, 48 )];
        UIImage * backImage = [UIImage imageNamed:@"back"];
        [leftBtn setImage:backImage forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _leftBtn = leftBtn;
        
        UILabel * countLb = [[UILabel alloc]initWithFrame:CGRectMake(__kWidth/2 - 50, 27, 100, 30)];
        countLb.textColor = [UIColor whiteColor];
        countLb.font = [UIFont fontWithName:Helvetica size:17];
        countLb.textAlignment = NSTextAlignmentCenter;
        _countLb = countLb;
        [_chooseHeadView addSubview:countLb];
        [_chooseHeadView addSubview:leftBtn];
        _countLb.text = WBLocalizedString(@"select_file", nil);
        _countLb.font = [UIFont fontWithName:FANGZHENG size:16];
        [_chooseHeadView setHidden:YES];
    }
    return _chooseHeadView;
}

- (VCFloatingActionButton *)addButton{
    if(!_addButton){
        CGRect floatFrame = CGRectMake(__kWidth - 56 - 16 , __kHeight - 64 - 56 - 16, 56, 56);
        _addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"add_album"] andPressedImage:[UIImage imageNamed:@"icon_close"] withScrollview:_tableView];
        _addButton.automaticallyInsets = YES;
        _addButton.imageArray = @[@"download"];
        _addButton.labelArray = @[@""];
        _addButton.delegate = self;
        _addButton.hidden = YES;
    }
    return _addButton;
}

- (JYProcessView *)progressView{
    if (!_progressView){
        _progressView = [JYProcessView processViewWithType:ProcessTypeLine];
    }
    return _progressView;
}

@end

