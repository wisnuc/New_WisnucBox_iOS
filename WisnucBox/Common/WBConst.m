//
//  WBConst.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/17.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBConst.h"

//　图片最大显示大小
CGFloat const MAX_SIZE = 134.0f;

CGFloat const THREE_IMAGE_SIZE = 89.0f;

CGFloat const SEPARATE = 1.0f;


CGFloat const BOX_FILE_SIZE_WIDTH = 269.0f;

CGFloat const BOX_FILE_SIZE_HEIGHT = 56.0f;

CGFloat const kNavBarHeight = 64.0f;
CGFloat const kTabBarHeight = 44;
CGFloat const kChatBarHeight = 48.0f;

CGFloat const kYYkitWidth = 250.f;


NSString *const kMessageKey = @"kMessageKey";
NSString *const kMessageImageKey = @"kMessageImageKey";
NSString *const kShouldResendCell = @"kShouldResendCell";
NSString *const kRouterEventChatCellBubbleTapEventName = @"kRouterEventChatCellBubbleTapEventName";
NSString *const kRouterEventChatHeadImageTapEventName = @"kRouterEventChatHeadImageTapEventName";
NSString *const kRouterEventChatResendEventName = @"kRouterEventChatResendEventName";
NSString *const kRouterEventTextURLTapEventName = @"kRouterEventTextURLTapEventName";
NSString *const kRouterEventImageBubbleTapEventName = @"kRouterEventImageBubbleTapEventName";

NSString *const kDataChangedName = @"kDataChangedName";
NSString *const kMessageImageBoxUUID = @"kMessageImageBoxUUID";
NSString *const kMessageImageBoxLocalAsset = @"kMessageImageBoxLocalAsset";
NSString *const kMessageImageBoxNetImageHash = @"kMessageImageBoxNetImageHash";

NSInteger kMessageCount = 20;

NSString *const kBoxFileSelect = @"kBoxFileSelect";

#pragma mark - IM模块常量

// 头像大小
CGFloat const HEAD_SIZE = 40.0f;
// 头像到cell的内间距和头像到bubble的间距
CGFloat const HEAD_PADDING = 8.0f;
CGFloat const HEAD_X = 12.0f;
// Cell之间间距
CGFloat const CELLPADDING = 5.0f;

// nameLabel宽度
CGFloat const NAME_LABEL_WIDTH = 180.f;
// nameLabel 高度
CGFloat const NAME_LABEL_HEIGHT = 11.0f;
// nameLabel间距
CGFloat const NAME_LABEL_PADDING = 0.0f;
// 字体
CGFloat const NAME_LABEL_FONT_SIZE = 10.0f;



// bubbleView中，箭头的宽度
CGFloat const BUBBLE_ARROW_WIDTH = 6.0f;
// bubbleView 与 在其中的控件内边距
CGFloat const BUBBLE_VIEW_PADDING = 13.0f;

// 文字在右侧时,bubble用于拉伸点的X坐标
CGFloat const BUBBLE_RIGHT_LEFT_CAP_WIDTH = 15.0f;
// 文字在右侧时,bubble用于拉伸点的Y坐标
CGFloat const BUBBLE_RIGHT_TOP_CAP_HEIGHT = 18.0f;

// 文字在左侧时,bubble用于拉伸点的X坐标
CGFloat const BUBBLE_LEFT_LEFT_CAP_WIDTH = 18.0f;

// 文字在左侧时,bubble用于拉伸点的Y坐标
CGFloat const BUBBLE_LEFT_TOP_CAP_HEIGHT = 15.0f;

// progressView 高度
CGFloat const BUBBLE_PROGRESSVIEW_HEIGHT = 10;


@implementation WBConst

@end
