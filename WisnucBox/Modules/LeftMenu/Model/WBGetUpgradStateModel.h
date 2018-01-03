//
//  WBGetUpgradStateModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"
@interface WBGetUpgradStateRemoteModel : NSObject
@property (nonatomic)NSString *tag_name;
@property (nonatomic)NSString *published_at;
@end

@interface WBGetUpgradStateReleasesModel : NSObject
@property (nonatomic)NSString *state;
@property (nonatomic)WBGetUpgradStateRemoteModel *remote;
@property (nonatomic)WBGetUpgradStateRemoteModel *local;
@end

@interface WBGetUpgradStateAppifiModel : NSObject
@property (nonatomic)NSString *state;
@property (nonatomic)NSString *tagName;
@end

@interface WBGetUpgradStateModel : WBBaseModel
@property (nonatomic) WBGetUpgradStateAppifiModel *appifi;
@property (nonatomic) NSArray *releases;
@end
