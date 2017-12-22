//
//  WBTorrentMagnetAlertViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBTorrentMagnetAlertViewController.h"


@interface WBTorrentMagnetAlertViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UITextView *magnetTextView;
@end

@implementation WBTorrentMagnetAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = WBLocalizedString(@"create_new_download_task", nil);
    [self.confirmButton setTitle:WBLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:WBLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    self.magnetTextView.backgroundColor = UICOLOR_RGB(0xfafafa);
    self.magnetTextView.layer.masksToBounds = YES;
    self.magnetTextView.layer.borderWidth = 1;
    self.magnetTextView.layer.borderColor = RGBACOLOR(0, 0, 0, 0.12f).CGColor;
    self.magnetTextView.layer.cornerRadius = 2;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)confirmButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(magnetDownload:)]) {
        [_delegate magnetDownload:_magnetTextView.text];
    }
}
- (IBAction)cancelButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)magnetPastButtonClick:(UIButton *)sender {
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSLog(@"%@",pasteboard.string);
    _magnetTextView.text = pasteboard.string;
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
