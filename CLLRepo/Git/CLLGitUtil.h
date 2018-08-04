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
 同步svn
 */
- (void)syncSvnForLibs:(NSArray <NSString *>*)libs block:(void(^)(NSData *data,CLLGitLog *log))block;
@end
