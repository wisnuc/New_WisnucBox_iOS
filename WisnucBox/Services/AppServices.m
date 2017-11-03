//
//  AppServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "AppServices.h"

@implementation AppServices

+ (instancetype)sharedService {
    static AppServices * appServices;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appServices = [[AppServices alloc] init];
    });
    return appServices;
}


- (void)abort {
    [self.userServices abort];
    [self.fileServices abort];
    [self.assetServices abort];
    [self.netServices abort];
    [self.dbServices abort];
    
    self.userServices = nil;
    self.fileServices = nil;
    self.assetServices = nil;
    self.netServices = nil;
    self.dbServices = nil;
}

@end
