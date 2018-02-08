//
//  WBChatViewBaseTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBChatBaseBubbleView.h"
#import "WBTweetModel.h"
#import "WBBoxesModel.h"
#import "WBChatTextBubbleView.h"
#import "WBChatImageBubbleView.h"
#import "WBChatFileBubbleView.h"

#import "LHChatAudioBubbleView.h"
#import "LHChatVideoBubbleView.h"
#import "LHChatLocationBubbleView.h"
@interface WBChatViewBaseTableViewCell : UITableViewCell{
    UIImageView *_headImageView;
    UILabel *_nameLabel;
    WBChatBaseBubbleView *_bubbleView;
}
@property (nonatomic, strong) UIImageView *headImageView;       //头像
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) WBChatBaseBubbleView *bubbleView;   //内容区域
@property (nonatomic, strong) WBTweetModel *messageModel;
@property (nonatomic, strong) WBBoxesModel *boxModel;
- (void)layout;
- (id)initWithMessageModel:(WBTweetModel *)model reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setupSubviewsForMessageModel:(WBTweetModel *)model;

+ (NSString *)cellIdentifierForMessageModel:(WBTweetModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(WBTweetModel *)model;
@end
