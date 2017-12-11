//
//  WBLoginTableView.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/11.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBLoginTableView.h"
@interface WBLoginTableView ()<UITableViewDelegate,UITableViewDataSource>
@end

@implementation WBLoginTableView

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat offset = - ABS(self.bounds.size.width - self.bounds.size.height) / 2;
        self.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), offset, offset);
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = self.frame;
        rect.size.width = self.bounds.size.height;
        rect.size.height = self.bounds.size.width;
        self.frame = rect;
        CGFloat offset = -ABS(self.bounds.size.width - self.bounds.size.height) / 2;
        self.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), offset, offset);
        
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}
//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        CGFloat offset = - ABS(self.bounds.size.width - self.bounds.size.height) / 2;
//        self.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), offset, offset);
//        self.delegate = self;
//        self.dataSource = self;
//    }
//    return self;
//}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate_Y respondsToSelector:@selector(h_tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate_Y h_tableView:self heightForRowAtIndexPath:indexPath];
    }
    return 100;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //设置分割线到头
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.dataSource_Y respondsToSelector:@selector(h_tableView:numberOfRowsInSection:)]) {
        return [self.dataSource_Y h_tableView:self numberOfRowsInSection:section];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource_Y respondsToSelector:@selector(h_tableView:cellForRowAtIndexPath:)]) {
        return [self.dataSource_Y h_tableView:self cellForRowAtIndexPath:indexPath];
    }
    return nil;
}


@end
