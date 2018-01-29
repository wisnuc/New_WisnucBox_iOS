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
#import "FilesNextViewController.h"
#import "FilesDataSourceManager.h"
#import "CSFilesOneDownloadManager.h"
#import "WBFilesAndTransmitProtocal.h"

@interface FilesNextViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
floatMenuDelegate,
LCActionSheetDelegate,
UIDocumentInteractionControllerDelegate,
FLDataSourceDelegate,
FilesHelperOpenFilesDelegate
>
{
    UIButton * _leftBtn;
    UILabel * _countLb;
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
    if (self.cellStatus != FLFliesCellStatusCanChoose) {
        [self actionForNormalStatus];
    }
    if (!self.chooseHeadView.hidden) {
        [self.chooseHeadView setHidden:YES];
    }
    [self.chooseHeadView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.view addSubview:self.chooseHeadView];
}

- (void)dealloc{
    [KDefaultNotificationCenter removeObserver:self];
}

-(void)createNavBtns{
    self.title = _name;
//    self.navigationItem.rightBarButtonItem = nil;
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
//    UIBarButtonItem * rightItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBtnClick:) nomalImage:[UIImage imageNamed:@"more"]  higeLightedImage:[UIImage imageNamed:@"more_highlight"]  imageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
//     UIBarButtonItem * rightItemfixSpace = [UIBarButtonItem fixedSpaceWithWidth:100];
//    self.navigationItem.rightBarButtonItems = @[rightItem,rightItemfixSpace];

//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem fixedSpaceWithWidth:10];
}

- (void)initView{
    [self.view addSubview:self.tableView];
    [self initMjRefresh];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.addButton];
}

- (void)loadData{
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
    [KDefaultNotificationCenter addObserver:self selector:@selector(handlerStatusChangeNotify:) name:FLFilesStatusChangeNotify object:nil];

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
    [UIView animateWithDuration:0.2 animations:^{
        self.chooseHeadView.transform = CGAffineTransformTranslate(self.chooseHeadView.transform, 0, -64);
    } completion:^(BOOL finished) {
        [self.chooseHeadView setHidden:YES];
         _addButton.hidden = YES;
    }];
  
   
//    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    self.cellStatus = FLFliesCellStatusNormal;
    _countLb.text = [NSString stringWithFormat:WBLocalizedString(@"select_count", nil),1];
    [self.tableView reloadData];
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
                [self actionForNormalStatus];
                [[FLFIlesHelper helper] downloadChooseFilesParentUUID:_parentUUID RootUUID:_driveUUID];
                LocalDownloadViewController  *downloadVC = [[LocalDownloadViewController alloc]init];
                [self.navigationController pushViewController:downloadVC animated:YES];
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
    [[FLFIlesHelper helper] configCells:cell withModel:dataModel cellStatus:self.cellStatus viewController:self parentUUID:_parentUUID RootUUID:_driveUUID];
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
                NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
                NSString* suffixName = model.uuid;
                NSString *fileName = model.name;
                NSString *extensionstring = [fileName pathExtension];
                NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
                NSLog(@"文件位置%@",saveFile);
                if ([[NSFileManager defaultManager] fileExistsAtPath:saveFile]) {
                    _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:saveFile]];
                    _documentController.delegate = self;
                    [self presentOptionsMenu];
                }else{
                    self.progressView.descLb.text =@"正在下载文件";
                    self.progressView.subDescLb.text = [NSString stringWithFormat:@"1个项目 "];
                    self.progressView.cancleBlock = ^(){
                        [[CSFilesOneDownloadManager shareManager] cancelAllDownloadTask];
                    };
                    [_progressView show];
                    [[CSDownloadHelper shareManager] downloadOneFileWithFileModel:model RootUUID:_driveUUID  UUID:_parentUUID IsDownloading:^(BOOL isDownloading) {
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
//}

#pragma mark UIDocumentInteractionControllerDelegate


- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
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
