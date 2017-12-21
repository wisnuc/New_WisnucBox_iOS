//
//  WBTorrentDownloadActionAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBTorrentDownloadActionAPI : JYBaseRequest
@property (nonatomic)NSString *torrentId;
@property (nonatomic)NSString *op;
+ (instancetype)apiWithTorrentId:(NSString *)torrentId Option:(NSString *)op;
@end
