
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
#import "BuyVC.h"
//#import "AboutVC.h"
#import "NotificationMessageVC.h"
#import "MoreVC.h"
#import "BannerDetailVC.h"
#import "SystemSettingVC.h"

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

#if 0
//#warning 暂时以天使作为常开常闭的关门开关, 后续需要做调整
/*
 **************************************************************
 **************************************************************
 **************************************************************
            暂时以天使作为常开常闭的关门开关, 后续需要做调整
        cupidBtn
 **************************************************************
 **************************************************************
 **************************************************************
 */
#endif

@interface MainVC () <UIWebViewDelegate>

#pragma mark -
@property (nonatomic, strong) NSString *bannersUrl;
@property (nonatomic, strong) UIWebView *bannersView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *openLockBtn;
//@property (nonatomic, strong) UIButton *closeLockBtn;
@property (nonatomic, strong) UIButton *normallyOpenLockBtn;
@property (nonatomic, strong) UIButton *normallyCloseLockBtn;
@property (nonatomic, strong) UIButton *cupidBtn;
@property (nonatomic, strong) UIImageView *arrow;

@property (nonatomic, strong) UIButton *myDeviceBtn;
@property (nonatomic, strong) UIButton *sendKeyBtn;
@property (nonatomic, strong) UIButton *settingBtn;

@property (nonatomic, strong) UIButton *buyBtn;
//@property (nonatomic, strong) UIButton *aboutBtn;
@property (nonatomic, strong) UIButton *messageBtn;
//@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *profileBtn;

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
@property (nonatomic, assign) BOOL isNeedPop;
@property (nonatomic, assign) Byte openLockCmdCode;

@property (nonatomic, assign) BOOL isPeripheralResponsed;
@end

@implementation MainVC

- (void)dealloc {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockNoResponseHandler) object:nil];
    
    [self.lockList removeAllObjects], self.lockList = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([User getAutoOpenLockSwitch] && [User getOpenLockTypeSwitch]) {
//        self.closeLockBtn.hidden = NO;
        self.normallyOpenLockBtn.enabled = YES;
        self.normallyCloseLockBtn.enabled = YES;
        
        self.normallyOpenLockBtn.hidden = NO;
        self.normallyCloseLockBtn.hidden = NO;
    }
    else {
//        self.closeLockBtn.hidden = YES;
        self.normallyOpenLockBtn.enabled = NO;
        self.normallyCloseLockBtn.enabled = NO;
        
        self.normallyOpenLockBtn.hidden = YES;
        self.normallyCloseLockBtn.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.messageBadgeNumber = [[MyCoreDataManager sharedManager] objectsCountWithKey:@"isRead" contains:@NO withTablename:NSStringFromClass([Message class])];

    [UIView animateWithDuration:0.1 animations:^{
        self.navigationController.navigationBarHidden = YES;
    }];
    [self setBackButtonHide:YES];
    [self loadBannersRequest];
    
    [self createAndScheduleAutoOpenlockTimer];
    self.isMainVC = YES;
    self.isPeripheralResponsed = YES;
    _openLockCmdCode = 0x02; //普通开门
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
    
    _isNeedPop = YES;
    
    [User sharedUser].isLogined = YES;
    
    [self setBackButtonHide:YES];

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
    self.view.backgroundColor = [RLColor colorWithHexString:@"#0099cc"];//[RLColor colorWithHex:0x253640];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applictionWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applictionDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applictionDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applictionWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage) name:(NSString *)kReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLogoutMessage) name:(NSString *)kReceiveLogoutMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachable:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

#pragma mark -
- (void)applictionWillEnterForeground:(id)sender {
    _isNeedPop = YES;
    if(![[RLBluetooth sharedBluetooth] isSupportBluetoothLow]) {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"不支持低功耗蓝牙！", nil)];
        
        return;
    }
    if(![[RLBluetooth sharedBluetooth] bluetoothIsReady])  {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"未开启蓝牙！请打开蓝牙！", nil)];
        
        return;
    }
}

- (void)applictionDidEnterBackground:(id)sender {
    _isNeedPop = NO;
}

- (void)applictionDidBecomeActive {
    if(self.isMainVC) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockNoResponseHandler) object:nil];
        [[RLBluetooth sharedBluetooth] scanPeripheralsWithCompletionBlock:nil];
        [self createAndScheduleAutoOpenlockTimer];
    }
}

- (void)applictionWillResignActive {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockNoResponseHandler) object:nil];
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
//    DLog(@"%@", aUrl);
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
        CGFloat heightOffset = BannerViewHeight+self.bannersView.frame.origin.y+2;
        if([UIScreen mainScreen].bounds.size.height > 480) {
            heightOffset += 55;
        }
//        if(!([User getAutoOpenLockSwitch] && [User getOpenLockTypeSwitch])) {
//            heightOffset += 20;
//        }
        
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
        
#pragma mark -
//        [self.cupidBtn addTarget:self action:@selector(clickCupidBtn:) forControlEvents:UIControlEventTouchUpInside];
#pragma mark -
        
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
        
/**
 * 关门
 **/
#if 0
        heightOffset = self.cupidBtn.frame.origin.y + self.openLockBtn.frame.size.height;
        self.closeLockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeLockBtn.frame = CGRectMake(frame.size.width-LockSize, heightOffset-7, LockSize, LockSize+10);
        [self.closeLockBtn setImage:[UIImage imageNamed:@"Unlock.png"] forState:UIControlStateNormal];
        [self.closeLockBtn addTarget:self action:@selector(clickCloseLockBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.closeLockBtn];
        self.closeLockBtn.hidden = YES;
        if([User getAutoOpenLockSwitch] && [User getOpenLockTypeSwitch]) {
            self.closeLockBtn.hidden = NO;
        }
        
        [self.scrollView bringSubviewToFront:self.arrow];
#endif
        
//normallyOpenLockBtn;
//normallyCloseLockBtn;
        heightOffset += self.openLockBtn.frame.size.height-2;
        
        self.normallyOpenLockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.normallyOpenLockBtn.frame = CGRectMake(frame.size.width/2-LockSize-10 , heightOffset, 66, 38);
        [self.normallyOpenLockBtn setImage:[UIImage imageNamed:@"NormalOpenDisable.png"] forState:UIControlStateDisabled];
        [self.normallyOpenLockBtn setImage:[UIImage imageNamed:@"NormalOpenEnable.png"] forState:UIControlStateNormal];
        [self.normallyOpenLockBtn addTarget:self action:@selector(clickNormallyOpenLockBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.normallyOpenLockBtn];
        self.normallyOpenLockBtn.enabled = NO;
        
        self.normallyCloseLockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.normallyCloseLockBtn.frame = CGRectMake(frame.size.width/2-LockSize-10 + 66 + 10, heightOffset, 66, 38);
        [self.normallyCloseLockBtn setImage:[UIImage imageNamed:@"NormalCloseDisable.png"] forState:UIControlStateDisabled];
        [self.normallyCloseLockBtn setImage:[UIImage imageNamed:@"NormalCloseEnable.png"] forState:UIControlStateNormal];
        [self.normallyCloseLockBtn addTarget:self action:@selector(clickNormallyCloseLockBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.normallyCloseLockBtn];
        self.normallyCloseLockBtn.enabled = NO;
        
//        if([User getAutoOpenLockSwitch] && [User getOpenLockTypeSwitch]) {
//            self.normallyCloseLockBtn.hidden = NO;
//        }
        
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
//        self.profileBtn = [self buttonWithTitle:NSLocalizedString(@"我的资料", nil) selector:@selector(clickProfileBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
//        [self.scrollView addSubview:self.profileBtn];
        self.settingBtn = [self buttonWithTitle:NSLocalizedString(@"系统设置", nil) selector:@selector(clickSettingBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.settingBtn];

        
        heightOffset += btnHeight + 5;
        btnWidthOffset = 15;
        self.buyBtn = [self buttonWithTitle:NSLocalizedString(@"购买", nil) selector:@selector(clickBuyBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.buyBtn];
        
//        self.aboutBtn = [self buttonWithTitle:NSLocalizedString(@"关于", nil) selector:@selector(clickAboutBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
//        [self.scrollView addSubview:self.aboutBtn];
    
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
//        self.moreBtn = [self buttonWithTitle:NSLocalizedString(@"更多", nil) selector:@selector(clickMoreBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
//        [self.scrollView addSubview:self.moreBtn];
        
        self.profileBtn = [self buttonWithTitle:NSLocalizedString(@"我的", nil) selector:@selector(clickProfileBtn:) frame:CGRectMake(btnWidthOffset, heightOffset, btnWidth, btnHeight)];
        [self.scrollView addSubview:self.profileBtn];
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title selector:(SEL)selector frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [RLColor colorWithHex:0x81D4EA];//[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[RLColor colorWithHex:0x000000 alpha:0.9]/*[RLColor colorWithHex:0xF2E9AE alpha:0.9]*/ forState:UIControlStateNormal];
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

- (void)clickCupidBtn:(UIButton *)button{
    if(![User getAutoOpenLockSwitch]) return;
    if([User getOpenLockTypeSwitch]) { //常开常闭模式 // 关门
        _openLockCmdCode = 0x52;
        [self closeLockManual];
    }
}

- (void)clickOpenLockBtn:(UIButton *)button {
    if(![User getAutoOpenLockSwitch]) return;
    _openLockCmdCode = 0x02;
    if([User getOpenLockTypeSwitch]) { //常开常闭模式
        _openLockCmdCode = 0x42;
    }
    [self openLockManual];
}

- (void)clickCloseLockBtn:(UIButton *)button {
    if(![User getAutoOpenLockSwitch]) return;
    if([User getOpenLockTypeSwitch]) { //常开常闭模式 // 关门
        _openLockCmdCode = 0x52;
        [self closeLockManual];
    }
}

- (void)clickNormallyOpenLockBtn:(UIButton *)button {
    if(![User getAutoOpenLockSwitch]) return;
    _openLockCmdCode = 0x02;
    if([User getOpenLockTypeSwitch]) { //常开常闭模式
        _openLockCmdCode = 0x42;
        [self openLockManual];
    }
}

- (void)clickNormallyCloseLockBtn:(UIButton *)button {
    if(![User getAutoOpenLockSwitch]) return;
    if([User getOpenLockTypeSwitch]) { //常开常闭模式 // 关门
        _openLockCmdCode = 0x52;
        [self closeLockManual];
    }
}

- (void)clickMyDeviceBtn:(UIButton *)button {
    LockDevicesVC *vc = [LockDevicesVC new];
    vc.mainVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickSendKeyBtn:(UIButton *)button {
    SendKeyVC *vc = [[SendKeyVC alloc] init];
    vc.title = NSLocalizedString(@"发送钥匙", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickProfileBtn:(UIButton *)button {
    ProfileVC *vc = [[ProfileVC alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickSettingBtn:(UIButton *)button {
    MoreVC *vc = [MoreVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickBuyBtn:(UIButton *)button {
    BuyVC *vc = [[BuyVC alloc] init];
    vc.title = NSLocalizedString(@"购买", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)clickAboutBtn:(UIButton *)button {
//    AboutVC *vc = [[AboutVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//}

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
- (void)noResponseHandlerForOpenLock {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockNoResponseHandler) object:nil];
    [self performSelector:@selector(openLockNoResponseHandler) withObject:nil afterDelay:6.0f];
}

- (void)openLockNoResponseHandler {
    if(![User getAutoOpenLockSwitch]) {
        self.isOpenLockNow = NO;
    }
    else {
        self.openLockBtn.userInteractionEnabled = YES;
        if([User getOpenLockTypeSwitch]) { //常开常闭
            self.cupidBtn.userInteractionEnabled = YES;
//            self.closeLockBtn.userInteractionEnabled = YES;
            self.normallyOpenLockBtn.userInteractionEnabled = YES;
            self.normallyCloseLockBtn.userInteractionEnabled = YES;
        }
    }
}

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
        
        if(self.isPeripheralResponsed == YES || [User getOpenLockTypeSwitch]) {
            if(![User getVoiceSwitch]) {
                [[SoundManager sharedManager] playSound:@"SoundOperator.mp3" looping:NO];
            }
            self.isPeripheralResponsed = NO;
        }
        RLPeripheralRequest *perRequest = [[RLPeripheralRequest alloc] init];
        perRequest.cmdCode = _openLockCmdCode;
        perRequest.userPwd = key.keyOwner.pwd;
        perRequest.userType = key.userType;
        perRequest.startDate = key.startDate;
        perRequest.invalidDate = key.invalidDate;
        
        [self noResponseHandlerForOpenLock];
        [[RLBluetooth sharedBluetooth] connectPeripheralThanHandlePeripheral:peripheral withPeripheralRequest:perRequest connectionCompletion:^(NSError *error) {
            if(error) {
                [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockNoResponseHandler) object:nil];

                if(failure) {
                    failure(peripherals, error);
                }
                return ;
            }
            
        } notifyCompletion:^(NSError *error) {
            weakSelf.isPeripheralResponsed = YES;
            if(error) {
                [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockNoResponseHandler) object:nil];

                if(failure) {
                    failure(peripherals, error);
                }
                return ;
            }
        } onUpdateData:^(RLPeripheralResponse *peripheralRes, NSError *error) {
            weakSelf.isPeripheralResponsed = YES;
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockNoResponseHandler) object:nil];

//            if(peripheralRes.cmdCode == 0x03) {
//                return ;
//            }
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
            
//            if(peripheralRes.updateTimeCode == 0x01) { //同步时间失败！
//                [weakSelf updateLockTimeWithPeripheral:peripheral withKey:key];
//            }
            
        } withDisconnect:nil];
        
        if(peripheral) return;
    }
    
    if(failure) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(openLockNoResponseHandler) object:nil];

        failure(peripherals, nil);
    }
}

- (void)openLockWithSuccess:(void (^)(RLPeripheralResponse *peripheralRes))success failure:(void (^) (NSArray *peripherals, NSError *error))failure {
    if(![[RLBluetooth sharedBluetooth] isSupportBluetoothLow]) return;
    if(![[RLBluetooth sharedBluetooth] bluetoothIsReady]) return;

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
}

- (void)openLock {
    __weak __typeof(self)weakSelf = self;
    if(self.isOpenLockNow) return;
    self.isOpenLockNow = YES;
    [self openLockWithSuccess:^(RLPeripheralResponse *peripheralRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openLockSuccessWithPeripheralRes:peripheralRes];
        });
        
    } failure:^(NSArray *peripherals, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openLockFailedWithPeripherals:peripherals error:error];
        });
    }];
}

- (void)openLockManual {
    if(![User getAutoOpenLockSwitch]) return;
    if(![[RLBluetooth sharedBluetooth] isSupportBluetoothLow]) {
        return;
    }
    if(![[RLBluetooth sharedBluetooth] bluetoothIsReady])  {
        return;
    }
    __weak __typeof(self)weakSelf = self;
#pragma mark -
    self.openLockBtn.userInteractionEnabled = NO;
    if([User getOpenLockTypeSwitch]) {
        self.cupidBtn.userInteractionEnabled = NO;
//        self.closeLockBtn.userInteractionEnabled = NO;
        self.normallyOpenLockBtn.userInteractionEnabled = NO;
        self.normallyCloseLockBtn.userInteractionEnabled = NO;
    }
#pragma mark -
//    self.openLockBtn.userInteractionEnabled = NO;
    [self openLockWithSuccess:^(RLPeripheralResponse *peripheralRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openLockSuccessWithPeripheralRes:peripheralRes];
        });
        
    } failure:^(NSArray *peripherals, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openLockFailedWithPeripherals:peripherals error:error];
        });
    }];
}

- (void)closeLockManual {
    if(![User getAutoOpenLockSwitch] || ![User getOpenLockTypeSwitch]) return;
    if(![[RLBluetooth sharedBluetooth] isSupportBluetoothLow] || ![[RLBluetooth sharedBluetooth] bluetoothIsReady]) {
        
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
#pragma mark -
    self.openLockBtn.userInteractionEnabled = NO;
    if([User getOpenLockTypeSwitch]) {
        self.cupidBtn.userInteractionEnabled = NO;
//        self.closeLockBtn.userInteractionEnabled = NO;
        self.normallyOpenLockBtn.userInteractionEnabled = NO;
        self.normallyCloseLockBtn.userInteractionEnabled = NO;
    }
#pragma mark -
//    self.cupidBtn.userInteractionEnabled = NO;
    [self openLockWithSuccess:^(RLPeripheralResponse *peripheralRes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openLockSuccessWithPeripheralRes:peripheralRes];
        });
        
    } failure:^(NSArray *peripherals, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openLockFailedWithPeripherals:peripherals error:error];
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

/*
 0.表示成功
 1.设置失败
 2.ID校验失败
 3.命令有误
 4.子命令有误
 5.保留位数据有误
 6.设置管理员按键未按下或按下时间不足
 7.开锁按键未按下或者设置按键已经按下
 8.校验失败
 9.数据无效
 a.门是开着状态
 b.钥匙过期
 c.钥匙未到启用时间
 */

#pragma mark -
- (void)openLockSuccessWithPeripheralRes:(RLPeripheralResponse *)peripheralRes {
    if(![User getAutoOpenLockSwitch])
        self.isOpenLockNow = NO;
    else  {
        self.openLockBtn.userInteractionEnabled = YES;
        if([User getOpenLockTypeSwitch]) {
            self.cupidBtn.userInteractionEnabled = YES;
//            self.closeLockBtn.userInteractionEnabled = YES;
            self.normallyOpenLockBtn.userInteractionEnabled = YES;
            self.normallyCloseLockBtn.userInteractionEnabled = YES;
        }
    }
    
    if(peripheralRes.result == 0x00) {
        self.isOpenLockNow = YES;
        [self openLockAnimation:self.openLockBtn];
        if(peripheralRes.cmdCode == 0x52 || _openLockCmdCode == 0x52) {
            [RLHUD hudAlertSuccessWithBody:NSLocalizedString(@"关门成功！", nil)];
        }
        else {
            [RLHUD hudAlertSuccessWithBody:NSLocalizedString(@"开门成功！", nil)];
        }
        if([User getVoiceSwitch]) return ;
        if(peripheralRes.cmdCode == 0x52) return;
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        NSString *path = [RLUser getVoicePath];
        if(![RLUser getVoicePath] || path.length == 0) {
            [[SoundManager sharedManager] playSound:@"DoorOpened.mp3" looping:NO];
        }
        else {
            Sound *sound = [Sound soundWithContentsOfFile:[RLUser getVoicePath]];
            [[SoundManager sharedManager] playSound:sound looping:NO];
        }
//        [[SoundManager sharedManager] playSound:@"DoorOpened.mp3" looping:NO];
    }
    else if(peripheralRes.result == 0x0a) {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"门已是开着状态！", nil)];
    }
    else if(peripheralRes.result == 0x0b || peripheralRes.result == 0x0c) {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用的钥匙！", nil)];
        return;
    }
    else /*if(peripheralRes.result == 0x02)*/ {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"请重新设置管理员！", nil)];
//        if(peripheralRes.result == 0x08) {
//            if(![User getAutoOpenLockSwitch]) {
////                [self noResponseHandlerForOpenLock];
//
//                self.isOpenLockNow = YES;
//            }
//        }
        
        return;
    }
    
    if(peripheralRes.powerCode == 0x01) {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"电池电压过低，请更换电池！", nil)];
    }
    
//    if(peripheralRes.updateTimeCode == 0x01) { //同步时间失败！
//        [self updateLockTimeWithPeripheral:peripheral withKey:key];
//    }
}

- (void)openLockFailedWithPeripherals:(NSArray *)peripherals error:(NSError *)error {
    self.isOpenLockNow = NO;
    self.openLockBtn.userInteractionEnabled = YES;
    if([User getOpenLockTypeSwitch]) {
        self.cupidBtn.userInteractionEnabled = YES;
//        self.closeLockBtn.userInteractionEnabled = YES;
        self.normallyOpenLockBtn.userInteractionEnabled = YES;
        self.normallyCloseLockBtn.userInteractionEnabled = YES;
    }

    if(!peripherals) {
        if(error) {
            [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"连接出错!", nil)];
            return;
        }
        
        if([User getAutoOpenLockSwitch]) { //手动开锁
            [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用设备!", nil)];
        }
    }
    else {
        if(peripherals.count == 0) {
            [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用设备!", nil)];
            
            return;
        }
        
        if(![User getAutoOpenLockSwitch]) { //自动开锁
            if(self.isOpenLockNow && self.isNeedPop) {
                self.isNeedPop = NO;
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用的钥匙！", nil)];
            }
        }
        else {
            [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"没有可用的钥匙！", nil)];
        }
    }
}

/**
 *  同步时间
 *
 *  @param characteristic characteristic
 */
- (void)updateLockTimeWithPeripheral:(RLPeripheral *)peripheral withKey:(KeyModel *)key {
#if 0
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
#endif
    
    if(!(key.userType == kUserTypeAdmin))
        return;
    
    RLPeripheralRequest *perRequest = [[RLPeripheralRequest alloc] init];
    perRequest.cmdCode = 0x03;
    perRequest.cmdMode = 0x01; //0x01->设置 0x00->读取
    perRequest.userPwd = key.keyOwner.pwd;
    perRequest.userType = key.userType;
    perRequest.startDate = key.startDate;
    perRequest.invalidDate = key.invalidDate;

    [[RLBluetooth sharedBluetooth] updateTimeToPeripheral:peripheral request:perRequest];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //判断是否是单击
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = [request URL];
        if([[UIApplication sharedApplication]canOpenURL:url]) {
//            [[UIApplication sharedApplication]openURL:url];
            BannerDetailVC *vc = [[BannerDetailVC alloc] init];
            vc.url = url.absoluteString;
            [self.navigationController pushViewController:vc animated:YES];
            
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
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"error=%@", error);
    self.isBannersLoaded = NO;
    self.isBannersLoading = NO;
    [RLHUD hideProgress];
}
@end