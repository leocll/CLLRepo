//
//  CLLGitUtil.h
//  MacDemo
//
//  Created by leocll on 2018/7/30.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLLGitLog.h"

@interface CLLGitUtil : NSObject
/**模块主路径*/
@property (nonatomic, strong, readonly) NSString *repoPath;
/**库*/
@property (nonatomic, strong, readonly) NSArray <NSString *>*libs;
/**
 开始
 */
- (void)start;
/**
 追加

 @param astr 追加的字符串
 @param libs 库
 */
- (void)append:(NSString *)astr forLibs:(NSArray <NSString *>*)libs;
/**
 替换

 @param ostr 原字符串
 @param nstr 新字符串
 @param libs 库
 */
- (void)replace:(NSString *)ostr withString:(NSString *)nstr forLibs:(NSArray <NSString *>*)libs;
/**
 同步svn
 */
- (void)syncSvnForLibs:(NSArray <NSString *>*)libs;
@end
