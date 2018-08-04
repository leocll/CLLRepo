//
//  CLLCommon.h
//  CLLRepo
//
//  Created by leocll on 2018/8/4.
//  Copyright © 2018年 leocll. All rights reserved.
//

#ifndef CLLCommon_h
#define CLLCommon_h

#import <Cocoa/Cocoa.h>

#define RGBA(r,g,b,a) ([NSColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)])
#define RGB(r,g,b) RGBA(r,g,b,1.0)

#define CLLExecBlock(block,...) if(block){block(__VA_ARGS__);}
#define CLLMainExecBlock(block,...) dispatch_async(dispatch_get_main_queue(), ^{if(block){block(__VA_ARGS__);}});
#define CLLGlobalExecBlock(block,...) dispatch_async(dispatch_get_global_queue(0, 0), ^{if(block){block(__VA_ARGS__);}});

#endif /* CLLCommon_h */
