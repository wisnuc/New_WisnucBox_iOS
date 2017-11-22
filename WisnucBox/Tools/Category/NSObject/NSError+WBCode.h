//
//  NSError+WBCode.h
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (WBCode)

#define WBUndefindError  -1

@property (nonatomic, assign) NSInteger wbCode;

@end
