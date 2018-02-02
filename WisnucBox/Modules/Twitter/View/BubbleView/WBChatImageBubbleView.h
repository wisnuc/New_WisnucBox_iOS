//
//  WBChatImageBubbleView.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatBaseBubbleView.h"


@interface WBChatImageBubbleView : WBChatBaseBubbleView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *thumbnailRequestOperationArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSArray *localImageArray;
@property (nonatomic,strong) UIImageView * maskImageView;
@end
