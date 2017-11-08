//
//  Define.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#ifndef Define_h
#define Define_h

#define __kWidth [[UIScreen mainScreen]bounds].size.width
#define __kHeight [[UIScreen mainScreen]bounds].size.height

#define KWxAppID      @"wx99b54eb728323fe8"

#define kUserDefaults [NSUserDefaults standardUserDefaults]
#define kUD_Synchronize [[NSUserDefaults standardUserDefaults] synchronize]
#define kUD_ObjectForKey(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define IsNull(__Text) [__Text isKindOfClass:[NSNull class]]
#define IsEquallString(_Str1,_Str2)  [_Str1 isEqualToString:_Str2]

#ifndef weaky
#if DEBUG
#if __has_feature(objc_arc)
#define weaky(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weaky(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weaky(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weaky(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* Define_h */

//NSString * WB_UUID() {
//    CFUUIDRef   uuid_ref        = CFUUIDCreate(NULL);
//    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
//    CFRelease(uuid_ref);
//    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
//    CFRelease(uuid_string_ref);
//    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
//}
