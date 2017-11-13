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
//test
#import "TestDataModel.h"

@interface FilesViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataSouceArray;

@end

@implementation FilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBtns];
    [self loadData];
    [self.view addSubview:self.tableView];
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
}

- (void)loadData{
    TestDataModel *dataModel = [TestDataModel new];
    dataModel.URLstring = @"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.1.1.dmg";
    dataModel.fileName = @"QQ for Mac";
    dataModel.fileUUID = @"1";
    [self.dataSouceArray addObject:dataModel];
    
    TestDataModel *dataModel2 = [TestDataModel new];
    dataModel2.URLstring = @"http://d1.music.126.net/dmusic/NeteaseMusic_1.5.7_580_web.dmg";
    dataModel2.fileName = @"NeteaseMusic for Mac";
    dataModel.fileUUID = @"2";
    [self.dataSouceArray addObject:dataModel2];
    
    TestDataModel *dataModel3 = [TestDataModel new];
    dataModel3.URLstring = @"https://dldir1.qq.com/foxmail/MacFoxmail/Foxmail_for_Mac_V1.2.0.dmg";
    dataModel3.fileName = @"Foxmail_for_Mac";
    dataModel.fileUUID = @"3";
    [self.dataSouceArray addObject:dataModel3];
}

#pragma  TableView DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLFilesCell *cell  = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FLFilesCell class])];
    if (nil == cell) {
        cell= (FLFilesCell *)[[[NSBundle  mainBundle] loadNibNamed:NSStringFromClass([FLFilesCell class]) owner:self options:nil]  lastObject];
    }
    TestDataModel *dataModel = _dataSouceArray[indexPath.row];
    cell.downBtn.userInteractionEnabled = YES;
    cell.nameLabel.text = dataModel.fileName;
    cell.f_ImageView.image = [UIImage imageNamed:@"file_icon"];
    cell.clickBlock = ^(FLFilesCell * cell){
        NSString *downloadString  = @"下载该文件";
//        NSString *openFileString = @"";
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
        [arr addObject:downloadString];
        LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                 delegate:nil
                                                        cancelButtonTitle:@"取消"
                                                    otherButtonTitleArray:arr];
        actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
             if (buttonIndex == 1) {
                 [[CSDownloadHelper  shareManager] downloadFileWithFileModel:dataModel UUID:@"1"];
             }
        };
        actionSheet.scrolling          = YES;
        actionSheet.buttonHeight       = 60.0f;
        actionSheet.visibleButtonCount = 3.6f;
        [actionSheet show];
    };
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
