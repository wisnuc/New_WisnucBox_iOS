//
//  WBPpgAskToUploadAlertViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBPpgAskToUploadAlertViewController.h"

@interface WBPpgAskToUploadAlertViewController ()<BEMCheckBoxDelegate>
@property (weak, nonatomic) IBOutlet RadioButton *creatDownloadRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *uploadRadioButton;
@property (weak, nonatomic) IBOutlet BEMCheckBox *alwaysCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (nonatomic,assign) BOOL isAlways;

@end

@implementation WBPpgAskToUploadAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.alwaysCheckBox.boxType = BEMBoxTypeSquare;
    self.alwaysCheckBox.onAnimationType = BEMAnimationTypeBounce;
    self.alwaysCheckBox.offAnimationType = BEMAnimationTypeBounce;
    self.alwaysCheckBox.onFillColor = COR1;
    self.alwaysCheckBox.onTintColor = COR1;
    self.alwaysCheckBox.onCheckColor = [UIColor whiteColor];
    self.alwaysCheckBox.delegate = self;
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox{
    if (checkBox.on) {
        _isAlways = YES;
    }else{
        _isAlways = NO;
    }
}
- (IBAction)radioButtonClick:(RadioButton *)sender {
    NSLog(@"%@",sender.titleLabel.text) ;
    _typeString = sender.titleLabel.text;
}

- (IBAction)confirmButtonClick:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([_delegate respondsToSelector:@selector(confirmWithTypeString:isAlways:)]) { // 如果协议响应了sendValue:方法
        
        if (!_typeString) {
            _typeString = _creatDownloadRadioButton.titleLabel.text;
        }
        NSLog(@"%@",_typeString);
        [_delegate confirmWithTypeString:_typeString isAlways:_isAlways]; // 通知执行协议方法
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
