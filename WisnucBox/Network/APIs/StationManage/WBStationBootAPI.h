//
//  WBStationBootAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBStationBootAPI : JYBaseRequest
@property (nonatomic) NSString * state;
@property (nonatomic) NSString * mode;
@property (nonatomic) NSString * mothod;
@property (nonatomic) NSString * path;
+ (instancetype)apiWithState:(NSString *)state Mode:(NSString *)mode;
+ (instancetype)apiWithPath:(NSString *)path RequestMethod:(NSString *)mothod;
@end
