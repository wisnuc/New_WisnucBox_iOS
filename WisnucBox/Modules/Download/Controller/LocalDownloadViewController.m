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

#define TABLEVIEWIDENTIFIER  @"identifier"
@interface LocalDownloadViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
DownloadHelperDelegate
>
{
    CSFileDownloadManager* _manager;
    FilesServices *_filesServices;
}

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *downloadingArray;

@property (nonatomic,strong) NSMutableArray *downloadedArray;

@property (nonatomic,strong) CSFileDownloadManager *downloadManager;
@end

@implementation LocalDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载管理";
    [CSDownloadHelper shareManager].delegate = self;
    _manager  = [CSFileDownloadManager sharedDownloadManager];
    _filesServices = [FilesServices new];
    [self loadData];
    [self.view addSubview:self.tableView];
}

- (void)loadData{
    self.downloadingArray = [NSMutableArray arrayWithArray:_manager.downloadingTasks];
    self.downloadedArray = [NSMutableArray arrayWithArray: [_filesServices findAll]];
}

- (void)updateDataWithDownloadTask:(CSDownloadTask *)downloadTask {
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
        
        return cell;
    }else{
        LocalDownloadTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LocalDownloadTableViewCell class])];
        if (nil == cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LocalDownloadTableViewCell class]) owner:nil options:nil] lastObject];
        }
        NSLog(@"%@",_downloadedArray[indexPath.row]);
        WBFile * data=  _downloadedArray[indexPath.row];
//        WBFile * data= [WBFile MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];

        cell.fileNameLabel.text = data.fileName;
        cell.downloadTimeLabel.text = [CSDateUtil stringWithDate:data.timeDate withFormat:@"yyyy-MM-dd HH:mm:ss"];
        cell.downloadedSizeLabel.text = [CSFileUtil calculateUnit:[data.fileSize longLongValue]];
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

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
//    view.tintColor = [UIColor whiteColor];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    header.contentView.backgroundColor=MainColor;
//    header.textLabel.textAlignment=NSTextAlignmentCenter;
    [header.textLabel setTextColor:[UIColor darkTextColor]];
    
    
}
#pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
       
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
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


@end
