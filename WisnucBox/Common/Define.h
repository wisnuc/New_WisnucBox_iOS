//
//  Define.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#ifndef Define_h
#define Define_h

#define WB_IS_DEBUG NO

#define __kWidth [[UIScreen mainScreen]bounds].size.width
#define __kHeight [[UIScreen mainScreen]bounds].size.height

#define kCloudAddr    @"http://www.siyouqun.org/"
#define kCloudCommonJsonUrl [NSString stringWithFormat:@"c/v1/stations/%@/json", WB_UserService.currentUser.stationId]
#define kCloudCommonPipeUrl [NSString stringWithFormat:@"c/v1/stations/%@/pipe", WB_UserService.currentUser.stationId]

#define KWxAppID      @"wx99b54eb728323fe8"

//Cloud Body Keys
#define kCloudBodyResource @"resource"
#define kCloudBodyOp       @"op"
#define kCloudBodyMethod   @"method"
#define kCloudBodyToName   @"toName"
#define kCloudBodyFromName @"fromName"

#define WX_BASE_URL   @"http://www.siyouqun.org/c/v1/"

#define kVideoTypes @[@"MOV", @"MP4", @"3GP"]

#define BackUpAssetDirName @"上传的照片"
#define BackUpFilesDirName @"上传的文件"

#define KUploadFilesDocument [NSString stringWithFormat:@"Upload/%@",WB_UserService.currentUser.uuid]

#define kUserDefaults [NSUserDefaults standardUserDefaults]
#define kUD_Synchronize [[NSUserDefaults standardUserDefaults] synchronize]
#define kUD_ObjectForKey(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define KDefaultNotificationCenter [NSNotificationCenter defaultCenter]

#define IsNull(__Text) [__Text isKindOfClass:[NSNull class]]
#define IsEquallString(_Str1,_Str2)  [_Str1 isEqualToString:_Str2]
#define IsNilString(__String) (__String==nil || [__String isEqualToString:@""]|| [__String isEqualToString:@"null"])

#define ImageWithName(name) [UIImage imageNamed:name]

#define MyAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define KDefaultOffset 8


#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define debugMethod()
#endif

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

#ifndef strongy
#if DEBUG
#if __has_feature(objc_arc)
#define strongy(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongy(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongy(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongy(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* Define_h */

