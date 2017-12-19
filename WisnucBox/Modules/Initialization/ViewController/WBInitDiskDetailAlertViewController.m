//
//  WBInitDiskDetailAlertViewController.m
//  WisnucBox
//
//  Created by liupeng on 2017/12/18.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInitDiskDetailAlertViewController.h"

@interface WBInitDiskDetailAlertViewController ()

@end

@implementation WBInitDiskDetailAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNumber *sizeNumber = [NSNumber numberWithLongLong:[_blocksmodel.size longLongValue] *512];
    NSString *sizeString = [NSString transformedValue:sizeNumber];
    NSString *idBus = [_blocksmodel.idBus uppercaseStringWithLocale:[NSLocale currentLocale]];
    NSLog(@"%@",_blocksmodel.unformattable);
    _typeLabel.text = [NSString stringWithFormat:@"型号：%@",self.blocksmodel.model];
    _deviceNameLabel.text = [NSString stringWithFormat:@"设备名：%@",self.blocksmodel.name];
    _sizeLabel.text = [NSString stringWithFormat:@"容量：%@",sizeString];
    _interfaceLabel.text = [NSString stringWithFormat:@"接口：%@",idBus];
    
    if (_blocksmodel.isFileSystem && _blocksmodel.fileSystemType) {
         _stateLabel.text = [NSString stringWithFormat:@"状态：%@文件系统", _blocksmodel.fileSystemType];
    }else if ([_blocksmodel.isPartitioned boolValue]){
         _stateLabel.text = [NSString stringWithFormat:@"状态：%@",@"有文件分区"];
    }else{
         _stateLabel.text = [NSString stringWithFormat:@"状态：%@",@"未发现文件系统或分区"];
    }
    
    if ([_blocksmodel.unformattable containsString:@"RootFS"]) {
        _explainLabel.text = [NSString stringWithFormat:@"说明：%@",@"该磁盘含有rootfs，不可用"];
        _leftIconImageView.image = [UIImage imageNamed:@"disk_disable"];
    }else if ([_blocksmodel.unformattable containsString:@"ActiveSwap"]){
       _explainLabel.text = [NSString stringWithFormat:@"说明：%@",@"该磁盘含有在使用的交换分区，不可用"];
    }else if (_blocksmodel.unformattable){
        _explainLabel.text = [NSString stringWithFormat:@"说明：%@",@"该磁盘无法格式化，不可用"];
    }else if ([_blocksmodel.removable boolValue]){
        _explainLabel.text = [NSString stringWithFormat:@"说明：%@",@"该磁盘为可移动磁盘，可以加入磁盘卷，但请谨慎选择"];
    }else{
       _explainLabel.text = [NSString stringWithFormat:@"说明：%@",@"该磁盘可以加入磁盘卷"];
    }
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
