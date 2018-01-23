//
//  WBHttpDownloadAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/22.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBHttpDownloadAPI : JYBaseRequest
@property(nonatomic)NSString *dirUUID;
@property(nonatomic)NSString *downloadURL;
+ (instancetype)apiWithDirUUID:(NSString *)dirUUID DownloadURL:(NSString *)downloadURL;
@end