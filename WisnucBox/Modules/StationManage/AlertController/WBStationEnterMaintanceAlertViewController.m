//
//  WBStationEnterMaintanceAlertViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/3.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBStationEnterMaintanceAlertViewController.h"

@interface WBStationEnterMaintanceAlertViewController ()<MDCActivityIndicatorDelegate>
@property (weak, nonatomic) IBOutlet UIButton *outButton;
@property (weak, nonatomic) IBOutlet MDCActivityIndicator *activityIndicator;


@end

@implementation WBStationEnterMaintanceAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.activityIndicator.delegate = self;
    self.activityIndicator.cycleColors =@[COR1];
    self.activityIndicator.indicatorMode = MDCActivityIndicatorModeIndeterminate;
    [self.activityIndicator sizeToFit];
    [self.activityIndicator startAnimating];
}
- (IBAction)dismissButtonClick:(MDCButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)activityIndicatorAnimationDidFinish:(nonnull MDCActivityIndicator *)activityIndicator {
    return;
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
