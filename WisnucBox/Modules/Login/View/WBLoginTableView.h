//
//  WBLoginTableView.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/11.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBLoginTableViewDelegate.h"

@interface WBLoginTableView : UITableView
@property (nonatomic, weak, nullable) id <WBLoginTableViewDataSource> dataSource_Y;
@property (nonatomic, weak, nullable) id <WBLoginTableViewDelegate> delegate_Y;

@end
