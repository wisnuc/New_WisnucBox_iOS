//
//  WBGroupSettingUserTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/19.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGroupSettingUserTableViewCell.h"




#define Width_Space      40.0f      // 2个按钮之间的横间距
#define Height_Space     12.0f + 14.0f +20.0f     // 竖间距
#define Button_Height   40.0f    // 高
#define Button_Width    40.0f    // 宽
#define Start_X         (__kWidth - Button_Width *4 - Width_Space*3)/2     // 第一个按钮的X坐标
#define Start_Y          16.0f     // 第一个按钮的Y坐标


@implementation WBGroupSettingUserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self initUserImageView];
    // Initialization code
}

- (void)setUserArray:(NSMutableArray *)userArray{
    _userArray = userArray;
    [self initUserImageViewAndUserNameLabel];
}

- (void)initUserImageViewAndUserNameLabel{
     @weaky(self)
    [_userArray enumerateObjectsUsingBlock:^(WBBoxesUsersModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = idx % 4;
        NSInteger page = idx / 4;
        
        _userImageView = [[UIImageView alloc]init];
        _userImageView.frame = CGRectMake(index * (Button_Width + Width_Space) + Start_X,page * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);

        _userImageView.userInteractionEnabled = YES;
        _userImageView.tag = idx;
        if (model.avatarUrl) {
           [_userImageView was_setCircleImageWithUrlString:model.avatarUrl placeholder:[UIImage imageForName:model.nickName size:_userImageView.bounds.size]];
        }else{
            _userImageView.image = [UIImage imageForName:model.nickName size:_userImageView.size];
        }
       
        UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
        [_userImageView addGestureRecognizer:singleTap];
//        _userImageView
        
        _userNameLabel = [[UILabel alloc]init];
        _userNameLabel.frame = CGRectMake(0,0,60,14);
        _userNameLabel.center = CGPointMake(_userImageView.center.x, _userImageView.center.y +Button_Height/2 +14);
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.font = [UIFont systemFontOfSize:12];
        _userNameLabel.textColor = RGBACOLOR(0, 0, 0, 0.87f);
        _userNameLabel.text = model.nickName;
//        [_userNameLabel sizeToFit];
        [weak_self.contentView addSubview:_userImageView];
        [weak_self.contentView addSubview:_userNameLabel];
    }];
    
    UIButton *addUserButton = [[UIButton alloc]init];
//    addUserButton.backgroundColor = [UIColor cyanColor];
    [addUserButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [addUserButton setImage:[UIImage imageNamed:@"add_box_user"] forState:UIControlStateNormal];
    addUserButton.layer.masksToBounds = YES;
    addUserButton.layer.cornerRadius = Button_Width/2;
    addUserButton.layer.borderWidth = 1.0f;
    addUserButton.layer.borderColor = RGBACOLOR(0, 0, 0, 0.37f).CGColor;
    
    UIButton *removeUserButton = [[UIButton alloc]init];
//    removeUserButton.backgroundColor = [UIColor orangeColor];
    [removeUserButton addTarget:self action:@selector(removeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [removeUserButton setImage:[UIImage imageNamed:@"delete_box_user"] forState:UIControlStateNormal];
    removeUserButton.layer.masksToBounds = YES;
    removeUserButton.layer.cornerRadius = Button_Width/2;
    removeUserButton.layer.borderWidth = 1.0f;
    removeUserButton.layer.borderColor = RGBACOLOR(0, 0, 0, 0.37f).CGColor;
    
    NSInteger judgement = _userArray.count % 4;
    NSInteger page = _userArray.count / 4;
    NSLog(@"%ld",page);
    
    if (judgement <=2) {
     addUserButton.frame = CGRectMake(judgement * (Button_Width + Width_Space) + Start_X,page * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);
     removeUserButton.frame = CGRectMake((judgement + 1) * (Button_Width + Width_Space) + Start_X,page * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);
    }else if (judgement ==3){
     addUserButton.frame = CGRectMake(judgement * (Button_Width + Width_Space) + Start_X,page * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);
     removeUserButton.frame = CGRectMake(0 * (Button_Width + Width_Space) + Start_X,(page+1) * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);
    }else{
        addUserButton.frame = CGRectMake(judgement * (Button_Width + Width_Space) + Start_X,page * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);
        removeUserButton.frame = CGRectMake((judgement + 1) * (Button_Width + Width_Space) + Start_X,page * (Button_Height + Height_Space)+Start_Y, Button_Width, Button_Height);
    }
    
    UIButton *checkAllUserButton = [[UIButton alloc]init];
    checkAllUserButton.frame = CGRectMake(0, 0, __kWidth,15);
    checkAllUserButton.center = CGPointMake(__kWidth/2, CGRectGetMaxY(removeUserButton.frame) + 12.0f + 15.0f +30.0f+15/2);
    checkAllUserButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [checkAllUserButton setTitleColor:RGBACOLOR(0, 0, 0, 0.54f) forState:UIControlStateNormal];
    [checkAllUserButton setTitle:@"查看更多群员  >" forState:UIControlStateNormal];
    [checkAllUserButton addTarget:self action:@selector(checkAllUserButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.contentView addSubview:addUserButton];
    [self.contentView addSubview:removeUserButton];
    [self.contentView addSubview:checkAllUserButton];
}

- (void)onClickImage:(UIGestureRecognizer *)gestureRecognizer{
    NSInteger tageInteger = gestureRecognizer.view.tag;
    self.clickBlock(tageInteger);
}

- (void)addButtonClick:(UIButton *)sender{
    self.addUserClickBlock(self);
}

- (void)removeButtonClick:(UIButton *)sender{
    self.removeUserClickBlock(self);
}

- (void)checkAllUserButtonClick:(UIButton *)sender{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
