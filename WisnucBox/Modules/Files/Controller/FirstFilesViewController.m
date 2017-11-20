
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

@interface FirstFilesViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic,strong) NSMutableArray *dataSouceArray;
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

- (void)loadData{
    [[FLDrivesAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * responseArr = request.responseJsonObject;
        NSLog(@"%@",request.responseJsonObject);
        [responseArr enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DriveModel *model = [DriveModel yy_modelWithJSON:obj];
            NSLog(@"writelist: %@| uuid: %@",model.writelist, WB_UserService.currentUser.uuid);
            if(IsEquallString(model.tag, @"home")){
                *stop = YES;
            }else{
                NSString *string =WB_UserService.currentUser.uuid;
                NSRange range = [string rangeOfString:@":"];//匹配得到的下标
                NSLog(@"rang:%@",NSStringFromRange(range));
                string = [string substringWithRange:range];//截取范围内的字符串
                NSLog(@"截取的值为：%@",string);
                
    
                for (NSString *containUUID in model.writelist) {
                    if ([WB_UserService.currentUser.uuid isEqualToString:containUUID]) {
                        
                    }
                }
            }
            
            if (stop) {
               
            }
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
    EntriesModel *dataModel = _dataSouceArray[indexPath.row];
   
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSouceArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
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
