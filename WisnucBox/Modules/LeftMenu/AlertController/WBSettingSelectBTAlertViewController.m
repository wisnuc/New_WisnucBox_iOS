//
//  WBSettingSelectBTAlertViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBSettingSelectBTAlertViewController.h"
#import "FMSetting.h"

@interface WBSettingSelectBTAlertViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet RadioButton *askAllTimeRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *creatNewTaskRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *uploadRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;


@end

@implementation WBSettingSelectBTAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_typeString isEqualToString:[NSString stringWithFormat:@"%d", TorrentTypeCreatNewTask]]) {
        [self.creatNewTaskRadioButton setSelected:YES];
    }else if ([_typeString isEqualToString:[NSString stringWithFormat:@"%d", TorrentTypeUpload]]){
          [self.uploadRadioButton setSelected:YES];
    }else{
          [self.askAllTimeRadioButton setSelected:YES];
    }
    // Do any additional setup after loading the view.
}
- (IBAction)confirmButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([_delegate respondsToSelector:@selector(confirmWithTypeString:)]) { // 如果协议响应了sendValue:方法
        
        NSLog(@"%@",_typeString);
        [_delegate confirmWithTypeString:_typeString]; // 通知执行协议方法
    }
}
- (IBAction)radioButtonClick:(RadioButton *)sender {
    _typeString = sender.titleLabel.text;
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
