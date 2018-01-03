//
//  WBStationEnterMaintanceConfirmAVC.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/3.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBStationEnterMaintanceConfirmAVC.h"
#import "AppDelegate.h"

@interface WBStationEnterMaintanceConfirmAVC ()

@end

@implementation WBStationEnterMaintanceConfirmAVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)logoutButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self logOutAction];
}


- (void)logOutAction{
    [SXLoadingView showProgressHUD:WBLocalizedString(@"logout...", nil)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self skipToLogin];
    });
}

-(void)skipToLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        MyAppDelegate.window.rootViewController = nil;
        [MyAppDelegate.window resignKeyWindow];
        [WB_UserService logoutUser];
        [WB_AppServices rebulid];
        for (UIView *view in MyAppDelegate.window.subviews) {
            [view removeFromSuperview];
        }
        //reload menu
        //        [self reloadWithTitles:LeftMenu_NotAdminTitles andImages:LeftMenu_NotAdminImages];
        
        FMLoginViewController * vc = [[FMLoginViewController alloc]init];
        NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
        MyAppDelegate.window.rootViewController = nav;
        [MyAppDelegate.window makeKeyAndVisible];
    });
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
