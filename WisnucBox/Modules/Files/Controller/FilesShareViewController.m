//
//  FilesShareViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FilesShareViewController.h"
#import "FilesNextViewController.h"
#import "FLFilesCell.h"

@interface FilesShareViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (strong, nonatomic) UITableView *tableView;
@end

@implementation FilesShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)initView{
    [self.view addSubview:self.tableView];
//    [self initMjRefresh];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)initMjRefresh{
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = KDefaultOffset;
    [self.tableView.mj_header beginRefreshing];
}


- (void)loadData{
    [self.tableView reloadData];
//    [self.tableView.mj_header endRefreshing];
}

- (void)setDataSouceArrayWith:(NSMutableArray *)array{
    [self.dataSouceArray addObjectsFromArray:array];
    [self.tableView reloadData];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ShareFilesModel *model = self.dataSouceArray[indexPath.row];
    cell.nameLabel.text = model.label;
    cell.downBtn.hidden = YES;
    cell.f_ImageView.image = [UIImage imageNamed:@"share"];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSouceArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ShareFilesModel *model = _dataSouceArray[indexPath.row];
    FilesNextViewController *filesVC = [[FilesNextViewController alloc]init];
    filesVC.name = model.label;
    filesVC.parentUUID = model.uuid;
    filesVC.driveUUID = model.uuid;
    [self.navigationController pushViewController:filesVC animated:YES];
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

@end

@implementation ShareFilesModel

@end
