//
//  WBTweetModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"
#import "LHMessageModel.h"
@interface WBTweetlocalImageModel : NSObject <NSCopying,NSMutableCopying>
@property (nonatomic)id asset;
@property (nonatomic,copy)UIImage *localImage;
@end

@interface WBTweetlistModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic,copy)NSString *filename;
@property (nonatomic,copy)NSString *sha256;
@property (nonatomic,copy)NSDictionary *metadata;
@property (nonatomic,copy)NSNumber *size;
@property (nonatomic,copy)NSString *dirUUID;
@property (nonatomic,copy)NSString *parentUUID;
@property (nonatomic,copy)NSString *fileuuid;
@end

@interface WBTweetTweeterModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic,copy)NSString *tweeterId;
@property (nonatomic)NSArray *wx;
@end

@interface WBTweetModel : NSObject<NSCopying,NSMutableCopying>
/** 是否是发送者 */
@property (nonatomic, assign) BOOL isSender;
/** 是否已读 */
@property (nonatomic) BOOL isRead;

/** image */
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSURL *imageRemoteURL;
@property (nonatomic, copy) NSString *boxuuid;

@property (nonatomic, assign) MessageBodyType messageBodytype;
@property (nonatomic, assign) MessageDeliveryState status;
@property (nonatomic, copy)NSString *owner;
@property (nonatomic,copy)NSString *comment;
@property (nonatomic)long long ctime;
@property (nonatomic)NSInteger index;
@property (nonatomic)NSArray *list;
@property (nonatomic)WBTweetTweeterModel *tweeter;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,copy)NSString *uuid;
@property (nonatomic,strong)NSArray *localImageArray;
//@property (nonatomic,copy)NSString *dirUUID;
//@property (nonatomic,copy)NSString *driveUUID;
@end
