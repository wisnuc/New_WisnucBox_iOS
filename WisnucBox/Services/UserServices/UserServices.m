//
//  UserServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "UserServices.h"
#import "WBUser+CoreDataClass.h"
#import "WBGetUpgradStateAPI.h"
#import "WBGetUpgradStateModel.h"
#import "WBUpgradeCheckViewController.h"
#import "AppDelegate.h"

@interface UserServices ()<WBUpgradeCheckAlertDelegate>{
    NSInteger _upradeCount;
}

@property (readwrite) BOOL isUserLogin;

@end

@implementation UserServices

- (void)abort {
    
}

- (void)dealloc {
    NSLog(@"UserServices delloc");
}

- (instancetype)init {
    if(self = [super init]) {
        [self loadData];
        _upradeCount = 0;
    }
    return self;
}

- (NSString *)defaultToken {
    return self.currentUser ? (self.currentUser.isCloudLogin ? self.currentUser.cloudToken : self.currentUser.localToken) : nil;
}

// load Latest User Configuation
- (void)loadData {
    NSLog(@"%@",kUD_ObjectForKey(WBCURRENTUSER_UUID));
    if(kUD_ObjectForKey(WBCURRENTUSER_UUID)) {
        self.currentUser = [self getUserWithUUID:kUD_ObjectForKey(WBCURRENTUSER_UUID)];
        if(!self.currentUser) {
            self.isUserLogin = false;
            [kUserDefaults removeObjectForKey:WBCURRENTUSER_UUID];
            kUD_Synchronize;
            return ;
        }
        self.isUserLogin = true;
    }else{
        self.currentUser = nil;
        self.isUserLogin = false;
        self.defaultToken = nil;
    }
}

- (WBUser *)getUserWithUUID:(NSString *)uuid {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    WBUser * user = [WBUser MR_findFirstWithPredicate:predicate];
    return user;
}

- (void)logoutUser {
    _defaultToken = nil;
    _isUserLogin = false;
    _currentUser = nil;
    [kUserDefaults removeObjectForKey:WBCURRENTUSER_UUID];
    kUD_Synchronize;
}

- (void)setCurrentUser:(WBUser *)currentUser {
    if(!currentUser || !currentUser.uuid || IsNilString(currentUser.uuid))
       return [self logoutUser];
    self.defaultToken = currentUser.localToken;
    self.isUserLogin = true;
    _currentUser = currentUser;
    [kUserDefaults setObject:currentUser.uuid forKey:WBCURRENTUSER_UUID];
    kUD_Synchronize;
}

- (WBUser *)createUserWithUserUUID:(NSString *)uuid {
    return [WBUser MR_findFirstOrCreateByAttribute:@"uuid" withValue:uuid inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (WBUser *)saveUser:(WBUser *)user {
    if(!user) return nil;
    if(!user.uuid || IsNilString(user.uuid)) {
        [user MR_deleteEntity];
        return nil;
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    if(user.uuid == self.currentUser.uuid)
        self.currentUser = user;
    return user;
}

- (void)deleteUserWithUserId:(NSString  *)uuid {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    NSArray<WBUser *> *users = [WBUser MR_findAllWithPredicate:predicate];
    for (WBUser *user in users) {
        [user MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (NSArray<WBUser *> *)getAllLoginUser {
    return [WBUser MR_findAll];
}

- (void)synchronizedCurrentUser {
    [self saveUser:self.currentUser];        
}


- (void)upgradeCheckAction{
    if(WB_UserService.isUserLogin && !WB_UserService.currentUser.isIgnoreUpgradeCheck && WB_UserService.currentUser.isAdmin) {
        @weaky(self)
        NSString *urlString = [NSString stringWithFormat:@"%@",WB_UserService.currentUser.sn_address];
        NSLog(@"%@",urlString);
        if (!urlString) {
            return;
        }
        [[WBGetUpgradStateAPI apiWithURLPath:urlString] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            //        NSLog(@"%@",request.responseJsonObject);
            WBGetUpgradStateModel *model = [WBGetUpgradStateModel modelWithJSON:request.responseJsonObject];
            if ([model.fetch.state isEqualToString:@"Pending"]) {
                WBGetUpgradStateReleasesModel *releaseModel;
                if (model.releases.count >0) {
                    releaseModel = model.releases[0];
                }
                if (![model.appifi.tagName isEqualToString:releaseModel.remote.tag_name]) {
                     [weak_self alertController];
                }
                NSLog(@"%@",model.appifi.tagName);
            }else{
                _upradeCount ++;
                if (_upradeCount<=3) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                        if ([self respondsToSelector:@selector(upgradeCheckAction)]) {
                            [self performSelector:@selector(upgradeCheckAction) withObject:nil];
                        }
                    });
                }
            }
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
        }];
    }
}

- (void)alertController{
    NSBundle *bundle = [NSBundle bundleForClass:[WBUpgradeCheckViewController class]];
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:NSStringFromClass([WBUpgradeCheckViewController class]) bundle:bundle];
    NSString *identifier = NSStringFromClass([WBUpgradeCheckViewController class]);
    
    UIViewController *alertViewController =
    [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    alertViewController.mdm_transitionController.transition = [[MDCDialogTransition alloc] init];

    [[UIViewController getCurrentVC] presentViewController:alertViewController animated:YES completion:nil];
    WBUpgradeCheckViewController *vc = (WBUpgradeCheckViewController *)alertViewController;
    vc.delegate = self;
    MDCDialogPresentationController *presentationController =
    alertViewController.mdc_dialogPresentationController;
    if (presentationController) {
        presentationController.dismissOnBackgroundTap = NO;
    }
}

- (void)confirmWithIsIgnore:(BOOL)ignore{
    [WB_UserService.currentUser setIsIgnoreUpgradeCheck:ignore];
    [WB_UserService synchronizedCurrentUser];
}

@end

@implementation UserSession

@end
