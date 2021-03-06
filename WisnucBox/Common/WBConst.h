//
//  WBConst.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/17.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGFloat const MAX_SIZE;

extern CGFloat const THREE_IMAGE_SIZE;

extern CGFloat const SEPARATE;

extern CGFloat const BOX_FILE_SIZE_WIDTH;

extern CGFloat const BOX_FILE_SIZE_HEIGHT;

extern CGFloat const kNavBarHeight;
extern CGFloat const kTabBarHeight;
extern CGFloat const kChatBarHeight;
extern CGFloat const kYYkitWidth;

extern NSString *const kMessageKey;
extern NSString *const kMessageImageKey;
extern NSString *const kShouldResendCell;
extern NSString *const kRouterEventChatResendEventName;
extern NSString *const kRouterEventChatCellBubbleTapEventName;
extern NSString *const kRouterEventChatHeadImageTapEventName;
extern NSString *const kRouterEventTextURLTapEventName;
extern NSString *const kRouterEventImageBubbleTapEventName;
extern NSString *const kRouterEventFileBubbleTapEventName;

extern NSString *const kDataChangedName;
extern NSString *const kMessageImageBoxUUID;
extern NSString *const kMessageImageBoxLocalAsset;
extern NSString *const kMessageImageBoxNetImageHash;
extern NSString *const kBoxFileSelect;
extern NSString *const kBoxMQTTFresh;

extern NSString *const kBoxUnread;
extern NSString *const kBoxChatListArchiverName;

extern NSInteger kMessageCount;

#pragma mark - IM模块常量
// 头像大小
extern CGFloat const HEAD_SIZE;
// 头像到cell的内间距和头像到bubble的间距
extern CGFloat const HEAD_PADDING;
// 头像x
extern CGFloat const HEAD_X;
// Cell之间间距
extern CGFloat const CELLPADDING;
// nameLabel宽度
extern CGFloat const NAME_LABEL_WIDTH;
// nameLabel 高度
extern CGFloat const NAME_LABEL_HEIGHT;
// nameLabel间距
extern CGFloat const NAME_LABEL_PADDING;
// 字体
extern CGFloat const NAME_LABEL_FONT_SIZE;
// bubbleView中，箭头的宽度
extern CGFloat const BUBBLE_ARROW_WIDTH;
// bubbleView 与 在其中的控件内边距
extern CGFloat const BUBBLE_VIEW_PADDING;
// 文字在右侧时,bubble用于拉伸点的X坐标
extern CGFloat const BUBBLE_RIGHT_LEFT_CAP_WIDTH;
// 文字在右侧时,bubble用于拉伸点的Y坐标
extern CGFloat const BUBBLE_RIGHT_TOP_CAP_HEIGHT;
// 文字在左侧时,bubble用于拉伸点的X坐标
extern CGFloat const BUBBLE_LEFT_LEFT_CAP_WIDTH;
// 文字在左侧时,bubble用于拉伸点的Y坐标
extern CGFloat const BUBBLE_LEFT_TOP_CAP_HEIGHT;
// progressView 高度
extern CGFloat const BUBBLE_PROGRESSVIEW_HEIGHT;
@interface WBConst : NSObject

@end
