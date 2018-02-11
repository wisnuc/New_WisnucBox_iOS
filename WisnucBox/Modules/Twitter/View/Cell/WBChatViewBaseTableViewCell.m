//
//  WBChatViewBaseTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatViewBaseTableViewCell.h"

@implementation WBChatViewBaseTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = _headImageView.frame;
    frame.origin.x = _messageModel.isSender ? (self.bounds.size.width - _headImageView.frame.size.width - HEAD_X) : HEAD_X;
    _headImageView.frame = frame;
    
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 8, CGRectGetMinY(_headImageView.frame), NAME_LABEL_WIDTH, NAME_LABEL_HEIGHT);
}
- (void)layout{
    
}

- (void)setBoxModel:(WBBoxesModel *)boxModel{
    _boxModel = boxModel;
}

- (void)setMessageModel:(WBTweetModel *)messageModel {
    _messageModel = messageModel;
    _nameLabel.hidden = messageModel.isSender;
    

    NSString *imgaeName = nil;
    if (_messageModel.isSender) {
        imgaeName = @"";
        self.headImageView.image = [UIImage imageNamed:imgaeName];
    } else {
        if (messageModel) {
            [_boxModel.users enumerateObjectsUsingBlock:^(WBBoxesUsersModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([messageModel.tweeter.tweeterId isEqualToString:obj.userId]) {
                    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:obj.avatarUrl] placeholderImage:[UIImage imageForName:obj.nickName size:self.headImageView.size]];
                    _nameLabel.text = obj.nickName;
                }
            }];
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];

}

#pragma mark - 事件监听
- (void)headImagePressed:(id)sender {
    [super routerEventWithName:kRouterEventChatHeadImageTapEventName userInfo:@{kMessageKey : self.messageModel}];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    [super routerEventWithName:eventName userInfo:userInfo];
}

#pragma mark - public
- (id)initWithMessageModel:(WBTweetModel *)model reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePressed:)];
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HEAD_X, 0, HEAD_SIZE, HEAD_SIZE)];
     
        [_headImageView addGestureRecognizer:tap];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.multipleTouchEnabled = YES;
        _headImageView.backgroundColor = [UIColor lh_colorWithHex:0xeeeff3];
    
        [self.contentView addSubview:_headImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont boldSystemFontOfSize:NAME_LABEL_FONT_SIZE];
        [self.contentView addSubview:_nameLabel];
        
        [self setupSubviewsForMessageModel:model];
    }
    return self;
}

- (void)setupSubviewsForMessageModel:(WBTweetModel *)model {
    if (model.isSender) {
        self.headImageView.frame = CGRectMake(self.bounds.size.width - 4 - HEAD_PADDING, CELLPADDING, 4, 4);
        self.headImageView.backgroundColor = [UIColor redColor];
    } else {
        self.headImageView.frame = CGRectMake(0, CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
}

+ (NSString *)cellIdentifierForMessageModel:(WBTweetModel *)model {
    NSString *identifier = @"MessageCell";
    if (model.isSender) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    } else {
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    switch (model.messageBodytype) {
        case MessageBodyType_Text: {
            identifier = [identifier stringByAppendingString:@"Text"];
            break;
        }
        case MessageBodyType_Image: {
            NSString *string = [NSString stringWithFormat:@"Image_%lld",model.ctime];
            identifier = [identifier stringByAppendingString:string];
            break;
        }
        case MessageBodyType_Video: {
            identifier = [identifier stringByAppendingString:@"Audio"];
            break;
        }
        case MessageBodyType_Location: {
            identifier = [identifier stringByAppendingString:@"Location"];
            break;
        }
        case MessageBodyType_Voice: {
            identifier = [identifier stringByAppendingString:@"Video"];
            break;
        }
        case MessageBodyType_File: {
            identifier = [identifier stringByAppendingString:@"File"];
            break;
        }
            
        default:
            break;
    }
    
    return identifier;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(WBTweetModel *)model {
    return HEAD_SIZE + CELLPADDING;
}

@end
