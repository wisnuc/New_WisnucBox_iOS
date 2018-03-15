//
//  WBLoginViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/5.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBLoginViewController.h"
#import "LoginTableViewCell.h"
#import "FMUserLoginViewController.h"
#import "WBLoginTableView.h"

@interface WBLoginViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,WBLoginTableViewDelegate,WBLoginTableViewDataSource>
@property (strong, nonatomic) UITableView *userListTableViwe;
@property (strong, nonatomic) UIScrollView *stationScrollView;
@property (strong, nonatomic) UIView *userView;
@property (strong, nonatomic) WBLoginTableView *cardTableView;
@end

@implementation WBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.view addSubview:self.stationScrollView];
    [self.view addSubview:self.cardTableView];
    [self.view addSubview:self.userView];
    [self.view addSubview:self.userListTableViwe];

}

- (void)dealloc{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        LoginTableViewCell *cell;
        self.userListTableViwe.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LoginTableViewCell class])];
        if (!cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:@"LoginTableViewCell" owner:nil options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
}

#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        FMUserLoginViewController *userLoginVC = [[FMUserLoginViewController alloc]init];
    
        [self.navigationController pushViewController:userLoginVC animated:YES];
        
}


- (UIScrollView *)stationScrollView{
    if (!_stationScrollView) {
        _stationScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, __kWidth,448/2 + 64)];
        _stationScrollView.backgroundColor = UICOLOR_RGB(0x0288d1);
        _stationScrollView.pagingEnabled = YES;
        //        _stationScrollView.contentSize = CGSizeMake(self.tempDataSource.count * JYSCREEN_WIDTH, 0);
        _stationScrollView.delegate = self;
        _stationScrollView.bounces = YES;
        _stationScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _stationScrollView;
}

//- (UIPageControl *)stationPageControl{
//    if (!_stationPageControl) {
//        _stationPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,self.stationScrollView.frame.size.height - 36 , __kWidth, 30)];
//        //        _stationPageControl.numberOfPages = self.tempDataSource.count;
//        _stationPageControl.currentPage = 0;
//    }
//    return _stationPageControl;
//}

//- (UIImageView *)logoImageView{
//    if (!_logoImageView) {
//        UIImage *logoImage = [UIImage imageNamed:@"logo"];
//        CGSize logoSize=logoImage.size;
//        _logoImageView = [[UIImageView alloc]initWithImage:logoImage];
//        _logoImageView.frame = CGRectMake(16, 40, logoSize.width, logoSize.height);
//    }
//    return _logoImageView;
//}

-(UIView *)userView{
    if (!_userView) {
        _userView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.stationScrollView.frame) + 8, __kWidth , 40)];
        _userView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, __kWidth - 16, 40)];
        label.text = @"用户";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor lightGrayColor];
        [_userView addSubview:label];
    }
    return _userView;
}

- (UITableView *)userListTableViwe{
    if (!_userListTableViwe) {
        _userListTableViwe = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.userView.frame), __kWidth, __kHeight - _stationScrollView.frame.size.height - 8 - _userView.frame.size.height -48) style:UITableViewStylePlain];
        if (![WXApi isWXAppInstalled]) {
            _userListTableViwe.frame = CGRectMake(0, CGRectGetMaxY(self.userView.frame), __kWidth, __kHeight - _stationScrollView.frame.size.height - 8 - _userView.frame.size.height);
        }
        _userListTableViwe.delegate = self;
        _userListTableViwe.dataSource = self;
        _userListTableViwe.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _userListTableViwe;
}

-(WBLoginTableView *)cardTableView{
    if (!_cardTableView) {
        _cardTableView = [[WBLoginTableView alloc] initWithFrame:CGRectMake(0, 0, 320,448/2 + 64)];
        
        _cardTableView.backgroundColor = UICOLOR_RGB(0x0288d1);
        _cardTableView.pagingEnabled = YES;
        //        _stationScrollView.contentSize = CGSizeMake(self.tempDataSource.count * JYSCREEN_WIDTH, 0);
        _cardTableView.bounces = YES;
        _cardTableView.showsHorizontalScrollIndicator = NO;
        
        _cardTableView.delegate_Y = self;
        _cardTableView.dataSource_Y = self;
    }
    return _cardTableView;
}


@end
