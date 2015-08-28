//
//  AudioRecorderManager.m
//  Smartlock
//
//  Created by RivenL on 15/8/25.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "AudioRecorderManager.h"

#import <AVFoundation/AVFoundation.h>

NSString *kVoiceRecordDirectory = @"VoiceRecord";

static NSString *documentDirectory() {
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

NSString *voiceRecordDirectory() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *rd = documentDirectory();
    rd = [rd stringByAppendingPathComponent:kVoiceRecordDirectory];
    
    if(![fm fileExistsAtPath:rd]) {
        [fm createDirectoryAtPath:rd withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return   rd;
}

NSString *voiceRecordPathWithFileName(NSString *name) {
    if(name.length == 0)
        return nil;
    NSString *path = [voiceRecordDirectory() stringByAppendingPathComponent:name];
    
    return path;
}

void createVoiceRecordWithName(NSString *name, NSData *data) {
    if(name == nil || name.length == 0)
        return;
    
    NSString *rd = voiceRecordDirectory();
    
    NSString *filePath = [rd stringByAppendingPathComponent:name];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm createFileAtPath:filePath contents:data attributes:nil];
}

NSArray *voiceRecords() {
    NSString *path = voiceRecordDirectory();
    NSArray *records = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
//    NSLog(@"%@", records);
    return records;
}

NSString *voiceRecordName() {
    NSArray *records = voiceRecords();
    NSString *recordingFileName = nil;
    
    NSInteger max = 0;
    for(NSString *name in records) {
        NSArray *array = [name componentsSeparatedByString:@"."];
        if(!array.count) continue;
        NSInteger temp = [[array firstObject] integerValue];
        if(temp == 0) continue;
        if(max < temp) max = temp;
    }
    
    recordingFileName = [NSString stringWithFormat:@"%d", max + 1];
    
    return recordingFileName;
}

void deleteVoiceRecordWithName(NSString *name) {
    if(!name.length) return;
    
    NSString *path = voiceRecordDirectory();
    path = [path stringByAppendingPathComponent:name];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm removeItemAtPath:path error:nil];
}

void renameVoiceRecord(NSString *fromName, NSString *toName) {
    if(!fromName.length || !toName.length) return;
    
    NSString *fromPath = voiceRecordPathWithFileName(fromName);
    NSString *toPath = voiceRecordPathWithFileName(toName);
    
    if(fromPath.length==0 || toPath.length == 0) return;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm moveItemAtPath:fromPath toPath:toPath error:nil];
}
