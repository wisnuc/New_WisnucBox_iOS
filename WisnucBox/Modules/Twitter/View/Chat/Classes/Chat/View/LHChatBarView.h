//
//  LHChatInputView.h
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHChatBarMoreView.h"


@class LHContentModel;

@interface LHChatBarView : UIView

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) void(^sendContent)(LHContentModel *content);

- (void)hideKeyboard;
- (void)moreViewPhotoAction:(LHChatBarMoreView *)moreVie;
@end
