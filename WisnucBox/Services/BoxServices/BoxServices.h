//
//  BoxServices.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/31.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBTweetModel.h"
#import "WBBoxesModel.h"

@interface BoxServices : NSObject <ServiceProtocol>
- (void)sendTweetWithImageArray:(NSArray *)array BoxModel:(WBBoxesModel *)boxModel Complete:(void(^)(WBTweetModel *tweetModel,NSError *error))callback;
- (void)sendTweetWithFilesDic:(NSDictionary *)dic Boxuuid:(NSString *)boxuuid Complete:(void(^)(WBTweetModel *tweetModel,NSError *error))callback;
- (void)saveBoxesTokenWithGuid:(NSString *)guid;
- (NSString *)boxToken;
@end
