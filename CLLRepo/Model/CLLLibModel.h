//
//  CLLLibModel.h
//  MacDemo
//
//  Created by leocll on 2018/7/29.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLLLibModel : NSObject
/**名字*/
@property (strong) NSString *libName;
/**是否被选中*/
@property (assign) BOOL selected;
@end
