//
//  WBAsset.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYAsset.h"

@interface WBAsset : JYAsset

@property (nonatomic) NSString *m;
@property (nonatomic) NSInteger h;
@property (nonatomic) NSInteger w;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger orient;
@property (nonatomic) NSString *datetime;
@property (nonatomic) NSString *make;
@property (nonatomic) NSString *model;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *latr;
@property (nonatomic) NSString *fmlong;
@property (nonatomic) NSString *longr;
@property (nonatomic) NSString *fmhash;

@end
