//
//  WBInstallUpgradeAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBInstallUpgradeAPI : JYBaseRequest
@property (nonatomic) NSString *urlPath;
@property (nonatomic) NSString *tagName;
@property (nonatomic) NSString *method;
@property (nonatomic) NSString *state;
/*
 * WISNUC API:FIRMWARE INSTALL
 * @param urlPath    URL
 * @param tagName    Tag Name
 */
+ (instancetype)apiWithURLPath:(NSString *)urlPath  RequestMethod:(NSString *)method TagName:(NSString *)tagName;
+ (instancetype)apiWithURLPath:(NSString *)urlPath  RequestMethod:(NSString *)method State:(NSString *)state;
@end
