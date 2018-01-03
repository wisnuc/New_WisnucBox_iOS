//
//  CSDateUtil.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDateUtil : NSObject
+ (NSString*)stringWithDate:(NSDate*)date withFormat:(NSString*)format;
+ (NSString *)getUTCFormateLocalDate:(NSString *)localDate;
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate;
@end
