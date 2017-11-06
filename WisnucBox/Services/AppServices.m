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

- (UserServices *)userServices {
    @synchronized (self) {
        if(!_userServices){
            _userServices = [[UserServices alloc]init];
        }
        return _userServices;
    }
}

- (AssetsServices *)assetServices {
    @synchronized (self) {
        if(!_assetServices) {
            _assetServices = [[AssetsServices alloc]init];
        }
        return _assetServices;
    }
}

- (FilesServices *)fileServices {
    @synchronized (self) {
        if(!_fileServices) {
            _fileServices = [[FilesServices alloc] init];
        }
        return _fileServices;
    }
}

- (NetServices *)netServices {
    @synchronized (self) {
        if(!_netServices) {
            _netServices = [[NetServices alloc] init];
        }
        return _netServices;
    }
}

- (DBServices *)dbServices {
    @synchronized (self) {
        if(!_dbServices) {
            _dbServices = [[DBServices alloc] init];
        }
        return _dbServices;
    }
}

- (void)abort {
    _userServices ? [_userServices abort] :
    _fileServices ? [_fileServices abort] :
    _assetServices ? [_assetServices abort] :
    _netServices ? [_netServices abort] :
    _dbServices ? [_dbServices abort] : nil;
    
    _userServices = nil;
    _fileServices = nil;
    _assetServices = nil;
    _netServices = nil;
    _dbServices = nil;
}

@end
