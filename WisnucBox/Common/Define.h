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

#define RGBCOLOR(r, g, b)      [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]
#define RGBACOLOR(r, g, b ,a)      [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

#define kCloudAddr    @"http://www.siyouqun.org/"
#define kCloudCommonJsonUrl [NSString stringWithFormat:@"c/v1/stations/%@/json", WB_UserService.currentUser.stationId]
#define kCloudCommonPipeUrl [NSString stringWithFormat:@"c/v1/stations/%@/pipe", WB_UserService.currentUser.stationId]

#define KWxAppID      @"wx99b54eb728323fe8"

//localized
#define WBLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

//Cloud Body Keys
#define kCloudBodyResource @"resource"
#define kCloudBodyOp       @"op"
#define kCloudBodyMethod   @"method"
#define kCloudBodyToName   @"toName"
#define kCloudBodyFromName @"fromName"

#define WX_BASE_URL   @"http://www.siyouqun.org/c/v1/"
#define WX_MiniProgram_OriginID @"gh_37b3425fe189"

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

#define kFirstTabBarTitle WBLocalizedString(@"photo", nil)
#define kSecondTabBarTitle WBLocalizedString(@"file", nil)

#define kStationManageUserMangeString WBLocalizedString(@"user_manage", nil)
#define kStationManageEquipmentString WBLocalizedString(@"equipment", nil)
#define kStationManageNetworkString WBLocalizedString(@"network", nil)
#define kStationManageTimeString WBLocalizedString(@"time", nil)
#define kStationManageRebootShutdownString WBLocalizedString(@"reboot_shutdown", nil)

#define LeftMenuTransmissionManageString WBLocalizedString(@"transmission_manage", nil)
#define LeftMenuTorrentDownloadManageString WBLocalizedString(@"download_manage", nil)

#define LeftMenuSettingString WBLocalizedString(@"setting", nil)
#define LeftMenuEquipmentManageString WBLocalizedString(@"equipment_manage", nil)
#define LeftMenuInvitationString WBLocalizedString(@"invitation", nil)


//tmp
#define JY_TMP_Folder [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"JYTMP"]


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

