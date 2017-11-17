//
//  WBAsset.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBAsset.h"

@implementation WBAsset

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"fmlong" : @"long",
             @"fmhash": @"hash",
             @"datetime": @"date"
             };
}

- (instancetype)init{
    self = [super init];
    self.type = JYAssetTypeNetImage;
    return self;
}

- (NSDate *)createDate{
    if(!self.createDateB) {
        if(!IsNilString(self.date)){
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
            self.createDateB = [dateFormat dateFromString:self.date];
            if(!self.createDateB) // fix 0000:00:00 00:00:00
                self.createDateB = [NSDate dateWithTimeIntervalSince1970:0];
        }else
            self.createDateB = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return self.createDateB;
}

@end
