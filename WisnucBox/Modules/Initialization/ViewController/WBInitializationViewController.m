//
//  WBInitializationViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/12.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInitializationViewController.h"
#import "WBInitDiskTableViewCell.h"

@interface WBInitializationViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic)UIView *lineView;

@property (nonatomic)NSMutableArray *diskDataArray;

@property (nonatomic)UILabel *secondStepLabel;
@property (nonatomic)UILabel *thirdStepLabel;
@property (nonatomic)UILabel *fourStepLabel;
@property (nonatomic)UILabel *fifthStepLabel;


@property (nonatomic)UIView *secondStepIconView;
@property (nonatomic)UIView *thirdStepIconView;
@property (nonatomic)UIView *fourStepIconView;
@property (nonatomic)UIView *fifthStepIconView;


@property (nonatomic)UILabel *secondStepTitle;
@property (nonatomic)UILabel *thirdStepTitle;
@property (nonatomic)UILabel *fourStepTitle;
@property (nonatomic)UILabel *fifthStepTitle;
@property (nonatomic)UILabel *firstStepLabel;

@property (nonatomic)UIView *firstStepIconView;
@property (nonatomic)UILabel *firstStepTitle;
@property (nonatomic)UILabel *firstStepDetailLabel;
@property (nonatomic)UIButton *firstStepbutton;
@property (nonatomic)UITableView *diskTableView;

@end

@implementation WBInitializationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"initialization_guide", nil);
    [self.view addSubview:self.lineView];
    [self.firstStepIconView addSubview:self.firstStepLabel];
    [self.view addSubview:self.firstStepIconView];
    [self.view addSubview:self.firstStepTitle];
    [self.view addSubview:self.firstStepDetailLabel];
    [self.view addSubview:self.diskTableView];
    [self.view addSubview:self.firstStepbutton];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:COR1] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = UICOLOR_RGB(0x03a9f4);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor]}];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)firstStepbuttonClick:(UIButton *)sender{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        _firstStepbutton.alpha = 0;
        _diskTableView.alpha = 0;
        _firstStepTitle.font = [UIFont systemFontOfSize:16];
        _firstStepTitle.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.54f];;
        _firstStepDetailLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.54f];
    } completion:^(BOOL finished) {
       
//        _firstStepbutton.hidden = YES;
//        _diskTableView.hidden = YES;
    }];
}

#pragma tableViewdataSouce

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WBInitDiskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBInitDiskTableViewCell class])];
    if (!cell) {
        cell = (WBInitDiskTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBInitDiskTableViewCell class]) owner:self options:nil]lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(26, 14, 1,__kHeight - 44-64 )];
        _lineView.backgroundColor = [UIColor lightGrayColor];
    }
    return _lineView;
}

- (UILabel *)firstStepLabel{
    if (!_firstStepLabel) {
        _firstStepLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _firstStepLabel.layer.cornerRadius = 20/2;
        _firstStepLabel.layer.masksToBounds = YES;
        _firstStepLabel.textColor = [UIColor whiteColor];
        _firstStepLabel.text = @"1";
        _firstStepLabel.textAlignment = NSTextAlignmentCenter;
        _fifthStepLabel.font = [UIFont systemFontOfSize:12];
        _firstStepLabel.backgroundColor = COR1;
    }
    return _firstStepLabel;
}

- (UIView *)firstStepIconView{
    if (!_firstStepIconView) {
        _firstStepIconView = [[UIView alloc]initWithFrame:CGRectMake(16, 12, 20, 28)];
        _firstStepIconView.backgroundColor = [UIColor whiteColor];
    }
    return _firstStepIconView;
}

- (UILabel *)firstStepTitle{
    if (!_firstStepTitle) {
        _firstStepTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firstStepIconView.frame) + 16, 8,100 , 17)];
        _firstStepTitle.textColor = [UIColor blackColor];
        _fifthStepLabel.alpha = 0.87;
        _firstStepTitle.text = @"创建磁盘卷";
        _firstStepTitle.font = [UIFont boldSystemFontOfSize:16];
    }
    return _firstStepTitle;
}

- (UILabel *)firstStepDetailLabel{
    if (!_firstStepDetailLabel) {
        _firstStepDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepTitle.frame), CGRectGetMaxY(_firstStepTitle.frame) + 8,__kWidth - CGRectGetMinY(_firstStepTitle.frame) -16 , 20)];
        _firstStepDetailLabel.textColor = UICOLOR_RGB(0xf44336);
        _firstStepDetailLabel.numberOfLines = 0;
//        _firstStepDetailLabel.adjustsFontSizeToFitWidth = YES;
        _firstStepDetailLabel.font = [UIFont systemFontOfSize:12];
        _firstStepDetailLabel.text = @"选择磁盘创建新的磁盘卷，所选磁盘的数据会被清除";
       
    }
    return _firstStepDetailLabel;
}

- (UITableView *)diskTableView{
    if (!_diskTableView) {
        _diskTableView = [[UITableView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepDetailLabel.frame), CGRectGetMaxY(_firstStepDetailLabel.frame) + 8,__kWidth - CGRectGetMinX(_firstStepDetailLabel.frame) - 56 ,56 *3 + 8) style:UITableViewStylePlain];
        _diskTableView.delegate = self;
        _diskTableView.dataSource = self;
        _diskTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _diskTableView.separatorStyle = UITableViewCellAccessoryNone;
    }
    return _diskTableView;
}

- (UIButton *)firstStepbutton{
    if (!_firstStepbutton) {
        _firstStepbutton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepTitle.frame),CGRectGetMaxY(_diskTableView.frame) +20, 100, 40)];
        [_firstStepbutton setTitle:@"下一步" forState:UIControlStateNormal];
        [_firstStepbutton setTitleColor:COR1 forState:UIControlStateNormal];
        _firstStepbutton.contentVerticalAlignment = NSTextAlignmentLeft;
        [_firstStepbutton addTarget:self action:@selector(firstStepbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _firstStepbutton;
}

- (NSMutableArray *)diskDataArray{
    if (!_diskDataArray) {
        _diskDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _diskDataArray;
}

@end
