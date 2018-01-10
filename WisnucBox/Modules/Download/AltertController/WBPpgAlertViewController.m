//
//  WBPpgAlertViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBPpgAlertViewController.h"


@interface WBPpgAlertViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation WBPpgAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = WBLocalizedString(@"create_new_download_task", nil);
    [self.confirmButton setTitle:WBLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:WBLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    self.textView.backgroundColor = UICOLOR_RGB(0xfafafa);
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = RGBACOLOR(0, 0, 0, 0.12f).CGColor;
    self.textView.layer.cornerRadius = 2;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)confirmButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(Ppgdownload:)]) {
        [_delegate Ppgdownload:_textView.text];
    }
}
- (IBAction)cancelButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)magnetPastButtonClick:(UIButton *)sender {
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSLog(@"%@",pasteboard.string);
    _textView.text = pasteboard.string;
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
