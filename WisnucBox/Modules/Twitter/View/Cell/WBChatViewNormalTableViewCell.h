//
//  WBChatViewNormalTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBChatViewBaseTableViewCell.h"
@class WBChatViewNormalTableViewCell;
typedef void(^ReloadCellBlock)(WBChatViewNormalTableViewCell *cell);

@interface WBChatViewNormalTableViewCell : WBChatViewBaseTableViewCell <RefreshDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *activtiy;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic)ReloadCellBlock reloadCellBlock;
@end
