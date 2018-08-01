//
//  CLLCheckCell.h
//  MacDemo
//
//  Created by leocll on 2018/7/29.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLLLibModel.h"

@interface CLLCheckCell : NSTableCellView
/**模型*/
@property (nonatomic, strong) CLLLibModel *model;
@end

