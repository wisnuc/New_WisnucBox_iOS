//
//  WBInitChangeDiskTypeAlertViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/18.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInitChangeDiskTypeAlertViewController.h"

@interface WBInitChangeDiskTypeAlertViewController ()
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@end

@implementation WBInitChangeDiskTypeAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)dismissButtonClick:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)sureButtonClick:(UIButton *)sender {
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
