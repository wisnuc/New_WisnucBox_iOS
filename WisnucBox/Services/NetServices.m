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

- (void)dealloc {
    NSLog(@"NetServices dealloc");
}

- (instancetype)initWithLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl {
    if(self = [super init]){
        self.localUrl = localUrl;
        self.cloudUrl = cloudUrl;
        self.isCloud = NO;
    }
    return self;
}



@end
