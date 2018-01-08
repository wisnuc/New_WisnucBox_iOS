//
//  WBUpgradeCheckViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/8.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBUpgradeCheckViewController.h"
#import "AppDelegate.h"
#import "WBUpgradeAppfiViewController.h"

@interface WBUpgradeCheckViewController ()<BEMCheckBoxDelegate>
@property (weak, nonatomic) IBOutlet UILabel *alertTitleLabel;
@property (weak, nonatomic) IBOutlet BEMCheckBox *ignoreCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *ignoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic,assign) BOOL isIgnore;

@end

@implementation WBUpgradeCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isIgnore = NO;
    self.ignoreCheckBox.boxType = BEMBoxTypeSquare;
    self.ignoreCheckBox.onAnimationType = BEMAnimationTypeBounce;
    self.ignoreCheckBox.offAnimationType = BEMAnimationTypeBounce;
    self.ignoreCheckBox.onFillColor = COR1;
    self.ignoreCheckBox.onTintColor = COR1;
    self.ignoreCheckBox.onCheckColor = [UIColor whiteColor];
    self.ignoreCheckBox.delegate = self;
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox{
    if (checkBox.on) {
        _isIgnore = YES;
    }else{
        _isIgnore = NO;
    }
}

- (IBAction)upgradeButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([_delegate respondsToSelector:@selector(confirmWithIsIgnore:)]) { // 如果协议响应了sendValue:方法
            [_delegate confirmWithIsIgnore:_isIgnore]; // 通知执行协议方法
        }
        
        CYLTabBarController * tVC = (CYLTabBarController *)MyAppDelegate.window.rootViewController;
        NavViewController * selectVC = (NavViewController *)tVC.selectedViewController;
        WBUpgradeAppfiViewController *upgradeViewController  = [[WBUpgradeAppfiViewController alloc]init];
        
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:upgradeViewController animated:YES];
        }
        
    }];
}

- (IBAction)cancelButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([_delegate respondsToSelector:@selector(confirmWithIsIgnore:)]) { // 如果协议响应了sendValue:方法
            [_delegate confirmWithIsIgnore:_isIgnore]; // 通知执行协议方法
        }
    }];
}


@end
