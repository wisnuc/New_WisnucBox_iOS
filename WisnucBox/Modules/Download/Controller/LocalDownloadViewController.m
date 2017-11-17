//
//  LocalDownloadViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "LocalDownloadViewController.h"
#import "LocalDownloadTableViewCell.h"
#import "LocalDownloadingTableViewCell.h"
#import "CSFileDownloadManager.h"
#import "CSDownloadTask.h"
#import "CSDownloadModel.h"
#import "CSFileUtil.h"
#import "CSDateUtil.h"
#import "CSDownloadHelper.h"
#import "FilesServices.h"


@interface LocalDownloadViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
DownloadHelperDelegate,
UIDocumentInteractionControllerDelegate
>
{
    CSFileDownloadManager* _manager;
    FilesServices *_filesServices;
}

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *downloadingArray;

@property (nonatomic,strong) NSMutableArray *downloadedArray;

@property (nonatomic,strong) CSFileDownloadManager *downloadManager;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic) LocalFliesCellStatus cellStatus;

@property (nonatomic) NSMutableArray * chooseArr;

@end

@implementation LocalDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBtns];
    self.title = @"下载管理";
    [CSDownloadHelper shareManager].delegate = self;
    _manager  = [CSFileDownloadManager sharedDownloadManager];
    _filesServices = [FilesServices new];
    [self loadData];
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)loadData{
    self.downloadingArray = [NSMutableArray arrayWithArray:_manager.downloadingTasks];
    self.downloadedArray = [NSMutableArray arrayWithArray: [_filesServices findAll]];
}

- (void)createNavBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)updateDataWithDownloadTask:(CSDownloadTask *)downloadTask {
    [self loadData];
    [self.tableView reloadData];
}

- (void)presentOptionsMenu
{
    BOOL canOpen = [self.documentController presentPreviewAnimated:YES];
    if (!canOpen) {
        [SXLoadingView showProgressHUDText:@"文件预览失败" duration:1];
        [_documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }

}

- (void)deleteChooseFiles{
    for (CSDownloadTask * task in self.downloadingArray) {
        if ([self.chooseArr containsObject:task.downloadFileModel.getDownloadFileUUID]) {
            [self.chooseArr removeObject:task];
            [[CSFileDownloadManager sharedDownloadManager] cancelOneDownloadTaskWith:task];
        }
    }

    NSMutableArray * arrayTemp = self.downloadedArray;
    NSArray * array = [NSArray arrayWithArray: arrayTemp];
    for (WBFile * downloadFileModel in array) {
        if ([self.chooseArr containsObject:downloadFileModel.fileUUID]) {
            [self.downloadedArray removeObject:downloadFileModel];
            [_filesServices deleteFileWithFileUUID:downloadFileModel.fileUUID];
        }
    }
    [self changeStatus];

}

- (void)rightBtnClick:(UIButton *)btn{
    @weaky(self);
    if(_downloadedArray.count == 0 && _downloadingArray.count == 0){
        [SXLoadingView showProgressHUDText:@"没有文件可以进行选择" duration:1];
    }else{
        if (!self.cellStatus) {
            [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [weak_self changeStatus];
                }
            } otherButtonTitles:@"选择", nil] show];
        }else{
            [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [weak_self changeStatus];
                }else if ( buttonIndex == 2){
                    [weak_self deleteChooseFiles];
                }
            } otherButtonTitles:@"清除选择",@"删除", nil] show];
        }
    }
}

- (void)changeStatus{
    if (_cellStatus == LocalFliesCellStatusCanChoose) {
        [self.chooseArr removeAllObjects];
    }
    _cellStatus = !_cellStatus;
    [self loadData];
    [self.tableView reloadData];
}

#pragma UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (indexPath.section==0) {
      LocalDownloadingTableViewCell *cell;
       cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LocalDownloadingTableViewCell class])];
        if (nil == cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LocalDownloadingTableViewCell class]) owner:nil options:nil] lastObject];
        }
        CSDownloadTask *downloadTask = _downloadingArray[indexPath.row];
        CSDownloadModel* downloadFileModel = [downloadTask getDownloadFileModel];
        cell.fileNameLabel.text = downloadFileModel.downloadFileName;
        cell.progressLabel.text = @"等待下载";
        downloadTask.progressBlock = ^(long long totalBytesRead, long long totalBytesExpectedToRead, float progress) {
            NSString *progressString = [NSString stringWithFormat:@"%@/%@",[CSFileUtil calculateUnit:totalBytesRead],[CSFileUtil calculateUnit:totalBytesExpectedToRead]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.progressLabel.text = progressString;
            });
        };
        if ([self.chooseArr containsObject:downloadFileModel.getDownloadFileUUID]) {
            cell.f_ImageView.hidden = YES;
            cell.layerView.image = [UIImage imageNamed:@"check_circle_select"];
        }else{
            cell.f_ImageView.hidden = NO;
            cell.layerView.image = [UIImage imageNamed:@"check_circle"];
        }
        cell.clickBlock = ^(LocalDownloadingTableViewCell * cell){
            LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                     delegate:nil
                                                            cancelButtonTitle:@"取消"
                                                        otherButtonTitleArray:@[@"取消下载"]];
            actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
                if (buttonIndex == 1) {
                    if (self.downloadingArray.count == 0) {
                        [actionSheet setHidden:YES];
                        return ;
                    }
                    
                    CSDownloadTask *downloadTask = [self.downloadingArray objectAtIndex:indexPath.row];
                    NSLog(@"%u",downloadTask.downloadStatus);
                    if (downloadTask.downloadStatus == CSDownloadStatusCanceled||
                       downloadTask.downloadStatus == CSDownloadStatusSuccess||
                        downloadTask.downloadStatus == CSDownloadStatusFailure ) {
                        [actionSheet setHidden:YES];
                        return ;
                    }
                    [[CSFileDownloadManager sharedDownloadManager] cancelOneDownloadTaskWith:downloadTask];
                    [self.downloadingArray removeObjectAtIndex:[indexPath row]];
                    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView reloadData];
                }
            };
            actionSheet.scrolling          = YES;
            actionSheet.buttonHeight       = 60.0f;
            actionSheet.visibleButtonCount = 3.6f;
            [actionSheet show];
        };
        
        @weaky(self);
        cell.longpressBlock =^(LocalDownloadingTableViewCell *cell){
            if (_cellStatus == LocalFliesCellStatusNormal) {
                NSString * uuid = downloadFileModel.getDownloadFileUUID;
                [weak_self.chooseArr addObject:uuid];
                [weak_self changeStatus];
            }
        };
        
        cell.status = _cellStatus;
          return cell;
    }else{
        LocalDownloadTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LocalDownloadTableViewCell class])];
        if (nil == cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LocalDownloadTableViewCell class]) owner:nil options:nil] lastObject];
        }
        NSLog(@"%@",_downloadedArray[indexPath.row]);
        WBFile * data = _downloadedArray[indexPath.row];
//        WBFile * data= [WBFile MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];

        cell.fileNameLabel.text = data.fileName;
        cell.downloadTimeLabel.text = [CSDateUtil stringWithDate:data.timeDate withFormat:@"yyyy-MM-dd HH:mm:ss"];
        cell.downloadedSizeLabel.text = [CSFileUtil calculateUnit:[data.fileSize longLongValue]];
        
        if ([self.chooseArr containsObject:data.fileUUID]) {
            cell.f_ImageView.hidden = YES;
            cell.layerView.image = [UIImage imageNamed:@"check_circle_select"];
        }else{
            cell.f_ImageView.hidden = NO;
            cell.layerView.image = [UIImage imageNamed:@"check_circle"];
        }
        
        @weaky(self);
        cell.longpressBlock =^(LocalDownloadTableViewCell * cell){
            if (_cellStatus == LocalFliesCellStatusNormal) {
                NSString * uuid = data.fileUUID;
                [weak_self.chooseArr addObject:uuid];
                [weak_self changeStatus];
            }
        };
        
        cell.status = _cellStatus;
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
         return self.downloadingArray.count;
    }else{
         return self.downloadedArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"正在下载";
    }
    else{
        return @"已下载";
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

#pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.cellStatus == LocalFliesCellStatusCanChoose){
        id model = indexPath.section == 0?
        self.downloadingArray[indexPath.row]:self.downloadedArray[indexPath.row];
        NSString * uuid = [model isKindOfClass:[CSDownloadTask class]]?
        ((CSDownloadTask *)model).downloadFileModel.getDownloadFileUUID:((WBFile*)model).fileUUID;
        
        if([self.chooseArr containsObject:uuid]){
            [self.chooseArr removeObject:uuid];
        }
        else
        {
            [self .chooseArr addObject:uuid];
        }
        [self.tableView reloadData];
    }else{
        if (indexPath.section == 1) {
            WBFile *downloadedFileModel = _downloadedArray[indexPath.row];
            NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
            NSString* suffixName = downloadedFileModel.fileName;
            NSString* saveFile = [savePath stringByAppendingPathComponent:suffixName];
            NSLog(@"文件位置%@",saveFile);
            if ([[NSFileManager defaultManager] fileExistsAtPath:saveFile]) {
                _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:saveFile]];
                _documentController.delegate = self;
                [self presentOptionsMenu];
            }
        }
    }
    if (self.chooseArr.count == 0 && _cellStatus == LocalFliesCellStatusCanChoose) {
        [self changeStatus];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
//     UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//     header.contentView.backgroundColor = [UIColor lightTextColor];
//}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}


//lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)downloadedArray{
    if(!_downloadedArray){
        _downloadedArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _downloadedArray;
}

- (NSMutableArray *)downloadingArray{
    if(!_downloadingArray){
        _downloadingArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _downloadingArray;
}

- (NSMutableArray *)chooseArr{
    if (!_chooseArr) {
        _chooseArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _chooseArr;
}

@end
