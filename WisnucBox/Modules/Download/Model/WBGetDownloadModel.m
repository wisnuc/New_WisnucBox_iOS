//
//  WBGetDownloadModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBGetDownloadModel.h"
@implementation WBGetDownloadFinishModel
@end

@implementation WBGetDownloadRunnngModel

@end

@implementation WBGetDownloadModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"running" : [WBGetDownloadRunnngModel class],
             @"finish" : [WBGetDownloadFinishModel class]
             };
}
@end
