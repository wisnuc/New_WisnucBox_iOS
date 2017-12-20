//
//  WBTorrentDownloadHelper.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBTorrentDownloadHelper : NSObject
+ (WBTorrentDownloadHelper *)shareManager;

+ (void)destroyAll;

@end
