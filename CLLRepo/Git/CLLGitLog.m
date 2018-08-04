//
//  CLLGitLog.m
//  CLLRepo
//
//  Created by leocll on 2018/8/4.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import "CLLGitLog.h"

@implementation CLLGitLog

+ (CLLGitLog *)logMessage:(NSString *)message {
    return [self log:CLLGitConsoleLog message:message];
}

+ (CLLGitLog *)log:(CLLGitLogType)type message:(NSString *)message {
    CLLGitLog *log = [[CLLGitLog alloc] init];
    log.type = type;
    log.message = message;
    return log;
}

@end
