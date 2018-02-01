//
//  BoxServices.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/31.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoxServices : NSObject <ServiceProtocol>
- (void)sendTweetWithImageArray:(NSArray *)array Boxuuid:(NSString *)boxuuid Complete:(void(^)(NSError *error))callback;
@end
