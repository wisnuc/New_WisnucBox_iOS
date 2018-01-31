//
//  WBGroupAdressBookViewController.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/19.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGroupAdressBookViewController.h"
#import "WBGroupAdressBookTableViewCell.h"

@interface WBGroupAdressBookViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    NSString * _addName;
    BOOL _isSearch;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *contactsSource;
@property (nonatomic,strong) NSMutableArray *sectionTitles;
@end

@implementation WBGroupAdressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


#pragma mark -- Delegate Methods

#pragma mark -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.contactsSource.count == 0) {
        return 0;
    }
    if (_isSearch == 1) {
        return 1;
    }
    return self.sectionTitles.count - 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (([self.foldArray[section] boolValue] == YES ||self.contactsSource.count == 0) && _isSearch == 0) {
//        return 0;
//    }
    
    if (_isSearch == 1) {
//        return self.searchResultArr.count;
    }
    return [self.contactsSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WBGroupAdressBookTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WBGroupAdressBookTableViewCell class]) forIndexPath:indexPath];
    if (!cell) {
        cell = (WBGroupAdressBookTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WBGroupAdressBookTableViewCell class]) owner:self options:nil]lastObject];
    }
    if (_isSearch == 1) {
        
//        FriendModel * model = self.searchResultArr[indexPath.row];
//        cell.nameLabel.text = model.nameStr;
//        cell.headImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpeg",model.imageName]];
        return cell;
    }
//    FriendModel * model = self.contactsSource[indexPath.section][indexPath.row];
//    cell.nameLabel.text = model.nameStr;
//    cell.headImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpeg",model.imageName]];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (_isSearch == 1) {
        return nil;
    }
    return self.sectionTitles;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_isSearch == 1) {
        return 0;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(_isSearch == 1){
        return nil;
    }
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = [UIColor orangeColor];
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(25, 0, 30, 30)];
    [btn setTitle:self.sectionTitles[section + 1] forState:UIControlStateNormal];
    btn.tag = section;
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btn];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isSearch == 1) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing == NO) {
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.contactsSource[indexPath.section] removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        if ([self.contactsSource[indexPath.section] count] == 0) {
            [self.sectionTitles removeObjectAtIndex:indexPath.section + 1];
            [self.contactsSource removeObjectAtIndex:indexPath.section];
        }
        
        [tableView reloadData];
    }
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // 取出要拖动的模型数据
//    FriendModel *model = self.contactsSource[sourceIndexPath.section][sourceIndexPath.row];
//    //删除之前行的数据
//    [self.contactsSource[sourceIndexPath.section] removeObject:model];
//    // 插入数据到新的位置
//    [self.contactsSource[destinationIndexPath.section] insertObject:model atIndex:destinationIndexPath.row];
    if([self.contactsSource[sourceIndexPath.section] count] == 0){
        [self.sectionTitles removeObjectAtIndex:sourceIndexPath.section + 1];
        [self.contactsSource removeObjectAtIndex:sourceIndexPath.section];
        [tableView reloadData];
    }
}

- (UITableView *)tableView{
    
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
        //设置索引部分为透明
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"contactsTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
        _tableView.tableHeaderView = self.searchBar;
    }
    return _tableView;
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [_searchBar setBackgroundImage:[UIImage imageNamed:@"ic_searchBar_bgImage"]];
        [_searchBar sizeToFit];
        [_searchBar setPlaceholder:@"搜索"];
        [_searchBar.layer setBorderWidth:0.5];
        [_searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];
        _searchBar.barTintColor = [UIColor whiteColor];
        _searchBar.translucent = YES;
        [_searchBar setDelegate:self];
        [_searchBar setKeyboardType:UIKeyboardTypeDefault];
    }
    return _searchBar;
}

- (NSMutableArray *)contactsSource{
    if (!_contactsSource) {
        _contactsSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _contactsSource;
}

- (NSMutableArray *)sectionTitles{
    if (!_sectionTitles) {
        _sectionTitles = [NSMutableArray arrayWithCapacity:0];
    }
    return _sectionTitles;
}
@end
