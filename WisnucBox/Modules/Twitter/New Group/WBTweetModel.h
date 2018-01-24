//
//  WBTweetModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"
//comment = "\U4e0d\U77e5\U75b2\U5026\U7684\U7ffb\U8d8a\Uff0c \U6bcf\U4e00\U5ea7\U5c71\U4e18";
//ctime = 1516349811931;
//index = 0;
//list =         (
//                {
//                    filename = "pc\U5206\U4eab2_spec.png";
//                    sha256 = 91ef2850754c891409940460a73271b12be85ed475860a527cb7e4d4e5f9ec65;
//                }
//                );
//tweeter =         {
//    id = "b20ea9c9-c9a6-4a4f-adde-c8f7c1c11884";
//    wx =             (
//                      "oOMKGwvkssIOT-Ceo6IX6y0Oas5E"
//                      );
//};
//type = list;
//uuid = "7c0cd12a-451f-42fe-a3aa-29c4ed5f5ce3";

@interface WBTweetlistModel : NSObject
@property (nonatomic,copy)NSString *filename;
@property (nonatomic,copy)NSString *sha256;
//@property (nonatomic,copy)NSString *metadata;
@end

@interface WBTweetTweeterModel : NSObject
@property (nonatomic,copy)NSString *tweeterId;
@property (nonatomic)NSArray *wx;
@end

@interface WBTweetModel : NSObject
@property (nonatomic,copy)NSString *comment;
@property (nonatomic)long long ctime;
@property (nonatomic)NSInteger index;
@property (nonatomic)NSArray *list;
@property (nonatomic)WBTweetTweeterModel *tweeter;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,copy)NSString *uuid;
@end
