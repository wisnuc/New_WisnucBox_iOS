//
//  FMSetting.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    TorrentTypeAskAllTime = 0,
    TorrentTypeCreatNewTask,
    TorrentTypeUpload
    
} TorrentType;

@interface FMSetting : FABaseVC
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
- (instancetype)initPrivate;
@end
