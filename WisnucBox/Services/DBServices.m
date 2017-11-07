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

- (dispatch_queue_t)saveQueue{
    if(!_saveQueue){
        _saveQueue = dispatch_queue_create("com.wisnucbox.save", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_saveQueue, dispatch_get_global_queue(1, 0));
    }
    return _saveQueue;
}

@end
