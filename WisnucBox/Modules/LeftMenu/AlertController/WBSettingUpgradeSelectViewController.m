//
//  WBSettingUpgradeSelectViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/8.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBSettingUpgradeSelectViewController.h"

@interface WBSettingUpgradeSelectViewController ()
@property (weak, nonatomic) IBOutlet UILabel *alertTitleLabel;
@property (weak, nonatomic) IBOutlet RadioButton *trueRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *falseRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmRadioButton;

@end

@implementation WBSettingUpgradeSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_typeString isEqualToString:@"是"]) {
        [self.trueRadioButton setSelected:YES];
    }else if ([_typeString isEqualToString:@"否"]){
        [self.falseRadioButton setSelected:YES];
    }
}
- (IBAction)radioButtonClick:(RadioButton *)sender {
     _typeString = sender.titleLabel.text;
}

- (IBAction)confirmButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([_delegate respondsToSelector:@selector(confirmWithTypeString:)]) { // 如果协议响应了sendValue:方法
        
        NSLog(@"%@",_typeString);
        [_delegate confirmWithTypeString:_typeString]; // 通知执行协议方法
    }
}

@end
