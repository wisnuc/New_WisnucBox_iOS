//
//  WBStationManageRenameViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageRenameViewController.h"
#import "WBReNameAPI.h"
#import "WBUpdateBoxAPI.h"

@interface WBStationManageRenameViewController ()

@end

@implementation WBStationManageRenameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitleText];
   
    self.renameTextField.text = _stationName;
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
    [self.navigationController.navigationBar setBarTintColor:COR1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)setTitleText{
    switch (_vcType) {
        case WBRenameVCTypeStationName:
             self.title = WBLocalizedString(@"modify_equipment_label", nil);
            break;
        case WBRenameVCTypeBoxName:
            self.title = @"修改群名称";
            break;
            
        default:
            break;
    }
    
}

- (void)backbtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonClick:(UIButton *)sender{
    switch (_vcType) {
        case WBRenameVCTypeStationName:{
            [self patchToReName];
        }
            break;
        case WBRenameVCTypeBoxName:{
            [self renameForBoxName];
        }
            break;
            
        default:
            break;
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
}

- (void)renameForBoxName{
   if (![_renameTextField.text isEqualToString:_stationName]) {
    
       if (_renameTextField.text.length == 0 ||_boxuuid.length == 0 ) {
           return;
       }
       [[WBUpdateBoxAPI updateApiWithBoxName:_renameTextField.text Boxuuid:_boxuuid]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
           if (self.delegate && [self.delegate respondsToSelector:@selector(reNameComplete)]) {
               [self.delegate reNameComplete];
               [SXLoadingView showProgressHUDText:@"修改成功" duration:1.2f];
           }
       } failure:^(__kindof JYBaseRequest *request) {
           NSLog(@"%@",request.error);
             [SXLoadingView showProgressHUDText:@"修改失败" duration:1.2f];
       }] ;
   }
}

- (void)patchToReName{
    if (![_renameTextField.text isEqualToString:_stationName]) {
//        [SXLoadingView showProgressHUDText:WBLocalizedString(@"loading...", nil)  duration:1.2];
        WBReNameAPI *api = [WBReNameAPI apiWithName:_renameTextField.text];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.responseJsonObject);
            if (self.delegate && [self.delegate respondsToSelector:@selector(reNameComplete)]) {
                [self.delegate reNameComplete];
            }
              [SXLoadingView showProgressHUDText:@"修改成功" duration:1.2f];
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
              [SXLoadingView showProgressHUDText:@"修改失败" duration:1.2f];
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


@end
