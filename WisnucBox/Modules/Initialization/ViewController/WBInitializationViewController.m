//
//  WBInitializationViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/12.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInitializationViewController.h"
#import "WBInitDiskTableViewCell.h"
#import "WBInitDiskSelectedTableViewCell.h"
#import "WBStorageVolumesAPI.h"
#import "WBStationBootAPI.h"
#import "BootModel.h"
#import "FMAsyncUsersAPI.h"
#import "UserModel.h"
#import "FMGetJWTAPI.h"
#import "AppDelegate.h"
#import "WBgetStationInfoAPI.h"
#import "WBInitChangeDiskTypeAlertViewController.h"
#import "WBStationTicketsAPI.h"
#import "TicketUserModel.h"
#import "WBCloudLoginAPI.h"
#import "CloudLoginModel.h"
#import "WBTicketsUserAPI.h"
#import "WBStationTicketsWechatAPI.h"
#import "FMUserEditVC.h"
#import "WBInitDiskDetailAlertViewController.h"
#import "NetServices.h"
#import "WBStationBootAPI.h"

#define WarningDetailColor UICOLOR_RGB(0xf44336)
#define IgnoreColor RGBACOLOR(0, 0, 0, 0.54f)
#define OriginTitleColor RGBACOLOR(0, 0, 0, 0.87f)
#define MainBackgroudColor  UICOLOR_RGB(0xfafafa)
#define userNameMax 16
#define passwordMax 30

@interface WBInitializationViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>

@property(nonatomic,assign) BOOL keyBoardlsVisible;
@property (nonatomic)UIView *lineView;
@property (nonatomic)TicketModel *ticketModel;
@property (nonatomic)NSDictionary *loginDataDic;

@property (nonatomic)NSMutableArray *diskDataArray;
@property (nonatomic)NSMutableArray *diskSelectedArray;
@property (nonatomic)UIScrollView *mainScrollView;

@property (nonatomic)UILabel *firstStepLabel;
@property (nonatomic)UIView *firstStepIconView;
@property (nonatomic)UILabel *firstStepTitle;
@property (nonatomic)UILabel *firstStepDetailLabel;
@property (nonatomic)UIButton *firstStepButton;
@property (nonatomic)BEMCheckBox *firstCheckBox;
@property (nonatomic)UITableView *diskTableView;
@property (nonatomic) UILabel *diskTypeTitle;
@property (nonatomic) UILabel *diskTypeLabel;
@property (nonatomic) UIButton *diskTypeChangeButton;

@property (nonatomic)UILabel *secondStepLabel;
@property (nonatomic)UIView *secondStepIconView;
@property (nonatomic)UILabel *secondStepTitle;
@property (nonatomic)UILabel *secondStepDetailLabel;
@property (nonatomic)MDCButton *secondStepNextButton;
@property (nonatomic)MDCButton *secondPreviousButton;
@property (nonatomic)BEMCheckBox *secondCheckBox;
@property (nonatomic)MDCTextField *userNameTextField;
@property (nonatomic)MDCTextField *passwordTextField;
@property (nonatomic)MDCTextField *confirmPasswordTextField;
@property (nonatomic, strong) MDCTextInputControllerLegacyDefault *textFieldControllerUserName;
@property (nonatomic, strong) MDCTextInputControllerLegacyDefault *textFieldControllerPassword;
@property (nonatomic, strong) MDCTextInputControllerLegacyDefault *textFieldControllerConfirmPassword;

@property (nonatomic)UILabel *thirdStepTitle;
@property (nonatomic)UILabel *thirdStepLabel;
@property (nonatomic)UIView *thirdStepIconView;
@property (nonatomic)UILabel *thirdUserNameLabel;
@property (nonatomic)UILabel *thirdDiskTypeLabel;
@property (nonatomic)MDCButton *thirdStepNextButton;
@property (nonatomic)MDCButton *thirdPreviousButton;
@property (nonatomic)UITableView *diskSelectedTableView;
@property (nonatomic)BEMCheckBox *thirdCheckBox;

@property (nonatomic)UILabel *fourthStepLabel;
@property (nonatomic)UIView *fourthStepIconView;
@property (nonatomic)UILabel *fourthStepTitle;
@property (nonatomic)UILabel *fourthStepDetailLabel;
@property (nonatomic)MDCButton *fourthStepNextButton;
@property (nonatomic)MDCButton *fourthIgnoreButton;
@property (nonatomic)BEMCheckBox *fourthCheckBox;

@property (nonatomic)UILabel *fifthStepLabel;
@property (nonatomic)UIView *fifthStepIconView;
@property (nonatomic)UILabel *fifthStepTitle;
@property (nonatomic)UILabel *fifthStepDetailLabel;
@property (nonatomic)MDCButton *fifthStepEnterButton;
@property (nonatomic)MDCButton *fifthPreviousButton;

@property (nonatomic)NetServices *netServices;

@end

@implementation WBInitializationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"initialization_guide", nil);
    [self.view addSubview:self.mainScrollView];
    UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidTouch)];
    [self.view addGestureRecognizer:tapRecognizer];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
    [center addObserver:self selector:@selector(diskTypeChangeNoti:) name:@"diskTypeChange" object:nil];
    [self getDiskData];
    [self.mainScrollView addSubview:self.lineView];
    [self.mainScrollView addSubview:self.firstStepIconView];
    [self.mainScrollView addSubview:self.firstStepTitle];
    [self.mainScrollView addSubview:self.firstStepDetailLabel];
    [self.mainScrollView addSubview:self.diskTableView];
    [self.mainScrollView addSubview:self.diskTypeTitle];
    [self.mainScrollView addSubview:self.diskTypeChangeButton];
    [self.mainScrollView addSubview:self.diskTypeLabel];
    [self.mainScrollView addSubview:self.firstStepButton];

    
    [self.mainScrollView addSubview:self.secondStepIconView];
    [self.mainScrollView addSubview:self.secondStepTitle];
    [self.mainScrollView addSubview:self.secondStepDetailLabel];
    [self.mainScrollView addSubview:self.userNameTextField];
    [self.mainScrollView addSubview:self.passwordTextField];
    [self.mainScrollView addSubview:self.confirmPasswordTextField];
    [self.mainScrollView addSubview:self.secondStepNextButton];
    [self.mainScrollView addSubview:self.secondPreviousButton];
    
    [self.mainScrollView addSubview:self.thirdStepIconView];
    [self.mainScrollView addSubview:self.thirdStepTitle];
    [self.mainScrollView addSubview:self.diskSelectedTableView];
    [self.mainScrollView addSubview:self.thirdUserNameLabel];
    [self.mainScrollView addSubview:self.thirdDiskTypeLabel];
    [self.mainScrollView addSubview:self.thirdStepNextButton];
    [self.mainScrollView addSubview:self.thirdPreviousButton];
    
    [self.mainScrollView addSubview:self.fourthStepIconView];
    [self.mainScrollView addSubview:self.fourthStepTitle];
    [self.mainScrollView addSubview:self.fourthStepDetailLabel];
    [self.mainScrollView addSubview:self.fourthStepNextButton];
    [self.mainScrollView addSubview:self.fourthIgnoreButton];
    
    [self.mainScrollView addSubview:self.fifthStepIconView];
    [self.mainScrollView addSubview:self.fifthStepTitle];
    [self.mainScrollView addSubview:self.fifthStepDetailLabel];
     [self.mainScrollView addSubview:self.fifthStepEnterButton];
     [self.mainScrollView addSubview:self.fifthPreviousButton];
    
    _mainScrollView.contentSize = CGSizeMake(__kWidth,CGRectGetMaxY( _fifthStepDetailLabel.frame) +8);
}

- (void)keyboardDidShow
{
    NSLog(@"键盘弹出");
    _keyBoardlsVisible =YES;
}
//  键盘隐藏触发该方法
- (void)keyboardDidHide
{
    NSLog(@"键盘隐藏");
    _keyBoardlsVisible =NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"diskTypeChange" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:COR1];
 
//    self.navigationController.navigationBar.backgroundColor = UICOLOR_RGB(0x03a9f4);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//   [self.navigationController.navigationBar setBarTintColor:COR1];
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

- (void)changeDiskTypeClick:(UIButton *)sender{    
    NSBundle *bundle = [NSBundle bundleForClass:[WBInitChangeDiskTypeAlertViewController class]];
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:@"WBInitChangeDiskTypeAlertViewController" bundle:bundle];
    NSString *identifier = @"DialogID";
    
    UIViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:identifier];
   
    viewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];
    WBInitChangeDiskTypeAlertViewController *vc = (WBInitChangeDiskTypeAlertViewController *)viewController;
    vc.typeString = _diskTypeLabel.text;
//    viewController
    [self presentViewController:viewController animated:YES completion:NULL];
}




- (void)firstStepButtonClick:(UIButton *)sender{
    @weaky(self)
    if (self.diskSelectedArray.count == 0) {
        return;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        [weak_self creatDiskModuleAnimateLayout];
        [weak_self creatUserModuleAnimateLayout];
        [weak_self thirdFourthFifthAnimateLayout];
        [weak_self lineViewAnimateLayout];
    } completion:^(BOOL finished) {
       
//        _firstStepButton.hidden = YES;
//        _diskTableView.hidden = YES;
        
    }];
}

- (void)secondPreviousButtonClick:(UIButton *)sender{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        @weaky(self)
        [weak_self creatDiskBackOriginModuleAnimateLayout];
        [weak_self creatUserBackOriginModuleAnimateLayout];
        [weak_self secondPreviousfourthAndFifthStepAnimateLayout];
        [weak_self lineViewAnimateLayout];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)secondStepNextButtonClick:(UIButton *)sender{
    if (_userNameTextField.text.length == 0) {
        [_textFieldControllerUserName setErrorText:WBLocalizedString(@"empty_username", nil) errorAccessibilityValue:nil];
        return;
    }else if (_userNameTextField.text.length > 16){
//       [_textFieldControllerUserName setErrorText:WBLocalizedString(@"username_exceed_character", nil) errorAccessibilityValue:nil];
         return;
    }else if (![NSString isUserName:_userNameTextField.text]){
        [_textFieldControllerUserName setErrorText:WBLocalizedString(@"username_has_illegal_character", nil) errorAccessibilityValue:nil];
       
         return;
    }
    
    if (_passwordTextField.text.length == 0) {
        [_textFieldControllerPassword setErrorText:WBLocalizedString(@"empty_password", nil) errorAccessibilityValue:nil];
         return;
    } if (_passwordTextField.text.length > 30){
//        [_textFieldControllerPassword setErrorText:WBLocalizedString(@"password_exceed_character", nil) errorAccessibilityValue:nil];
        return;
    }else if (![NSString isPassword:_passwordTextField.text]){
        [_textFieldControllerPassword setErrorText:WBLocalizedString(@"password_has_illegal_character", nil) errorAccessibilityValue:nil];
        return;
    }
    
    if (_confirmPasswordTextField.text.length == 0) {
        [_textFieldControllerConfirmPassword setErrorText:WBLocalizedString(@"empty_confirm_user_password", nil) errorAccessibilityValue:nil];
        return;
    } if (![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]){
        [_textFieldControllerConfirmPassword setErrorText:WBLocalizedString(@"new_password_inconsistent", nil) errorAccessibilityValue:nil];
        return;
    }
    
    
    [self.diskSelectedTableView reloadData];
    if (_keyBoardlsVisible) {
       [self tapDidTouch];
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        @weaky(self)
        [weak_self creatUserModuleConfirmInstallAnimateLayout];
        [weak_self confirmInstallAnimateLayout];
        [weak_self fourthAndFifthStepAnimateLayout];
        [weak_self lineViewAnimateLayout];
            } completion:^(BOOL finished) {
        
    }];
}

- (void)lineViewAnimateLayout{
    _lineView.frame = CGRectMake(26, 14, 1,CGRectGetMaxY(self.fifthStepIconView.frame) -CGRectGetMinY(self.firstStepIconView.frame) - 6);
}

- (void)thirdPreviousButtonClick:(UIButton *)sender{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        @weaky(self)
        [weak_self creatUserModuleBackSecondStepAnimateLayout];
        [weak_self installModuleBackOriginAnimateLayout];
        [weak_self otherAnimateLayout];
        [weak_self lineViewAnimateLayout];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)secondPreviousfourthAndFifthStepAnimateLayout{
    _thirdStepIconView.frame = CGRectMake(CGRectGetMinX(self.secondStepIconView.frame),CGRectGetMaxY(self.secondStepDetailLabel.frame)+ 24, 20, 28);
    
    _thirdStepTitle.frame = CGRectMake(CGRectGetMinX(_secondStepTitle.frame), CGRectGetMinY(_thirdStepIconView.frame),_secondStepTitle.jy_Width, 17);
    _fourthStepIconView.frame = CGRectMake(CGRectGetMinX(self.thirdStepIconView.frame),CGRectGetMaxY(self.thirdStepTitle.frame)+ 24, 20, 28);
    _fourthStepTitle.frame = CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMinY(_fourthStepIconView.frame),_thirdStepTitle.jy_Width, 17);
    
    
    _fifthStepIconView.frame = CGRectMake(CGRectGetMinX(self.fourthStepIconView.frame),CGRectGetMaxY(self.fourthStepTitle.frame)+ 24, 20, 28);
    
    _fifthStepTitle.frame =CGRectMake(CGRectGetMinX(_fourthStepTitle.frame), CGRectGetMinY(_fifthStepIconView.frame),_fourthStepTitle.jy_Width, 17);
}

- (void)creatDiskModuleAnimateLayout{
    _firstStepButton.alpha = 0;
    _diskTableView.alpha = 0;
    _diskTypeTitle.alpha = 0;
    _diskTypeChangeButton.alpha = 0;
    _diskTypeLabel.alpha = 0;
    _firstStepTitle.font = [UIFont systemFontOfSize:16];
    _firstStepTitle.textColor = IgnoreColor;
    _firstStepDetailLabel.textColor = IgnoreColor;
    [_firstCheckBox  setHidden:NO];
}

- (void)thirdFourthFifthAnimateLayout{
    [UIView animateWithDuration:0.3 animations:^{
        _thirdStepIconView.frame = CGRectMake(CGRectGetMinX(self.secondStepIconView.frame),CGRectGetMaxY(self.secondStepNextButton.frame)+ 24, 20, 28);
        _thirdStepTitle.frame = CGRectMake(CGRectGetMinX(_secondStepTitle.frame), CGRectGetMinY(_thirdStepIconView.frame),_secondStepTitle.jy_Width, 17);
        _fourthStepIconView.frame = CGRectMake(CGRectGetMinX(self.thirdStepIconView.frame),CGRectGetMaxY(self.thirdStepTitle.frame)+ 24, 20, 28);
        _fourthStepTitle.frame = CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMinY(_fourthStepIconView.frame),_thirdStepTitle.jy_Width, 17);
        
        
        _fifthStepIconView.frame = CGRectMake(CGRectGetMinX(self.fourthStepIconView.frame),CGRectGetMaxY(self.fourthStepTitle.frame)+ 24, 20, 28);
        
        _fifthStepTitle.frame =CGRectMake(CGRectGetMinX(_fourthStepTitle.frame), CGRectGetMinY(_fifthStepIconView.frame),_fourthStepTitle.jy_Width, 17);
        
        }];

}

- (void)creatUserModuleAnimateLayout{
    _secondStepLabel.backgroundColor = COR1;
    _secondStepDetailLabel.textColor = WarningDetailColor;
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
    _secondStepNextButton.center = CGPointMake(_secondStepNextButton.center.x,_confirmPasswordTextField.center.y + 28  + _confirmPasswordTextField.bounds.size.height/2 + _secondStepNextButton.bounds.size.height/2);
    _secondStepNextButton.alpha = 1.0f;
    _secondPreviousButton.center = CGPointMake(_secondPreviousButton.center.x,_confirmPasswordTextField.center.y + 28  + _confirmPasswordTextField.bounds.size.height/2 + _secondStepNextButton.bounds.size.height/2);
    _secondPreviousButton.alpha = 1.0f;
}

- (void)creatDiskBackOriginModuleAnimateLayout{
    _firstStepButton.alpha = 1;
    _diskTableView.alpha = 1;
    _diskTypeTitle.alpha = 1;
    _diskTypeChangeButton.alpha = 1;
    _diskTypeLabel.alpha = 1;
    _firstStepTitle.font = [UIFont boldSystemFontOfSize:16];
    _firstStepTitle.textColor = OriginTitleColor;
    _firstStepDetailLabel.textColor = WarningDetailColor;
    [_firstCheckBox  setHidden:YES];
}

- (void)creatUserBackOriginModuleAnimateLayout{
    _secondStepLabel.backgroundColor = IgnoreColor;
    _secondStepIconView.frame = CGRectMake(CGRectGetMinX(self.firstStepIconView.frame),CGRectGetMaxY(self.firstStepButton.frame)+ 24, 20, 28);
     _secondStepTitle.font = [UIFont systemFontOfSize:16];
    _secondStepTitle.frame =CGRectMake(CGRectGetMinX(_firstStepTitle.frame), CGRectGetMinY(_secondStepIconView.frame),_firstStepTitle.jy_Width, 17);
    _secondStepTitle.textColor = OriginTitleColor;
    _secondStepDetailLabel.frame = CGRectMake(CGRectGetMinX(_firstStepDetailLabel.frame), CGRectGetMaxY(_secondStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_secondStepTitle.frame) -32 , 30);
    _secondStepDetailLabel.textColor = IgnoreColor;

    _userNameTextField.center = CGPointMake(_userNameTextField.center.x,_secondStepDetailLabel.center.y + 8  + _secondStepDetailLabel.bounds.size.height/2 + _userNameTextField.bounds.size.height/2);
    _userNameTextField.alpha = 0;
    _passwordTextField.frame = CGRectMake(CGRectGetMinX(_secondStepDetailLabel.frame)  , CGRectGetMaxY(_userNameTextField.frame) + 8,__kWidth  - 32 -CGRectGetMinX(_secondStepDetailLabel.frame) , 80);
    _passwordTextField.alpha = 0;
    _confirmPasswordTextField.frame = CGRectMake(CGRectGetMinX(_secondStepDetailLabel.frame) , CGRectGetMaxY(_passwordTextField.frame) + 8,__kWidth  - 32 -CGRectGetMinX(_secondStepDetailLabel.frame) , 80);
    
    _confirmPasswordTextField.alpha = 0;
    _secondStepNextButton.frame = CGRectMake(CGRectGetMinX(_secondStepTitle.frame),CGRectGetMaxY(_confirmPasswordTextField.frame) +28, 86, 36);
    _secondStepNextButton.alpha = 0;
    _secondPreviousButton.frame = CGRectMake(CGRectGetMaxX(_secondStepNextButton.frame) + 8,CGRectGetMaxY(_confirmPasswordTextField.frame) +28, 86, 36);
    _secondPreviousButton.alpha = 0;
}

- (void)fourthAndFifthStepAnimateLayout{
    _fourthStepIconView.center = CGPointMake(_fourthStepIconView.center.x,  _thirdStepNextButton. center.y + 36 + _thirdStepNextButton.bounds.size.height/2 + _fourthStepIconView.bounds.size.height/2);
    _fourthStepTitle.center = CGPointMake(_fourthStepTitle.center.x,_fourthStepIconView.center.y - 4);
    
    _fifthStepIconView.center = CGPointMake(_fifthStepIconView.center.x,  _fourthStepTitle. center.y + 36 + _fourthStepTitle.bounds.size.height/2 + _fifthStepIconView.bounds.size.height/2);
    _fifthStepTitle.center = CGPointMake(_fifthStepTitle.center.x,_fifthStepIconView.center.y - 4);
}

- (void)creatUserModuleConfirmInstallAnimateLayout{
    _secondPreviousButton.alpha = 0;
    _secondStepNextButton.alpha = 0;
    _userNameTextField.alpha = 0;
    _passwordTextField.alpha = 0;
    _confirmPasswordTextField.alpha = 0;
    _secondStepTitle.font = [UIFont systemFontOfSize:16];
    _secondStepTitle.textColor = IgnoreColor;
    _secondStepDetailLabel.textColor = IgnoreColor;
    [_secondCheckBox setHidden:NO];
}

- (void)confirmInstallAnimateLayout{
    _thirdStepLabel.backgroundColor = COR1;
    _thirdStepIconView.center = CGPointMake(_secondStepIconView.center.x,  _secondStepDetailLabel. center.y + 36 + _secondStepDetailLabel.bounds.size.height/2 + _thirdStepIconView.bounds.size.height/2);
    _thirdStepTitle.font = [UIFont boldSystemFontOfSize:16];
    _thirdStepTitle.center = CGPointMake(_thirdStepTitle.center.x,_thirdStepIconView.center.y - 4);
    _diskSelectedTableView.frame = CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMaxY(_thirdStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_thirdStepTitle.frame) - 56 ,56 *self.diskSelectedArray.count + 8);
    _diskSelectedTableView.alpha = 1;
    _thirdUserNameLabel.text = [NSString stringWithFormat:@"用户名：%@",_userNameTextField.text];
    NSString *typeString ;
    if ([_diskTypeLabel.text containsString:@"Single"]) {
        typeString = @"single";
    }else  if ([_diskTypeLabel.text containsString:@"Raid0"]) {
        typeString = @"raid0";
    }else  if ([_diskTypeLabel.text containsString:@"Raid1"]) {
        typeString = @"raid1";
    }
    _thirdDiskTypeLabel.text = [NSString stringWithFormat:@"模式：%@",typeString];
    _thirdUserNameLabel.center = CGPointMake(_thirdUserNameLabel.center.x,  _diskSelectedTableView.center.y + 8 + _thirdUserNameLabel.bounds.size.height/2 + _diskSelectedTableView.bounds.size.height/2);
    _thirdDiskTypeLabel.center = CGPointMake(_thirdDiskTypeLabel.center.x,  _thirdUserNameLabel.center.y + 8 + _thirdUserNameLabel.bounds.size.height/2 + _thirdDiskTypeLabel.bounds.size.height/2);
    _thirdUserNameLabel.alpha = 1.0f;
    _thirdDiskTypeLabel.alpha = 1.0f;
    _thirdStepNextButton.center = CGPointMake(_thirdStepNextButton.center.x,  _thirdDiskTypeLabel.center.y + 28 + _thirdStepNextButton.bounds.size.height/2 + _thirdDiskTypeLabel.bounds.size.height/2);
    _thirdPreviousButton.center = CGPointMake(_thirdPreviousButton.center.x,  _thirdDiskTypeLabel.center.y + 28 + _thirdPreviousButton.bounds.size.height/2 + _thirdDiskTypeLabel.bounds.size.height/2);
    _thirdStepNextButton.alpha = 1.0f;
    _thirdPreviousButton.alpha = 1.0f;
}

- (void)creatUserModuleBackSecondStepAnimateLayout{
    [_secondCheckBox setHidden:YES];
    _secondStepLabel.backgroundColor = COR1;
    _secondStepDetailLabel.textColor = WarningDetailColor;
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
    _secondStepNextButton.center = CGPointMake(_secondStepNextButton.center.x,_confirmPasswordTextField.center.y + 28  + _confirmPasswordTextField.bounds.size.height/2 + _secondStepNextButton.bounds.size.height/2);
    _secondStepNextButton.alpha = 1.0f;
    _secondPreviousButton.center = CGPointMake(_secondPreviousButton.center.x,_confirmPasswordTextField.center.y + 28  + _confirmPasswordTextField.bounds.size.height/2 + _secondStepNextButton.bounds.size.height/2);
    _secondPreviousButton.alpha = 1.0f;
}

- (void)installModuleBackOriginAnimateLayout{
    _thirdStepLabel.backgroundColor = IgnoreColor;
    _thirdStepIconView.frame = CGRectMake(CGRectGetMinX(self.secondStepIconView.frame),CGRectGetMaxY(self.secondPreviousButton.frame)+ 24, 20, 28);

    _thirdStepTitle.frame = CGRectMake(CGRectGetMinX(_secondStepTitle.frame), CGRectGetMinY(_thirdStepIconView.frame),_secondStepTitle.jy_Width, 17);
    _thirdStepTitle.textColor = OriginTitleColor;
    _thirdStepTitle.font = [UIFont systemFontOfSize:16];

    _diskSelectedTableView.frame = CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMaxY(_thirdStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_thirdStepTitle.frame) - 56 ,56 *self.diskSelectedArray.count + 8);
    _diskSelectedTableView.alpha = 0;
    _thirdUserNameLabel.frame = CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMaxY(_diskSelectedTableView.frame) + 8, __kWidth - CGRectGetMinX(_thirdStepTitle.frame) - 16, 14);
    _thirdUserNameLabel.alpha = 0;
    _thirdDiskTypeLabel.frame = CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMaxY(_thirdUserNameLabel.frame) + 8, __kWidth - CGRectGetMinX(_thirdStepTitle.frame) - 16, 14);
    _thirdDiskTypeLabel.alpha = 0;
    _thirdStepNextButton.frame = CGRectMake(CGRectGetMinX(_thirdStepTitle.frame),CGRectGetMaxY(_thirdDiskTypeLabel.frame) +28, 86, 36);
    _thirdStepNextButton.alpha = 0;
    _thirdPreviousButton.frame = CGRectMake(CGRectGetMaxX(_thirdStepNextButton.frame) + 8,CGRectGetMaxY(_thirdDiskTypeLabel.frame) +28, 86, 36);
    _thirdPreviousButton.alpha = 0;
}

- (void)otherAnimateLayout{
    _fourthStepIconView.frame = CGRectMake(CGRectGetMinX(self.thirdStepIconView.frame),CGRectGetMaxY(self.thirdStepTitle.frame)+ 24, 20, 28);
    _fourthStepTitle.frame = CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMinY(_fourthStepIconView.frame),_thirdStepTitle.jy_Width, 17);
    
    
    _fifthStepIconView.frame = CGRectMake(CGRectGetMinX(self.fourthStepIconView.frame),CGRectGetMaxY(self.fourthStepTitle.frame)+ 24, 20, 28);

    _fifthStepTitle.frame =CGRectMake(CGRectGetMinX(_fourthStepTitle.frame), CGRectGetMinY(_fifthStepIconView.frame),_fourthStepTitle.jy_Width, 17);
}

- (void)bindWechatAnimiteLayout{
    _fourthStepTitle.font = [UIFont boldSystemFontOfSize:16];
     _fourthStepLabel.backgroundColor = COR1;
    _fourthStepIconView.center = CGPointMake(_fourthStepIconView.center.x,  _thirdStepTitle. center.y + 36 + _thirdStepTitle.bounds.size.height/2 + _fourthStepIconView.bounds.size.height/2);
    _fourthStepTitle.center = CGPointMake(_fourthStepTitle.center.x,_fourthStepIconView.center.y - 4);
    _fourthStepDetailLabel.center = CGPointMake(_fourthStepDetailLabel.center.x,_fourthStepTitle.center.y + 8  + _fourthStepTitle.bounds.size.height/2 + _fourthStepDetailLabel.bounds.size.height/2);
    _fourthStepDetailLabel.alpha = 1.0f;
    _fourthStepNextButton.center = CGPointMake(_fourthStepNextButton.center.x,  _fourthStepDetailLabel.center.y + 28 + _fourthStepNextButton.bounds.size.height/2 + _fourthStepDetailLabel.bounds.size.height/2);
    _fourthIgnoreButton.center = CGPointMake(_fourthIgnoreButton.center.x,  _fourthStepDetailLabel.center.y + 28 + _fourthIgnoreButton.bounds.size.height/2 + _fourthStepDetailLabel.bounds.size.height/2);
    _fourthStepNextButton.alpha = 1.0f;
    _fourthIgnoreButton.alpha = 1.0f;
    _fifthStepIconView.center = CGPointMake(_fifthStepIconView.center.x,  _fourthIgnoreButton. center.y + 36 + _fourthIgnoreButton.bounds.size.height/2 + _fifthStepIconView.bounds.size.height/2);
    _fifthStepTitle.center = CGPointMake(_fifthStepTitle.center.x,_fifthStepIconView.center.y - 4);
}

- (void)confirmInstallCompleteAnimateLayout{
    _thirdStepTitle.font = [UIFont systemFontOfSize:16];
    _diskSelectedTableView.alpha = 0;
    _thirdUserNameLabel.alpha = 0;
    _thirdDiskTypeLabel.alpha = 0;
    _thirdPreviousButton.alpha = 0;
    _thirdStepNextButton.alpha = 0;
    [self.thirdCheckBox setHidden:NO];
}

#warning install
- (void)installButtonClick:(UIButton *)sender{
    @weaky(self);
    [SXLoadingView showProgressHUD:@"正在创建"];
    NSMutableArray * targetMutableArray = [NSMutableArray arrayWithCapacity:0];
    [_diskSelectedArray enumerateObjectsUsingBlock:^(WBStationManageBlocksModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        [targetMutableArray addObject:model.name];
    }];
    NSArray *tagetArray = [NSArray arrayWithArray:targetMutableArray];
    NSLog(@"%@",tagetArray);
    NSString *typeString ;
    if ([_diskTypeLabel.text containsString:@"Single"]) {
        typeString = @"single";
    }else  if ([_diskTypeLabel.text containsString:@"Raid0"]) {
        typeString = @"raid0";
    }else  if ([_diskTypeLabel.text containsString:@"Raid1"]) {
        typeString = @"raid1";
    }
    [[WBStorageVolumesAPI apiWithURLPath:_searchModel.path Target:tagetArray Mode:typeString]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSDictionary *dic= request.responseJsonObject;
        //        NSDictionary *dic = dataArray[0];
        NSString *uuid = dic[@"uuid"];
        [weak_self installBootRequestWithUUID:uuid];
        
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            
            NSLog(@"%@",serializedData);
        }
        [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.0f];
    }];
}

- (void)installBootRequestWithUUID:(NSString *)uuid{
    @weaky(self)
    [[WBStationBootAPI apiWithPath:_searchModel.path RequestMethod:@"PATCH" UUID:uuid]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        BootModel *bootModel = [BootModel yy_modelWithJSON:request.responseJsonObject];
        if (bootModel.current) {
            if ([bootModel.state isEqualToString:@"started"]) {
                [weak_self getStationUsers];
            }else if ([bootModel.state isEqualToString:@"stopping"]){
                NSLog(@"error --- bootInstall");
            }else{
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    [weak_self installBootRequestWithUUID:uuid];
                });
            }
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"%@",serializedData);
            //            [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"error :StationBootAPI --%@",serializedData] duration:1.0f];
        }
        [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.0f];
    }];
}

- (void)getStationUsers{
    @weaky(self)
    [[FMAsyncUsersAPI apiWithURLPath:_searchModel.path UserName:_userNameTextField.text Password:_confirmPasswordTextField.text] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSDictionary *dic  = request.responseJsonObject;
        UserModel * model = [UserModel yy_modelWithJSON:dic];
        
        self.loginDataDic  = @{@"userModel":model
                               };
        [SXLoadingView showProgressHUDText:@"创建完成" duration:1.0f];
        [UIView animateWithDuration:0.3 animations:^{
            [weak_self confirmInstallCompleteAnimateLayout];
            [weak_self bindWechatAnimiteLayout];
            [weak_self lineViewAnimateLayout];
        }];
        
    } failure:^(__kindof JYBaseRequest *request) {
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        NSLog(@"%@",serializedData);
        
        //        [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"error :userAPI --%@",serializedData] duration:1.0];
        [SXLoadingView showProgressHUDText:WBLocalizedString(@"error", nil) duration:1.0f];
    }];
}


- (void)fourthStepNextButtonClick:(UIButton *)sender{
   @weaky(self)
   
    [self bootCheckForLastActionCompleteBlock:^(BootModel *bootModel) {
        UserModel *model = [self.loginDataDic valueForKey:@"userModel"];
        //    NSString *stationName = [self.loginDataDic valueForKey:@"stationName"];
        NSString * UUID = [NSString stringWithFormat:@"%@:%@",model.uuid,_confirmPasswordTextField.text];
        NSString * Basic = [UUID base64EncodedString];
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        NSString* urlString = [NSString stringWithFormat:@"http://%@:3000/", _searchModel.displayPath];
        
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",Basic] forHTTPHeaderField:@"Authorization"];
        [manager GET:[NSString stringWithFormat:@"%@token",urlString] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString * token = responseObject[@"token"];
            
            self.netServices = [[NetServices alloc]initWithLocalURL:urlString andCloudURL:nil];
            WBUser *user = [WB_UserService createUserWithUserUUID:model.uuid];
            user.userName = model.username;
            user.localAddr = urlString;
            user.localToken = token;
            user.isFirstUser = NO;
            user.isAdmin = NO;
            user.isCloudLogin = NO;
            //        user.bonjour_name = stationName;
            user.sn_address = _searchModel.displayPath;
            if (model.avatar) {
                user.avaterURL = model.avatar;
            }
            [WB_UserService setCurrentUser:user];
            [WB_UserService synchronizedCurrentUser];
            [weak_self requestWechat];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            error.wbCode = 10001;
            
        }];
    }];
    
}

- (void)requestWechat{
     @weaky(self)
    [[WBStationTicketsAPI apiWithRequestMethodString:@"POST" Type:@"bind"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        TicketModel *model = [TicketModel yy_modelWithJSON:request.responseJsonObject];
        _ticketModel = model;
        if ([WXApi isWXAppInstalled]) {
            SendAuthReq *req = [[SendAuthReq alloc] init];
            req.scope = @"snsapi_userinfo";
            req.state = @"App";
            [WXApi sendReq:req];
        }
        else {
            [weak_self setupAlertController];
        }
        
        NSLog(@"%@",request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        [SXLoadingView hideProgressHUD];
    }];
}

- (void)setupAlertController{
    [SXLoadingView showProgressHUDText:WBLocalizedString(@"not_installed_WeChat", nil) duration:1.5];
}

- (void)weChatCallBackRespCode:(NSString *)code{
    @weaky(self);
    [SXLoadingView showProgressHUD:nil];
    [[WBCloudLoginAPI apiWithCode:code] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        CloudLoginModel * model = [CloudLoginModel yy_modelWithJSON:request.responseJsonObject];
        [weak_self bindWechtWithCloudToken:model.data.token];
        //        weak_self.avatarUrl = model.data.user.avatarUrl;
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        
    }];
    
}

- (void)bindWechtWithCloudToken:(NSString *)token{
    @weaky(self);
    NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
    RACSubject *subject = [RACSubject subject];
    [[WBTicketsUserAPI apiWithTicketId:_ticketModel.ticketId WithToken:token]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * responseDic =  request.responseJsonObject[@"data"];
        TicketUserModel *model = [TicketUserModel yy_modelWithDictionary:responseDic];
        [SXLoadingView hideProgressHUD];
        [subject sendNext:model];
        NSLog(@"%@",request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSLog(@"%@",request.error);
    }];
    
    [subject subscribeNext:^(id  _Nullable x) {
        TicketUserModel *userModel = x;
        NSString *alertActionTitleString = WBLocalizedString(@"bind", nil);
        NSString *alertTitleString = WBLocalizedString(@"confirm_binding_WeChat", nil);
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:alertTitleString message:WBLocalizedString(@"binding_WeChat?", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"点击了取消按钮");
            
            [weak_self bindWechatLastActionWith:userModel IsBind:NO];
        }];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:alertActionTitleString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"点击了确定按钮");
            [SXLoadingView showProgressHUD:WBLocalizedString(@"binding", nil)];
            [weak_self bindWechatLastActionWith:userModel IsBind:YES];
            
        }];
        [alertVc addAction:cancle];
        [alertVc addAction:confirm];
        [self presentViewController:alertVc animated:YES completion:^{
        }];
        
    }];
}

- (void)bindWechatLastActionWith:(TicketUserModel *)model IsBind:(BOOL)isBind{
    @weaky(self)
    [[WBStationTicketsWechatAPI apiWithTicketId:_ticketModel.ticketId Guid:model.userId Isbind:isBind] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        
        WBUser *user = WB_UserService.currentUser;
        user.avaterURL = model.avatarUrl;
        user.isBindWechat = YES;
        [WB_UserService setCurrentUser:user];
        [WB_UserService synchronizedCurrentUser];
        if (isBind) {
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"success", nil) duration:1.5];
            
#warning Do something for last Action
            
           [weak_self animiteForLastAction];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length>0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"%@",serializedData);
            [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"error，reason：%@",serializedData[@"message"]] duration:1.5];
        }
    }];
}

- (void)fourthIgnoreButtonClick:(UIButton *)sender{
    
    [self bootCheckForLastActionCompleteBlock:^(BootModel *model) {
         [self animiteForLastAction];
    }];
}

- (void)bootCheckForLastActionCompleteBlock:(void(^)(BootModel *model))block{
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [[WBStationBootAPI apiWithPath:_searchModel.path RequestMethod:@"GET"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        @weaky(self)
        NSLog(@"%@",request.responseJsonObject);
        BootModel *bootModel = [BootModel yy_modelWithJSON:request.responseJsonObject];
        //        if (bootModel.current) {
        if ([bootModel.state isEqualToString:@"started"]) {
            [SXLoadingView hideProgressHUD];
            block(bootModel);
        }else if ([bootModel.state isEqualToString:@"stopping"]){
             [SXLoadingView showProgressHUDText:@"设备已停止服务" duration:1.0f];
//             block(bootModel);
        }else{
            
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
            
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [weak_self bootCheckForLastActionCompleteBlock:block];
            });
        }
        //        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
}

- (void)animiteForLastAction{
    [UIView animateWithDuration:0.3f animations:^{
        
        [_fourthCheckBox setHidden:NO];
        _fourthStepTitle.font = [UIFont systemFontOfSize:16];
        _fourthStepTitle.textColor = IgnoreColor;
        _fourthStepDetailLabel.textColor = IgnoreColor;
        _fourthIgnoreButton.alpha = 0;
        _fourthStepNextButton.alpha = 0;
        
        _fifthStepLabel.backgroundColor = COR1;
        _fifthStepIconView.center = CGPointMake(_fifthStepIconView.center.x,  _fourthStepDetailLabel. center.y + 36 + _fourthStepDetailLabel.bounds.size.height/2 + _fifthStepIconView.bounds.size.height/2);
        _fifthStepTitle.center = CGPointMake(_fifthStepTitle.center.x,_fifthStepIconView.center.y - 4);
        _fifthStepTitle.font = [UIFont boldSystemFontOfSize:16];
        _fifthStepDetailLabel.center = CGPointMake(_fifthStepDetailLabel.center.x,_fifthStepTitle.center.y + 8  + _fifthStepTitle.bounds.size.height/2 + _fifthStepDetailLabel.bounds.size.height/2);
        _fifthStepEnterButton.center = CGPointMake(_fifthStepEnterButton.center.x,  _fifthStepDetailLabel.center.y + 28 + _fifthStepEnterButton.bounds.size.height/2 + _fifthStepDetailLabel.bounds.size.height/2);
        _fifthPreviousButton.center = CGPointMake(_fifthPreviousButton.center.x,  _fifthStepDetailLabel.center.y + 28 + _fifthPreviousButton.bounds.size.height/2 + _fifthStepDetailLabel.bounds.size.height/2);
        _fifthStepDetailLabel.alpha = 1.0f;
        _fifthStepEnterButton.alpha = 1.0f;
        _fifthPreviousButton.alpha = 1.0f;
        [self lineViewAnimateLayout];
    }];

}

- (void)fifthStepEnterButtonClick:(UIButton *)sender{
    @weaky(self)
    [[WBgetStationInfoAPI apiWithServicePath:_searchModel.path]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSDictionary *rootDic =  request.responseJsonObject;
        NSString *nameString = [rootDic objectForKey:@"name"];
        if (nameString.length == 0) {
            nameString = WBLocalizedString(@"wisnuc_box", nil);
        }
        [weak_self loaginWithStationName:nameString];
    } failure:^(__kindof JYBaseRequest *request) {
        NSString *nameString = WBLocalizedString(@"wisnuc_box", nil);
        [weak_self loaginWithStationName:nameString];
        NSLog(@"%@",request.error);
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"失败,%@",serializedData);
        }
        
    }];
   
}

- (void)loaginWithStationName:(NSString *)stationName{
    [WB_UserService logoutUser];
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    if (self.loginDataDic) {
        UserModel *model = [self.loginDataDic valueForKey:@"userModel"];
        NSString * UUID = [NSString stringWithFormat:@"%@:%@",model.uuid,_confirmPasswordTextField.text];
        NSString * Basic = [UUID base64EncodedString];
        [WB_AppServices loginWithBasic:Basic userUUID:model.uuid StationName:stationName UserName:model.username addr:_searchModel.displayPath AvatarURL:model.avatar isWechat:NO completeBlock:^(NSError *error, WBUser *user) {
            if(error || IsNilString(user.userHome)){
                if(!user) NSLog(@"GET TOKEN ERROR");
                else NSLog(@"Get User Home Error");
                [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"%@ code: %ld", WBLocalizedString(@"login_failed", nil),(long)error.wbCode] duration:1];
                
            }else{
                AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate ;
                app.window.rootViewController = nil;
                [app.window resignKeyWindow];
                [app.window removeFromSuperview];
                
                [MyAppDelegate initRootVC];
                [SXLoadingView hideProgressHUD];
            }
        }];
    }
}

- (void)fifthPreviousButtonClick:(UIButton *)sender{
    [UIView animateWithDuration:0.3 animations:^{
      
        [_fourthCheckBox setHidden:YES];
        _fourthStepNextButton.alpha = 1.0f;
        _fourthIgnoreButton.alpha = 1.0f;
        _fourthStepTitle.font = [UIFont boldSystemFontOfSize:16];
        _fourthStepDetailLabel.textColor = WarningDetailColor;
        
        
        _fifthStepDetailLabel.alpha = 0;
        _fifthPreviousButton.alpha = 0;
        _fifthStepEnterButton.alpha = 0;
        _fifthStepTitle.font = [UIFont systemFontOfSize:16];
        _fifthStepLabel.backgroundColor = IgnoreColor;
        _fifthStepIconView.frame = CGRectMake(CGRectGetMinX(self.fourthStepIconView.frame),CGRectGetMaxY(self.fourthStepNextButton.frame)+ 24, 20, 28);
        _fifthStepTitle.frame = CGRectMake(CGRectGetMinX(_fourthStepTitle.frame), CGRectGetMinY(_fifthStepIconView.frame),_fourthStepTitle.jy_Width, 17);
        [self lineViewAnimateLayout];
    }];
}

- (void)diskTypeChangeNoti:(NSNotification *)noti{
    NSLog(@"%@",noti);
    NSString *typeString = noti.object;
    _diskTypeLabel.text = typeString;
}

#pragma tableViewdataSouce

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView == self.diskTableView) {
    WBInitDiskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBInitDiskTableViewCell class])];
    if (!cell) {
        cell = (WBInitDiskTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBInitDiskTableViewCell class]) owner:self options:nil]lastObject];
    }
    cell.backgroundColor = UICOLOR_RGB(0xfafafa);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WBStationManageBlocksModel *model = self.diskDataArray[indexPath.row];
    cell.nameLabel.text = model.model?model.model:@"未知设备";
    NSNumber *sizeNumber = [NSNumber numberWithLongLong:[model.size longLongValue] *512];
    NSString *sizeString = [NSString transformedValue:sizeNumber];
//    NSLog(@"%@",sizeString);
    NSString *idBus = [model.idBus uppercaseStringWithLocale:[NSLocale currentLocale]];
    cell.detailLabel.text = [NSString stringWithFormat:@"%@  %@  %@",model.name,sizeString,idBus];
    if (model.unformattable &&[model.unformattable containsString:@"RootFS"]) {
        cell.nameLabel.textColor = RGBACOLOR(0, 0, 0, 0.26f);
        cell.detailLabel.textColor = RGBACOLOR(0, 0, 0, 0.26f);
        [cell.checkBox setEnabled:NO];
        cell.checkBox.onCheckColor = IgnoreColor;
        cell.leftIconImageView.image = [UIImage imageNamed:@"disk_disable"];
    }else if (model.unformattable){
        cell.nameLabel.textColor = RGBACOLOR(0, 0, 0, 0.26f);
        cell.detailLabel.textColor = RGBACOLOR(0, 0, 0, 0.26f);
        [cell.checkBox setEnabled:NO];
        cell.checkBox.onCheckColor = IgnoreColor;
    }
    
    cell.cellCheckBoxBlock = ^(BEMCheckBox *cellCheckBox) {
        if (cellCheckBox.on) {
            NSLog(@"😆");
            if (![self.diskSelectedArray containsObject:model]) {
                [self.diskSelectedArray addObject:model];
            }
          
        }else{
            NSLog(@"😑");
            if ([self.diskSelectedArray containsObject:model]) {
                [self.diskSelectedArray removeObject:model];
            }
        }
        
        if (self.diskSelectedArray.count == 1) {
            _diskTypeLabel.text = WBLocalizedString(@"single_mode", nil);
        }else if (self.diskSelectedArray.count >1){
//             _diskTypeLabel.text = @"未设置";
            _diskTypeChangeButton.enabled = YES;
        }
    };
        
        cell.cellDetailButtonBlock = ^(UIButton *button) {
            NSBundle *bundle = [NSBundle bundleForClass:[WBInitDiskDetailAlertViewController class]];
            UIStoryboard *storyboard =
            [UIStoryboard storyboardWithName:@"WBInitDiskDetailAlertViewController" bundle:bundle];
            NSString *identifier = @"diskDetail";
            
            UIViewController *viewController =
            [storyboard instantiateViewControllerWithIdentifier:identifier];
            
            viewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];
            WBInitDiskDetailAlertViewController *vc = (WBInitDiskDetailAlertViewController *)viewController;
            vc.blocksmodel = model;
            [self presentViewController:viewController animated:YES completion:NULL];
        };
 
    return cell;
    }else{
        WBInitDiskSelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBInitDiskSelectedTableViewCell class])];
        if (!cell) {
            cell = (WBInitDiskSelectedTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBInitDiskSelectedTableViewCell class]) owner:self options:nil]lastObject];
        }
        cell.backgroundColor = UICOLOR_RGB(0xfafafa);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        WBStationManageBlocksModel *model = self.diskSelectedArray[indexPath.row];
        cell.nameLabel.text = model.model?model.model:@"未知设备";
        NSNumber *sizeNumber = [NSNumber numberWithLongLong:[model.size longLongValue] *512];
        NSString *sizeString = [NSString transformedValue:sizeNumber];
        //    NSLog(@"%@",sizeString);
        NSString *idBus = [model.idBus uppercaseStringWithLocale:[NSLocale currentLocale]];
        cell.detailLabel.text = [NSString stringWithFormat:@"%@  %@  %@",model.name,sizeString,idBus];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (tableView == self.diskTableView) {
          return self.diskDataArray.count;
     }else{
         return self.diskSelectedArray.count;
     }
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 8;
//}

#pragma mark - UITextFieldDelegate

// All the usual UITextFieldDelegate methods work with MDCTextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _userNameTextField) {
        if (textField.text.length>0) {
            [_textFieldControllerUserName setErrorText:nil errorAccessibilityValue:nil];
        }
    }else if (textField == _passwordTextField){
        if (textField.text.length>0) {
            [_textFieldControllerPassword setErrorText:nil errorAccessibilityValue:nil];
        }
    }else if (textField == _confirmPasswordTextField){
        if (textField.text.length>0) {
            [_textFieldControllerConfirmPassword setErrorText:nil errorAccessibilityValue:nil];
        }
    }
   
   
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField

{
    
    NSLog(@"textFieldDidBeginEditing");
    
    CGRect frame = textField.frame;
    
    CGFloat heights = self.mainScrollView.frame.size.height;
    
    // 当前点击textfield的坐标的Y值 + 当前点击textFiled的高度 - （屏幕高度- 键盘高度 - 键盘上tabbar高度）
    
    // 在这一部 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
    
    int offset = frame.origin.y + 42- ( heights - 216.0-35.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.mainScrollView.frame.size.width;
    
    float height = self.mainScrollView.frame.size.height;
    
    if(offset > 0)
        
    {
        
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        
        self.mainScrollView.frame = rect;
        
    }
    
    [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([_userNameTextField isFirstResponder]) {
        [_passwordTextField becomeFirstResponder];
    } else if([_passwordTextField isFirstResponder]) {
        [_confirmPasswordTextField becomeFirstResponder];
    }else if([_confirmPasswordTextField isFirstResponder]){
        [self.view endEditing:YES];
        
        NSTimeInterval animationDuration = 0.30f;
        
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        
        [UIView setAnimationDuration:animationDuration];
        
        CGRect rect = CGRectMake(0.0f, 0.0f, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
        
        self.mainScrollView.frame = rect;
        
        [UIView commitAnimations];
    }
    return YES;
}


- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView= [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, __kWidth,__kHeight)];
        _mainScrollView.delegate = self;
        _mainScrollView.scrollEnabled = YES;
        _mainScrollView.backgroundColor = MainBackgroudColor;
    }
    return _mainScrollView;
}

- (NSMutableArray *)diskDataArray{
    if (!_diskDataArray) {
        _diskDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _diskDataArray;
}

- (NSMutableArray *)diskSelectedArray{
    if (!_diskSelectedArray) {
         _diskSelectedArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _diskSelectedArray;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(26, 14, 1,__kHeight)];
        _lineView.backgroundColor = [UIColor lightGrayColor];
    }
    return _lineView;
}

- (UILabel *)firstStepLabel{
    if (!_firstStepLabel) {
        _firstStepLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 22, 22)];
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
        _firstStepIconView.backgroundColor = MainBackgroudColor;
        [_firstStepIconView addSubview:self.firstStepLabel];
        [_firstStepIconView addSubview:self.firstCheckBox];
        self.firstCheckBox.center =  _firstStepLabel.center;
    }
    return _firstStepIconView;
}

- (UILabel *)firstStepTitle{
    if (!_firstStepTitle) {
        _firstStepTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_firstStepIconView.frame) + 16, 8,__kWidth - 16 -  CGRectGetMaxX(_firstStepIconView.frame) + 16, 17)];
        _firstStepTitle.textColor = OriginTitleColor;
        _firstStepTitle.text = @"创建磁盘卷";
        _firstStepTitle.font = [UIFont boldSystemFontOfSize:16];
    }
    return _firstStepTitle;
}

- (UILabel *)firstStepDetailLabel{
    if (!_firstStepDetailLabel) {
        _firstStepDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepTitle.frame), CGRectGetMaxY(_firstStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_firstStepTitle.frame) -16 , 24)];
        _firstStepDetailLabel.textColor = WarningDetailColor;
        _firstStepDetailLabel.numberOfLines = 0;
        _firstStepDetailLabel.adjustsFontSizeToFitWidth = YES;
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
        _diskTableView.backgroundColor = UICOLOR_RGB(0xfafafa);
        UIView *footBackgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 8)];
        UIView *footlineView  = [[UIView alloc]initWithFrame:CGRectMake(0, 7, __kWidth, 0.5)];
        footlineView.backgroundColor = RGBCOLOR(222, 222, 224);
        footBackgroudView.backgroundColor = UICOLOR_RGB(0xfafafa);
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
        _diskTypeTitle.text = @"磁盘卷模式：";
        _diskTypeTitle.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        _diskTypeTitle.font = [UIFont systemFontOfSize:14];
//        _diskTypeTitle
    }
    return _diskTypeTitle;
}

- (UIButton *)diskTypeChangeButton{
    if (!_diskTypeChangeButton) {
        _diskTypeChangeButton = [[UIButton alloc]initWithFrame:CGRectMake(__kWidth - 56 - 24,CGRectGetMinY(_diskTypeTitle.frame) + 16/2 , 24, 24)];
        [_diskTypeChangeButton setImage:[UIImage imageNamed:@"ic_mode_edit_18pt"] forState:UIControlStateNormal];
        _diskTypeChangeButton.enabled = NO;
        [_diskTypeChangeButton addTarget:self action:@selector(changeDiskTypeClick:) forControlEvents:UIControlEventTouchUpInside];
        [_diskTypeChangeButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
//        _diskTypeChangeButton.backgroundColor = [UIColor cyanColor];
    }
    return _diskTypeChangeButton;
}

- (UILabel *)diskTypeLabel{
    if (!_diskTypeLabel) {
        _diskTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_diskTypeTitle.frame), CGRectGetMaxY(_diskTableView.frame) +8, 150, 40)];
        _diskTypeLabel.adjustsFontSizeToFitWidth = YES;
        _diskTypeLabel.text = @"未设置";
        _diskTypeLabel.textColor =  WarningDetailColor;
        _diskTypeLabel.font = [UIFont systemFontOfSize:14];
        //        _diskTypeTitle
    }
    return _diskTypeLabel;
}

- (UIButton *)firstStepButton{
    if (!_firstStepButton) {
        _firstStepButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepTitle.frame),CGRectGetMaxY(_diskTypeTitle.frame) +8, 86, 36)];
        [_firstStepButton setTitle:WBLocalizedString(@"next_step", nil) forState:UIControlStateNormal];
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
        _secondStepLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, 22, 22)];
        _secondStepLabel.layer.cornerRadius = 22/2;
        _secondStepLabel.layer.masksToBounds = YES;
        _secondStepLabel.textColor = [UIColor whiteColor];
        _secondStepLabel.text = @"2";
        _secondStepLabel.textAlignment = NSTextAlignmentCenter;
        _secondStepLabel.font = [UIFont systemFontOfSize:12];
        _secondStepLabel.backgroundColor = IgnoreColor;
    }
    return _secondStepLabel;
}

- (BEMCheckBox *)secondCheckBox{
    if (!_secondCheckBox) {
        _secondCheckBox = [[BEMCheckBox alloc]initWithFrame:CGRectMake(0, 3, 20, 20)];
        _secondCheckBox.onFillColor = COR1;
        _secondCheckBox.onTintColor = COR1;
        _secondCheckBox.onCheckColor = [UIColor whiteColor];
        [_secondCheckBox setOn:YES];
        [_secondCheckBox setHidden:YES];
    }
    return _secondCheckBox;
}

- (UIView *)secondStepIconView{
    if (!_secondStepIconView) {
        _secondStepIconView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.firstStepIconView.frame),CGRectGetMaxY(self.firstStepButton.frame)+ 24, 20, 28)];
        _secondStepIconView.backgroundColor = MainBackgroudColor;
        [_secondStepIconView addSubview:self.secondStepLabel];
        [_secondStepIconView addSubview:self.secondCheckBox];
    }
    return _secondStepIconView;
}

- (UILabel *)secondStepTitle{
    if (!_secondStepTitle) {
        _secondStepTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepTitle.frame), CGRectGetMinY(_secondStepIconView.frame),_firstStepTitle.jy_Width, 17)];
        _secondStepTitle.textColor = OriginTitleColor;
        _secondStepTitle.text = @"创建第一个用户";
        _secondStepTitle.font = [UIFont systemFontOfSize:16];
    }
    return _secondStepTitle;
}

- (UILabel *)secondStepDetailLabel{
    if (!_secondStepDetailLabel) {
        _secondStepDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_firstStepDetailLabel.frame), CGRectGetMaxY(_secondStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_secondStepTitle.frame) -32 , 30)];
        _secondStepDetailLabel.textColor = IgnoreColor;
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
        _userNameTextField.returnKeyType = UIReturnKeyNext;
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
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.delegate = self;
        _passwordTextField.returnKeyType = UIReturnKeyNext;
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
        _confirmPasswordTextField.secureTextEntry = YES;
        _confirmPasswordTextField.returnKeyType = UIReturnKeyDone;
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

- (MDCButton *)secondStepNextButton{
    if (!_secondStepNextButton) {
    _secondStepNextButton = [[MDCButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_secondStepTitle.frame),CGRectGetMaxY(_confirmPasswordTextField.frame) +28, 86, 36)];
    [_secondStepNextButton setTitle:WBLocalizedString(@"next_step", nil) forState:UIControlStateNormal];
    [_secondStepNextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _secondStepNextButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _secondStepNextButton.backgroundColor = COR1;
    _secondStepNextButton.layer.masksToBounds = YES;
    _secondStepNextButton.layer.cornerRadius = 2;
    //        _secondStepNextButton.contentVerticalAlignment = NSTextAlignmentCenter;
    [_secondStepNextButton addTarget:self action:@selector(secondStepNextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _secondStepNextButton.alpha = 0;
        
    }
    return _secondStepNextButton;
}

- (MDCButton *)secondPreviousButton{
    if (!_secondPreviousButton) {
        _secondPreviousButton = [[MDCButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_secondStepNextButton.frame) + 8,CGRectGetMaxY(_confirmPasswordTextField.frame) +28, 86, 36)];
        [_secondPreviousButton setTitle:WBLocalizedString(@"previous_step", nil) forState:UIControlStateNormal];
        _secondPreviousButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_secondPreviousButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _secondPreviousButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _secondPreviousButton.backgroundColor = [UIColor whiteColor];
        _secondPreviousButton.layer.masksToBounds = YES;
        _secondPreviousButton.layer.cornerRadius = 2;
        //        _secondPreviousButton.contentVerticalAlignment = NSTextAlignmentCenter;
        [_secondPreviousButton addTarget:self action:@selector(secondPreviousButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _secondPreviousButton.alpha = 0;
    }
    return _secondPreviousButton;
    
}

- (UILabel *)thirdStepLabel{
    if (!_thirdStepLabel) {
        _thirdStepLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, 22, 22)];
        _thirdStepLabel.layer.cornerRadius = 22/2;
        _thirdStepLabel.layer.masksToBounds = YES;
        _thirdStepLabel.textColor = [UIColor whiteColor];
        _thirdStepLabel.text = @"3";
        _thirdStepLabel.textAlignment = NSTextAlignmentCenter;
        _thirdStepLabel.font = [UIFont systemFontOfSize:12];
        _thirdStepLabel.backgroundColor = IgnoreColor;
    }
    return _thirdStepLabel;
}

- (UIView *)thirdStepIconView{
    if (!_thirdStepIconView) {
        _thirdStepIconView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.secondStepIconView.frame),CGRectGetMaxY(self.secondStepDetailLabel.frame)+ 24, 20, 28)];
        _thirdStepIconView.backgroundColor = MainBackgroudColor;
        [_thirdStepIconView addSubview:self.thirdStepLabel];
        [_thirdStepIconView addSubview:self.thirdCheckBox];
    }
    return _thirdStepIconView;
}

- (UILabel *)thirdStepTitle{
    if (!_thirdStepTitle) {
        _thirdStepTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_secondStepTitle.frame), CGRectGetMinY(_thirdStepIconView.frame),_secondStepTitle.jy_Width, 17)];
        _thirdStepTitle.textColor = OriginTitleColor;
        _thirdStepTitle.text = @"确认安装";
        _thirdStepTitle.font = [UIFont systemFontOfSize:16];
    }
    return _thirdStepTitle;
}

- (UITableView *)diskSelectedTableView{
    if (!_diskSelectedTableView) {
        _diskSelectedTableView = [[UITableView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMaxY(_thirdStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_thirdStepTitle.frame) - 56 ,56 *self.diskSelectedArray.count + 8) style:UITableViewStylePlain];
        _diskSelectedTableView.delegate = self;
        _diskSelectedTableView.dataSource = self;
        _diskSelectedTableView.backgroundColor = UICOLOR_RGB(0xfafafa);
        UIView *footBackgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 8)];
        UIView *footlineView  = [[UIView alloc]initWithFrame:CGRectMake(0, 7, __kWidth, 0.5)];
        footlineView.backgroundColor = RGBCOLOR(222, 222, 224);
        footBackgroudView.backgroundColor = UICOLOR_RGB(0xfafafa);
        [footBackgroudView addSubview:footlineView];
        _diskSelectedTableView.tableFooterView = footBackgroudView;
        _diskSelectedTableView.separatorStyle = UITableViewCellAccessoryNone;
        _diskSelectedTableView.bounces = NO;
        _diskSelectedTableView.alpha = 0;
    }
    return _diskSelectedTableView;
}

- (UILabel *)thirdUserNameLabel{
    if (!_thirdUserNameLabel) {
        _thirdUserNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMaxY(_diskSelectedTableView.frame) + 8, __kWidth - CGRectGetMinX(_thirdStepTitle.frame) - 16, 14)];
        _thirdUserNameLabel.textColor = IgnoreColor;
        _thirdUserNameLabel.font = [UIFont systemFontOfSize:12];
        _thirdUserNameLabel.alpha = 0;
    }
    return _thirdUserNameLabel;
}

- (UILabel *)thirdDiskTypeLabel{
    if (!_thirdDiskTypeLabel) {
        _thirdDiskTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMaxY(_thirdUserNameLabel.frame) + 8, __kWidth - CGRectGetMinX(_thirdStepTitle.frame) - 16, 14)];
        _thirdDiskTypeLabel.textColor = IgnoreColor;
        _thirdDiskTypeLabel.font = [UIFont systemFontOfSize:12];
        _thirdDiskTypeLabel.alpha = 0;
    }
    return _thirdDiskTypeLabel;
}

- (MDCButton *)thirdStepNextButton{
    if (!_thirdStepNextButton) {
        _thirdStepNextButton = [[MDCButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_thirdStepTitle.frame),CGRectGetMaxY(_thirdDiskTypeLabel.frame) +28, 86, 36)];
        [_thirdStepNextButton setTitle:@"创建" forState:UIControlStateNormal];
        [_thirdStepNextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _thirdStepNextButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _thirdStepNextButton.backgroundColor = COR1;
        _thirdStepNextButton.layer.masksToBounds = YES;
        _thirdStepNextButton.layer.cornerRadius = 2;
        //        _secondStepNextButton.contentVerticalAlignment = NSTextAlignmentCenter;
        [_thirdStepNextButton addTarget:self action:@selector(installButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _thirdStepNextButton.alpha = 0;
        
    }
    return _thirdStepNextButton;
}

- (MDCButton *)thirdPreviousButton{
    if (!_thirdPreviousButton) {
        _thirdPreviousButton = [[MDCButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_thirdStepNextButton.frame) + 8,CGRectGetMaxY(_thirdDiskTypeLabel.frame) +28, 86, 36)];
        [_thirdPreviousButton setTitle:WBLocalizedString(@"previous_step", nil) forState:UIControlStateNormal];
        _thirdPreviousButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_thirdPreviousButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _thirdPreviousButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _thirdPreviousButton.backgroundColor = [UIColor whiteColor];
        _thirdPreviousButton.layer.masksToBounds = YES;
        _thirdPreviousButton.layer.cornerRadius = 2;
        //        _secondPreviousButton.contentVerticalAlignment = NSTextAlignmentCenter;
        [_thirdPreviousButton addTarget:self action:@selector(thirdPreviousButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _thirdPreviousButton.alpha = 0;
    }
    return _thirdPreviousButton;
    
}

- (BEMCheckBox *)thirdCheckBox{
    if (!_thirdCheckBox) {
        _thirdCheckBox = [[BEMCheckBox alloc]initWithFrame:CGRectMake(0, 3, 20, 20)];
        _thirdCheckBox.onFillColor = COR1;
        _thirdCheckBox.onTintColor = COR1;
        _thirdCheckBox.onCheckColor = [UIColor whiteColor];
        [_thirdCheckBox setOn:YES];
        [_thirdCheckBox setHidden:YES];
    }
    return _thirdCheckBox;
}

- (UILabel *)fourthStepLabel{
    if (!_fourthStepLabel) {
        _fourthStepLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, 22, 22)];
        _fourthStepLabel.layer.cornerRadius = 22/2;
        _fourthStepLabel.layer.masksToBounds = YES;
        _fourthStepLabel.textColor = [UIColor whiteColor];
        _fourthStepLabel.text = @"4";
        _fourthStepLabel.textAlignment = NSTextAlignmentCenter;
        _fourthStepLabel.font = [UIFont systemFontOfSize:12];
        _fourthStepLabel.backgroundColor = IgnoreColor;
    }
    return _fourthStepLabel;
}

- (UIView *)fourthStepIconView{
    if (!_fourthStepIconView) {
        _fourthStepIconView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.thirdStepIconView.frame),CGRectGetMaxY(self.thirdStepTitle.frame)+ 24, 20, 28)];
        _fourthStepIconView.backgroundColor = MainBackgroudColor;
        [_fourthStepIconView addSubview:self.fourthStepLabel];
        [_fourthStepIconView addSubview:self.fourthCheckBox];
    }
    return _fourthStepIconView;
}

- (UILabel *)fourthStepTitle{
    if (!_fourthStepTitle) {
        _fourthStepTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_thirdStepTitle.frame), CGRectGetMinY(_fourthStepIconView.frame),_thirdStepTitle.jy_Width, 17)];
        _fourthStepTitle.textColor = OriginTitleColor;
        _fourthStepTitle.text = WBLocalizedString(@"bind_wechat_user", nil);
        _fourthStepTitle.font = [UIFont systemFontOfSize:16];
    }
    return _fourthStepTitle;
}

- (UILabel *)fourthStepDetailLabel{
    if (!_fourthStepDetailLabel) {
        _fourthStepDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_fourthStepTitle.frame), CGRectGetMaxY(_fourthStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_fourthStepTitle.frame) -32 , 30)];
        _fourthStepDetailLabel.textColor = WarningDetailColor;
        _fourthStepDetailLabel.numberOfLines = 0;
        //        _secondStepDetailLabel.adjustsFontSizeToFitWidth = YES;
        _fourthStepDetailLabel.font = [UIFont systemFontOfSize:12];
        _fourthStepDetailLabel.text = @"您可以选择现在绑定微信，成功绑定后就可以通过微信扫码，远程登录设备";
        _fourthStepDetailLabel.alpha = 0;
    }
    return _fourthStepDetailLabel;
}

- (BEMCheckBox *)fourthCheckBox{
    if (!_fourthCheckBox) {
        _fourthCheckBox = [[BEMCheckBox alloc]initWithFrame:CGRectMake(0, 3, 20, 20)];
        _fourthCheckBox.onFillColor = COR1;
        _fourthCheckBox.onTintColor = COR1;
        _fourthCheckBox.onCheckColor = [UIColor whiteColor];
        [_fourthCheckBox setOn:YES];
        [_fourthCheckBox setHidden:YES];
    }
    return _fourthCheckBox;
}


- (MDCButton *)fourthStepNextButton{
    if (!_fourthStepNextButton) {
        _fourthStepNextButton = [[MDCButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_fourthStepDetailLabel.frame),CGRectGetMaxY(_fourthStepDetailLabel.frame) +28, 86, 36)];
        [_fourthStepNextButton setTitle:@"绑定" forState:UIControlStateNormal];
        [_fourthStepNextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _fourthStepNextButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _fourthStepNextButton.backgroundColor = COR1;
        _fourthStepNextButton.layer.masksToBounds = YES;
        _fourthStepNextButton.layer.cornerRadius = 2;
        //        _fourthStepNextButton.contentVerticalAlignment = NSTextAlignmentCenter;
        [_fourthStepNextButton addTarget:self action:@selector(fourthStepNextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _fourthStepNextButton.alpha = 0;
        
    }
    return _fourthStepNextButton;
}

- (MDCButton *)fourthIgnoreButton{
    if (!_fourthIgnoreButton) {
        _fourthIgnoreButton = [[MDCButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_fourthStepNextButton.frame) + 8,CGRectGetMaxY(_fourthStepDetailLabel.frame) +28, 86, 36)];
        [_fourthIgnoreButton setTitle:@"忽略" forState:UIControlStateNormal];
        [_fourthIgnoreButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _fourthIgnoreButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _fourthIgnoreButton.backgroundColor = [UIColor whiteColor];
        _fourthIgnoreButton.layer.masksToBounds = YES;
        _fourthIgnoreButton.layer.cornerRadius = 2;
        //        _secondPreviousButton.contentVerticalAlignment = NSTextAlignmentCenter;
        [_fourthIgnoreButton addTarget:self action:@selector(fourthIgnoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _fourthIgnoreButton.alpha = 0;
    }
    return _fourthIgnoreButton;
}


- (UILabel *)fifthStepLabel{
    if (!_fifthStepLabel) {
        _fifthStepLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, 22, 22)];
        _fifthStepLabel.layer.cornerRadius = 22/2;
        _fifthStepLabel.layer.masksToBounds = YES;
        _fifthStepLabel.textColor = [UIColor whiteColor];
        _fifthStepLabel.text = @"5";
        _fifthStepLabel.textAlignment = NSTextAlignmentCenter;
        _fifthStepLabel.font = [UIFont systemFontOfSize:12];
        _fifthStepLabel.backgroundColor = IgnoreColor;
    }
    return _fifthStepLabel;
}

- (UIView *)fifthStepIconView{
    if (!_fifthStepIconView) {
        _fifthStepIconView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.fourthStepIconView.frame),CGRectGetMaxY(self.fourthStepTitle.frame)+ 24, 20, 28)];
        _fifthStepIconView.backgroundColor = MainBackgroudColor;
        [_fifthStepIconView addSubview:self.fifthStepLabel];
        _lineView.frame = CGRectMake(26, 14, 1,CGRectGetMaxY(self.fifthStepIconView.frame) -CGRectGetMinY(self.firstStepIconView.frame) - 6);
    }
    return _fifthStepIconView;
}

- (UILabel *)fifthStepTitle{
    if (!_fifthStepTitle) {
        _fifthStepTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_fourthStepTitle.frame), CGRectGetMinY(_fifthStepIconView.frame),_fourthStepTitle.jy_Width, 17)];
        _fifthStepTitle.textColor = OriginTitleColor;
        _fifthStepTitle.text = @"进入系统";
        _fifthStepTitle.font = [UIFont systemFontOfSize:16];
    }
    return _fifthStepTitle;
}

- (UILabel *)fifthStepDetailLabel{
    if (!_fifthStepDetailLabel) {
        _fifthStepDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_fifthStepTitle.frame), CGRectGetMaxY(_fifthStepTitle.frame) + 8,__kWidth - CGRectGetMinX(_fifthStepTitle.frame) -32 , 30)];
        _fifthStepDetailLabel.textColor = WarningDetailColor;
        _fifthStepDetailLabel.numberOfLines = 0;
        //        _secondStepDetailLabel.adjustsFontSizeToFitWidth = YES;
        _fifthStepDetailLabel.font = [UIFont systemFontOfSize:12];
        _fifthStepDetailLabel.text = @"您已成功创建了WISNUC系统";
        _fifthStepDetailLabel.alpha = 0;
    }
    return _fifthStepDetailLabel;
}


- (MDCButton *)fifthStepEnterButton{
    if (!_fifthStepEnterButton) {
        _fifthStepEnterButton = [[MDCButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_fifthStepDetailLabel.frame),CGRectGetMaxY(_fifthStepDetailLabel.frame) +28, 86, 36)];
        [_fifthStepEnterButton setTitle:@"进入" forState:UIControlStateNormal];
        [_fifthStepEnterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _fifthStepEnterButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _fifthStepEnterButton.backgroundColor = COR1;
        _fifthStepEnterButton.layer.masksToBounds = YES;
        _fifthStepEnterButton.layer.cornerRadius = 2;
        //        _fourthStepNextButton.contentVerticalAlignment = NSTextAlignmentCenter;
        [_fifthStepEnterButton addTarget:self action:@selector(fifthStepEnterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _fifthStepEnterButton.alpha = 0;
        
    }
    return _fifthStepEnterButton;
}

- (MDCButton *)fifthPreviousButton{
    if (!_fifthPreviousButton) {
        _fifthPreviousButton = [[MDCButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_fifthStepEnterButton.frame) + 8,CGRectGetMaxY(_fifthStepDetailLabel.frame) +28, 86, 36)];
        _fifthPreviousButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_fifthPreviousButton setTitle:WBLocalizedString(@"previous_step", nil) forState:UIControlStateNormal];
        _fifthPreviousButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_fifthPreviousButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _fifthPreviousButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _fifthPreviousButton.backgroundColor = [UIColor whiteColor];
        _fifthPreviousButton.layer.masksToBounds = YES;
        _fifthPreviousButton.layer.cornerRadius = 2;
        //        _secondPreviousButton.contentVerticalAlignment = NSTextAlignmentCenter;
        [_fifthPreviousButton addTarget:self action:@selector(fifthPreviousButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _fifthPreviousButton.alpha = 0;
    }
    return _fifthPreviousButton;
}

-  (NSDictionary *)loginDataDic{
    if (!_loginDataDic) {
        _loginDataDic = [[NSDictionary alloc]init];
    }
    return _loginDataDic;
}

- (void) tapDidTouch {
//    [self.view endEditing:YES];
    NSLog(@"touchesBegan");
    
    [self.view endEditing:YES];
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
    
    self.mainScrollView.frame = rect;
    
    [UIView commitAnimations];
}

@end

