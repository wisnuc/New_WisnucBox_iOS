//
//  WBInitChangeDiskTypeAlertViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/18.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInitChangeDiskTypeAlertViewController.h"

@interface WBInitChangeDiskTypeAlertViewController ()

@property (nonatomic) NSInteger selectedTag;
@property (weak, nonatomic) IBOutlet RadioButton *raid1RadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *raid0RadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *singleRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation WBInitChangeDiskTypeAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_singleRadioButton setTag:0];
       [_raid0RadioButton setTag:1];
       [_raid1RadioButton setTag:2];
//    [self.singleRadioButton setImage:[UIImage imageNamed:@"ic_radio_button_unchecked"] forState:UIControlStateNormal];
//
//    [self.singleRadioButton setImage:[UIImage imageNamed:@"ic_radio_button"] forState:UIControlStateSelected];
//
//     [self.raid0RadioButton setImage:[UIImage imageNamed:@"ic_radio_button_unchecked"] forState:UIControlStateNormal];
//
//      [self.raid0RadioButton setImage:[UIImage imageNamed:@"ic_radio_button"] forState:UIControlStateSelected];
//
//     [self.raid1RadioButton setImage:[UIImage imageNamed:@"ic_radio_button_unchecked"] forState:UIControlStateNormal];
//
//    [self.raid1RadioButton setImage:[UIImage imageNamed:@"ic_radio_button"] forState:UIControlStateSelected];
//        _typeString = self.title ;
//        if ([_typeString isEqualToString:@"single模式"]) {
//            _singleRadioButton.selected = YES;
//            _raid0RadioButton.selected = NO;
//            _raid1RadioButton.selected = NO;
//        }else  if ([_typeString isEqualToString:@"raid0模式"]) {
//            _singleRadioButton.selected = NO;
//            _raid0RadioButton.selected = YES;
//            _raid1RadioButton.selected = NO;
//        }else  if ([_typeString isEqualToString:@"raid1模式"]) {
//            _singleRadioButton.selected = NO;
//            _raid0RadioButton.selected = NO;
//            _raid1RadioButton.selected = YES;
//        }
}
- (IBAction)dismissButtonClick:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)sureButtonClick:(UIButton *)sender {
    NSString * typeString;
    switch (_selectedTag) {
        case 0:
            typeString = WBLocalizedString(@"single_mode", nil);
            break;
        case 1:
            typeString = WBLocalizedString(@"raid0_mode", nil);;
            break;
        case 2:
            typeString = WBLocalizedString(@"raid1_mode", nil);;
            break;

        default:{
            typeString = WBLocalizedString(@"single_mode", nil);;
        }
            break;
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"diskTypeChange" object:typeString];
    
}
- (IBAction)radioButtonClick:(UIButton *)sender {
    NSLog(@"%ld",(long)sender.tag);
    _selectedTag = sender.tag;
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
