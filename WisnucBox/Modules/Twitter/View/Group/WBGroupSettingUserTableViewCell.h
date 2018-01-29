//
//  WBGroupSettingUserTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/19.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupUserModel.h"
@class WBGroupSettingUserTableViewCell;
typedef void(^ImageClickBlock)(NSInteger iamgeTag);
typedef void(^AddUserClickBlock)(WBGroupSettingUserTableViewCell *groupSettingUsercell);
typedef void(^RemoveUserClickBlock)(WBGroupSettingUserTableViewCell *groupSettingUsercell);

@interface WBGroupSettingUserTableViewCell : UITableViewCell
@property (nonatomic) UIImageView *userImageView;
@property (nonatomic) UIButton *addButton;
@property (nonatomic) UIButton *clearButton;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *moreUserLabel;
@property (nonatomic) NSMutableArray *userArray;
@property (nonatomic) ImageClickBlock clickBlock;
@property (nonatomic) AddUserClickBlock  addUserClickBlock;
@property (nonatomic) RemoveUserClickBlock  removeUserClickBlock;
@end
