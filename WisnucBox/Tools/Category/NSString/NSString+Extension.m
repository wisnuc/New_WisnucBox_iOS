//
//  NSString+Extension.h
//  Dialysis
//
//  Created by jackygood on 14/12/27.
//  Copyright (c) 2014年 beyondwinet. All rights reserved.
//

#import "NSString+Extension.h"


@implementation NSString (Extension)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
+ (NSString *)fileSizeWithFileName:(NSString *)fileName
{
    // 总大小
    unsigned long long size = 0;
    NSString *sizeText = nil;
    // 文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 文件属性
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"JYDownloadCache/%@",fileName]];
//    MyNSLog(@"🌶%@",docDir);
    NSDictionary *attrs = [mgr attributesOfItemAtPath:docDir error:nil];
    
    // 如果这个文件或者文件夹不存在,或者路径不正确直接返回0;
    if (attrs == nil) return [NSString stringWithFormat:@"%llu",size];

        size = attrs.fileSize;
        if (size >= pow(10, 9)) { // size >= 1GB
            sizeText = [NSString stringWithFormat:@"%.2fG", size / pow(10, 9)];
        } else if (size >= pow(10, 6)) { // 1GB > size >= 1MB
            sizeText = [NSString stringWithFormat:@"%.2fM", size / pow(10, 6)];
        } else if (size >= pow(10, 3)) { // 1MB > size >= 1KB
            sizeText = [NSString stringWithFormat:@"%.2fK", size / pow(10, 3)];
        } else { // 1KB > size
            sizeText = [NSString stringWithFormat:@"%zdB", size];
        }
    
    return sizeText;
}
    
+(NSString *)fileSizeWithFLModel:(EntriesModel *)model {
    long long size = 0;
    NSString *sizeText = nil;
    if ([model.type isEqualToString:@"file"]) { // 如果是文件夹
        size = model.size;
        if (size >= pow(10, 9)) { // size >= 1GB
            sizeText = [NSString stringWithFormat:@"%.2fG", size / pow(10, 9)];
        } else if (size >= pow(10, 6)) { // 1GB > size >= 1MB
            sizeText = [NSString stringWithFormat:@"%.2fM", size / pow(10, 6)];
        } else if (size >= pow(10, 3)) { // 1MB > size >= 1KB
            sizeText = [NSString stringWithFormat:@"%.2fK", size / pow(10, 3)];
        } else { // 1KB > size
            sizeText = [NSString stringWithFormat:@"%zdB", size];
        }
    }
    return sizeText;
}

+ (NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

+ (NSString *)transformedValue:(id)value
{
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"B",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB",    @"YB",nil];
    while (convertedValue > 1024) {
        convertedValue /= 1024;multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

+ (NSString *)getReleaseTime:(long long)releaseTime
{
    if (releaseTime == 0 ||!releaseTime) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //dateFormat时间样式属性,传入格式必须按这个
    //    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.S";
    
    //locale："区域；场所"
    formatter.locale = [NSLocale currentLocale];
    
    //发布时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(releaseTime/1000.0)];
    
    //现在时间
    NSDate *now = [NSDate date];
    
    //发布时间到现在间隔多长时间，用timeIntervalSinceDate
    NSTimeInterval interval = [now timeIntervalSinceDate:date];
    
    NSString *format;
    
    if (interval <= 60) {
        
        format = @"刚刚";
        
    } else if(interval <= 60*60){
        
        format = [NSString stringWithFormat:@"%.f分钟前",interval/60];
        
    } else if(interval <= 60*60*24){
        
        format = [NSString stringWithFormat:@"%.f小时前",interval/3600];
        
    } else if (interval <= 60*60*24*7){
        
        format = [NSString stringWithFormat:@"%d天前",
                  (int)interval/(60*60*24)];
        
    } else if (interval > 60*60*24*7 & interval <= 60*60*24*30 ){
        
        format = [NSString stringWithFormat:@"%d周前",
                  (int)interval/(60*60*24*7)];
        
    }else if(interval > 60*60*24*30 ){
        format = [NSString stringWithFormat:@"%d月前",
                  (int)interval/(60*60*24*30)];
    }
   
   
    
    return format;
    
}
@end
