//
//  FilesModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FilesModel.h"

@implementation FilesModel

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"entries" : [EntriesModel class],
             };
}
@end
