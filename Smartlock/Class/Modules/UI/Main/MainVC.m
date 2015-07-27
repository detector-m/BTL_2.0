
//
//  MainVC.m
//  Smartlock
//
//  Created by RivenL on 15/3/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "MainVC.h"

#import "LockDevicesVC.h"
#import "SendKeyVC.h"
#import "ProfileVC.h"
//#import "BuyVC.h"
#import "AboutVC.h"
#import "NotificationMessageVC.h"
#import "MoreVC.h"

#pragma mark -
#import "RLAlertLabel.h"
#import "RLColor.h"
#import "RLSecurityPolicy.h"
#import "MSWeakTimer.h"

#import "Message.h"
#import "KeyEntity.h"

#pragma mark -
#import "XMPPManager.h"
#import "SoundManager.h"
#import "DeviceManager.h"
#import "RecordManager.h"



@interface MainVC () <UIWebViewDelegate>

#pragma mark -
@property (nonatomic, strong) NSString *bannersUrl;
@property (nonatomic, strong) UIWebView *bannersView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *openLockBtn;
@property (nonatomic, strong) UIButton *cupidBtn;
@property (nonatomic, strong) UIImageView *arrow;

@property (nonatomic, strong) UIButton *myDeviceBtn;
@property (nonatomic, strong) UIButton *sendKeyBtn;
@property (nonatomic, strong) UIButton *profileBtn;
//@property (nonatomic, strong) UIButton *buyBtn;
@property (nonatomic, strong) UIButton *aboutBtn;
@property (nonatomic, strong) UIButton *messageBtn;
@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UILabel *messageBadgeLabel;

#pragma mark -
@property (nonatomic, strong) NSMutableArray *lockList;

#pragma mark -
@property (assign) BOOL isBannersLoaded;
@property (assign) BOOL isBannersLoading;

@property (assign) BOOL isLockListLoading;

#pragma mark -
@property (nonatomic, strong) NSData *dateData;

#pragma mark -
//@property (nonatomic, strong) NSTimer *animationTimer;

#pragma mark -
@property (nonatomic, strong) MSWeakTimer *autoOpenlockTimer;

@property (nonatomic, assign) BOOL isMainVC;

@property (atomic, assign) BOOL isOpenLockNow;
@end

@implementation MainVC

- (void)dealloc {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockManualNoResponseHandler) object:nil];
    
    [self.lockList removeAllObjects], self.lockList = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.messageBadgeNumber = [[MyCoreDataManager sharedManager] objectsCountWithKey:@"isRead" contains:@NO withTablename:NSStringFromClass([Message class])];

    self.navigationController.navigationBarHidden = YES;
    [self setBackButtonHide:YES];
    [self loadBannersRequest];
    
    [self createAndScheduleAutoOpenlockTimer];
    self.isMainVC = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [self setBackButtonHide:NO];
    [self stopLoadingBannersRequest];
    
    [self cancelAutoOpenlockTimer];
    self.isMainVC = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [User sharedUser].isLogined = YES;
    
    [self setBackButtonHide:YES];

//    self.title = NSLocalizedString(@"yongjiakeji", nil);
    self.title = @"";
    
    [self setupBLCentralManaer];

    [[SoundManager sharedManager] prepareToPlay];
    
    [self setupBackground];
#pragma mark -
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 64);
    self.backgroundImage.frame = self.view.frame;

    [self setupBanners];
    [self setupMainView];
    [self setupLockList];
    [self setupNotification];
}

- (void)setupBLCentralManaer {
    self.manager = [RLBluetooth sharedBluetooth];
}

- (void)setupBackground {
    self.view.backgroundColor = [RLColor colorWithHex:0x253640];
    self.backgroundImage.image = [UIImage imageNamed:@"MainBackground.jpeg"];
}

- (void)setupLockList {
    [[RLBluetooth sharedBluetooth] scanPeripheralsWithCompletionBlock:nil];

    if(!self.lockList) {
        self.lockList = [NSMutableArray new];
    }
    [self loadLockList];
}

- (void)setupNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applictionWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applictionDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applictionDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applictionWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage) name:(NSString *)kReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLogoutMessage) name:(NSString *)kReceiveLogoutMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachable:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

#pragma mark -
//- (void)applictionWillEnterForeground:(id)sender {
////    if(self.isMainVC)
////        [self createAndScheduleAutoOpenlockTimer];
//}
//
//- (void)applictionDidEnterBackground:(id)sender {
////    [self cancelAutoOpenlockTimer];
//}

- (void)applictionDidBecomeActive {
    if(self.isMainVC) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockManualNoResponseHandler) object:nil];
        [[RLBluetooth sharedBluetooth] scanPeripheralsWithCompletionBlock:nil];
        [self createAndScheduleAutoOpenlockTimer];
    }
}

- (void)applictionWillResignActive {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockManualNoResponseHandler) object:nil];
    [self cancelAutoOpenlockTimer];

}

#pragma mark ----------- network status changed
- (void)networkReachable:(id)sender {
    NSNotification *notification = sender;
    NSDictionary *dic = notification.userInfo;
    NSInteger status = [[dic objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if(status > 0) {
        [[XMPPManager sharedXMPPManager] reconnect];
        [self loadBannersRequest];
        
        [self loadLockListFromNet];
        [self updateRecords];
    }
    else {
        [self stopLoadingBannersRequest];
    }
}

static CGFloat BannerViewHeight = 120.0f;
static NSString *kBannersPage = @"/bleLock/advice.jhtml";
- (void)loadBannersRequest {
    if(!self.isBannersLoaded && !self.isBannersLoading) {
        self.bannersView.delegate = self;
        self.isBannersLoading = YES;
        [self.bannersView loadRequest:[self requestForBanners:self.bannersUrl]];
    }
}

- (void)stopLoadingBannersRequest {
    self.isBannersLoading = NO;
    if(!self.isBannersLoaded) {
        [self.bannersView stopLoading];
        self.bannersView.delegate = nil;
    }
}

- (NSURLRequest *)requestForBanners:(NSString *)aUrl {
    DLog(@"%@", aUrl);
    aUrl = [aUrl stringByAppendingString:[NSString stringWithFormat:@"?accessToken=%@", encryptedTokenToBase64([User sharedUser].sessionToken, [User sharedUser].certificazte)]];
    NSURL *newsUrl = [NSURL URLWithString:[aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:newsUrl];
    return request;
}

- (void)setupBanners {
    if(self.bannersView)
        return;
    CGFloat ratio = (3.0/1.0);
    self.bannersUrl = [kRLHTTPAPIBaseURLString stringByAppendingString:kBannersPage];
    CGRect frame = self.view.frame;
    BannerViewHeight = frame.size.width/ratio;
    self.bannersView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, BannerViewHeight)];
    self.bannersView.backgroundColor = [UIColor lightGrayColor];
    self.bannersView.delegate = self;
    self.bannersView.scrollView.bounces = NO;
    [self.view addSubview:self.bannersView];
    [self loadBannersRequest];
}

#define LockSize (120.0f)
- (void)setupMainView {
    if(!self.scrollView) {
        CGRect frame = self.view.frame;
        CGFloat heightOffset = BannerViewHeight+self.bannersView.frame.origin.y+22;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, heightOffset, frame.size.width, frame.size.height-heightOffset)];
        self.scrollView.contentSize = CGSizeMake(frame.size.width, self.scrollView.frame.size.height);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.panGestureRecognizer.delaysTouchesBegan = YES;
        [self.view addSubview:self.scrollView];
        
        /**************** central button ***************/
        frame = self.scrollView.frame;
        
        self.cupidBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cupidBtn.frame = CGRectMake(frame.size.width/2+60, 5, 80, 80);
        [self.cupidBtn setImage:[UIImage imageNamed:@"Cupid.png"] forState:UIControlStateNormal];
        [self.scrollView addSubview:self.cupidBtn];
        
        frame = self.cupidBtn.frame;
        self.arrow = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x+3, frame.origin.y+46, frame.size.width/2, frame.size.height/2)];
        self.arrow.image = [UIImage imageNamed:@"Arrow.png"];
        [self.scrollView addSubview:self.arrow];
        
        frame = self.scrollView.frame;
        heightOffset = self.cupidBtn.frame.origin.y + self.cupidBtn.frame.size.height;
        
        self.openLockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.openLockBtn.frame = CGRectMake(frame.size.width/2-LockSize, heightOffset-7, LockSize, LockSize+10);
        [self.openLockBtn setImage:[UIImage imageNamed:@"Lock.png"] forState:UIControlStateNormal];
        [self.openLockBtn setImage:[UIImage imageNamed:@"Unlock.png"] forState:UIControlStateSelected];
        [self.openLockBtn addTarget:self action:@selector(clickOpenLockBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.openLockBtn];
        [self.scrollView bringSubviewToFront:self.arrow];
        
//        heightOffset += self.openLockBtn.frame.size.height + 20;
        heightOffset = self.scrollView.frame.size.height - 100;
        CGFloat btnWidth = (frame.size.width - 2*(15+5))/3;
        CGFloat btnWidthOffset = 15;
        CGFloat btnHeight = 40;
        self.myDeviceBtn = [self buttonWithTitle:NSLocalizedString(@"我的设备", nil) selector:@selector(clickMyDeviceBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.myDeviceBtn];
        
        btnWidthOffset += 5+btnWidth;
        self.sendKeyBtn = [self buttonWithTitle:NSLocalizedString(@"发送钥匙", nil) selector:@selector(clickSendKeyBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.sendKeyBtn];
        
        btnWidthOffset += 5+btnWidth;
        self.profileBtn = [self buttonWithTitle:NSLocalizedString(@"我的资料", nil) selector:@selector(clickProfileBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.profileBtn];
        
        heightOffset += btnHeight + 5;
        btnWidthOffset = 15;
//        self.buyBtn = [self buttonWithTitle:NSLocalizedString(@"购买", nil) selector:@selector(clickBuyBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
//        [self.scrollView addSubview:self.buyBtn];
        
        self.aboutBtn = [self buttonWithTitle:NSLocalizedString(@"关于", nil) selector:@selector(clickAboutBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.aboutBtn];
    
        btnWidthOffset += 5+btnWidth;
        self.messageBtn = [self buttonWithTitle:NSLocalizedString(@"消息", nil) selector:@selector(clickMessageBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.messageBtn];
        
        self.messageBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.messageBtn.frame.size.width-20-2, 2, 20, 20)];
        self.messageBadgeLabel.backgroundColor = [UIColor redColor];
        self.messageBadgeLabel.textColor = [UIColor whiteColor];
        
        self.messageBadgeLabel.textAlignment = NSTextAlignmentCenter;
        self.messageBadgeLabel.font = [UIFont systemFontOfSize:11];
        self.messageBadgeLabel.layer.cornerRadius = 10;
        self.messageBadgeLabel.clipsToBounds = YES;
        self.messageBadgeNumber = 0;
        [self.messageBtn addSubview:self.messageBadgeLabel];
        
        btnWidthOffset += 5+btnWidth;
        self.moreBtn = [self buttonWithTitle:NSLocalizedString(@"更多", nil) selector:@selector(clickMoreBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.moreBtn];
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title selector:(SEL)selector frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [RLColor colorWithHex:0x81D4EA];//[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[RLColor colorWithHex:0x000000 alpha:0.8]/*[RLColor colorWithHex:0xF2E9AE alpha:0.9]*/ forState:UIControlStateNormal];
    button.layer.cornerRadius = 5.0f;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (NSArray *)sortLockForList:(NSArray *)list {
    return [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        KeyModel *key1 = obj1;
        KeyModel *key2 = obj2;
        if(key1.userType < key2.userType)
            return NSOrderedAscending;
        else if (key1.userType > key2.userType)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

- (void)loadLockList {
    __weak __typeof(self)weakSelf = self;
    [weakSelf.lockList removeAllObjects];
    NSArray *array = [[MyCoreDataManager sharedManager] objectsSortByAttribute:nil withTablename:NSStringFromClass([KeyEntity class])];
    NSMutableArray *tempList = [NSMutableArray array];
    for(KeyEntity *key in array) {
        [tempList addObject:[[KeyModel alloc] initWithKeyEntity:key]];
    }
    
    NSArray *list = [self sortLockForList:tempList];
    [weakSelf.lockList addObjectsFromArray:list];
    [self loadLockListFromNet];
}

- (void)loadLockListFromNet {
    if(self.isLockListLoading)
        return;
    self.isLockListLoading = YES;
    __weak __typeof(self)weakSelf = self;
    [DeviceManager lockList:[User sharedUser].sessionToken withBlock:^(DeviceResponse *response, NSError *error) {
        self.isLockListLoading = NO;
        if(response.status == -999) {
            [weakSelf cancelAutoOpenlockTimer];
            return ;
        }
        if(error || !response.list.count) return;

        NSArray *list = [weakSelf sortLockForList:response.list];
        [weakSelf.lockList removeAllObjects];
        [weakSelf.lockList addObjectsFromArray:list];
        
        [[MyCoreDataManager sharedManager] deleteAllTableObjectInTable:NSStringFromClass([KeyEntity class])];
        for(KeyModel *key in weakSelf.lockList) {
            [[MyCoreDataManager sharedManager] insertUpdateObjectInObjectTable:keyEntityDictionaryFromKeyModel(key) updateOnExistKey:@"keyID" withTablename:NSStringFromClass([KeyEntity class])];
        }
    }];
}

- (void)clickOpenLockBtn:(UIButton *)button {
    [self openLockManual];
}

- (void)clickMyDeviceBtn:(UIButton *)button {
    LockDevicesVC *vc = [LockDevicesVC new];
    vc.mainVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickSendKeyBtn:(UIButton *)button {
    BOOL isAdmin = NO;
    for(KeyModel *key in self.lockList) {
        if(key.userType == 0) {
            isAdmin = YES;
            break;
        }
    }
    
    if(!isAdmin) {
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"你并非管理员！", nil)];
        return;
    }
    SendKeyVC *vc = [[SendKeyVC alloc] init];
    vc.title = NSLocalizedString(@"发送钥匙", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickProfileBtn:(UIButton *)button {
    ProfileVC *vc = [[ProfileVC alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)clickBuyBtn:(UIButton *)button {
//    BuyVC *vc = [[BuyVC alloc] init];
//    vc.title = NSLocalizedString(@"购买", nil);
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)clickAboutBtn:(UIButton *)button {
    AboutVC *vc = [[AboutVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickMessageBtn:(UIButton *)button {
    [[MyCoreDataManager sharedManager] updateObjectsInObjectTable:@{@"isRead" : @YES} withKey:@"isRead" contains:@NO withTablename:NSStringFromClass([Message class])];

    self.messageBadgeNumber = 0;

    NotificationMessageVC *vc = [[NotificationMessageVC alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickMoreBtn:(UIButton *)button {
    MoreVC *vc = [MoreVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 
- (void)receiveMessage {
    self.messageBadgeNumber ++;
    [self loadLockListFromNet];
}

- (void)receiveLogoutMessage{
    [self loadLockListFromNet];
}

#pragma mark - public methods
- (void)removeKey:(KeyModel *)key {
    if(!key)
        return;
    [self.lockList removeObject:key];
}

- (void)setMessageBadgeNumber:(NSInteger)messageBadgeNumber {
    _messageBadgeNumber = messageBadgeNumber;

    if(messageBadgeNumber == 0) {
        self.messageBadgeLabel.hidden = YES;
        
        return;
    }
    
    self.messageBadgeLabel.hidden = NO;
    self.messageBadgeLabel.text = [NSString stringWithFormat:@"%li", (long)messageBadgeNumber];
}

- (NSArray *)locks {
    return self.lockList;
}

#pragma mark - private methods
- (void)addOpenLockRecordWithKey:(KeyModel *)key {
    if(key.type == kKeyTypeTimes) {
        if(key.validCount > 0) {
            --key.validCount;
            
            [[MyCoreDataManager sharedManager] updateObjectsInObjectTable:@{@"useCount":[NSNumber numberWithInteger:key.validCount]} withKey:@"keyID" contains:[NSNumber numberWithInteger:key.ID] withTablename:NSStringFromClass([KeyEntity class])];
        }
    }
    NSDictionary *record = createOpenLockRecord(key.ID, key.lockID);
    [[MyCoreDataManager sharedManager] insertObjectInObjectTable:record withTablename:NSStringFromClass([OpenLockRecord class])];
    [self updateRecords];
}

- (void)updateRecords {
    /*remove invalid records*/
    [RecordManager updateRecordsWithBlock:^(BOOL success) {
        [self loadLockListFromNet];
        
        for(KeyModel *key in self.lockList) {
            if(![key isValid]) {
                [RecordManager removeRecordsWithKeyID:(long long)key.ID];
                
                continue;
            }
        }
    }];
}

/**
 *  同步时间
 *
 *  @param characteristic characteristic
 */
- (void)updateLockTimeWithCharacteristic:(RLCharacteristic *)characteristic withKey:(KeyModel *)key {
    if(!(key.userType == kUserTypeAdmin))
        return;
    int len = 0;
    long long data = key.keyOwner.pwd;
    Byte *dateData = dateNowToBytes(&len);
    self.dateData = [NSData dataWithBytes:dateData length:len];
    int size = sizeof(data)+len;
    Byte *tempData = calloc(size, sizeof(Byte));
    memcpy(tempData, dateData, len);
    
    Byte *temp = (Byte *)&(data);
    for(NSInteger j = len; j<size; j++) {
        tempData[j] = temp[j-len];
    }
    
    NSData *writeData = [NSData dataWithBytes:tempData length:size];
    free(tempData);
    
    Byte cmdMode = 0x01; //0x01->设置 0x00->读取
    
    [[RLBluetooth sharedBluetooth] writeDataToCharacteristic:characteristic cmdCode:0x03 cmdMode:cmdMode withDatas:writeData];
}

- (void)readLockPowerWithCharacteristic:(RLCharacteristic *)characteristic withKey:(KeyModel *)key {
    long long data = key.keyOwner.pwd;
    NSData *writeData = [NSData dataWithBytes:&data length:sizeof(long long)];
    Byte cmdMode = 0x00; //0x01->设置 0x00->读取
    
    [[RLBluetooth sharedBluetooth] writeDataToCharacteristic:characteristic cmdCode:0x06 cmdMode:cmdMode withDatas:writeData];
}

#pragma mark -
- (void)openLockAnimation:(UIButton *)button {
    button.userInteractionEnabled = NO;
    CGRect frame = self.cupidBtn.frame;
    CGRect orignalFrame = CGRectMake(frame.origin.x+3, frame.origin.y+46, frame.size.width/2, frame.size.height/2);// self.arrow.frame;
    __weak __typeof(self)weakSelf = self;
    [UIView animateKeyframesWithDuration:0.3f delay:0.0f options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect frame = self.arrow.frame;
        frame.origin = button.center;
        frame.origin.x += 10;
        frame.origin.y -= 22;
        weakSelf.arrow.frame = frame;
    } completion:^(BOOL finished) {
        if(finished) {
            weakSelf.arrow.frame = orignalFrame;
            weakSelf.arrow.hidden = NO;
            weakSelf.arrow.alpha = 0.0;
            button.selected = !button.selected;
            
            [UIView animateKeyframesWithDuration:0.3f delay:3.5f options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
                weakSelf.arrow.alpha = 0.95;
            } completion:^(BOOL finished) {
                weakSelf.arrow.alpha = 1.0;
                button.userInteractionEnabled = YES;
                button.selected = !button.selected;
                weakSelf.isOpenLockNow = NO;
            }];
        }
    }];
}

#pragma mark －

- (void)openLockWithPeripherals:(NSArray *)peripherals success:(void (^)(RLPeripheralResponse *peripheralRes))success failure:(void (^) (NSArray *peripherals, NSError *error))failure {
    __weak __typeof(self)weakSelf = self;

    for(KeyModel *key in self.lockList) {
        if(![key isValid]) {
            continue;
        }
        
        RLPeripheral *peripheral = [[RLBluetooth sharedBluetooth] peripheralForName:key.keyOwner.address];
        if(!peripheral) {
            continue;
        }
        
        if(![User getVoiceSwitch]) {
            [[SoundManager sharedManager] playSound:@"SoundOperator.mp3" looping:NO];
        }
        RLPeripheralRequest *perRequest = [[RLPeripheralRequest alloc] init];
        perRequest.cmdCode = 0x02;
        perRequest.userPwd = key.keyOwner.pwd;
        
        [[RLBluetooth sharedBluetooth] connectPeripheralThanHandlePeripheral:peripheral withPeripheralRequest:perRequest connectionCompletion:^(NSError *error) {
            if(error) {
                if(failure) {
                    failure(peripherals, error);
                }
                return ;
            }
            
        } notifyCompletion:^(NSError *error) {
            if(error) {
                if(failure) {
                    failure(peripherals, error);
                }
                return ;
            }
        } onUpdateData:^(RLPeripheralResponse *peripheralRes, NSError *error) {
            if(error) {
                if(failure) {
                    failure(peripherals, error);
                }
                return ;
            }
            if(peripheralRes.result == 0x00) {
                [weakSelf addOpenLockRecordWithKey:key];
            }
            
            if(success) {
                success(peripheralRes);
            }
            
        } withDisconnect:nil];
        
        if(peripheral) return;
    }
    
    if(failure) {
        failure(peripherals, nil);
    }
}

- (void)openLockWithSuccess:(void (^)(RLPeripheralResponse *peripheralRes))success failure:(void (^) (NSArray *peripherals, NSError *error))failure {
    if(![[RLBluetooth sharedBluetooth] isSupportBluetoothLow]) return;
    if(![[RLBluetooth sharedBluetooth] bluetoothIsReady]) return;
#if 1
//    [[RLBluetooth sharedBluetooth] scanPeripheralsWithCompletionBlock:^(NSArray *peripherals) {
//        if(!peripherals.count) {
//            if(failure) {
//                failure(nil, nil);
//            }
//            
//            return ;
//        }
//        
//        for(KeyModel *key in weakSelf.lockList) {
//            if(![key isValid]) {
//                continue;
//            }
//            
//            RLPeripheral *peripheral = [[RLBluetooth sharedBluetooth] peripheralForName:key.keyOwner.address];
//            
//            RLPeripheralRequest *perRequest = [[RLPeripheralRequest alloc] init];
//            perRequest.cmdCode = 0x02;
//            perRequest.userPwd = key.keyOwner.pwd;
//            
//            [[RLBluetooth sharedBluetooth] connectPeripheralThanHandlePeripheral:peripheral withPeripheralRequest:perRequest connectionCompletion:^(NSError *error) {
//                if(error) {
//                    if(failure) {
//                        failure(peripherals, error);
//                    }
//                    return ;
//                }
//                
//            } notifyCompletion:^(NSError *error) {
//                if(error) {
//                    if(failure) {
//                        failure(peripherals, error);
//                    }
//                    return ;
//                }
//            } onUpdateData:^(RLPeripheralResponse *peripheralRes, NSError *error) {
//                if(error) {
//                    if(failure) {
//                        failure(peripherals, error);
//                    }
//                    return ;
//                }
//                if(peripheralRes.result == 0x00) {
//                    [weakSelf addOpenLockRecordWithKey:key];
//                    
//                    [RLHUD hudAlertSuccessWithBody:NSLocalizedString(@"开门成功！", nil)];
//
//                }
//                else /*if(peripheralRes.result == 0x02)*/ {
//                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"请重新设置管理员！", nil)];
//                }
//                
//                if(peripheralRes.powerCode == 0x01) {
//                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"电池电压过低，请更换电池！", nil)];
//                }
//                
//                if(peripheralRes.updateTimeCode == 0x01) {
//                    
//                }
//                
//                
//                if(success) {
//                    success(peripheralRes);
//                }
//                
//            } withDisconnect:nil];
//            
//            if(peripheral) return;
//        }
//        
//        if(failure) {
//            failure(peripherals, nil);
//        }
//    }];
    
    NSArray *peripherals = [RLBluetooth sharedBluetooth].manager.peripherals;
    if(!peripherals.count) {
        [[RLBluetooth sharedBluetooth] scanPeripheralsWithCompletionBlock:^(NSArray *tempPeripherals) {
            if(!tempPeripherals.count) {
                if(failure) {
                    failure(nil, nil);
                }
                
                return ;
            }
            
            [self openLockWithPeripherals:peripherals success:success failure:failure];
        }];
        return;
    }
    
    [self openLockWithPeripherals:peripherals success:success failure:failure];
#else
    [[RLBluetooth sharedBluetooth] scanPeripheralsWithCompletionBlock:^(NSArray *peripherals) {
        if(!peripherals.count) {
            if(failure) {
                failure(nil, nil);
            }
            
            return ;
        }
        
        for(KeyModel *key in weakSelf.lockList) {
            if(![key isValid]) {
                continue;
            }
            
            RLPeripheral *peripheral = [[RLBluetooth sharedBluetooth] peripheralForName:key.keyOwner.address];
            
            RLPeripheralRequest *perRequest = [[RLPeripheralRequest alloc] init];
            perRequest.cmdCode = 0x02;
            perRequest.userPwd = key.keyOwner.pwd;
            
            [[RLBluetooth sharedBluetooth] btlConnectPeripheralThanHandlePeripheral:peripheral withPeripheralRequest:perRequest connectionCompletion:^(NSError *error) {
                if(error) {
                    if(failure) {
                        failure(peripherals, error);
                    }
                    return ;
                }
                
            } notifyCompletion:^(NSError *error) {
                if(error) {
                    if(failure) {
                        failure(peripherals, error);
                    }
                    return ;
                }
            } onUpdateData:^(RLPeripheralResponse *peripheralRes, NSError *error) {
                if(error) {
                    if(failure) {
                        failure(peripherals, error);
                    }
                    return ;
                }
                if(peripheralRes.result == 0x00) {
                    [weakSelf addOpenLockRecordWithKey:key];
                }
                
                if(success) {
                    success(peripheralRes);
                }
                
            } withDisconnect:nil];
            
            if(peripheral) return;
        }
        
        if(failure) {
            failure(peripherals, nil);
        }
    }];
#endif
}
- (void)openLock {
    __weak __typeof(self)weakSelf = self;
    if(self.isOpenLockNow) return;
    self.isOpenLockNow = YES;
    [self openLockWithSuccess:^(RLPeripheralResponse *peripheralRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(peripheralRes.result == 0x00) {
                [weakSelf openLockAnimation:weakSelf.openLockBtn];
                [RLHUD hudAlertSuccessWithBody:NSLocalizedString(@"开门成功！", nil)];
                if([User getVoiceSwitch]) return ;
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                [[SoundManager sharedManager] playSound:@"DoorOpened.mp3" looping:NO];
            }
            else /*if(peripheralRes.result == 0x02)*/ {
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"请重新设置管理员！", nil)];
                
                weakSelf.isOpenLockNow = NO;
            }
            
            if(peripheralRes.powerCode == 0x01) {
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"电池电压过低，请更换电池！", nil)];
            }
            
            if(peripheralRes.updateTimeCode == 0x01) {
                
            }
        });
        
    } failure:^(NSArray *peripherals, NSError *error) {
        if(!peripherals) {
            if(error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"连接出错!", nil)];
                });
            }
        }
        else {
            if(peripherals.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用设备!", nil)];

                });
            }
            else if(peripherals.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用的钥匙！", nil)];
                });
            }
        }
        weakSelf.isOpenLockNow = NO;
    }];
}

- (void)noResponseHandlerForOpenLockManual {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockManualNoResponseHandler) object:nil];
    [self performSelector:@selector(openLockManualNoResponseHandler) withObject:nil afterDelay:3.0f];
}

- (void)openLockManualNoResponseHandler {
    self.openLockBtn.userInteractionEnabled = YES;
}
- (void)openLockManual {
    if(![User getAutoOpenLockSwitch]) return;
    if(![[RLBluetooth sharedBluetooth] isSupportBluetoothLow]) {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"不支持低功耗蓝牙！", nil)];

        return;
    }
    if(![[RLBluetooth sharedBluetooth] bluetoothIsReady])  {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"未开启蓝牙！", nil)];

        return;
    }
    __weak __typeof(self)weakSelf = self;
    self.openLockBtn.userInteractionEnabled = NO;
    [self noResponseHandlerForOpenLockManual];
    [self openLockWithSuccess:^(RLPeripheralResponse *peripheralRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockManualNoResponseHandler) object:nil];

            [weakSelf openLockAnimation:weakSelf.openLockBtn];
            if(peripheralRes.result == 0x00) {
                [RLHUD hudAlertSuccessWithBody:NSLocalizedString(@"开门成功！", nil)];

                if([User getVoiceSwitch]) return ;
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                [[SoundManager sharedManager] playSound:@"DoorOpened.mp3" looping:NO];
            }
            
            if(peripheralRes.powerCode == 0x01) {
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"电池电压过低，请更换电池！", nil)];
            }
            
            if(peripheralRes.updateTimeCode == 0x01) {
                
            }
        });
        
    } failure:^(NSArray *peripherals, NSError *error) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockManualNoResponseHandler) object:nil];

        if(!peripherals) {
            if(error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"连接出错!", nil)];
                });
            }
            else
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用设备!", nil)];
                });

        }
        else {
            if(peripherals.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用设备!", nil)];
                });
            }
            else if(peripherals.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用的钥匙！", nil)];
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.openLockBtn.userInteractionEnabled = YES;
        });
    }];
}

/**
 *  自动开锁
 */
- (void)createAndScheduleAutoOpenlockTimer {
    
    if(![[RLBluetooth sharedBluetooth] isSupportBluetoothLow])
        return;
    
    self.isOpenLockNow = NO;
    if([User getAutoOpenLockSwitch]) return;
    if(self.autoOpenlockTimer) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.autoOpenlockTimer invalidate];
        self.autoOpenlockTimer = nil;
        self.autoOpenlockTimer = [MSWeakTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(openLock) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [self openLock];
    });
}

- (void)cancelAutoOpenlockTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.autoOpenlockTimer invalidate];
        self.autoOpenlockTimer = nil;
    });
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //判断是否是单击
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = [request URL];
        if([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
            
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.isBannersLoaded = NO;
    self.isBannersLoading = YES;
    [RLHUD hudProgressWithBody:nil onView:webView timeout:4.0f];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.isBannersLoaded = YES;
    self.isBannersLoading = NO;
    [RLHUD hideProgress];
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"error=%@", error);
    self.isBannersLoaded = NO;
    self.isBannersLoading = NO;
    [RLHUD hideProgress];
}
@end