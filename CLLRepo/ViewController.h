//
//  ViewController.h
//  MacDemo
//
//  Created by leocll on 2018/7/28.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLLGitLog.h"

#define CLLLog(atype,msg) {\
    [ViewController log:[CLLGitLog log:atype message:msg]];\
}

#define CLLConsoleLog(...) CLLLog(CLLGitConsoleLog,([NSString stringWithFormat:__VA_ARGS__]));
#define CLLNormalLog(...) CLLLog(CLLGitNormalLog,([NSString stringWithFormat:__VA_ARGS__]));
#define CLLSuccessLog(...) CLLLog(CLLGitSuccessLog,([NSString stringWithFormat:__VA_ARGS__]));
#define CLLErrorLog(...) CLLLog(CLLGitErrorLog,([NSString stringWithFormat:__VA_ARGS__]));
#define CLLWarningLog(...) CLLLog(CLLGitWarningLog,([NSString stringWithFormat:__VA_ARGS__]));

@interface ViewController : NSViewController
/**
 日志信息

 @param log log
 */
+ (void)log:(CLLGitLog *)log;
@end
