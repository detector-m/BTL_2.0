//
//  VoiceSelectVC.m
//  Smartlock
//
//  Created by RivenL on 15/8/24.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "VoiceSelectVC.h"

#import "AudioRecorderManager.h"
//#import "VoiceRcorderVC.h"
#import "IQAudioRecorderController.h"
#import "AudioCell.h"
#import "RLUtilitiesMethods.h"
#import "AudioRecorderManager.h"
#import "SoundManager.h"
#import "RLColor.h"

@interface VoiceSelectVC () <IQAudioRecorderControllerDelegate>

@end

@implementation VoiceSelectVC {
    NSInteger _selectedIndex;
    
    NSString *_modifyItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.table.datas removeAllObjects];
    [self.table.datas addObject:@"默认"];
    [self.table.datas addObjectsFromArray:voiceRecords()];
    
    [self reloadDatas];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[SoundManager sharedManager] stopAllSounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"声音提示", nil);
    [self setupRightItem];
    
    [self setupLongPressGesture];
}

- (void)setupRightItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickRightItem)];
}

- (void)clickRightItem {
    IQAudioRecorderController *vc = [[IQAudioRecorderController alloc] init];
    vc.delegate = self;
    [self.parentViewController presentViewController:vc animated:YES completion:nil];
}

- (void)reloadDatas {
    NSArray *array = [[RLUser getVoicePath] componentsSeparatedByString:@"/"];
    id obj = [array lastObject];
    
    _selectedIndex = 0;
    for(int i=1; i<self.table.datas.count; i++) {
        NSString *name = self.table.datas[i];
        if([name isEqualToString:obj]) {
            _selectedIndex = i;
            break;
        }
    }
    
    if(_selectedIndex == 0) {
        [RLUser setVoicePath:nil];
    }
    
    [self.table.tableView reloadData];
}

#pragma mark -
- (void)showAlertView {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    UITextField *txt = [alert addTextField:@"请输入"];
    __weak __typeof(self)weakSelf = self;
    [alert addButton:NSLocalizedString(@"确定", nil) actionBlock:^(void) {
        NSString *txtStr = [txt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
        txtStr = [txtStr stringByTrimmingCharactersInSet:set];
        if(!txtStr || txtStr.length == 0)
            return;
        
        if(_modifyItem.length == 0) return;
        
        renameVoiceRecord(_modifyItem, txtStr);
        [self.table.datas removeAllObjects];
        [self.table.datas addObject:@"默认"];
        [self.table.datas addObjectsFromArray:voiceRecords()];
        
        [weakSelf reloadDatas];
    }];
    
    [alert showEdit:self title:NSLocalizedString(@"修改录音文件名", nil) subTitle:nil closeButtonTitle:NSLocalizedString(@"取消", nil) duration:0.0f];
}

- (void)setupLongPressGesture {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    gesture.minimumPressDuration = 1.0f;
    gesture.numberOfTouchesRequired = 1;
    [self.table.tableView addGestureRecognizer:gesture];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.table.tableView];
        NSIndexPath *indexPath = [self.table.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil || indexPath.row == 0)
            return;
        
        _modifyItem = [self.table.datas objectAtIndex:indexPath.row];
        [self showAlertView];
    }
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"Cell";
    AudioCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[AudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.audioPlayBtn.tag = indexPath.row;
    [cell.audioPlayBtn addTarget:self action:@selector(clickPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
    if(_selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor colorWithRed:19/255.0 green:116/255.0 blue:233/255.0 alpha:1];//[UIColor blueColor];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = self.table.datas[[self indexForData:indexPath]];
    
    return cell;
}

- (void)clickPlayBtn:(UIButton *)sender {
    Sound *sound = nil;
    
    if(sender.tag == 0) {
        sound = [Sound soundWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DoorOpened.mp3" ofType:nil]];
    }
    else {
        NSString *path = voiceRecordPathWithFileName(self.table.datas[sender.tag]);
        if(path == nil)
            return;
        sound = [Sound soundWithContentsOfFile:path];
    }
    if(!sound) return;
    
    [[SoundManager sharedManager] stopAllSounds];
    sender.selected = !sender.selected;
    
    [sound setCompletionHandler:^(BOOL isFinished){
        sender.selected = !sender.selected;
    }];
    
    [[SoundManager sharedManager] playSound:sound looping:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectRow];
    
    if(indexPath.row == _selectedIndex) return;
    
    if(indexPath.row == 0) {
        [RLUser setVoicePath:[[NSBundle mainBundle] pathForResource:@"DoorOpened.mp3" ofType:nil]];
    }
    else {
        [RLUser setVoicePath:voiceRecordPathWithFileName(self.table.datas[indexPath.row])];
    }
    
    [self reloadDatas];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
        return;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        id obj = self.table.datas[[self indexForData:indexPath]];
        deleteVoiceRecordWithName(obj);
        [self.table.datas removeObject:obj];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self reloadDatas];
    }
}

-(void)audioRecorderController:(IQAudioRecorderController *)controller didFinishWithAudioAtPath:(NSString*)filePath {
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    if(data.length) {
        createVoiceRecordWithName(voiceRecordName(), data);
    }
}

-(void)audioRecorderControllerDidCancel:(IQAudioRecorderController *)controller {

}
@end
