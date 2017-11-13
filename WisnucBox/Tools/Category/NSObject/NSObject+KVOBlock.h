//
//  NSObject+KVOBlock.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVOBlock)
typedef void (^KVOFullBlock)(NSString *keyPath, id object, NSDictionary *change);
- (id)addKVOBlockForKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler;
- (void)removeKVOBlockForToken:(id)inToken;

/// One shot blocks remove themselves after they've been fired once.
- (id)addOneShotKVOBlockForKeyPath:(NSString *)inKeyPath options:(NSKeyValueObservingOptions)inOptions handler:(KVOFullBlock)inHandler;
@end
