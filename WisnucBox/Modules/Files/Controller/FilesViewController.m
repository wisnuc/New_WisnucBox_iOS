//
//  FilesViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

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

@interface FilesViewController ()
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

@implementation FilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBtns];
    [self loadData];
    [self initView];
    [self registerNotifacationAndDelegate];
}

- (void)dealloc{
    [KDefaultNotificationCenter removeObserver:self];
}

-(void)createNavBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem,nil];
    [self.navigationController.view addSubview:self.chooseHeadView];
}

- (void)initView{
    [self.view addSubview:self.tableView];
    [self initMjRefresh];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.addButton];
}

- (void)loadData{
    [FilesDataSourceManager manager].delegate = self;
    [[FilesDataSourceManager manager] getFilesWithUUID:WB_UserService.currentUser.userHome];
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
    if (self.cellStatus != FLFliesCellStatusCanChoose) {
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self actionForChooseStatus];
            }
        } otherButtonTitles:@"选择文件", nil] show];
    }else{
//        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [[FLFIlesHelper helper] removeAllChooseFile];
//            }else if ( buttonIndex == 2){
//                [[FLFIlesHelper helper] downloadChooseFilesParentUUID:WB_UserService.currentUser.userHome];
//                [self.rdv_tabBarController setSelectedIndex:2];
//            }
//        } otherButtonTitles:@"清除选择",@"下载所选项", nil] show];
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
        [SXLoadingView showProgressHUDText:@"文件预览失败" duration:1];
        [_documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }
}

- (void)actionForChooseStatus{
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
        return;
    }
    if (self.dataSouceArray.count == 0) {
        [SXLoadingView showAlertHUD:@"您所在的文件夹没有文件可以选择" duration:2];
        return;
    }
    [self.tableView.mj_header setHidden:YES];
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, 64);
    }];
    _addButton.hidden = NO;
    [self.cyl_tabBarController.tabBar setHidden:YES];
    self.cellStatus = FLFliesCellStatusCanChoose;
    _countLb.text = [NSString stringWithFormat:@"已选%ld个文件",(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
    [self.tableView reloadData];
}

- (void)actionForNormalStatus{
    if (self.cellStatus == FLFliesCellStatusNormal) {
        return;
    }
    
    [self.tableView.mj_header setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, -64);
    }];
    _addButton.hidden = YES;
    [self.cyl_tabBarController.tabBar setHidden:NO];
    self.cellStatus = FLFliesCellStatusNormal;
    _countLb.text = [NSString stringWithFormat:@"已选1个文件"];
    [self.tableView reloadData];
}

- (void)handlerStatusChangeNotify:(NSNotification *)notify{
    if (![notify.object boolValue]) {
        [self actionForNormalStatus];
    }else{
        if (self.cellStatus != FLFliesCellStatusCanChoose) {
            [self actionForChooseStatus];
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
    }else{
        [self.tableView.mj_header endRefreshing];
    }
}

#pragma mark - floatMenuDelegate

- (void)didSelectMenuOptionAtIndex:(NSInteger)row{
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
        if (row == 0) {
            if ([FLFIlesHelper helper].chooseFiles.count == 0) {
                [SXLoadingView showAlertHUD:@"请先选择文件" duration:1];
            }else{
                [self actionForNormalStatus];
                [[FLFIlesHelper helper] downloadChooseFilesParentUUID:WB_UserService.currentUser.uuid];
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
    [[FLFIlesHelper helper] configCells:cell withModel:dataModel cellStatus:self.cellStatus viewController:self parentUUID:WB_UserService.currentUser.uuid];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSouceArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSelect == false) {
        self.isSelect = true;
        [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5f];
        EntriesModel * model = self.dataSouceArray[indexPath.row];
        if (![model.type isEqualToString:@"file"]){
            FilesNextViewController * vc = [FilesNextViewController new];
            vc.parentUUID = model.uuid;
            vc.name = model.name;
            if (self.cellStatus == FLFliesCellStatusNormal) {
                [[FilesDataSourceManager manager].dataArray removeAllObjects];
//                [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
//                    [self.cyl_tabBarController.tabBar setHidden:YES];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else{
            EntriesModel *model = _dataSouceArray[indexPath.row];
            if (self.cellStatus == FLFliesCellStatusCanChoose) {
                if ([[FLFIlesHelper helper].chooseFiles containsObject:model]) {
                    [[FLFIlesHelper helper] removeChooseFile:model];
                }else
                    [[FLFIlesHelper helper] addChooseFile:model];
                _countLb.text = [NSString stringWithFormat:@"已选%ld个文件",(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
                [self.tableView reloadData];
            }else{
                NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
                NSString* suffixName = model.name;
                NSString* saveFile = [savePath stringByAppendingPathComponent:suffixName];
                NSLog(@"文件位置%@",saveFile);
                if ([[NSFileManager defaultManager] fileExistsAtPath:saveFile]) {
                    _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:saveFile]];
                    _documentController.delegate = self;
                    [self presentOptionsMenu];
                }else{
                    self.progressView.descLb.text =@"正在下载文件";
                    self.progressView.subDescLb.text = [NSString stringWithFormat:@"1个项目 "];
                    self.progressView.cancleBlock = ^(){
                        [[CSDownloadHelper shareManager] cancleDownload];
                    };
                    [_progressView show];
                    [[CSDownloadHelper shareManager] downloadOneFileWithFileModel:model UUID:WB_UserService.currentUser.uuid IsDownloading:^(BOOL isDownloading) {
                        if (isDownloading){
                            [_progressView dismiss];
                            LocalDownloadViewController *localDownloadViewController = [[LocalDownloadViewController alloc] init];
                            [self.navigationController pushViewController:localDownloadViewController animated:YES];
                        }
                    } begin:^{
                        
                    } progress:^(long long totalBytesRead, long long totalBytesExpectedToRead, float progress) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_progressView setValueForProcess:progress];

                        });
                    } complete:^(CSDownloadTask *downloadTask,NSError *error) {
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

#pragma mark UIDocumentInteractionControllerDelegate


- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
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
        _countLb.text = @"选择文件";
        _countLb.font = [UIFont fontWithName:FANGZHENG size:16];
    }
    return _chooseHeadView;
}

- (VCFloatingActionButton *)addButton{
    if(!_addButton){
        CGRect floatFrame = CGRectMake(__kWidth - 80 , __kHeight - 64 - 56 - 88, 56, 56);
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

