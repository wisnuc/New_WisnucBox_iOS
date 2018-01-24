//
//  DBServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "DBServices.h"

@implementation DBServices

- (void)abort {
    
}

- (void)dealloc {
    NSLog(@"DBServices delloc");
}

- (dispatch_queue_t)saveQueue{
    if(!_saveQueue){
        _saveQueue = dispatch_queue_create("com.wisnucbox.save", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_saveQueue, dispatch_get_global_queue(0, 0));
    }
    return _saveQueue;
}

- (NSManagedObjectContext *)saveContext {
    if(!_saveContext) {
        _saveContext = [NSManagedObjectContext MR_newMainQueueContext];
    }
    return _saveContext;
}


- (NSManagedObjectContext *)createContext {
    return [NSManagedObjectContext MR_contextWithParent:self.saveContext];
}

@end
