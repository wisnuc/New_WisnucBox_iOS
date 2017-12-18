//
//  WBInitChangeDiskTypeAlertViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/18.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInitChangeDiskTypeAlertViewController.h"

@interface WBInitChangeDiskTypeAlertViewController ()
/**
 * 是否点击
 */
@property (nonatomic ,assign) BOOL selected;
@property (weak, nonatomic) IBOutlet UIButton *raid1RadioButton;
@property (weak, nonatomic) IBOutlet UIButton *raid0RadioButton;
@property (weak, nonatomic) IBOutlet UIButton *singleRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@end

@implementation WBInitChangeDiskTypeAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.singleRadioButton setImage:[UIImage imageNamed:@"ic_radio_button_unchecked"] forState:UIControlStateNormal];
    
    [self.singleRadioButton setImage:[UIImage imageNamed:@"ic_radio_button"] forState:UIControlStateSelected];
    
     [self.raid0RadioButton setImage:[UIImage imageNamed:@"ic_radio_button_unchecked"] forState:UIControlStateNormal];
    
      [self.raid0RadioButton setImage:[UIImage imageNamed:@"ic_radio_button"] forState:UIControlStateSelected];
    
     [self.raid1RadioButton setImage:[UIImage imageNamed:@"ic_radio_button_unchecked"] forState:UIControlStateNormal];
    
    [self.raid1RadioButton setImage:[UIImage imageNamed:@"ic_radio_button"] forState:UIControlStateSelected];
        _typeString = self.title ;
        if ([_typeString isEqualToString:@"single模式"]) {
            _singleRadioButton.selected = YES;
            _raid0RadioButton.selected = NO;
            _raid1RadioButton.selected = NO;
        }else  if ([_typeString isEqualToString:@"raid0模式"]) {
            _singleRadioButton.selected = NO;
            _raid0RadioButton.selected = YES;
            _raid1RadioButton.selected = NO;
        }else  if ([_typeString isEqualToString:@"raid1模式"]) {
            _singleRadioButton.selected = NO;
            _raid0RadioButton.selected = NO;
            _raid1RadioButton.selected = YES;
        }
}
- (IBAction)dismissButtonClick:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)sureButtonClick:(UIButton *)sender {
    
}
- (IBAction)singleRadioButtonClick:(UIButton *)sender {
    _selected = !_selected;
    if(_selected) {
        NSLog(@"选中");
    }else {
        NSLog(@"取消选中");
    }
}
- (IBAction)raid0RadioButtonClick:(UIButton *)sender {
    _selected = !_selected;
    if(_selected) {
        NSLog(@"选中");
    }else {
        NSLog(@"取消选中");
    }
}
- (IBAction)raid1RadioButtonClick:(UIButton *)sender {
    _selected = !_selected;
    if(_selected) {
        NSLog(@"选中");
    }else {
        NSLog(@"取消选中");
    }
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
