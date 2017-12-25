//
//  WBSettingSelectRolesViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/25.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBSettingSelectRolesViewController.h"

@interface WBSettingSelectRolesViewController ()
@property (weak, nonatomic) IBOutlet RadioButton *adminRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *normalRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation WBSettingSelectRolesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_adminRadioButton setTitle:WBLocalizedString(@"administrator", nil) forState:UIControlStateNormal];
    [_normalRadioButton setTitle:WBLocalizedString(@"general_user", nil) forState:UIControlStateNormal];
    if ([_typeString containsString:WBLocalizedString(@"administrator", nil)]) {
        [_adminRadioButton setSelected:YES];
    }else{
        [_normalRadioButton setSelected:YES];
    }
}

- (IBAction)radioButtonClick:(RadioButton *)sender {
   _typeString = sender.titleLabel.text;
}
- (IBAction)confirmButtonClick:(UIButton *)sender {
    if (_delegate &&[_delegate respondsToSelector:@selector(confirmWithTypeString:)]) {
        [_delegate confirmWithTypeString:_typeString];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
