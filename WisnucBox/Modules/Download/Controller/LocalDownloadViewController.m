//
//  LocalDownloadViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "LocalDownloadViewController.h"
#import "LocalDownloadTableViewCell.h"
#import "CSFileDownloadManager.h"

#define TABLEVIEWIDENTIFIER  @"identifier"
@interface LocalDownloadViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *downloadingArray;

@property (nonatomic,strong) NSMutableArray *downloadedArray;

@property (nonatomic,strong) CSFileDownloadManager *downloadManager;
@end

@implementation LocalDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载管理";
    _downloadManager = [CSFileDownloadManager shareManager];
    [self.view addSubview:self.tableView];
   
}


#pragma UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    LocalDownloadTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LocalDownloadTableViewCell class])];
    if (nil == cell) {
        cell= [[[NSBundle mainBundle] loadNibNamed:@"LocalDownloadTableViewCell" owner:nil options:nil] lastObject];
    }
//    NSNumber* number = self.array[indexPath.row];
    if (indexPath.section == 0) {
      cell.downloadTimeLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0 * _downloadManager.currentLength / _downloadManager.fileLength];
    }
    cell.fileNameLabel.text = @"文件名";
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
         return 2;
    }else if (section == 1){
         return self.downloadingArray.count;
    }else{
         return self.downloadedArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"下载测试section";
    }else if(section == 1){
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
    [header.textLabel setTextColor:[UIColor lightGrayColor]];
    
    
}
#pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [_downloadManager removeFiles];
        [[CSFileDownloadManager shareManager]OfflinResumeDownload:NO];
         [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         LocalDownloadTableViewCell *cell = (LocalDownloadTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        [RACObserve(cell.downloadTimeLabel, text) subscribeNext:^(id x) {
//            if (![x isEqualToString:@"当前下载进度:nan%"]) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            }
            NSLog(@"====label的文字变了");
        }];
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
