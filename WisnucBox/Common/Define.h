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

#define kUserDefaults = [NSUserDefaults standardUserDefaults]
#define kUD_Synchronize = [kUserDefaults synchronize]
#define kUD_ObjectForKey(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#endif /* Define_h */
