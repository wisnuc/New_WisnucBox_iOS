
//
//  FirstFilesViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FirstFilesViewController.h"
#import "FLDrivesAPI.h"
#import "FLFilesCell.h"
#import "FilesNextViewController.h"
#import "FilesViewController.h"
#import "FilesShareViewController.h"


@interface FirstFilesViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic,strong) NSMutableArray *dataSouceArray;
@property (nonatomic,strong) NSMutableArray *shareDataArray;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation FirstFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)initView{
    [self.view addSubview:self.tableView];
    [self initMjRefresh];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)initMjRefresh{
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = KDefaultOffset;
    //    [self.tableView.mj_header beginRefreshing];
}

- (void)sequenceDataSouce{
    NSComparator cmptr = ^(FirstFilesModel * model1, FirstFilesModel * model2){
        
        if (model1.type > model2.type) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    [_dataSouceArray sortUsingComparator:cmptr];
    [_tableView reloadData];
}

- (void)loadData{
    [self.dataSouceArray removeAllObjects];
    [[FLDrivesAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
    NSArray * responseArr = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSLog(@"%@",request.responseJsonObject);
        __block NSInteger i = 0;
        [responseArr enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DriveModel *model = [DriveModel yy_modelWithJSON:obj];
//            NSLog(@"writelist: %@| uuid: %@",model.writelist, WB_UserService.currentUser.uuid);
            if(IsEquallString(model.tag, @"home")){
                FirstFilesModel *filesModel =  [FirstFilesModel new];
                filesModel.type = WBFilesFirstDirectoryMyFiles;
                filesModel.name = @"我的文件";
                [self.dataSouceArray addObject:filesModel];
            }else{
                NSString *string = WB_UserService.currentUser.uuid;
                //                NSRange iStart = [string rangeOfString: @":" options:NSCaseInsensitiveSearch];
                //                NSString *subStr;
                //                if (iStart.length > 0){
                //                    //获取从escapedPath开始位置到iStart.location-1长度的子字符串
                //                 subStr  = [string  substringToIndex:iStart.location];
                //                }
                
                for (NSString *containUUID in model.writelist) {
                    if ([string isEqualToString:containUUID]) {
                        i++;
                        if (i == 1) {
                            FirstFilesModel *shareModel =  [FirstFilesModel new];
                            shareModel.type = WBFilesFirstDirectoryShare;
                            shareModel.name = @"共享盘";
                            [self.dataSouceArray addObject:shareModel];
                        }
                        [self.shareDataArray addObject:model];
                    }
                }
            }
            [self sequenceDataSouce];
            [self.tableView.mj_header endRefreshing];
        }];
    } failure:^(__kindof JYBaseRequest *request) {
        [self.tableView.mj_header endRefreshing];
    }];
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
    FirstFilesModel *model = _dataSouceArray[indexPath.row];
    cell.nameLabel.text = model.name;
    cell.downBtn.hidden = YES;
    if (model.type == WBFilesFirstDirectoryShare) {
        cell.f_ImageView.image = [UIImage imageNamed:@"share"];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSouceArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FirstFilesModel *model = _dataSouceArray[indexPath.row];
    if (model.type == WBFilesFirstDirectoryMyFiles) {
        FilesNextViewController *filesVC = [[FilesNextViewController alloc]init];
        filesVC.name = model.name;
        filesVC.parentUUID = WB_UserService.currentUser.userHome;
        filesVC.driveUUID = WB_UserService.currentUser.userHome;
        [self.navigationController pushViewController:filesVC animated:YES];
    }else{
        FilesShareViewController * filesVC = [[FilesShareViewController alloc]init];
        filesVC.title = model.name;
        filesVC.dataSouceArray = _shareDataArray;
//        [filesVC setDataSouceArrayWith:self.shareDataArray];
        [self.navigationController pushViewController:filesVC animated:YES];
    }
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight ) style:UITableViewStylePlain];
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

- (NSMutableArray *)shareDataArray{
    if (!_shareDataArray) {
        _shareDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _shareDataArray;
}


@end

@implementation FirstFilesModel

@end

