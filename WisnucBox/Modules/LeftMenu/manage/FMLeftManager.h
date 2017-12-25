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


#define LeftMenu_NotAdminTitles [NSMutableArray arrayWithObjects:LeftMenuTransmissionManageString,LeftMenuTorrentDownloadManageString,LeftMenuSettingString,nil]
#define LeftMenu_NotAdminImages [NSMutableArray arrayWithObjects:@"upload_download",@"bt_download",@"set",nil]

#define LeftMenu_AdminTitles [NSMutableArray arrayWithObjects:LeftMenuTransmissionManageString,LeftMenuEquipmentManageString,LeftMenuTorrentDownloadManageString,LeftMenuSettingString,nil]
#define LeftMenu_AdminImages [NSMutableArray arrayWithObjects:@"upload_download",@"ic_dns_black",@"bt_download",@"set",nil]

#define LeftMenu_AdminBindWechetTitles [NSMutableArray arrayWithObjects:LeftMenuTransmissionManageString,LeftMenuEquipmentManageString,LeftMenuTorrentDownloadManageString,LeftMenuInvitationString,LeftMenuSettingString,nil]
#define LeftMenu_AdminBindWechetImages [NSMutableArray arrayWithObjects:@"upload_download",@"ic_dns_black",@"bt_download",@"weChat_add",@"set",nil]

@interface FMLeftManager : NSObject

@property (nonatomic) MenuView * menu;

@property (nonatomic) FMLeftMenu *leftMenu;



- (instancetype)initLeftMenuWithTitles:(NSArray *)titles andImages:(NSArray *)imageNames;

- (void)reloadWithTitles:(NSArray *)titles andImages:(NSArray *)imageNames;

@end
