//
//  FMUserSettingCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UserSettingCellStateNormal,
    UserSettingCellStateCanDel,
} FMUserSettingCellState;

@interface FMUserSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;
@property (weak, nonatomic) IBOutlet UILabel *roleLb;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *wxLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wxIconImageView;

@property (nonatomic) FMUserSettingCellState state;

@end
