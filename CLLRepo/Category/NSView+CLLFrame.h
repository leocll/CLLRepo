//
//  NSView+CLLFrame.h
//  MacDemo
//
//  Created by leocll on 2018/7/29.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (CLLFrame)
/**origin*/
@property CGPoint origin;
/**size*/
@property CGSize size;
/**top*/
@property CGFloat top;
/**bottom*/
@property CGFloat bottom;
/**left*/
@property CGFloat left;
/**right*/
@property CGFloat right;
/**width*/
@property CGFloat width;
/**height*/
@property CGFloat height;
@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;
@end
