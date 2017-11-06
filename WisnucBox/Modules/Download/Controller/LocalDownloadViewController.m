//
//  LocalDownloadViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "LocalDownloadViewController.h"
#import "LocalDownloadTableViewCell.h"


#define TABLEVIEWIDENTIFIER  @"identifier"
@interface LocalDownloadViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic,strong) UITableView *tableView;
@end

@implementation LocalDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载管理";

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
    cell.fileNameLabel.text = @"11";
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
         return 3;
    }else{
         return 5;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"正在下载";
    }
    else
        return @"已下载";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}


#pragma UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
@end
