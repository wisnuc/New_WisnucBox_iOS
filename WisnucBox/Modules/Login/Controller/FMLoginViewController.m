//
//  FMLoginViewController.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/14.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMLoginViewController.h"
#import "FMSerachService.h"
#import "UserModel.h"
#import "ServerBrowser.h"
#import "ChooseAlertView.h"
#import "GCDAsyncSocket.h"
#import "FMHandLoginVC.h"
#import "FMCloudUserTableViewCell.h"
#import "LoginTableViewCell.h"
#import "FMUserLoginViewController.h"
#import "WBCloudLoginAPI.h"
#import "CloudLoginModel.h"
#import "WBCloudGetStationsAPI.h"
#import "FMGetUsersAPI.h"
#import "AppDelegate.h"
#import "WBgetStationInfoAPI.h"
#import "WBGetSystemInformationAPI.h"
#import "NSError+WBCode.h"
#import "WBStationBootAPI.h"
#import "BootModel.h"
#import "WBStationManageStorageAPI.h"
#import "WBStationManageStorageModel.h"
#import "WBInitializationViewController.h"


@interface FMLoginViewController ()
<
UIScrollViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
ServerBrowserDelegate,
WXApiDelegate
>
{
    NSMutableArray *_dataSource;
    AFNetworkReachabilityManager * _manager;
    NSTimer* _reachabilityTimer;
    NSMutableArray *_userDataSource;
    RACSubject *_subject;
    int _count;
}
@property (strong, nonatomic) UIScrollView *stationScrollView;
@property (strong, nonatomic) UIView *stationCardView;
@property (strong, nonatomic) UIPageControl *stationPageControl;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UIImageView *stationLogoImageView;
@property (strong, nonatomic) UILabel *stationNameLabel;
@property (strong, nonatomic) UILabel *stationTypeLabel;
@property (strong, nonatomic) UILabel *stationIpLabel;
@property (strong, nonatomic) UIView *userView;
@property (strong, nonatomic) UITableView *userListTableViwe;
@property (strong, nonatomic) UIView *wechatView;
@property (strong, nonatomic) NSMutableArray *tempDataSource;
@property (nonatomic) FMSerachService * expandCell;
@property (nonatomic) NSInteger userDataCount;
@property (nonatomic) UIButton *handButton;
@property (nonatomic) UserModel * user;
@property (strong, nonatomic) NSMutableArray *cloudLoginStationArray;
@property (strong, nonatomic) NSMutableArray *cloudOriginStationArray;
@property (nonatomic) NSInteger current;
@property (nonatomic) NSString *guid;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *nickName;
@property (nonatomic) ServerBrowser* browser;
@property (nonatomic) ChooseAlertView *alertView;
@property (nonatomic) NSString *avatarUrl;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) WBStationManageStorageModel *storageModel;

@end

@implementation FMLoginViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
        _reachabilityTimer =  [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(searchingAndRefresh) userInfo:nil repeats:YES];
    [_reachabilityTimer fire];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    [self.navigationController.navigationBar setBackgroundColor:UICOLOR_RGB(0x0288d1)];
    [UIApplication sharedApplication].statusBarStyle =UIStatusBarStyleLightContent;
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
  
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//      [self firstbeginSearching];
  }

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [_reachabilityTimer invalidate];
    _reachabilityTimer = nil;
    self.browser.delegate = nil;
    [self.browser stopServerBrowser];
}

-(void)dealloc{
    [_reachabilityTimer invalidate];
    _reachabilityTimer = nil;
    self.browser.delegate = nil;
    [self.browser stopServerBrowser];
}

- (instancetype)init{
    if (self = [super init]) {
   
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewOfSeaching:YES];
//    [self firstbeginSearching];
    _count = 0;
    _dataSource = [NSMutableArray arrayWithCapacity:0];
    [self.view addSubview:self.stationScrollView];
 
    [self setStationCardView];
    [self.view addSubview:self.stationPageControl];
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.userView];
    [self.view addSubview:self.userListTableViwe];
    [self.view addSubview:self.handButton];
     if ([WXApi isWXAppInstalled]) {
     [self.view addSubview:self.wechatView];
    }

    [self.view addSubview:self.alertView];
}

- (void)beginSearching {
   
//    double delayInSeconds = 2;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        NSLog(@"发现 %lu 台设备",(unsigned long)self.browser.discoveredServers.count);
//          [self viewOfSeaching:NO];
//    });
    if (self.browser.discoveredServers.count == 0) {
        [SXLoadingView hideProgressHUD];
    }
}

- (void)firstbeginSearching {
    [self viewOfSeaching:YES];
//    double delayInSeconds = 1;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"发现 %lu 台设备",(unsigned long)_browser.discoveredServers.count);
        if (self.browser.discoveredServers.count == 0) {
             [SXLoadingView hideProgressHUD];
        }
//    });
}

static BOOL needHide = YES;
-(void)viewOfSeaching:(BOOL)seaching{
    if(seaching){
        [SXLoadingView showProgressHUD:WBLocalizedString(@"searching", nil)];
    }else{
        if(needHide) {
            needHide = NO;
            NSLog(@"=============>>>>>>>          _____>>>>");
            [SXLoadingView hideProgressHUD];
        }
    }
}

- (void)serverBrowserFoundService:(NSNetService *)service {
//    NSLog(@"%@",service.hostName);
        if ([service.hostName rangeOfString:@"wisnuc-"].location !=NSNotFound) {
            for (NSData * address in service.addresses) {
                NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
                [self findIpToCheck:addressString andService:service];
            }
        }
}

- (void)serverBrowserLostService:(NSNetService *)service index:(NSUInteger)index {
    if (self.browser.discoveredServers.count <= 0) {
        [self beginSearching];
    }
}

- (void)searchingAndRefresh{
    [self beginSearching];
    [self refreshDatasource];
}

-(void)rightBtnClick{
    FMHandLoginVC * vc = [[FMHandLoginVC alloc]init];
    @weaky(self)
    vc.block = ^(FMSerachService * ser){
        ser.isReadly = YES;
        [_dataSource addObject:ser];
        [weak_self refreshDatasource];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)findIpToCheck:(NSString *)addressString andService:(NSNetService *)service{
     @weaky(self)
    __block NSString* urlString = [NSString stringWithFormat:@"http://%@:3000/", addressString];
    NSLog(@"%@", urlString);
    //    @weaky(self)
//    if (IsEquallString(urlString, @"http://10.10.9.141:3000/")) {
    if (!urlString || urlString.length == 0) {
        return;
    }
    FMSerachService * ser = [FMSerachService new];
    
    
//    if ([urlString isEqualToString:@"http://10.10.9.141:3000/"]) {
        [self getBootInfoWithPath:urlString completeBlock:^(BootModel *model) {
            if (IsEquallString(model.error, @"ENOALT")) {
                [[WBStationManageStorageAPI apiWithURLPath:urlString]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                    WBStationManageStorageModel *model = [WBStationManageStorageModel yy_modelWithJSON:request.responseJsonObject];
                    NSLog(@"%@",request.responseJsonObject);
                    if (model.volumes && model.volumes.count == 0) {
                    ser.storageModel = model;
                    [weak_self getSystemInformationWithURL:addressString Service:service Name:nil FMSerachServiceModel:ser NASType:NASTypeUninitialized];
                    }
                } failure:^(__kindof JYBaseRequest *request) {
                    
                }];
                return ;
            }
            
            [[WBgetStationInfoAPI apiWithServicePath:urlString]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                //            NSLog(@"%@",request.responseJsonObject);
                NSDictionary *rootDic =  request.responseJsonObject;
                NSString *nameString = [rootDic objectForKey:@"name"];
                if (nameString.length == 0) {
                    nameString = @"闻上盒子";
                }
               [weak_self getSystemInformationWithURL:addressString Service:service Name:nameString FMSerachServiceModel:ser NASType:NASTypeNormal];
            } failure:^(__kindof JYBaseRequest *request) {
                NSString *nameString = @"闻上盒子";
                [weak_self getSystemInformationWithURL:addressString Service:service Name:nameString FMSerachServiceModel:ser NASType:NASTypeNormal];
                NSLog(@"%@",request.error);
                NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                if(errorData.length >0){
                    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                    NSLog(@"失败,%@",serializedData);
                }
            }];
        }];
//    }
}

- (void)getBootInfoWithPath:(NSString *)path completeBlock:(void(^)(BootModel *model))block{
    [[WBStationBootAPI apiWithPath:path RequestMethod:@"GET"] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        @weaky(self)
        NSLog(@"%@",request.responseJsonObject);
        BootModel *bootModel = [BootModel yy_modelWithJSON:request.responseJsonObject];
//        if (bootModel.current) {
            if ([bootModel.state isEqualToString:@"started"]) {
                block(bootModel);
            }else if ([bootModel.state isEqualToString:@"stopping"]){
                
            }else{
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    _count ++;
//                    if (_count<11) {
                         [weak_self getBootInfoWithPath:path completeBlock:block];
//                    }
                });
            }
//        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
}

- (void)getSystemInformationWithURL:(NSString *)url Service:(NSNetService *)service Name:(NSString *)name FMSerachServiceModel:(FMSerachService *)model NASType:(NASType)NAStype{
      @weaky(self)
      NSString* finalUrl = [NSString stringWithFormat:@"http://%@:3000/", url];
    [[WBGetSystemInformationAPI apiWithServicePath:finalUrl]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        //            NSLog(@"%@",request.responseJsonObject);
      
        NSDictionary *rootDic =request.responseJsonObject;
        NSDictionary *dic = [rootDic objectForKey:@"ws215i"];
        NSString *type;
        if (dic) {
            type = @"WS215i";
        }else{
            type = WBLocalizedString(@"virtual_machine",nil);
        }
        FMSerachService *ser = model;
        if (name) {
            ser.name = name;
        }
        ser.isNormal = YES;
        if (NAStype == NASTypeUninitialized) {
            ser.name = @"未配置";
            ser.isNormal = NO;
            if (_storageModel) {
                ser.storageModel = _storageModel;
            }
        }
        
        ser.path = finalUrl;
        ser.type = type;
        //            MyNSLog(@"%@",service.type);
        ser.displayPath = url;
        ser.hostName = service.hostName;
        _expandCell = ser;
        if (_dataSource.count == 0) {
            [_dataSource addObject:ser];
            [weak_self refreshDatasource];
            return ;
        }
        BOOL isNew = YES;
        for (FMSerachService * s in _dataSource) {
            if (IsEquallString(s.path, ser.path)) {
                isNew = NO;
                break;
            }
        }
        if (isNew) {
            [_dataSource addObject:ser];
            [weak_self refreshDatasource];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
    
}

- (void)refreshDatasource{

    NSMutableArray * temp = [NSMutableArray arrayWithCapacity:0];
    _userDataSource = [NSMutableArray arrayWithCapacity:0];
    for (FMSerachService * ser in _dataSource) {
        if (ser.isNormal) {
            if (ser.isReadly) {
                [temp addObject:ser];
            }
        }else{
             [temp addObject:ser];
            
        }
    }

    if(self.tempDataSource.count != temp.count){
        self.tempDataSource = temp;
        [self.userListTableViwe reloadData];
    }else if (self.tempDataSource && self.tempDataSource.count ==0){
        self.tempDataSource = temp;
        [self.userListTableViwe reloadData];
    }
    if (_stationScrollView) {
        [_stationScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    [self updateInfo];
    [self setStationCardView];
    [SXLoadingView hideProgressHUD];
}

- (void)updateInfo{
    _stationScrollView.contentSize = CGSizeMake(self.tempDataSource.count * __kWidth, 0);
    _stationPageControl.numberOfPages = self.tempDataSource.count;
}

- (void)setStationCardView{
    if (self.tempDataSource.count ==0) {
        _stationCardView = [[UIView alloc]init];
        _stationCardView.backgroundColor =  UICOLOR_RGB(0x03a9f4);
        _stationCardView.frame = CGRectMake(32,64,__kWidth - 32*2, 166);
        _stationCardView.layer.cornerRadius = 8;
        _stationCardView.layer.masksToBounds = YES;
        [self.stationScrollView addSubview:self.stationCardView];
        //        [self setStationLogoImageView];
        [self setNullInfo];
    }else{
        for (int i = 0; i<self.tempDataSource.count; i++) {
            _stationCardView = [[UIView alloc]init];
            _stationCardView.backgroundColor =  UICOLOR_RGB(0x03a9f4);
            _stationCardView.frame = CGRectMake(i*__kWidth + 32,64,__kWidth - 32*2, 166);
            _stationCardView.layer.cornerRadius = 8;
            _stationCardView.layer.masksToBounds = YES;
            [self.stationScrollView addSubview:self.stationCardView];
            
            //        [self setInfoButton];
            [self setStationLogoImageView];
            [self setInfo];
            FMSerachService *ser = _tempDataSource[i];
            if ([NSThread isMainThread]){
                [self reloadDataWithService:ser];
            }else{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self reloadDataWithService:ser];
                });
            }
        }
        
        FMSerachService *serforUser;
        if (_userDataCount > 0) {
            serforUser  = _tempDataSource[_userDataCount];
            
        }else{
            serforUser  = _tempDataSource[0];
        }
        _userDataSource = serforUser.users;
        [self initializationLayoutUpdateWithModel:serforUser];
        [self.userListTableViwe reloadData];
    }
}

- (void)setInfoButton{
    UIImage *infoImage = [UIImage imageNamed:@"info"];
    _infoButton = [[UIButton alloc]init];
    [_infoButton setImage:infoImage forState:UIControlStateNormal];
    [_infoButton addTarget:self action:@selector(infoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_stationCardView addSubview:self.infoButton];
    [_infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.centerY.equalTo(_stationCardView);
        make.size.mas_equalTo(infoImage.size);
    }];
}

- (void)setStationLogoImageView{
    UIImage *logo = [UIImage imageNamed:@"stationLogo"];
    _stationLogoImageView = [[UIImageView alloc]initWithImage:logo];
    [self.stationCardView addSubview:self.stationLogoImageView];
    [_stationLogoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationCardView.mas_left).offset(16);
        make.centerY.equalTo(_stationCardView);
        make.size.mas_equalTo(logo.size);
    }];
}
- (void)setNullInfo{
    _stationTypeLabel = [[UILabel alloc]init];
    _stationTypeLabel.text = @"未搜索到设备";
    _stationTypeLabel.font = [UIFont boldSystemFontOfSize:16];
    _stationTypeLabel.textColor = [UIColor whiteColor];
    _stationTypeLabel.textAlignment = NSTextAlignmentCenter;
    _stationTypeLabel.alpha = 0.87;
    [self.stationCardView addSubview:self.stationTypeLabel];
    [_stationTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationCardView.mas_left).offset(16);
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.centerY.equalTo(_stationCardView.mas_centerY);
        make.height.equalTo(@15);
    }];
}

- (void)setInfo{
    _stationTypeLabel = [[UILabel alloc]init];
    _stationTypeLabel.text = @"我的设备";
    _stationTypeLabel.font = [UIFont systemFontOfSize:14];
    _stationTypeLabel.textColor = [UIColor whiteColor];
    _stationTypeLabel.alpha = 0.54;
    [self.stationCardView addSubview:self.stationTypeLabel];
    [_stationTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationLogoImageView.mas_right).offset(16);
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.centerY.equalTo(_stationCardView.mas_centerY).offset(2);
        make.height.equalTo(@15);
    }];

    _stationNameLabel = [[UILabel alloc]init];
    _stationNameLabel.text = @"WS215i";
    _stationNameLabel.font = [UIFont boldSystemFontOfSize:16];
    _stationNameLabel.textColor = [UIColor whiteColor];
    _stationNameLabel.alpha = 0.87;
    [self.stationCardView addSubview:self.stationNameLabel];
    [_stationNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationLogoImageView.mas_right).offset(16);
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.bottom.equalTo(_stationTypeLabel.mas_top).offset(-3.5);
        make.height.equalTo(@20);
    }];
    
    _stationIpLabel = [[UILabel alloc]init];
    _stationIpLabel.text = @"10.10.10";
    _stationIpLabel.font = [UIFont systemFontOfSize:16];
    _stationIpLabel.textColor = [UIColor whiteColor];
    _stationIpLabel.alpha = 0.54;
    [self.stationCardView addSubview:self.stationIpLabel];
    [_stationIpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationLogoImageView.mas_right).offset(16);
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.top.equalTo(_stationTypeLabel.mas_bottom).offset(2);
        make.height.equalTo(@15);
    }];
}

- (void)reloadDataWithService:(FMSerachService *)ser{
    _stationTypeLabel.text = ser.type;
    if ([ser.type isEqualToString:WBLocalizedString(@"virtual_machine",nil)]) {
         _stationLogoImageView.image = [UIImage imageNamed:@"virtual_machine"];
    }
    _stationNameLabel.text = ser.name;
     _stationIpLabel.text = ser.displayPath;
 
//      [self viewOfSeaching:NO];
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    [self.userListTableViwe reloadData];
}

- (void) applicationDidBecomeActive:(NSNotification*)notification {
    [self beginSearching];
}

-(void)wechatLoginAction:(id)sender{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
    }
    else {
        [self setupAlertController];
    }
}

- (void)setupAlertController{
    [SXLoadingView showProgressHUDText:WBLocalizedString(@"not_installed_WeChat", nil) duration:1.5];
}

- (void)weChatCallBackRespCode:(NSString *)code{
    @weaky(self)
    [SXLoadingView showProgressHUD:@""];
    self.cloudLoginStationArray=[NSMutableArray arrayWithCapacity:0];
    [[WBCloudLoginAPI apiWithCode:code] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView updateProgressHUD:WBLocalizedString(@"loading...", nil)];
        CloudLoginModel * model = [CloudLoginModel yy_modelWithJSON:request.responseJsonObject];
        weak_self.token = model.data.token;
        weak_self.avatarUrl = model.data.user.avatarUrl;
        [weak_self getStationWithModel:model completeBlock:^(NSError *error, NSArray<NSDictionary *> *stations) {
            if(error) {
                [SXLoadingView hideProgressHUD];
                NSLog(@"%@", error);
                if(error.wbCode == 50001)
                    [SXLoadingView showAlertHUD:WBLocalizedString(@"no_binding_user_in_nas", nil) duration:1];
                if(error.wbCode == 50002)
                    [SXLoadingView showAlertHUD:WBLocalizedString(@"no_online_device", nil) duration:1];
                else
                    [SXLoadingView showAlertHUD:WBLocalizedString(@"error", nil) duration:1];
            }else {
                _alertView.hidden = NO;
                [stations enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [weak_self getUsersWithStationDic:obj Model:model completeBlock:^(NSError *err, CloudModelForUser *user) {
                        [SXLoadingView hideProgressHUD];
                        if(err) {
                            return [SXLoadingView showAlertHUD:WBLocalizedString(@"no_user_info", nil) duration:1];
                        }
                        [weak_self.cloudLoginStationArray addObject:user];
                        [weak_self.alertView.tableView reloadData];
                    }];
                }];
            }
        }];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSLog(@"%@",request.error);
        NSHTTPURLResponse * res = (NSHTTPURLResponse *)request.dataTask.response;
        [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"%@:%ld",WBLocalizedString(@"login_failed", nil),(long)res.statusCode] duration:1];
    }];
}
- (void)infoButtonClick:(UIButton *)sender{
    NSLog(@"点击了信息");
}

// wberror: 50001 --> 未绑定设备
// 50002  --->  无在线设备
// 50003  --->
- (void)getStationWithModel:(CloudLoginModel *)model completeBlock:(void(^)(NSError *, NSArray<NSDictionary *> *))callback {
    [[WBCloudGetStationsAPI apiWithGuid:model.data.user.userId andToken:model.data.token]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary *rootDic = request.responseJsonObject;
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[rootDic objectForKey:@"data"]];
        NSMutableArray *onlineArray = [NSMutableArray arrayWithCapacity:0];
        if([rootDic[@"data"] isEqual:[NSNull null]]||rootDic[@"data"] == nil ||dataArray.count == 0) {
            NSError * err = [NSError errorWithDomain:@"no station had bind" code:50001 userInfo:nil];
            err.wbCode = 50001;
            return callback(err, nil);
        }else{
            [dataArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSNumber * isOnlineNumber = dic[@"isOnline"];
                if ([isOnlineNumber boolValue])
                    [onlineArray addObject:dic];
            }];
            if (onlineArray.count == 0) {
                NSError * err = [NSError errorWithDomain:@"no station on line" code:50001 userInfo:nil];
                err.wbCode = 50002;
                return callback(err, nil);
            }else
                return callback(nil, onlineArray);
        }
    } failure:^(__kindof JYBaseRequest *request) {
        return callback(request.error, nil);
    }];
}

- (void)getUsersWithStationDic:(NSDictionary *)stationDic Model:(CloudLoginModel *)model completeBlock:(void(^)(NSError *, CloudModelForUser *user))block{
     NSString *stationId = stationDic[@"id"];
    FMGetUsersAPI *api = [FMGetUsersAPI apiWithStationId:stationId Token:model.data.token];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary *rootDic = request.responseJsonObject;
        NSMutableArray *arr = rootDic[@"data"];
        NSMutableDictionary *mutableDic;
        for (int i = 0; i<arr.count; i++) {
            NSDictionary *dic = arr[i];
            if (dic[@"global"]!=nil && dic[@"global"]!=[NSNull null]) {
                NSDictionary *globalDic = dic[@"global"];
                NSString * idString =  globalDic[@"id"];
                if ([model.data.user.userId isEqualToString:idString]) {
                     mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [mutableDic addEntriesFromDictionary:stationDic];
                     NSLog(@"%@",model.data.user.userId);
                    CloudModelForUser *userModel = [CloudModelForUser yy_modelWithDictionary:mutableDic];
                    if(stationDic[@"LANIP"] && ((NSArray *)stationDic[@"LANIP"]).count){
                        userModel.LANIP = stationDic[@"LANIP"][0];
                    }
                    return block(nil, userModel);
                }
            }
        }
        
        NSLog(@"FUCK FOR NO USER!");
        NSError * e = [NSError errorWithDomain:@"No this User" code:50003 userInfo:nil];
        return block(e, nil);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        return block(request.error, nil);
    }];
}

- (void)loginButtonClick:(UIButton *)sender{
    [SXLoadingView showProgressHUD:WBLocalizedString(@"logging_in", nil)];
    [self.alertView setHidden:YES];
    CloudModelForUser *userModel;
    if (_cloudLoginStationArray.count!=0) {
        userModel  = _cloudLoginStationArray[_current];
    }
    [WB_AppServices wechatLoginWithUserModel:userModel Token:_token AvatarUrl:_avatarUrl addr:WX_BASE_URL completeBlock:^(NSError *error, WBUser *user) {
        sender.userInteractionEnabled = YES;
        if(error || IsNilString(user.userHome)){
            if(!user) NSLog(@"GET TOKEN ERROR");
            else NSLog(@"Get User Home Error");
            [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"%@ code: %ld", WBLocalizedString(@"login_failed", nil),error.wbCode] duration:1];
            [SXLoadingView hideProgressHUD];
        }else{
            [MyAppDelegate initRootVC];
            [SXLoadingView hideProgressHUD];
        }
    }];
}

- (void)initializationLayoutUpdateWithModel:(FMSerachService *)model{
    if (model.isNormal || _userDataSource.count !=0) {
        [_userView setHidden:NO];
        [_userListTableViwe removeEmptyView];
        _userListTableViwe.bounces = YES;
    }else{
        [_userListTableViwe removeEmptyView];
        [_userView setHidden:YES];
        _userListTableViwe.bounces = NO;
        _userListTableViwe.noDataImageName = @"disk_settings";
        CGRect rect = CGRectMake(0, 0, self.userListTableViwe.bounds.size.width, self.userListTableViwe.bounds.size.height);
        NSLog(@"%@--- %@",NSStringFromCGRect(rect),NSStringFromCGRect(self.userListTableViwe.bounds));
        [_userListTableViwe displayWithMsg:WBLocalizedString(@"initialization", nil) withRowCount:0 andIsNoData:YES  andTableViewFrame:rect
                             andTouchBlock:^(UIButton *btn) {
                                 //                                      NSLog(@"😋");
                                 WBInitializationViewController *initializationVC = [[WBInitializationViewController alloc]init];
                                 initializationVC.searchModel = model;
                                 [self.navigationController pushViewController:initializationVC animated:YES];
                             }];
    }
}

#pragma mark ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.stationScrollView &&scrollView.contentOffset.x > __kWidth/2) {
        int page = scrollView.contentOffset.x/__kWidth;
        _stationPageControl.currentPage = page;
        _currentPage = page;
        if (page > _tempDataSource.count) {
            return;
        }
        FMSerachService *ser = _tempDataSource[page];
        _userDataSource = ser.users;
        _userDataCount = page;
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.stationScrollView) {
        FMSerachService *ser = _tempDataSource[_currentPage];
        [self initializationLayoutUpdateWithModel:ser];
        [_userListTableViwe reloadData];
    }
}

#pragma mark tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.alertView.tableView) {
        return _cloudLoginStationArray.count;
    }else{
        return _userDataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _userListTableViwe) {
        LoginTableViewCell *cell;
        self.userListTableViwe.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LoginTableViewCell class])];
        if (!cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:@"LoginTableViewCell" owner:nil options:nil] lastObject];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UserModel *model = _userDataSource[indexPath.row];
        NSLog(@"%@======%lu",model.username,(unsigned long)_userDataSource.count);
        cell.userNameLabel.text = model.username;
        cell.userNameImageView.image = [UIImage imageForName:model.username size:cell.userNameImageView.bounds.size];
        
        return cell;
    }else{
      FMCloudUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMCloudUserTableViewCell class])];
        if (!cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:@"FMCloudUserTableViewCell" owner:nil options:nil] lastObject];
        }
     
       CloudModelForUser *model = _cloudLoginStationArray[indexPath.row];
       NSLog(@"%@",model);
       cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
       cell.userNameLabel.text = [NSString stringWithFormat:@"%@",model.username];
       cell.stationName.text = [NSString stringWithFormat:@"在%@上",model.name];
        return cell;
    }
    
}

#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _userListTableViwe) {
        UserModel *model = _userDataSource[indexPath.row];;
//        NSLog(@"%@",model.global);
        FMUserLoginViewController *userLoginVC = [[FMUserLoginViewController alloc]init];
        FMSerachService * ser;
        if (_userDataCount >0) {
            ser  = _tempDataSource[_userDataCount];
        }else{
            ser = _tempDataSource[0];
        }
        userLoginVC.service = ser;
        userLoginVC.user = model;
        [self.navigationController pushViewController:userLoginVC animated:YES];
        [self applicationWillResignActive:nil];
    }else{
        _current=indexPath.row;
        [self.alertView.tableView reloadData];
    }
    
}

- (UITableViewCellAccessoryType)tableView:(UITableView*)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath*)indexPath
{

    if(tableView == self.alertView.tableView){
        if(_current==indexPath.row)
        {
            return UITableViewCellAccessoryCheckmark;
        }
        else
        {
            return UITableViewCellAccessoryNone;
        }
    }else{
        return UITableViewCellAccessoryNone;
    }

}
- (UIScrollView *)stationScrollView{
    if (!_stationScrollView) {
        _stationScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, __kWidth,448/2 + 64)];
        _stationScrollView.backgroundColor = UICOLOR_RGB(0x0288d1);
        _stationScrollView.pagingEnabled = YES;
//        _stationScrollView.contentSize = CGSizeMake(self.tempDataSource.count * JYSCREEN_WIDTH, 0);
        _stationScrollView.delegate = self;
        _stationScrollView.bounces = YES;
        _stationScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _stationScrollView;
}

- (UIPageControl *)stationPageControl{
    if (!_stationPageControl) {
        _stationPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,self.stationScrollView.frame.size.height - 36 , __kWidth, 30)];
//        _stationPageControl.numberOfPages = self.tempDataSource.count;
        _stationPageControl.currentPage = 0;
    }
    return _stationPageControl;
}

- (UIImageView *)logoImageView{
    if (!_logoImageView) {
        UIImage *logoImage = [UIImage imageNamed:@"logo"];
        CGSize logoSize=logoImage.size;
        _logoImageView = [[UIImageView alloc]initWithImage:logoImage];
        _logoImageView.frame = CGRectMake(16, 40, logoSize.width, logoSize.height);
    }
    return _logoImageView;
}

-(UIView *)userView{
    if (!_userView) {
        _userView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.stationScrollView.frame) + 8, __kWidth , 40)];
        _userView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, __kWidth - 16, 40)];
        label.text = WBLocalizedString(@"user", nil);
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor lightGrayColor];
        [_userView addSubview:label];
    }
    return _userView;
}

- (UITableView *)userListTableViwe{
    if (!_userListTableViwe) {
        _userListTableViwe = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.userView.frame), __kWidth, __kHeight - _stationScrollView.frame.size.height - 8 - _userView.frame.size.height -48) style:UITableViewStylePlain];
        if (![WXApi isWXAppInstalled]) {
            _userListTableViwe.frame = CGRectMake(0, CGRectGetMaxY(self.userView.frame), __kWidth, __kHeight - _stationScrollView.frame.size.height - 8 - _userView.frame.size.height);
        }
        _userListTableViwe.delegate = self;
        _userListTableViwe.dataSource = self;
        _userListTableViwe.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//        _userListTableViwe.backgroundColor = [UIColor orangeColor];
    }
    return _userListTableViwe;
}

- (UIView *)wechatView{
    if (!_wechatView) {
        _wechatView = [[UIView alloc]initWithFrame:CGRectMake(0, __kHeight - 48, __kWidth, 48)];
        _wechatView.backgroundColor = [UIColor whiteColor];
        _wechatView.layer.shadowColor = [[UIColor blackColor]CGColor];
        _wechatView.layer.shadowOffset = CGSizeMake(0, 2);
        _wechatView.layer.shadowRadius = 2.0;
        _wechatView.layer.shadowOpacity = 0.4;
        _wechatView.userInteractionEnabled = YES;
        
        UIImage *wechatImage = [UIImage imageNamed:@"WeChat"];
        UIImageView *wechatImageView = [[UIImageView alloc]initWithImage:wechatImage];
        [_wechatView addSubview:wechatImageView];
        [wechatImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_wechatView.mas_centerX).offset(-30);
            make.centerY.equalTo(_wechatView.mas_centerY);
            make.size.mas_equalTo(wechatImage.size);
        }];
        
        UILabel *label = [[UILabel alloc]init];
        label.text = WBLocalizedString(@"wechat_login", nil) ;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.alpha = 0.87;
        [_wechatView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wechatImageView.mas_right).offset(8);
            make.centerY.equalTo(_wechatView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(100,20));
        }];
        
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(wechatLoginAction:)];
        [_wechatView addGestureRecognizer:tapGesture];
    }
    return _wechatView;
}

- (UIButton *)handButton{
    if (!_handButton) {
        _handButton = [[UIButton alloc]initWithFrame:CGRectMake(__kWidth - 16 - 30 , CGRectGetMinY(_logoImageView.frame) - 5, 30, 30)];
        [_handButton setImage:[UIImage imageNamed:@"PLUS"] forState:UIControlStateNormal];
        [_handButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_handButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
      }
    return _handButton;
}

- (ServerBrowser *)browser{
    if (!_browser) {
        _browser = [[ServerBrowser alloc] initWithServerType:@"_http._tcp" port:-1];
        _browser.delegate = self;
    }
    return _browser;
}

- (ChooseAlertView *)alertView{
    if (!_alertView) {
        _alertView = [[[NSBundle mainBundle] loadNibNamed:@"ChooseAlertView" owner:self options:nil] lastObject];
        _alertView.frame = CGRectMake(0, 0, __kWidth, __kHeight);
        _alertView.tableView.delegate = self;
        _alertView.tableView.dataSource = self;
        [_alertView.loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _alertView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _alertView.hidden = YES;
    }
    return _alertView;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_alertView && [touches anyObject].view == _alertView) {
        // 判断点击的区域如果不是菜单按钮_btnMenu, 则关闭菜单
        [_alertView setHidden:YES];
    }
}

@end

@implementation CloudModelForUser
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"stationId" : @"id",
             };
}
@end

@implementation GlobalModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"guid" : @"id",
             };
}
@end
