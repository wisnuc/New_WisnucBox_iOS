//
//  WBStationManageRenameViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageRenameViewController.h"
#import "WBReNameAPI.h"

@interface WBStationManageRenameViewController ()

@end

@implementation WBStationManageRenameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WBLocalizedString(@"modify_equipment_label", nil);
    self.renameTextField.text = _stationName;
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andHighlightButtonImage:nil andSEL:@selector(backbtnClick:)];
    UIButton * rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 24)];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitle:WBLocalizedString(@"finish_text", nil) forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setEnlargeEdgeWithTop:5 right:10 bottom:5 left:5];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UICOLOR_RGB(0x03a9f4)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkTextColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonClick:(UIButton *)sender{
    [self patchToReName];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
}

- (void)patchToReName{
    if (![_renameTextField.text isEqualToString:_stationName]) {
        [SXLoadingView showProgressHUDText:@"loading..." duration:1.2];
        WBReNameAPI *api = [WBReNameAPI apiWithName:_renameTextField.text];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.responseJsonObject);
            if (self.delegate && [self.delegate respondsToSelector:@selector(reNameComplete)]) {
                [self.delegate reNameComplete];
            }
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
