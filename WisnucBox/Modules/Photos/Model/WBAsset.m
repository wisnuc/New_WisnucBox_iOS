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

- (JYAssetType)type {
    if(!IsNilString(self.m) && [kVideoTypes containsObject:self.m]){
        return JYAssetTypeNetVideo;
    }else if(IsEquallString(self.m, @"GIF")) {
        return JYAssetTypeGIF;
    }
    return JYAssetTypeNetImage;
}

-(NSString *)duration
{
    if (self.type != JYAssetTypeNetVideo || self.dur == 0) return @"00:00";
    
    NSInteger duration = (NSInteger)round(self.dur);
    
    if (duration < 60) return [NSString stringWithFormat:@"00:%02ld", (long)duration];
    
    else if (duration < 3600) return [NSString stringWithFormat:@"%02ld:%02ld", duration / 60, duration % 60];
    
    NSInteger h = duration / 3600;
    NSInteger m = (duration % 3600) / 60;
    NSInteger s = duration % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)h, (long)m, (long)s];
    
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
