//
//  CSDownloadTaskQueue.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDownloadTaskQueue : NSObject
{
    NSMutableArray* _operationQueue;
}

@property (nonatomic) BOOL isEmpty;
@property (nonatomic) BOOL isFull;

/**
 *  初始化一个下载任务队列，并指定初始队列容量
 *
 *  @param maxCapacity
 *
 *  @return
 */
- (id)initWithMaxCapacity:(int)maxCapacity;

/**
 *  任务队列最大容量
 */
@property (nonatomic) int maxCapacity;

/**
 *  元素入队
 *
 *  @param anObject 要添加的对象
 */
- (void)enqueue:(id)anObject;

/**
 *  元素出队
 *
 *  @return
 */
- (id)dequeue;

/**
 *  是否为空
 *
 *  @return YES/NO
 */
- (BOOL)empty;

/**
 *  判断队列是否是满的
 *
 *  @return
 */
- (BOOL)full;

/**
 *  从队列中移除掉一指定对象（如果对象不存在于队列中，什么都不干）
 *
 *  @param anObject 要移除的对象
 *
 *  @return
 */
- (void)remove:(id)anObject;

/**
 *  获得队列数量
 *
 *  @return
 */
- (int)queueCount;

/**
 *  获取队列中指定索引的对象
 *
 *  @param index 队列索引
 *
 *  @return
 */
- (id)peekAtIndex:(int)index;

/**
 *  清空队列
 */
- (void)clearQueue;

@end
