//
//  AppServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBServices.h"
#import "UserServices.h"
#import "AssetsServices.h"
#import "FilesServices.h"
#import "NetServices.h"

@interface AppServices : NSObject <ServiceProtocol>

@property (nonatomic, strong) DBServices * dbServices;

@property (nonatomic, strong) UserServices * userServices;

@property (nonatomic, strong) AssetsServices * assetServices;

@property (nonatomic, strong) FilesServices * fileServices;

@property (nonatomic, strong) NetServices * netServices;

+ (instancetype)sharedService;

@end
