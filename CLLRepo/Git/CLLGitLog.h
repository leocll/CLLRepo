//
//  CLLGitLog.h
//  CLLRepo
//
//  Created by leocll on 2018/8/4.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLLGitLogType) {
    CLLGitConsoleLog = 0,   //控制台日志
    CLLGitNormalLog,        //正常日志
    CLLGitSuccessLog,       //成功
    CLLGitErrorLog,         //错误
    CLLGitWarningLog,       //警告
};

@interface CLLGitLog : NSObject
/**信息*/
@property (strong) NSString *message;
/**code*/
@property (assign) CLLGitLogType type;

+ (CLLGitLog *)logMessage:(NSString *)message;
+ (CLLGitLog *)log:(CLLGitLogType)type message:(NSString *)message;
@end
