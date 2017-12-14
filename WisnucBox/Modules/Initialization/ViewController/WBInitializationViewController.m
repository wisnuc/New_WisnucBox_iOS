//
//  WBInitializationViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/12.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInitializationViewController.h"
#import "WBInitDiskTableViewCell.h"

#define WarningColor UICOLOR_RGB(0xf44336)
#define IgnoreColor RGBACOLOR(0, 0, 0, 0.54f)
#define userNameMax 20
#define passwordMax 40

@interface WBInitializationViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>
@property (nonatomic)UIView *lineView;

@property (nonatomic)NSMutableArray *diskDataArray;
@property (nonatomic)UIScrollView *mainScrollView;

@property (nonatomic)UILabel *thirdStepLabel;
@property (nonatomic)UILabel *fourStepLabel;
@property (nonatomic)UILabel *fifthStepLabel;



@property (nonatomic)UIView *thirdStepIconView;
@property (nonatomic)UIView *fourStepIconView;
@property (nonatomic)UIView *fifthStepIconView;



@property (nonatomic)UILabel *thirdStepTitle;
@property (nonatomic)UILabel *fourStepTitle;
@property (nonatomic)UILabel *fifthStepTitle;


@property (nonatomic)UILabel *firstStepLabel;
@property (nonatomic)UIView *firstStepIconView;
@property (nonatomic)UILabel *firstStepTitle;
@property (nonatomic)UILabel *firstStepDetailLabel;
@property (nonatomic)UIButton *firstStepButton;
@property (nonatomic)BEMCheckBox *firstCheckBox;

@property (nonatomic)UILabel *secondStepLabel;
@property (nonatomic)UIView *secondStepIconView;
@property (nonatomic)UILabel *secondStepTitle;
@property (nonatomic)UILabel *secondStepDetailLabel;
@property (nonatomic)UIButton *secondStepNextButton;
@property (nonatomic)UIButton *secondPreviousButton;
@property (nonatomic)BEMCheckBox *secondCheckBox;
@property (nonatomic)MDCTextField *userNameTextField;
@property (nonatomic)MDCTextField *passwordTextField;
@property (nonatomic)MDCTextField *confirmPasswordTextField;
@property (nonatomic, strong) MDCTextInputControllerLegacyDefault *textFieldControllerUserName;
@property (nonatomic, strong) MDCTextInputControllerLegacyDefault *textFieldControllerPassword;
@property (nonatomic, strong) MDCTextInputControllerLegacyDefault *textFieldControllerConfirmPassword;

@property (nonatomic)UITableView *diskTableView;

@property (nonatomic) UILabel *diskTypeTitle;
@property (nonatomic) UILabel *diskTypeLabel;

@end

@implementation WBInitializationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"initialization_guide", nil);
    [self.view addSubview:self.mainScrollView];
    UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidTouch)];
    [self.view addGestureRecognizer:tapRecognizer];
    [self getDiskData];
//    [self.view addSubview:self.lineView];
    [self.mainScrollView addSubview:self.firstStepIconView];
    [self.mainScrollView addSubview:self.firstStepTitle];
    [self.mainScrollView addSubview:self.firstStepDetailLabel];
    [self.mainScrollView addSubview:self.diskTableView];
    [self.mainScrollView addSubview:self.diskTypeTitle];
    [self.mainScrollView addSubview:self.firstStepButton];
    
    [self.mainScrollView addSubview:self.secondStepIconView];
    [self.mainScrollView addSubview:self.secondStepTitle];
    [self.mainScrollView addSubview:self.secondStepDetailLabel];
    [self.mainScrollView addSubview:self.userNameTextField];
    [self.mainScrollView addSubview:self.passwordTextField];
    [self.mainScrollView addSubview:self.confirmPasswordTextField];
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

- (void)getDiskData{
    [self.diskDataArray removeAllObjects];
    if (_searchModel.storageModel) {
        [_searchModel.storageModel.blocks enumerateObjectsUsingBlock:^(WBStationManageBlocksModel *blocksModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([blocksModel.isDisk boolValue]) {
                [self.diskDataArray addObject:blocksModel];
            }
        }];
//        [self.diskTableView reloadData];
    }
}

- (void)firstStepButtonClick:(UIButton *)sender{
    @weaky(self)
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        [weak_self creatDiskModuleAnimateLayout];
        [weak_self creatUserModuleAnimateLayout];
      
        
    } completion:^(BOOL finished) {
       
//        _firstStepButton.hidden = YES;
//        _diskTableView.hidden = YES;
        
    }];
}

- (void)creatDiskModuleAnimateLayout{
    _firstStepButton.alpha = 0;
    _diskTableView.alpha = 0;
    _diskTypeTitle.alpha = 0;
    _firstStepTitle.font = [UIFont systemFontOfSize:16];
    _firstStepTitle.textColor = IgnoreColor;
    _firstStepDetailLabel.textColor = IgnoreColor;
    [_firstCheckBox  setHidden:NO];
}

- (void)creatUserModuleAnimateLayout{
    _secondStepIconView.center = CGPointMake(_secondStepIconView.center.x,  _firstStepDetailLabel. center.y + 36 + _firstStepDetailLabel.bounds.size.height/2 + _secondStepIconView.bounds.size.height/2);
    _secondStepTitle.font = [UIFont boldSystemFontOfSize:16];
    _secondStepTitle.center = CGPointMake(_secondStepTitle.center.x,_secondStepIconView.center.y - 4);
    _secondStepDetailLabel.center = CGPointMake(_secondStepDetailLabel.center.x,_secondStepTitle.center.y + 8  + _secondStepTitle.bounds.size.height/2 + _secondStepDetailLabel.bounds.size.height/2);
    _userNameTextField.center = CGPointMake(_userNameTextField.center.x,_secondStepDetailLabel.center.y + 8  + _secondStepDetailLabel.bounds.size.height/2 + _userNameTextField.bounds.size.height/2);
    _userNameTextField.alpha = 1.0f;
    _passwordTextField.center = CGPointMake(_passwordTextField.center.x,_userNameTextField.center.y + 8  + _userNameTextField.bounds.size.height/2 + _passwordTextField.bounds.size.height/2);
    _passwordTextField.alpha = 1.0f;
    _confirmPasswordTextField.center = CGPointMake(_confirmPasswordTextField.center.x,_passwordTextField.center.y + 8  + _passwordTextField.bounds.size.height/2 + _confirmPasswordTextField.bounds.size.height/2);
    _confirmPasswordTextField.alpha = 1.0f;
}


#pragma tableViewdataSouce

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WBInitDiskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBInitDiskTableViewCell class])];
    if (!cell) {
        cell = (WBInitDiskTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBInitDiskTableViewCell class]) owner:self options:nil]lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WBStationManageBlocksModel *model = self.diskDataArray[indexPath.row];
    cell.nameLabel.text = model.model?model.model:@"未知设备";
    NSNumber *sizeNumber = [NSNumber numberWithLongLong:[model.size longLongValue] *512];
    NSString *sizeString = [NSString transformedValue:sizeNumber];
//    NSLog(@"%@",sizeString);
    NSString *idBus = [model.idBus uppercaseStringWithLocale:[NSLocale currentLocale]];
    cell.detailLabel.text = [NSString stringWithFormat:@"%@  %@  %@",model.name,sizeString,idBus];
    if (model.unformattable) {
        cell.nameLabel.textColor = RGBACOLOR(0, 0, 0, 0.26f);
        cell.detailLabel.textColor = RGBACOLOR(0, 0, 0, 0.26f);
        [cell.checkBox setEnabled:NO];
        cell.leftIconImageView.image = [UIImage imageNamed:@"disk_disable"];
    }
    
    if (cell.checkBox.on) {
        
    }else{
        
    }
 
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.diskDataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 8;
}

#pragma mark - UITextFieldDelegate

// All the usual UITextFieldDelegate methods work with MDCTextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView= [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, __kWidth,__kHeight - 64)];
        _mainScrollView.delegate = self;
    }
    return _mainScrollView;
}

- (NSMutableArray *)diskDataArray{
    if (!_diskDataArray) {
        _diskDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _diskDataArray;
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
        _firstStepLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
        _firstStepLabel.layer.cornerRadius = 22/2;
        _firstStepLabel.layer.masksToBounds = YES;
        _firstStepLabel.textColor = [UIColor whiteColor];
        _firstStepLabel.text = @"1";
        _firstStepLabel.textAlignment = NSTextAlignmentCenter;
        _firstStepLabel.font = [UIFont systemFontOfSize:12];
        _firstStepLabel.backgroundColor = COR1;
    }
    return _firstStepLabel;
}

- (BEMCheckBox *)firstCheckBox{
    if (!_firstCheckBox) {
        _firstCheckBox = [[BEMCheckBox alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _firstCheckBox.onFillColor = COR1;
        _firstCheckBox.onTintColor = COR1;
        _firstCheckBox.onCheckColor = [UIColor whiteColor];
        [_firstCheckBox setOn:YES];
        [_firstCheckBox setHidden:YES];
    }
    return _firstCheckBox;
}

- (UIView *)firstStepIconView{
    if (!_firstStepIconView) {
        _firstStepIconView = [[UIView alloc]initWithFrame:CGRectMake(16, 8, 20, 28)];
        _firstStepIconView.backgroundColor = [UIColor whiteColor];
        [_firstStepIconView addSubview:self.firstStepLabel];
        [_firstStepIconView addSubview:self.firstCheckBox];
        self.firstCheckBox.center =  _firstStepLabel.center;
    }
    return _firstStepIconView;
}

- (UILabel *)firstStepTitle{
    if (!_firstStepTitle) {
        _firstStepTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firstStepIconView.frame) + 16, 8,__kWidth - 16 -  CGRectGetMaxX(_firstStepIconView.frame) + 16, 17)];
        _firstStepTitle.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        _firstStepTitle.text = @"创建磁盘卷";
        _firstStepTitle.font = [UIFont boldSystemFontOfSize:16];
    }
    return _firstStepTitle;
}

- (UILabel *)firstStepDetailLabel{
    if (!_firstStepDetailLabel) {
        _firstStepDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepTitle.frame), CGRectGetMaxY(_firstStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_firstStepTitle.frame) -16 , 20)];
        _firstStepDetailLabel.textColor = WarningColor;
        _firstStepDetailLabel.numberOfLines = 0;
//        _firstStepDetailLabel.adjustsFontSizeToFitWidth = YES;
        _firstStepDetailLabel.font = [UIFont systemFontOfSize:12];
        _firstStepDetailLabel.text = @"选择磁盘创建新的磁盘卷，所选磁盘的数据会被清除";
    }
    return _firstStepDetailLabel;
}

- (UITableView *)diskTableView{
    if (!_diskTableView) {
        _diskTableView = [[UITableView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepDetailLabel.frame), CGRectGetMaxY(_firstStepDetailLabel.frame) + 8,__kWidth - CGRectGetMinX(_firstStepDetailLabel.frame) - 56 ,56 *self.diskDataArray.count + 8) style:UITableViewStylePlain];
        _diskTableView.delegate = self;
        _diskTableView.dataSource = self;
        UIView *footBackgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 8)];
        UIView *footlineView  = [[UIView alloc]initWithFrame:CGRectMake(0, 7, __kWidth, 0.5)];
        footlineView.backgroundColor = RGBCOLOR(222, 222, 224);
        footBackgroudView.backgroundColor = [UIColor whiteColor];
        [footBackgroudView addSubview:footlineView];
        _diskTableView.tableFooterView = footBackgroudView;
        _diskTableView.separatorStyle = UITableViewCellAccessoryNone;
        _diskTableView.bounces = NO;
    }
    return _diskTableView;
}

- (UILabel *)diskTypeTitle{
    if (!_diskTypeTitle) {
        _diskTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_diskTableView.frame), CGRectGetMaxY(_diskTableView.frame) +8, 100, 40)];
        _diskTypeTitle.adjustsFontSizeToFitWidth = YES;
        _diskTypeTitle.text = @"磁盘卷模式";
        _diskTypeTitle.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        _diskTypeTitle.font = [UIFont systemFontOfSize:14];
//        _diskTypeTitle
    }
    return _diskTypeTitle;
}

- (UIButton *)firstStepButton{
    if (!_firstStepButton) {
        _firstStepButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepTitle.frame),CGRectGetMaxY(_diskTypeTitle.frame) +8, 86, 36)];
        [_firstStepButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_firstStepButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _firstStepButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _firstStepButton.backgroundColor = COR1;
        _firstStepButton.layer.masksToBounds = YES;
        _firstStepButton.layer.cornerRadius = 2;
        //        _firstStepButton.contentVerticalAlignment = NSTextAlignmentCenter;
        [_firstStepButton addTarget:self action:@selector(firstStepButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _firstStepButton;
}

//Second

- (UILabel *)secondStepLabel{
    if (!_secondStepLabel) {
        _secondStepLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
        _secondStepLabel.layer.cornerRadius = 22/2;
        _secondStepLabel.layer.masksToBounds = YES;
        _secondStepLabel.textColor = [UIColor whiteColor];
        _secondStepLabel.text = @"2";
        _secondStepLabel.textAlignment = NSTextAlignmentCenter;
        _secondStepLabel.font = [UIFont systemFontOfSize:12];
        _secondStepLabel.backgroundColor = COR1;
    }
    return _secondStepLabel;
}

- (UIView *)secondStepIconView{
    if (!_secondStepIconView) {
        _secondStepIconView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.firstStepIconView.frame),CGRectGetMaxY(self.firstStepButton.frame)+ 24, 20, 28)];
        _secondStepIconView.backgroundColor = [UIColor whiteColor];
        [_secondStepIconView addSubview:self.secondStepLabel];
    }
    return _secondStepIconView;
}

- (UILabel *)secondStepTitle{
    if (!_secondStepTitle) {
        _secondStepTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepTitle.frame), CGRectGetMinY(_secondStepIconView.frame),_firstStepTitle.jy_Width, 17)];
        _secondStepTitle.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        _secondStepTitle.text = @"创建第一个用户";
        _secondStepTitle.font = [UIFont systemFontOfSize:16];
    }
    return _secondStepTitle;
}

- (UILabel *)secondStepDetailLabel{
    if (!_secondStepDetailLabel) {
        _secondStepDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepDetailLabel.frame), CGRectGetMaxY(_secondStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_secondStepTitle.frame) -32 , 30)];
        _secondStepDetailLabel.textColor = WarningColor;
        _secondStepDetailLabel.numberOfLines = 0;
//        _secondStepDetailLabel.adjustsFontSizeToFitWidth = YES;
        _secondStepDetailLabel.font = [UIFont systemFontOfSize:12];
        _secondStepDetailLabel.text = @"请输入第一个用户名的用户名和密码，该用户会成为系统权限最高的管理员";

    }
    return _secondStepDetailLabel;
}

- (MDCTextField *)userNameTextField{
    if (!_userNameTextField) {
        _userNameTextField = [[MDCTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(_secondStepDetailLabel.frame) , CGRectGetMaxY(_secondStepDetailLabel.frame) + 8,__kWidth  - 32 -CGRectGetMinX(_secondStepDetailLabel.frame) , 80)];
        
        _userNameTextField.delegate = self;
        _userNameTextField.clearButtonMode = UITextFieldViewModeAlways;
        _userNameTextField.cursorColor = COR1;
        NSOperatingSystemVersion iOS10Version = {10, 0, 0};
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        if ([processInfo isOperatingSystemAtLeastVersion:iOS10Version]) {
            _userNameTextField.adjustsFontForContentSizeCategory = YES;
        } else {
            [_userNameTextField mdc_setAdjustsFontForContentSizeCategory:YES];
        }
        
        self.textFieldControllerUserName =
        [[MDCTextInputControllerLegacyDefault alloc] initWithTextInput:_userNameTextField];
         self.textFieldControllerUserName.floatingEnabled = YES;
        self.textFieldControllerUserName.placeholderText = WBLocalizedString(@"user_name", nil);
        self.textFieldControllerUserName.activeColor = COR1;
        self.textFieldControllerUserName.characterCountMax = userNameMax;
        [self.textFieldControllerUserName mdc_setAdjustsFontForContentSizeCategory:YES];
        _userNameTextField.alpha = 0.0f;
    }
    return _userNameTextField;
}

- (MDCTextField *)passwordTextField{
    if (!_passwordTextField) {
        _passwordTextField = [[MDCTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(_secondStepDetailLabel.frame)  , CGRectGetMaxY(_userNameTextField.frame) + 8,__kWidth  - 32 -CGRectGetMinX(_secondStepDetailLabel.frame) , 80)];
        
        _passwordTextField.delegate = self;
        _passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
        _passwordTextField.cursorColor = COR1;
        NSOperatingSystemVersion iOS10Version = {10, 0, 0};
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        if ([processInfo isOperatingSystemAtLeastVersion:iOS10Version]) {
            _passwordTextField.adjustsFontForContentSizeCategory = YES;
        } else {
            [_passwordTextField mdc_setAdjustsFontForContentSizeCategory:YES];
        }
        self.textFieldControllerPassword =
        [[MDCTextInputControllerLegacyDefault alloc] initWithTextInput:_passwordTextField];
        self.textFieldControllerPassword.floatingEnabled = YES;
        self.textFieldControllerPassword.placeholderText = WBLocalizedString(@"password_text", nil);
        self.textFieldControllerPassword.activeColor = COR1;
        self.textFieldControllerPassword.characterCountMax = passwordMax;
        [self.textFieldControllerPassword mdc_setAdjustsFontForContentSizeCategory:YES];
        _passwordTextField.alpha = 0.0f;
    }
    return _passwordTextField;
}

- (MDCTextField *)confirmPasswordTextField{
    if (!_confirmPasswordTextField) {
        _confirmPasswordTextField = [[MDCTextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(_secondStepDetailLabel.frame) , CGRectGetMaxY(_passwordTextField.frame) + 8,__kWidth  - 32 -CGRectGetMinX(_secondStepDetailLabel.frame) , 80)];
        
        _confirmPasswordTextField.delegate = self;
        _confirmPasswordTextField.clearButtonMode = UITextFieldViewModeAlways;
        _confirmPasswordTextField.cursorColor = COR1;
        NSOperatingSystemVersion iOS10Version = {10, 0, 0};
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        if ([processInfo isOperatingSystemAtLeastVersion:iOS10Version]) {
            _confirmPasswordTextField.adjustsFontForContentSizeCategory = YES;
        } else {
            [_confirmPasswordTextField mdc_setAdjustsFontForContentSizeCategory:YES];
        }
        
        self.textFieldControllerConfirmPassword =
        [[MDCTextInputControllerLegacyDefault alloc] initWithTextInput:_confirmPasswordTextField];
        self.textFieldControllerConfirmPassword.floatingEnabled = YES;
        self.textFieldControllerConfirmPassword.placeholderText = WBLocalizedString(@"confirm_user_password", nil);
        self.textFieldControllerConfirmPassword.activeColor = COR1;
        self.textFieldControllerConfirmPassword.characterCountMax = passwordMax;
        [self.textFieldControllerConfirmPassword mdc_setAdjustsFontForContentSizeCategory:YES];
        _confirmPasswordTextField.alpha = 0.0f;
    }
    return _confirmPasswordTextField;
}


- (void)tapDidTouch {
    [self.view endEditing:YES];
}
@end
