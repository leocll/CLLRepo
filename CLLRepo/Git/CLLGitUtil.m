//
//  CLLGitUtil.m
//  MacDemo
//
//  Created by leocll on 2018/7/30.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import "CLLGitUtil.h"
#import "ViewController.h"
#import "CLLCommon.h"

#define CLLTrimNewLine(str) ([(str) length]?[(str) stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]:(str))

typedef NS_ENUM(NSInteger, PythonFunction) {
    PythonFiles4PathFn = 1,     //路径的文件，参数：路径
    PythonDirs4PathFn = 2,      //路径的文件夹，参数：路径
    PythonMaxVersion4Path = 3,  //版本号中最大的版本号
    PythonVersionRise,          //版本追加
    PythonFileContentRp,        //文件内容替换，参数：路径、原类型、新内容
    PythonFileContentAp,        //文件内容追加，参数：路径、追加的内容(尾部换行追加)
};

typedef NS_ENUM(NSInteger, ShellCommend) {
    ShellGitPull = 100,     //pull，参数：
    ShellGitAdd,            //add，参数：
    ShellGitCommit,         //commit，参数：文案
    ShellGitPush,           //push，参数
    ShellGitAllOnce,        //上面命令全部一次
};

#define PyFn(fn) CLLPyFn[@(fn)]
#define ShCmd(cmd) CLLShCmd[@(cmd)]
#define CLLLibPath(lib) [NSString stringWithFormat:@"%@/%@",self.repoPath,(lib)]
#define CLLVerPath(lib,ver) [NSString stringWithFormat:@"%@/%@/%@",self.repoPath,(lib),(ver)]

@implementation CLLGitUtil

static NSDictionary *CLLPyFn = nil;
static NSDictionary *CLLShCmd = nil;

+ (void)load {
    CLLPyFn = @{@(PythonFiles4PathFn):@"filelist4path",
              @(PythonDirs4PathFn):@"dirlist4path",
              @(PythonMaxVersion4Path):@"maxverdir4path",
              @(PythonVersionRise):@"",
              @(PythonFileContentRp):@"file_content_rp",
              @(PythonFileContentAp):@"file_content_ap",
              };
    CLLShCmd = @{@(ShellGitPull):@"git_pull",
                 @(ShellGitAdd):@"git_add",
                 @(ShellGitCommit):@"git_commit",
                 @(ShellGitPush):@"git_push",
                 @(ShellGitAllOnce):@"git_all",
                 };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self start];
    }
    return self;
}

#pragma mark - 重启
- (void)start {
    _repoPath = [self findRepoPath];//@"/Users/leocll/SVN项目/hftapp";//
    if (!self.repoPath.length) {
        CLLErrorLog(@"%@未找到repo：hftsoft或hftapp",self.repoPath);
        return ;
    }
    CLLNormalLog(@"正在获取'%@'的libs...",[self.repoPath lastPathComponent]);
    NSData *data = [self execPyFn:PythonDirs4PathFn arguments:@[self.repoPath] block:nil];
    if (data) {
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        _libs = res;
        CLLNormalLog(@"获取'%@'的libs成功",[self.repoPath lastPathComponent]);
    } else {
        CLLErrorLog(@"获取'%@'的libs失败",[self.repoPath lastPathComponent]);
    }
}

#pragma mark - repoPath
- (NSString *)findRepoPath {
    NSString *path = NSHomeDirectory();
    path = [NSString stringWithFormat:@"%@/.cocoapods/repos",path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/hftsoft",path]]) {
        return [NSString stringWithFormat:@"%@/hftsoft",path];
    } else if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/hftapp",path]]) {
        return [NSString stringWithFormat:@"%@/hftapp",path];
    }
    return nil;
}

#pragma mark - python
- (NSData *)execPyFn:(PythonFunction)fnt arguments:(NSArray <NSString *>*)args block:(void(^)(NSData *data,CLLGitLog *log))block {
    NSString *fn = PyFn(fnt);
    if (!fn.length) {
        CLLErrorLog(@"没找到python方法%@",@(fnt));
        return nil;
    }
    fn = [NSString stringWithFormat:@"fn=%@",fn];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"git_upgrade" ofType:@"py"];
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    // 解释器
    [task setLaunchPath:@"/usr/bin/python"];
    // 参数
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:path];
    [arguments addObject:fn];
    if (args.count) {[arguments addObjectsFromArray:args];}
    [task setArguments:arguments];
    // 结果
    [task setStandardOutput:pipe];
    // 执行
    [task launch];
    [task waitUntilExit];
    // 结果解析
    NSData *data = [file readDataToEndOfFile];
    NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (res.length) {res = CLLTrimNewLine(res);}
    if ([res hasPrefix:@"error"]) {
        CLLErrorLog(@"%@",res);
    }
    CLLMainExecBlock(block, data, [CLLGitLog log:[res containsString:@"error"]?CLLGitErrorLog:CLLGitConsoleLog message:res]);
    CLLConsoleLog(@"Python:\nfn=%@\nargs=%@\nres=%@\n", fn, args, res);
    return [res dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - shell
+ (NSString *)executeShellWithArguments:(NSArray<NSString *> *)args block:(void(^)(NSData *data,CLLGitLog *log))block {
    if (!args.count) {
        return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"git_update" ofType:@"sh"];
    // 初始化
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    // 解释器
    [task setLaunchPath:@"/bin/bash"];
    // 参数
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:path];
    if (args.count) {
        [arguments addObjectsFromArray:args];
    }
    [task setArguments:arguments];
    // 结果
    [task setStandardOutput:pipe];
    // 执行
    [task launch];
    [task waitUntilExit];
    // 结果解析
    NSData *data = [file readDataToEndOfFile];
    NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (res.length) {res = CLLTrimNewLine(res);}
    if ([res containsString:@"error"] || [res containsString:@"success"]) {
        void(^logBlock)(NSString *) = ^(NSString *msg) {
            if ([msg containsString:@"error"]) {
                CLLErrorLog(@"%@",msg);
            } else if ([msg containsString:@"success"]) {
                CLLSuccessLog(@"%@",[msg substringFromIndex:[msg rangeOfString:@"success"].location]);
            } else {
                CLLWarningLog(@"%@",msg);
            }
        };
        NSArray *arr = [res componentsSeparatedByString:@"\n"];
        if (arr.count) {
            for (NSString *msg in arr) {
                logBlock(msg);
            }
        } else {
            logBlock(res);
        }
    }
    CLLMainExecBlock(block, data, [CLLGitLog log:[res containsString:@"error"]?CLLGitErrorLog:CLLGitConsoleLog message:res]);
    CLLConsoleLog(@"Shell:\nfn=%@\nargs=%@\nres=%@\n", args.firstObject, args, res);
    return res;
}

- (NSString *)execShCmd:(ShellCommend)cmdt arguments:(NSArray <NSString *>*)args block:(void(^)(NSData *data,CLLGitLog *log))block {
    NSString *cmd = ShCmd(cmdt);
    if (!cmd.length) {
        CLLErrorLog(@"没找到shell方法%@",@(cmdt));
        return nil;
    }
    if (!self.repoPath.length) {
        CLLErrorLog(@"未找到repo：hftsoft或hftapp");
        return nil;
    }
    if (args.count) {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:cmd];
        [arr addObject:self.repoPath];
        [arr addObjectsFromArray:args];
        args = arr;
    } else {
        args = @[cmd,self.repoPath];
    }
    return [self.class executeShellWithArguments:args block:block];
}

- (void)execShCmds:(NSArray <NSNumber *> *)cmds index:(NSInteger)i arguments:args block:(void(^)(NSData *data, CLLGitLog *log))block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak typeof(self) weakSelf = self;
        [self execShCmd:cmds[i].integerValue arguments:args block:^(NSData *data, CLLGitLog *log) {
            if (log.type != CLLGitErrorLog && i+1 < cmds.count) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [weakSelf execShCmds:cmds index:i+1 arguments:args block:block];
                });
            } else {
                CLLMainExecBlock(block,data,log);
            }
        }];
    });
}

#pragma mark - 库中最大的版本
- (NSString *)maxVersionForLib:(NSString *)lib {
    CLLNormalLog(@"正在获取'%@'的最大版本...",lib);
    NSString *libPath = CLLLibPath(lib);
    NSData *data = [self execPyFn:PythonMaxVersion4Path arguments:@[libPath] block:nil];
    if (!data) {
        CLLErrorLog(@"获取'%@'的最大版本失败，请检查'%@'路径下是否存在版本号形式的文件夹",lib,libPath);
        return nil;
    }
    NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    CLLNormalLog(@"'%@'的最大版本为：'%@'",lib, res);
    return res;
}

#pragma mark - 追加
- (void)append:(NSString *)astr forLibs:(NSArray <NSString *>*)libs {
    CLLWarningLog(@"正在修改文件...");
    for (NSString *lib in libs) {
        NSString *maxVer = [self maxVersionForLib:lib];
        if (maxVer.length) {
            CLLNormalLog(@"正在修改'%@'、'%@'版本中的spec文件...",lib,maxVer);
            [self execPyFn:PythonFileContentAp arguments:@[CLLVerPath(lib, maxVer),astr] block:nil];
        }
    }
}

#pragma mark - 替换
- (void)replace:(NSString *)ostr withString:(NSString *)nstr forLibs:(NSArray <NSString *>*)libs {
    CLLWarningLog(@"正在替换文件...");
    for (NSString *lib in libs) {
        NSString *maxVer = [self maxVersionForLib:lib];
        if (maxVer.length) {
            CLLNormalLog(@"正在替换'%@'、'%@'版本中spec文件...",lib,maxVer);
            [self execPyFn:PythonFileContentRp arguments:@[CLLVerPath(lib, maxVer),ostr,nstr] block:nil];
        }
    }
}

#pragma mark - 同步
- (void)sync:(NSArray<NSString *> *)libs block:(void (^)(NSData *, CLLGitLog *))block {
    CLLWarningLog(@"正在同步修改...");
    NSArray *args = libs.count==1 ? @[libs.firstObject] : nil;
    NSArray *cmds = @[@(ShellGitPull),@(ShellGitAdd),@(ShellGitCommit),@(ShellGitPush)];
    [self execShCmds:cmds index:0 arguments:args block:block];
//    [self execShCmd:ShellGitAllOnce arguments:args block:block];
}

#pragma mark - public
- (void)syncSvnForLibs:(NSArray<NSString *> *)libs block:(void (^)(NSData *, CLLGitLog *))block {
    if (!libs.count) {
        CLLWarningLog(@"请先选择要同步的libs");
        CLLMainExecBlock(block,nil,nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self append:@"\n" forLibs:libs];
        [self sync:libs block:block];
    });
    // FIXME: 测试 警告 leocll
//    NSString *res1 = [CLLGitUtil executeShellWithArguments:@[@"test_ls",self.repoPath] block:nil];
//    NSString *res2 = [CLLGitUtil executeShellWithArguments:@[@"test_rm",self.repoPath] block:nil];
//    NSString *res3 = [CLLGitUtil executeShellWithArguments:@[@"test_ffasfda",self.repoPath] block:nil];
}

@end
