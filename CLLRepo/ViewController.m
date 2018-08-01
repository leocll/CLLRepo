//
//  ViewController.m
//  MacDemo
//
//  Created by leocll on 2018/7/28.
//  Copyright © 2018年 leocll. All rights reserved.
//

#import "ViewController.h"
#import "NSView+CLLFrame.h"
#import "CLLLibModel.h"
#import <objc/runtime.h>
#import "CLLCheckCell.h"
#import "CLLTextCell.h"
#import "CLLGitUtil.h"

@interface ViewController ()<NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSView *topView;
@property (weak) IBOutlet NSView *centerView;
@property (weak) IBOutlet NSTableView *listView;
@property (weak) IBOutlet NSButton *allSelectBtn;
@property (weak) IBOutlet NSButton *refreshBtn;
@property (weak) IBOutlet NSButton *pushBtn;
/**文件夹名数组*/
@property (strong) NSMutableArray <CLLLibModel *>*arrLib;
///**已选的库*/
//@property (nonatomic, strong) NSMutableArray <CLLLibModel *>*arrSelectedLib;
/**引擎*/
@property (nonatomic, strong) CLLGitUtil *git;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.topView.wantsLayer = YES;
//    self.topView.layer.backgroundColor = [NSColor whiteColor].CGColor;
//    self.topView.layer.borderWidth = 1;
//    self.centerView.wantsLayer = YES;
//    self.centerView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.listView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    [self.listView registerNib:[[NSNib alloc] initWithNibNamed:@"CLLCheckCell" bundle:nil] forIdentifier:@"CLLCheckCell"];
    [self.listView registerNib:[[NSNib alloc] initWithNibNamed:@"CLLTextCell" bundle:nil] forIdentifier:@"CLLTextCell"];
    
    self.git = [[CLLGitUtil alloc] init];
    self.arrLib = [NSMutableArray array];
    [self start];
    // @"/Users/leocll/SVN项目/hftapp/"
}

- (void)start {
    [self.git start];
    [self.arrLib removeAllObjects];
    for (NSString *lib in self.git.libs) {
        CLLLibModel *model = [[CLLLibModel alloc] init];
        model.libName = lib;
        [self.arrLib addObject:model];
    }
    [self.listView reloadData];
}

- (IBAction)allSelectAction:(NSButton *)sender {
    BOOL selected = sender.state == NSOnState;
    [self.arrLib enumerateObjectsUsingBlock:^(CLLLibModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = selected;
    }];
    [self.listView reloadData];
}

- (IBAction)syncSvnAction:(NSButtonCell *)sender {
    NSMutableArray *arr = [NSMutableArray array];
    [self.arrLib enumerateObjectsUsingBlock:^(CLLLibModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selected) {
            [arr addObject:obj.libName];
        }
    }];
    [self.git syncSvnForLibs:arr];
}

- (IBAction)refreshAction:(NSButton *)sender {
    [self.git start];
    [self.arrLib removeAllObjects];
    for (NSString *lib in self.git.libs) {
        CLLLibModel *model = [[CLLLibModel alloc] init];
        model.libName = lib;
        [self.arrLib addObject:model];
    }
    [self.listView reloadData];
}

#pragma mark - NSTableViewDataSource & NSTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.arrLib.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"CLLCheckCell"]) {
        CLLCheckCell *cell = [tableView makeViewWithIdentifier:@"CLLCheckCell" owner:self];
        cell.model = self.arrLib[row];
        return cell;
    } else {
        CLLTextCell *cell = [tableView makeViewWithIdentifier:@"CLLTextCell" owner:self];
        cell.textTf.stringValue = [self.arrLib[row] valueForKey:tableColumn.identifier];
        return cell;
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    NSLog(@"%s", __func__);
    return YES;
}

- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes NS_AVAILABLE_MAC(10_5) {
    NSLog(@"%s", __func__);
    return proposedSelectionIndexes;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn {
    NSLog(@"%s", __func__);
    return YES;
}

- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn {
    NSLog(@"%s", __func__);
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    NSLog(@"%s", __func__);
}

- (void)tableView:(NSTableView *)tableView didDragTableColumn:(NSTableColumn *)tableColumn {
    NSLog(@"%s", __func__);
}

- (void)tableView:(NSTableView *)theTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    NSLog(@"%s", __func__);
//    [self.arrLib sortUsingDescriptors:[tableView sortDescriptors]];
//    [tableView reloadData];
}

@end
