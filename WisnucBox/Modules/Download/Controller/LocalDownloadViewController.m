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
#import "CSUploadHelper.h"

@interface LocalDownloadViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
DownloadHelperDelegate,
UploadHelperDelegate,
UIDocumentInteractionControllerDelegate
>
{
    CSFileDownloadManager* _manager;
    CSFileUploadManager* _uploadManager;
    FilesServices *_filesServices;
}

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *transmitingArray;

@property (nonatomic,strong) NSMutableArray *transmitiedArray;

//@property (nonatomic,strong) NSMutableArray *downloadingArray;

@property (nonatomic,strong) NSMutableArray *downloadedArray;

@property (nonatomic,strong) NSMutableArray *uploadingArray;

@property (nonatomic,strong) NSMutableArray *uploadedArray;

@property (nonatomic,strong) CSFileDownloadManager *downloadManager;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic) LocalFliesCellStatus cellStatus;

@property (nonatomic) NSMutableArray * chooseArr;

@end

@implementation LocalDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBtns];
    self.title = LeftMenuTransmissionManageString;
    [CSDownloadHelper shareManager].delegate = self;
    [CSUploadHelper shareManager].delegate = self;
    _manager  = [CSFileDownloadManager sharedDownloadManager];
    _uploadManager = [CSFileUploadManager sharedUploadManager];
    _filesServices = [FilesServices new];
    [self loadData];
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [KDefaultNotificationCenter addObserver:self selector:@selector(handleNetReachabilityNotify:) name:NETWORK_REACHABILITY_CHANGE_NOTIFY object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.tableView) {
        [self.tableView reloadData];
    }
//    [self ]
//    [self.cyl_tabBarController.tabBar setHidden:YES];
}

- (void)loadData{
//    self.downloadingArray = [NSMutableArray arrayWithArray:_manager.downloadingTasks];
//    self.uploadingArray = [NSMutableArray arrayWithArray:_uploadManager.uploadingTasks];
    self.downloadedArray = [NSMutableArray arrayWithArray: [_filesServices findAll]];
    self.transmitingArray = [NSMutableArray arrayWithArray:_manager.downloadingTasks];
    [self.transmitingArray addObjectsFromArray:_uploadManager.uploadingTasks];
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

- (void)updateDataWithDownloadTask:(CSDownloadTask *)downloadTask {
    [self loadData];
//    NSLog(@"%@",_downloadingArray);
    [self.tableView reloadData];
}

- (void)updateDataWithUploadTask:(CSUploadTask *)uploadTask{
    [self loadData];
    [self.tableView reloadData];
//    NSLog(@"%@",_downloadingArray);
}

- (void)handleNetReachabilityNotify:(NSNotification *)noti {
    NSNumber *statusNumber = noti.object;
    AFNetworkReachabilityStatus status = [statusNumber integerValue];
    if (status != AFNetworkReachabilityStatusReachableViaWiFi) {
        [_transmitingArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            LocalDownloadingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//            cell.progressLabel.text = @"等待传输";
        }];
    }
}


- (void)presentOptionsMenu
{
    BOOL canOpen = [self.documentController presentPreviewAnimated:YES];
    if (!canOpen) {
        [SXLoadingView showProgressHUDText:WBLocalizedString(@"file_preview_failed", nil) duration:1];
        [_documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }

}

- (void)deleteChooseFiles{
    [self.transmitingArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSStringFromClass([obj class]) isEqualToString:NSStringFromClass([CSDownloadTask class])]) {
            CSDownloadTask * task = obj;
            if ([self.chooseArr containsObject:task.downloadFileModel.getDownloadFileUUID]) {
            [self.chooseArr removeObject:task];
            [[CSFileDownloadManager sharedDownloadManager] cancelOneDownloadTaskWith:task];
            }
        }else{
               CSUploadTask * task = obj;
                if ([self.chooseArr containsObject:task.uploadFileModel.getUploadFileUUID]) {
                    [self.chooseArr removeObject:task];
                    [[CSFileUploadManager sharedUploadManager] cancelOneUploadTaskWith:task];
            }
        }
    }];
        
    NSMutableArray * arrayTemp = self.downloadedArray;
    NSArray * array = [NSArray arrayWithArray: arrayTemp];
    for (WBFile * downloadFileModel in array) {
        if ([self.chooseArr containsObject:downloadFileModel.fileUUID]) {
            [self.downloadedArray removeObject:downloadFileModel];
            [_filesServices deleteFileWithFileUUID:downloadFileModel.fileUUID FileName:downloadFileModel.fileName ActionType:downloadFileModel.actionType];
        }
    }
    [self changeStatus];
}

- (void)rightBtnClick:(UIButton *)btn{
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    NSString *selectTitle = WBLocalizedString(@"choose_text", nil);
    NSString *clearTitle = WBLocalizedString(@"clear_select_item", nil);
    NSString *deleteTitle = WBLocalizedString(@"delete_text", nil);
    
    @weaky(self);
    if(_downloadedArray.count == 0 && self.transmitingArray.count == 0){
        [SXLoadingView showProgressHUDText:WBLocalizedString(@"no_file", nil) duration:1];
    }else{
        if (!self.cellStatus) {
            [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:cancelTitle clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [weak_self changeStatus];
                }
            } otherButtonTitles:selectTitle, nil] show];
        }else{
            [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:cancelTitle clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [weak_self changeStatus];
                }else if ( buttonIndex == 2){
                    [weak_self deleteChooseFiles];
                }
            } otherButtonTitles:clearTitle,deleteTitle, nil] show];
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
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (indexPath.section==0) {
      LocalDownloadingTableViewCell *cell;
       cell = [tableView  dequeueReusableCellWithIdentifier:NSStringFromClass([LocalDownloadingTableViewCell class])];
        if (!cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LocalDownloadingTableViewCell class]) owner:self options:nil] lastObject];
        }
        NSLog(@"%@",[_transmitingArray[indexPath.row] class]);
        if ([NSStringFromClass([_transmitingArray[indexPath.row] class]) isEqualToString:NSStringFromClass([CSDownloadTask class])]) {
            CSDownloadTask *downloadTask = _transmitingArray[indexPath.row] ;
            NSLog(@"%@",_transmitingArray);
            NSLog(@"%@",downloadTask);
            CSDownloadModel* downloadFileModel = [downloadTask getDownloadFileModel];
            cell.fileNameLabel.text = downloadFileModel.downloadFileName;
            //        cell.progressLabel.text = @"正在下载";
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
            downloadTask.progressBlock = ^(NSProgress *downloadProgress) {
                if (downloadProgress.fractionCompleted) {
                    if ([NSThread isMainThread] ) {
                        cell.progressView.progress = downloadProgress.fractionCompleted;
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.progressView.progress = downloadProgress.fractionCompleted;
                        });
                    }
                    
                }else{
                    
                    float progressFloat = (float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount;
                    NSLog(@"%f",progressFloat);
                    if ([NSThread isMainThread] ) {
                        cell.progressView.progress = progressFloat;
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.progressView.progress = progressFloat;
                        });
                    }
                }
                
              };
            });
            if ([self.chooseArr containsObject:downloadFileModel.getDownloadFileUUID]) {
                cell.f_ImageView.hidden = YES;
                cell.layerView.image = [UIImage imageNamed:@"check_circle_select"];
            }else{
                cell.f_ImageView.hidden = NO;
                cell.layerView.image = [UIImage imageNamed:@"check_circle"];
            }
            NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
            cell.clickBlock = ^(LocalDownloadingTableViewCell * cell){
                LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                         delegate:nil
                                                                cancelButtonTitle:cancelTitle
                                                            otherButtonTitleArray:@[@"取消下载"]];
                actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
                    if (buttonIndex == 1) {
                        if (self.transmitingArray.count == 0) {
                            [actionSheet setHidden:YES];
                            return ;
                        }
                        if (indexPath.row > self.transmitingArray.count -1 && self.transmitingArray.count -1 > 0) {
                            return;
                        }
                        
                        CSDownloadTask *downloadTask = [self.transmitingArray objectAtIndex:indexPath.row];
                        NSLog(@"%u",downloadTask.downloadStatus);
                        if (downloadTask.downloadStatus == CSDownloadStatusCanceled||
                            downloadTask.downloadStatus == CSDownloadStatusSuccess||
                            downloadTask.downloadStatus == CSDownloadStatusFailure ) {
                            [actionSheet setHidden:YES];
                            return ;
                        }
                        [[CSFileDownloadManager sharedDownloadManager] cancelOneDownloadTaskWith:downloadTask];
                        [self.transmitingArray removeObjectAtIndex:[indexPath row]];
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
            
        }else{
         CSUploadTask *uploadTask = _transmitingArray[indexPath.row] ;
            NSLog(@"%@",uploadTask);
            CSUploadModel* uploadFileModel = [uploadTask getUploadFileModel];
            cell.fileNameLabel.text = uploadFileModel.uploadFileName;
            //        cell.progressLabel.text = @"正在下载";
            uploadTask.progressBlock = ^(NSProgress *uploadProgress) {
//                float progressFloat = (float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount;
                
                //            NSString *progressString = [NSString stringWithFormat:@"%@/%@",[CSFileUtil calculateUnit:downloadProgress.],[CSFileUtil calculateUnit:totalBytesExpectedToRead]];
                if ([NSThread isMainThread] ) {
                    cell.progressView.progress = uploadProgress.fractionCompleted;
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.progressView.progress = uploadProgress.fractionCompleted;
                    });
                }
                
            };
            if ([self.chooseArr containsObject:uploadFileModel.getUploadFileUUID]) {
                cell.f_ImageView.hidden = YES;
                cell.layerView.image = [UIImage imageNamed:@"check_circle_select"];
            }else{
                cell.f_ImageView.hidden = NO;
                cell.layerView.image = [UIImage imageNamed:@"check_circle"];
            }
            NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
            cell.clickBlock = ^(LocalDownloadingTableViewCell * cell){
                LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                         delegate:nil
                                                                cancelButtonTitle:cancelTitle
                                                            otherButtonTitleArray:@[@"取消上传"]];
                actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
                    if (buttonIndex == 1) {
                        if (self.transmitingArray.count == 0) {
                            [actionSheet setHidden:YES];
                            return ;
                        }
                        if (indexPath.row > self.transmitingArray.count -1 && self.transmitingArray.count -1 > 0) {
                            return;
                        }
                        
                        CSUploadTask *uploadTask = [self.transmitingArray objectAtIndex:indexPath.row];
                        NSLog(@"%u",uploadTask.uploadStatus);
                        if (uploadTask.uploadStatus == CSUploadStatusCanceled||
                            uploadTask.uploadStatus == CSUploadStatusSuccess||
                            uploadTask.uploadStatus == CSUploadStatusFailure ) {
                            [actionSheet setHidden:YES];
                            return ;
                        }
                        [[CSFileUploadManager sharedUploadManager] cancelOneUploadTaskWith:uploadTask];
                        [self.transmitingArray removeObjectAtIndex:[indexPath row]];
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
                    NSString * uuid = uploadFileModel.getUploadFileUUID;
                    [weak_self.chooseArr addObject:uuid];
                    [weak_self changeStatus];
                }
            };
        }
        cell.status = _cellStatus;
          return cell;
    }else{
        LocalDownloadTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LocalDownloadTableViewCell class])];
        if (nil == cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LocalDownloadTableViewCell class]) owner:self options:nil] lastObject];
        }
        NSLog(@"%@",_downloadedArray[indexPath.row]);
        WBFile * data = _downloadedArray[indexPath.row];
//        WBFile * data= [WBFile MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];

        cell.fileNameLabel.text = data.fileName;
        NSString *typeString;
        if ([data.actionType isEqualToString:@"上传"]) {
            typeString = @"上传成功";
        }else if ([data.actionType isEqualToString:@"下载"]){
            typeString = @"下载成功";
        }else{
            typeString = @"下载成功";
        }
        cell.transmitTypeLabel.text = typeString;
//        [CSDateUtil stringWithDate:data.timeDate withFormat:@"yyyy-MM-dd HH:mm:ss"];
        cell.downloadedSizeLabel.text = [NSString transformedValue:data.fileSize];
        
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
         return self.transmitingArray.count;
    }else{
         return self.downloadedArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return WBLocalizedString(@"incomplete", nil);
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
    if(self.cellStatus == LocalFliesCellStatusCanChoose){
        id model = indexPath.section == 0?
        self.transmitingArray[indexPath.row]:self.downloadedArray[indexPath.row];
        NSString * uuid;
        if ([NSStringFromClass([model class]) isEqualToString:NSStringFromClass([CSDownloadTask class])]) {
          uuid = ((CSDownloadTask *)model).downloadFileModel.getDownloadFileUUID;
        }else if([NSStringFromClass([model class]) isEqualToString:NSStringFromClass([CSUploadTask class])]){
          uuid = ((CSUploadTask *)model).uploadFileModel.getUploadFileUUID;
        }else if([NSStringFromClass([model class]) isEqualToString:NSStringFromClass([WBFile class])]){
            uuid = ((WBFile*)model).fileUUID;
        }
    
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
            NSString *openPath ;
            WBFile *downloadedFileModel = _downloadedArray[indexPath.row];
            NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
            NSString* suffixName = downloadedFileModel.fileUUID;
            NSString *fileName = downloadedFileModel.fileName;
//            if ([downloadedFileModel.actionType isEqualToString:@"下载"]) {
//                NSString *extensionstring = [fileName pathExtension];
//                NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",suffixName,extensionstring]];
//                openPath = saveFile;
//            }else{
                NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
                openPath = saveFile;
//            }
         
//            NSURL *url = [NSURL fileURLWithPath:saveFile];
            NSLog(@"文件位置%@",openPath);
            if ([[NSFileManager defaultManager] fileExistsAtPath:openPath] ) {
                _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:openPath]];
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
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)uploadingArray{
    if(!_uploadingArray){
        _uploadingArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _uploadingArray;
}


- (NSMutableArray *)downloadedArray{
    if(!_downloadedArray){
        _downloadedArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _downloadedArray;
}

//- (NSMutableArray *)downloadingArray{
//    if(!_downloadingArray){
//        _downloadingArray = [NSMutableArray arrayWithCapacity:0];
//    }
//    return _downloadingArray;
//}

-(NSMutableArray *)transmitingArray{
    if(!_transmitingArray){
        _transmitingArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _transmitingArray;
}

- (NSMutableArray *)transmitiedArray{
    if(!_transmitiedArray){
        _transmitiedArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _transmitiedArray;
}

- (NSMutableArray *)chooseArr{
    if (!_chooseArr) {
        _chooseArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _chooseArr;
}

@end
