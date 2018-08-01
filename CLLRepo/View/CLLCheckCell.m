//
//  CLLCheckCell.m
//  MacDemo
//
//  Created by leocll on 2018/7/29.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import "CLLCheckCell.h"
//#import "CLLCheckCellView.h"

@interface CLLCheckCell ()
@property (weak) IBOutlet NSButton *checkButton;
@end

@implementation CLLCheckCell

- (IBAction)checkButtonAction:(NSButton *)sender {
    self.model.selected = sender.state==NSOnState;
}

- (void)setModel:(CLLLibModel *)model {
    _model = model;
//    self.checkButton.title = model.moduleName;
    [self.checkButton setState:self.model.selected ? NSOnState : NSOffState];
}

@end
