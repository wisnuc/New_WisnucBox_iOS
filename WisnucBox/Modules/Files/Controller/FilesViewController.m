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
//test
#import "TestDataModel.h"

@interface FilesViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
floatMenuDelegate,
LCActionSheetDelegate,
UIDocumentInteractionControllerDelegate
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

@end

@implementation FilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBtns];
    [self loadData];
    [self initView];
    
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
    TestDataModel *dataModel = [TestDataModel new];
    dataModel.URLstring = @"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.1.1.dmg";
    dataModel.fileName = @"QQ for Mac";
    dataModel.fileUUID = @"1";
    dataModel.type = @"file";
    [self.dataSouceArray addObject:dataModel];
    
    TestDataModel *dataModel2 = [TestDataModel new];
    dataModel2.URLstring = @"http://d1.music.126.net/dmusic/NeteaseMusic_1.5.7_580_web.dmg";
    dataModel2.fileName = @"NeteaseMusic for Mac";
    dataModel2.fileUUID = @"2";
    dataModel2.type = @"file";
    [self.dataSouceArray addObject:dataModel2];
    
    TestDataModel *dataModel3 = [TestDataModel new];
    dataModel3.URLstring = @"https://dldir1.qq.com/foxmail/MacFoxmail/Foxmail_for_Mac_V1.2.0.dmg";
    dataModel3.fileName = @"Foxmail_for_Mac";
    dataModel3.fileUUID = @"3";
    dataModel3.type = @"file";
    [self.dataSouceArray addObject:dataModel3];
    
    TestDataModel *dataModel4 = [TestDataModel new];
    dataModel4.URLstring = @"http://www.zcool.com.cn/community/037116d5970d5cba8012193a34315ac.jpg";
    dataModel4.fileName = @"BackgroudImage";
    dataModel4.fileUUID = @"4";
    dataModel4.type = @"file";
    [self.dataSouceArray addObject:dataModel4];
   
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

- (void)initMjRefresh{
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = KDefaultOffset;
    //    [self.tableView.mj_header beginRefreshing];
}

- (void)leftBtnClick:(id)sender{
    //    for (FLFilesModel * model in self.dataSource.dataSource) {
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
//        [[FLFIlesHelper helper] removeChooseFile:model];
        [self.tableView reloadData];
        [self actionForNormalStatus];
    }
    //    }
}

- (void)rightBtnClick:(UIButton *)btn{
    if (self.cellStatus != FLFliesCellStatusCanChoose) {
        //        @weaky(self);
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self actionForChooseStatus];
            }
        } otherButtonTitles:@"选择文件", nil] show];
    }else{
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[FLFIlesHelper helper] removeAllChooseFile];
            }else if ( buttonIndex == 2){
                [[FLFIlesHelper helper] downloadChooseFilesParentUUID:@""];
                [self.rdv_tabBarController setSelectedIndex:2];
            }
        } otherButtonTitles:@"清除选择",@"下载所选项", nil] show];
    }
}

- (void)presentOptionsMenu
{
    
    BOOL canOpen = [self.documentController presentPreviewAnimated:YES];
    if (!canOpen) {
        [SXLoadingView showProgressHUDText:@"文件预览失败" duration:1];
//        [MyAppDelegate.notification displayNotificationWithMessage:@"文件预览失败" forDuration:1];
        [_documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }
}

- (void)actionForChooseStatus{
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
        return;
    }
    //    if (self.dataSource.dataSource.count == 0) {
    //        [SXLoadingView showAlertHUD:@"您所在的文件夹没有文件可以选择" duration:2];
    //        return;
    //    }
    [self.tableView.mj_header setHidden:YES];
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, 64);
    }];
    _addButton.hidden = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.cellStatus = FLFliesCellStatusCanChoose;
    _countLb.text = [NSString stringWithFormat:@"已选%ld个文件",(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
    [self.tableView reloadData];
    //     }
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
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    self.cellStatus = FLFliesCellStatusNormal;
    _countLb.text = [NSString stringWithFormat:@"已选1个文件"];
    [self.tableView reloadData];
}

#pragma mark - floatMenuDelegate

- (void)didSelectMenuOptionAtIndex:(NSInteger)row{
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
        if (row == 0) {
            if ([FLFIlesHelper helper].chooseFiles.count == 0) {
                [SXLoadingView showAlertHUD:@"请先选择文件" duration:1];
            }else{
                [self actionForNormalStatus];
                [[FLFIlesHelper helper] downloadChooseFilesParentUUID:@""];
                //                 *downloadVC = [[FLLocalFIleVC alloc]init];
                //                [self.navigationController pushViewController:downloadVC animated:YES];
            }
        }else{
            //            [self shareFiles];
        }
    }
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
    TestDataModel *dataModel = _dataSouceArray[indexPath.row];
    [[FLFIlesHelper helper] configCells:cell withModel:dataModel cellStatus:self.cellStatus viewController:self parentUUID:@""];
    //    cell.downBtn.userInteractionEnabled = YES;
    //    cell.nameLabel.text = dataModel.fileName;
    //    cell.f_ImageView.image = [UIImage imageNamed:@"file_icon"];
    //    cell.clickBlock = ^(FLFilesCell * cell){
    //        NSString *downloadString  = @"下载该文件";
    //        //        NSString *openFileString = @"";
    //        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    //        [arr addObject:downloadString];
    //        LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
    //                                                                 delegate:nil
    //                                                        cancelButtonTitle:@"取消"
    //                                                    otherButtonTitleArray:arr];
    //        actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
    //            if (buttonIndex == 1) {
    //                [[CSDownloadHelper  shareManager] downloadFileWithFileModel:dataModel UUID:@"1"];
    //            }
    //        };
    //        actionSheet.scrolling          = YES;
    //        actionSheet.buttonHeight       = 60.0f;
    //        actionSheet.visibleButtonCount = 3.6f;
    //        [actionSheet show];
    //    };
    //
    //    cell.longpressBlock =^(FLFilesCell * cell){
    //        if (cell.status == FLFliesCellStatusNormal) {
    ////            if ([model.type isEqualToString:@"file"])
    ////                [weak_self addChooseFile:model];
    //        }
    //    };
    //
    //     cell.status = _cellStatus;
    
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
//    }
    TestDataModel *model = _dataSouceArray[indexPath.row];
    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
    NSString* suffixName = [model.URLstring lastPathComponent];
    NSString* saveFile = [savePath stringByAppendingPathComponent:suffixName];
    NSLog(@"%@",saveFile);
    if ([[NSFileManager defaultManager] fileExistsAtPath:saveFile]) {
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:saveFile]];
        _documentController.delegate = self;
        [self presentOptionsMenu];
    }else{
        
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

@end

