//
//  FMLeftManager.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/9.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMLeftMenu.h"
#import "FMLoginViewController.h"
#import "MenuView.h"

//#define LeftMenu_NotAdminTitles [NSMutableArray arrayWithObjects:@"文件下载",@"设置",@"注销",nil]
//#define LeftMenu_NotAdminImages [NSMutableArray arrayWithObjects:@"storage",@"set",@"cancel",nil]
//
//#define LeftMenu_AdminTitles [NSMutableArray arrayWithObjects:@"文件下载",@"用户管理",@"设置",@"注销",nil]
//#define LeftMenu_AdminImages [NSMutableArray arrayWithObjects:@"storage",@"person_add",@"set",@"cancel",nil]

//
#define LeftMenu_NotAdminTitles [NSMutableArray arrayWithObjects:@"传输管理",@"设置",@"注销",nil]
#define LeftMenu_NotAdminImages [NSMutableArray arrayWithObjects:@"upload_download",@"ic_dns_black",@"set",@"cancel",nil]

#define LeftMenu_AdminTitles [NSMutableArray arrayWithObjects:@"传输管理",@"设备管理",@"设置",@"注销",nil]
#define LeftMenu_AdminImages [NSMutableArray arrayWithObjects:@"upload_download",@"ic_dns_black",@"set",@"cancel",nil]

#define LeftMenu_AdminBindWechetTitles [NSMutableArray arrayWithObjects:@"传输管理",@"设备管理",@"邀请微信好友",@"设置",@"注销",nil]
#define LeftMenu_AdminBindWechetImages [NSMutableArray arrayWithObjects:@"upload_download",@"ic_dns_black",@"weChat_add",@"set",@"cancel",nil]

@interface FMLeftManager : NSObject

@property (nonatomic) MenuView * menu;

@property (nonatomic) FMLeftMenu *leftMenu;



- (instancetype)initLeftMenuWithTitles:(NSArray *)titles andImages:(NSArray *)imageNames;

- (void)reloadWithTitles:(NSArray *)titles andImages:(NSArray *)imageNames;

@end
