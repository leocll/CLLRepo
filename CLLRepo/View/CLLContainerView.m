//
//  CLLContainerView.m
//  CLLRepo
//
//  Created by leocll on 2018/8/4.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import "CLLContainerView.h"
#import "CLLCommon.h"

@implementation CLLContainerView

- (NSView *)hitTest:(NSPoint)point {
    if (self.offInteraction) {
        return nil;
    }
    return [super hitTest:point];
}

@end
