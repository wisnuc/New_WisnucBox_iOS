//
//  FMHandLoginVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMHandLoginVC.h"
#import "DGPopUpViewTextView.h"
//#import "NavViewController.h"
//#import "FMShareViewController.h"
//#import "FMAlbumsViewController.h"
//#import "FMPhotosViewController.h"
//#import "FMSlideMenuControllerViewController.h"
//#import "FMSlideMenuController.h"
//#import "TabBarViewController.h"

//#import "RDVTabBarItem.h"
//#import "FMGetJWTAPI.h"

@interface FMHandLoginVC ()

@property (nonatomic, strong) DGPopUpViewTextView *textView;
@property (nonatomic, strong) DGPopUpViewTextView *textView_2;
@property (nonatomic, strong) DGPopUpViewTextView *textView_3;
@property (nonatomic) RACSubject *signal;





@property (nonatomic) UILabel * Lb1;
@property (nonatomic) UILabel * Lb2;
@property (nonatomic) UILabel * Lb3;

@end

@implementation FMHandLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = WBLocalizedString(@"manual_setting", nil);
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(handlerTap)];
    [self.view addGestureRecognizer:tap];
    [self initView];
    [self addNavBtn];
   _signal  = [RACSubject subject];
}

-(BOOL)checkIPIsValidate{
    NSString * pre = @"[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}";
    NSPredicate * check = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pre];
    return [check evaluateWithObject:self.textView.textField.text];
}

-(void)addNavBtn{
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem =   nil;
//    self.navigationItem.leftItemsSupplementBackButton = YES;
    //左按钮
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    [leftBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];//设置按钮点击事件
    
    
    [leftBtn setImage:[UIImage imageNamed:@"back_gray"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"back_grayhighlight"] forState:UIControlStateHighlighted];
     [leftBtn setEnlargeEdgeWithTop:5 right:5 bottom:5 left:10];
    //设置按钮正常状态图片
    UIBarButtonItem *leftBarButon = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
 
    self.navigationItem.leftBarButtonItem = leftBarButon;
    UIButton * rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    rBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rBtn setEnlargeEdgeWithTop:5 right:10 bottom:5 left:5];
    [rBtn setTitleColor:COR1 forState:UIControlStateNormal];
    [rBtn setTitle:WBLocalizedString(@"finish_text", nil) forState:UIControlStateNormal];
    [rBtn addTarget:self action:@selector(rBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)backBtnClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rBtnClick{
    if(![self checkIPIsValidate]){
        [SXLoadingView showAlertHUD:WBLocalizedString(@"IP_error", nil) duration:1];
        return;
    }
    if (self.block) {
        @weaky(self);
        FMSerachService * ser = [[FMSerachService alloc]init];
        ser.path = [NSString stringWithFormat:@"http://%@:3000/",self.textView.textField.text];
        [ser getData];
         weak_self.block(ser);
    }
    self.block = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)handlerTap{
    [self.view endEditing:YES];
}

- (void)initView{
   
    self.textView = [[DGPopUpViewTextView alloc] initWithName:@"IP" andPlaceHolder:WBLocalizedString(@"eneter_IP", nil)];
//    self.textView_2 = [[DGPopUpViewTextView alloc] initWithName:@"Username" andPlaceHolder: @"用户名"];
//    self.textView_3 = [[DGPopUpViewTextView alloc] initWithName:@"Password" andPlaceHolder:@"密码"];
//    self.textView_3.textField.secureTextEntry = YES;

    [self.view addSubview: self.textView];
//    [self.view addSubview: self.textView_2];
//    [self.view addSubview: self.textView_3];
    
    [self setlayout];
   
}
- (void) setlayout {
    
    self.textView.frame = CGRectMake((__kWidth- 300)/2, 64+60, 300, 60);
//    self.textView_2.frame = CGRectMake((__kWidth- 300)/2, 140, 300, 60);
//    self.textView_3.frame = CGRectMake((__kWidth- 300)/2, 220, 300, 60);
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
      [self.navigationController setNavigationBarHidden:YES animated:YES];
}
@end
