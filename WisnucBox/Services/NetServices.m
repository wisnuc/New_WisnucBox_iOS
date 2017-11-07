//
//  NetServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "NetServices.h"

@implementation NetServices

- (void)abort {
    
}

- (instancetype)initWithLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl andToken:(NSString *)token {
    if(self = [super init]){
        self.localUrl = localUrl;
        self.cloudUrl = cloudUrl;
        self.token = token;
        self.isCloud = NO;
    }
    return self;
}



@end
