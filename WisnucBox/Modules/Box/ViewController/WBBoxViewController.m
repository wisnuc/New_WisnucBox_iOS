//
//  WBBoxViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/16.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBBoxViewController.h"
#import "WBBoxPhotoVideoTableViewCell.h"

@interface WBBoxViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WBBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WBBoxPhotoVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBBoxPhotoVideoTableViewCell class])];
    if (!cell) {
        cell = (WBBoxPhotoVideoTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBBoxPhotoVideoTableViewCell class]) owner:self options:nil]lastObject];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end
