//
//  WBChatListViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/16.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatListViewController.h"
#import "WBChatListTableViewCell.h"
#import "WBChatViewController.h"
#import "WBGetBoxesAPI.h"
#import "WBBoxesModel.h"

@interface WBChatListViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic)MDCFloatingButton *addButton;
@property (nonatomic)NSMutableArray *boxDataArray;
@end

@implementation WBChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addButton];
    [self initMjFreshHeader];
    [self getBoxesListData];
//    [self initMjFreshFooter];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)initMjFreshHeader{
    __weak __typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getBoxesListData];
         [self.tableView.mj_header endRefreshing];
    }];
   
    self.tableView.mj_header.ignoredScrollViewContentInsetTop = KDefaultOffset;
    
}

- (void)initMjFreshFooter{
    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
        
    }];
}

- (void)getBoxesListData{
    [[WBGetBoxesAPI new]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSMutableArray *array = request.responseJsonObject;
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
        [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
           WBBoxesModel *model = [WBBoxesModel yy_modelWithDictionary:obj];
            [dataArray addObject:model];
        }];
        self.boxDataArray = dataArray;
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)didTapAdd:(MDCFloatingButton *)sender{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.boxDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WBChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBChatListTableViewCell class])];
    if (!cell) {
        cell = (WBChatListTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBChatListTableViewCell class]) owner:self options:nil]lastObject];
    }
    WBBoxesModel *boxesModel = self.boxDataArray[indexPath.row];
    cell.nameLabel.text = boxesModel.name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WBBoxesModel *model = self.boxDataArray[indexPath.row];
    WBChatListTableViewCell * cell = (WBChatListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    WBChatViewController *chatVC = [[WBChatViewController alloc]init];
    chatVC.title = cell.nameLabel.text;
    chatVC.boxuuid = model.uuid;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64 - 48) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.contentInset = UIEdgeInsetsMake(KDefaultOffset, 0, 0, 0);
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (MDCFloatingButton *)addButton{
    if (!_addButton) {
        _addButton = [[MDCFloatingButton alloc] initWithFrame:CGRectMake(__kWidth - 63 -16, __kHeight - 63 -16 -64 -44, 63, 63) shape:MDCFloatingButtonShapeDefault];
        _addButton.mode = MDCFloatingButtonModeNormal;
        [_addButton setTitle:nil forState:UIControlStateNormal];
        [_addButton addTarget:self
                       action:@selector(didTapAdd:)
             forControlEvents:UIControlEventTouchUpInside];
        UIImage *plusImage = [UIImage imageNamed:@"ic_add_white"];
        [_addButton setImage:plusImage forState:UIControlStateNormal];
        [_addButton setBackgroundColor:COR1];
    }
    return _addButton;
}

- (NSMutableArray *)boxDataArray{
    if (!_boxDataArray) {
        _boxDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _boxDataArray;
}
@end
