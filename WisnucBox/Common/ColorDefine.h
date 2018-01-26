//
//  ColorDefine.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#ifndef ColorDefine_h
#define ColorDefine_h

#define UICOLOR_RGB(RGB)     ([UIColor colorWithRed:((float)((RGB & 0xFF0000) >> 16))/255.0 green:((float)((RGB & 0xFF00) >> 8))/255.0 blue:((float)(RGB & 0xFF))/255.0 alpha:1.0])

#define COR1  UICOLOR_RGB(0x03a9f4)
#define LINECOLOR  RGBACOLOR(0, 0, 0, 0.12f)
#define MainBackgroudColor  UICOLOR_RGB(0xfafafa)
#define kWhiteColor  [UIColor whiteColor]
#define kBlackColor  [UIColor blackColor]

#define kTitleTextColor RGBACOLOR(0, 0, 0, 0.87f)
#define kDetailTextColor RGBACOLOR(0, 0, 0, 0.54f)
#endif /* ColorDefine_h */
