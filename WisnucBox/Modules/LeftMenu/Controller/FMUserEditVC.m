//
//  FMUserEditVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserEditVC.h"
#import "FMChangePwdVC.h"
#import "FMChangeNameVC.h"

@interface FMUserEditVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderImageView;

@property (weak, nonatomic) IBOutlet UIButton *headerEditBtn;
@property (weak, nonatomic) IBOutlet UIButton *userName;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@end

@implementation FMUserEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑用户信息";
    self.navigationController.navigationBar.translucent = NO;
    [self.userHeaderImageView setImage:[UIImage imageForName:WB_UserService.currentUser.userName size:self.userHeaderImageView.bounds.size]];
    [self.userName setTitle:WB_UserService.currentUser.userName forState:UIControlStateNormal];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.userHeaderImageView setImage:[UIImage imageForName:WB_UserService.currentUser.userName size:self.userHeaderImageView.bounds.size]];
    [self.userName setTitle:WB_UserService.currentUser.userName forState:UIControlStateNormal];
}

- (IBAction)changUserName:(id)sender {
    FMChangeNameVC * vc = [FMChangeNameVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)changePwdBtn:(id)sender {
    FMChangePwdVC * vc = [[FMChangePwdVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
}

- (IBAction)changeAvater:(id)sender {

}
@end
