//
//  AppDelegate.h
//  Wisnuc-iOS
//
//  Created by wisnuc-imac on 2017/11/2.
//  Copyright © 2017年 wisnuc-imac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

