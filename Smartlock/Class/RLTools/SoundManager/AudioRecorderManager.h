//
//  AudioRecorderManager.h
//  Smartlock
//
//  Created by RivenL on 15/8/25.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kVoiceRecordDirectory;

extern NSString *voiceRecordDirectory();
extern NSString *voiceRecordPathWithFileName(NSString *name);
extern void createVoiceRecordWithName(NSString *name, NSData *data);

extern NSArray *voiceRecords();
extern NSString *voiceRecordName();
extern void deleteVoiceRecordWithName(NSString *name);

extern void renameVoiceRecord(NSString *fromName, NSString *toName);

