//
//  CLLGitUtil.m
//  MacDemo
//
//  Created by leocll on 2018/7/30.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import "CLLGitUtil.h"

#ifndef CLLLog
#define CLLLog(...) NSLog(__VA_ARGS__)
#endif

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
              @(PythonMaxVersion4Path):@"max4verdirlist",
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
- (CLLGitError *)start {
    _repoPath = @"/Users/leocll/Desktop/git_update";//@"/Users/leocll/SVN项目";//[self findRepoPath];
    if (!_repoPath.length) {
        return [CLLGitError error:@"未找到repo"];
    }
    CLLGitError *error = nil;
    // FIXME: 测试 警告 leocll 测试
    NSData *data = [self executePyFn:PythonFiles4PathFn arguments:@[self.repoPath] error:&error];
//    NSData *data = [self executePyFn:PythonDirs4PathFn arguments:@[self.repoPath] error:&error];
    id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    _libs = res;
    return error;
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
- (NSData *)executePyFn:(PythonFunction)fnt arguments:(NSArray <NSString *>*)args error:(CLLGitError **)err {
    NSString *fn = PyFn(fnt);
    if (!fn.length) {
        *err = [CLLGitError error:[NSString stringWithFormat:@"没找到python方法%@",@(fnt)]];
        return nil;
    }
    fn = [NSString stringWithFormat:@"fn=%@",fn];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"git_upgrade" ofType:@"py"];
    NSTask *pythonTask = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    // 解释器
    [pythonTask setLaunchPath:@"/Library/Frameworks/Python.framework/Versions/3.7/bin/python3"];
    // 参数
    NSMutableArray *arguments = [NSMutableArray array];
    [arguments addObject:path];
    [arguments addObject:fn];
    if (args.count) {[arguments addObjectsFromArray:args];}
    [pythonTask setArguments:arguments];
    // 结果
    [pythonTask setStandardOutput:pipe];
    // 执行
    [pythonTask launch];
    // 结果解析
    NSData *data = [file readDataToEndOfFile];
    NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([res hasPrefix:@"error"]) {
        CLLGitError *error = [[CLLGitError alloc] init];
        error.message = res;
        *err = error;
    }
    NSLog(@"Python:\nfn=%@\nargs=%@\nres=%@\n", fn, args, res);
    return data;
}

#pragma mark - shell
+ (NSString *)executeShellWithArguments:(NSArray<NSString *> *)args error:(CLLGitError *__autoreleasing *)err {
    if (!args.count) {
        return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"git_update" ofType:@"sh"];
    
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
    //    [task waitUntilExit];
    // 结果解析
    NSData *data = [file readDataToEndOfFile];
    NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    if ([res hasPrefix:@"error"]) {
//        CLLGitError *error = [[CLLGitError alloc] init];
//        error.message = res;
//        *err = error;
//    }
    NSLog(@"Shell:\nfn=%@\nargs=%@\nres=%@\n", args.firstObject, args, res);
    return res;
}

- (NSString *)executeShellCmd:(ShellCommend)cmdt arguments:(NSArray <NSString *>*)args error:(CLLGitError **)err {
    NSString *cmd = ShCmd(cmdt);
    if (!cmd.length) {
        *err = [CLLGitError error:[NSString stringWithFormat:@"没找到shell命令%@",@(cmdt)]];
        return nil;
    }
    if (self.repoPath.length) {
        if (args.count) {
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:cmd];
            [arr addObject:self.repoPath];
            [arr addObjectsFromArray:args];
            args = arr;
        } else {
            args = @[cmd,self.repoPath];
        }
    }
    return [self.class executeShellWithArguments:args error:err];
}

#pragma mark - 库中最大的版本
- (NSString *)maxVersionForLib:(NSString *)lib {
    NSString *libPath = CLLLibPath(lib);
    CLLGitError *error = nil;
    NSData *data = [self executePyFn:PythonMaxVersion4Path arguments:@[libPath] error:&error];
    if (error) {
        return nil;
    }
    NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return res;
}

#pragma mark - 追加
- (CLLGitError *)append:(NSString *)astr forLibs:(NSArray<NSString *> *)libs {
    NSString *message = @"";
    for (NSString *lib in libs) {
        NSString *maxVer = [self maxVersionForLib:lib];
        if (!maxVer.length) {
            message = [NSString stringWithFormat:@"%@\n%@%@",message,lib,@" fetch max version fail"];
            continue;
        }
        CLLGitError *error = nil;
        [self executePyFn:PythonFileContentAp arguments:@[CLLVerPath(lib, maxVer),astr] error:&error];
        if (error) {
            message = [NSString stringWithFormat:@"%@\n%@",message,error.message];
        }
    }
    if (message.length) {
        CLLGitError *er = [[CLLGitError alloc] init];
        er.message = message;
        return er;
    }
    return nil;
}

#pragma mark - 替换
- (CLLGitError *)replace:(NSString *)ostr withString:(NSString *)nstr forLibs:(NSArray<NSString *> *)libs {
    NSString *message = @"";
    for (NSString *lib in libs) {
        NSString *maxVer = [self maxVersionForLib:lib];
        if (!maxVer.length) {
            message = [NSString stringWithFormat:@"%@\n%@%@",message,lib,@" fetch max version fail"];
            continue;
        }
        CLLGitError *error = nil;
        [self.class executePyFn:PythonFileContentRp arguments:@[CLLVerPath(lib, maxVer),ostr,nstr] error:&error];
        if (error) {
            message = [NSString stringWithFormat:@"%@\n%@",message,error.message];
        }
    }
    if (message.length) {
        CLLGitError *er = [[CLLGitError alloc] init];
        er.message = message;
        return er;
    }
    return nil;
}

#pragma mark - public
- (CLLGitError *)syncSvnForLibs:(NSArray<NSString *> *)libs {
    if (!libs.count) {
        return nil;
    }
    // FIXME: 测试 警告 leocll 测试
    [self executePyFn:PythonFileContentAp arguments:@[CLLLibPath(libs.firstObject),@"\n"] error:nil];
//    [self append:@"\n" forLibs:libs];
//    [self executeShellCmd:ShellGitAllOnce arguments:nil error:nil];
    return nil;
}

@end

@implementation CLLGitError

+ (CLLGitError *)error:(NSString *)message {
    CLLGitError *err = [[CLLGitError alloc] init];
    err.message = message;
    return err;
}

@end
