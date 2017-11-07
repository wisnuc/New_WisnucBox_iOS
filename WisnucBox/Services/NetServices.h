//
//  NetServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetServices : NSObject <ServiceProtocol>

@property (nonatomic, assign) BOOL isCloud;

@property (nonatomic, copy) NSString *localUrl;

@property (nonatomic, copy) NSString *cloudUrl;

@property (nonatomic, copy) NSString *token;

- (instancetype)initWithLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl andToken:(NSString *)token;

@end
