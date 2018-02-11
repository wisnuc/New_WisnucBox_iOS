//
//  WBChatFileBubbleView.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/25.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatFileBubbleView.h"

@implementation WBChatFileBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.shareTextLable];
        [self addSubview:self.shareFileImageView];
        [self addSubview:self.sizeLabel];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor whiteColor];
    CGRect frame = self.bounds;
    CGRect imageViewFrame = self.bounds;
    imageViewFrame.size.width = 56 ;
//    frame = CGRectInset(frame, 2, 2);
//    if (self.messageModel.isSender) {
//        frame.origin.x = 2;
//    } else {
//        frame.origin.x = 2 + BUBBLE_ARROW_WIDTH;
//    }
    
//    frame.origin.y = 2;
    [self.shareFileImageView setFrame:imageViewFrame];
    UIImage *image = [UIImage imageNamed:@"folder_icon"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.center = self.shareFileImageView.center;
    imageView.image = image;
    
    [self.shareFileImageView addSubview:imageView];
    CGRect shareLabelFrame = frame;
    shareLabelFrame.origin.x = CGRectGetMaxX(imageViewFrame) + 8;
    shareLabelFrame.origin.y = 8;
    shareLabelFrame.size.width = frame.size.width - imageViewFrame.size.width - 10;
    shareLabelFrame.size.height = 15;
   [self.shareTextLable setFrame:shareLabelFrame];
//   [self.shareTextLable sizeToFit];
    
    CGRect sizeLabelFrame = shareLabelFrame;
    sizeLabelFrame.origin.y = shareLabelFrame.origin.y + shareLabelFrame.size.height + 8;
    [self.sizeLabel setFrame:sizeLabelFrame];
}


- (void)setMessageModel:(WBTweetModel *)messageModel{
    [super setMessageModel:messageModel];
    WBTweetlistModel *listModel = [messageModel.list firstObject];
    NSString *labelTextString = [NSString stringWithFormat:@"分享“%@”等%ld个文件",listModel.filename,messageModel.list.count];
    self.shareTextLable.text = labelTextString;
    [self otherColorLabel:self.shareTextLable Range:NSMakeRange(3, listModel.filename.length) Color:COR1];
    __block long long pulsSize = 0;
    [messageModel.list enumerateObjectsUsingBlock:^(WBTweetlistModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        pulsSize += [obj.size longLongValue];
    }];
    NSString *sizeLabelString = [NSString transformedValue:[NSNumber numberWithLongLong:pulsSize]];
    self.sizeLabel.text = sizeLabelString;
}

-(void)otherColorLabel:(UILabel *)label Range:(NSRange)range Color:(UIColor *)color
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    
    
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    label.attributedText = str;
}

- (CGSize)sizeThatFits:(CGSize)size {
//    CGSize retSize = CGSizeMake(self.messageModel.width, self.messageModel.height);//self.messageModel.size;
//    if (retSize.width == 0 || retSize.height == 0) {
//        retSize.width = BOX_FILE_SIZE_WIDTH;
//        retSize.height = BOX_FILE_SIZE_HEIGHT;
//    }
//    if (retSize.width > retSize.height) {
//        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
//        retSize.height = height;
//        retSize.width = MAX_SIZE;
//    } else {
//        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
//        retSize.width = width;
//        retSize.height = MAX_SIZE;
//    }
//
////    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 1 + BUBBLE_ARROW_WIDTH, 1 * BUBBLE_VIEW_PADDING + retSize.height);
//
////     return CGSizeMake(269, 56);
//    NSLog(@"%@",NSStringFromCGSize(retSize));
    return CGSizeMake(BOX_FILE_SIZE_WIDTH,BOX_FILE_SIZE_HEIGHT);
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventFileBubbleTapEventName userInfo:@{kMessageKey : self.messageModel}];
}


#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(WBTweetModel *)object {
    CGSize retSize = CGSizeMake(BOX_FILE_SIZE_WIDTH, BOX_FILE_SIZE_HEIGHT);//object.size;
//    if (retSize.width == 0 || retSize.height == 0) {
//        retSize.width = BOX_FILE_SIZE_WIDTH ;
//        retSize.height = BOX_FILE_SIZE_HEIGHT;
//    } else if (retSize.width > retSize.height) {
//        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
//        retSize.height = height;
//        retSize.width = MAX_SIZE;
//    } else {
//        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
//        retSize.width = width;
//        retSize.height = MAX_SIZE;
//    }
    return 2 * BUBBLE_VIEW_PADDING + retSize.height + 20;
}

- (UILabel *)shareTextLable{
    if (!_shareTextLable) {
        _shareTextLable = [[UILabel alloc]init];
        _shareTextLable.font = [UIFont systemFontOfSize:14];
        _shareTextLable.textAlignment = NSTextAlignmentLeft;
        _shareTextLable.textColor = kTitleTextColor;
//        _shareTextLable.numberOfLines = 0;
//        _shareTextLable.backgroundColor = [UIColor cyanColor];
    }
    return _shareTextLable;
}

- (UIImageView *)shareFileImageView{
        if (!_shareFileImageView) {
              _shareFileImageView = [[UIImageView alloc] init];
       
            _shareFileImageView.backgroundColor = [UIColor orangeColor];
        }
        return _shareFileImageView;
}

- (UILabel *)sizeLabel{
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc]init];
        _sizeLabel.textColor = kDetailTextColor;
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _sizeLabel;
}
@end
