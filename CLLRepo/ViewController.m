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
#import "CLLContainerView.h"
#import "CLLGitUtil.h"
#import "CLLCommon.h"

#define kLogNotiKey @"kLogNotiKey"

@interface ViewController ()<NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSView *topView;
@property (strong) NSTextView *textView;
@property (strong) NSScrollView *scrollView;
@property (weak) IBOutlet NSView *centerView;
@property (weak) IBOutlet NSButton *allSelectBtn;
@property (weak) IBOutlet NSButton *refreshBtn;
@property (weak) IBOutlet NSButton *pushBtn;
@property (weak) IBOutlet NSButton *clearLogBtn;
@property (weak) IBOutlet NSTableView *listView;
@property (weak) IBOutlet NSView *coverView;
@property (weak) IBOutlet NSProgressIndicator *indicator;
/**引擎*/
@property (nonatomic, strong) CLLGitUtil *git;
/**文件夹名数组*/
@property (strong) NSMutableArray <CLLLibModel *>*arrLib;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化UI
    [self createUI];
    // 初始化数据
    [self createData];
}

- (void)createUI {
    self.listView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    [self.listView registerNib:[[NSNib alloc] initWithNibNamed:@"CLLCheckCell" bundle:nil] forIdentifier:@"CLLCheckCell"];
    [self.listView registerNib:[[NSNib alloc] initWithNibNamed:@"CLLTextCell" bundle:nil] forIdentifier:@"CLLTextCell"];
    
    self.textView = [[NSTextView alloc]initWithFrame:self.topView.bounds];
    [self.topView addSubview:self.textView];
    self.textView.backgroundColor = [NSColor whiteColor];
    self.textView.editable = NO;
    self.textView.textColor = RGB(59, 187, 51);

    self.scrollView = [[NSScrollView alloc]initWithFrame:self.topView.bounds];
    [self.scrollView setBorderType:NSNoBorder];
    [self.scrollView setHasVerticalScroller:YES];
    [self.scrollView setHasHorizontalScroller:NO];
    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.textView setMinSize:NSMakeSize(0.0, self.topView.height)];
    [self.textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.textView setVerticallyResizable:YES];
    [self.textView setHorizontallyResizable:NO];
    [self.textView setAutoresizingMask:NSViewWidthSizable];
    [[self.textView textContainer] setContainerSize:NSMakeSize(self.topView.width, FLT_MAX)];
    [[self.textView textContainer] setWidthTracksTextView:YES];
    [self.textView setFont:[NSFont fontWithName:@"PingFang-SC-Regular" size:12.0]];
    [self.textView setEditable:NO];
    
    [self.scrollView setDocumentView:self.textView];
    [self.topView addSubview:self.scrollView];
    
    self.textView.string = @"Welcome!!!";
    self.textView.editable = NO;
    [self.indicator startAnimation:nil];
}

- (void)createData {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logNotifacation:) name:kLogNotiKey object:nil];
    self.git = [[CLLGitUtil alloc] init];
    self.arrLib = [NSMutableArray array];
    [self start];
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

+ (void)log:(CLLGitLog *)log {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (log.type == CLLGitConsoleLog) {
            NSLog(@"%@",log.message);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLogNotiKey object:nil userInfo:log?@{@"log":log}:nil];
        }
    });
}

- (void)logNotifacation:(NSNotification *)noti {
    CLLGitLog *log = noti.userInfo[@"log"];
    [self handleLog:log];
}

- (void)handleLog:(CLLGitLog *)log {
    dispatch_async(dispatch_get_main_queue(), ^{
        static NSDictionary *dicLogColor = nil;
        if (!dicLogColor) {
            dicLogColor = @{@(CLLGitConsoleLog):RGB(51, 51, 51),@(CLLGitNormalLog):RGB(51, 51, 51),@(CLLGitSuccessLog):RGB(59, 187, 51),@(CLLGitErrorLog):RGB(193, 57, 40),@(CLLGitWarningLog):RGB(237, 200, 86)};
        }
        NSString *message = [NSString stringWithFormat:@"\n%@",log.message];
        NSColor *color = dicLogColor[@(log.type)]?:RGB(102, 102, 102);
        BOOL scroll = (NSMaxY(self.textView.visibleRect) == NSMaxY(self.textView.bounds));
        [self.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:message attributes:@{NSForegroundColorAttributeName:color}]];
        if (scroll) {
            [self.textView scrollRangeToVisible:NSMakeRange(self.textView.string.length, 0)];
        }
    });
}

#pragma mark - 选择所有
- (IBAction)allSelectAction:(NSButton *)sender {
    BOOL selected = sender.state == NSOnState;
    [self.arrLib enumerateObjectsUsingBlock:^(CLLLibModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = selected;
    }];
    [self.listView reloadData];
}

#pragma mark - 刷新
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

#pragma mark - 同步
- (IBAction)syncSvnAction:(NSButtonCell *)sender {
    NSMutableArray *selectLibs = [NSMutableArray array];
    NSMutableArray *selectLibNames = [NSMutableArray array];
    [self.arrLib enumerateObjectsUsingBlock:^(CLLLibModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selected) {
            [selectLibs addObject:obj];
            [selectLibNames addObject:obj.libName];
        }
    }];
    if (!selectLibNames.count) {
         CLLWarningLog(@"请先选择要同步的libs");
        return;
    }
    [self showInteraction];
    __weak typeof(self) weakSelf = self;
    [self.git syncSvnForLibs:selectLibNames block:^(NSData *data, CLLGitLog *log) {
        for (CLLLibModel *lib in selectLibs) {
            lib.selected = NO;
        }
        [weakSelf hideInteraction];
        [weakSelf.listView reloadData];
    }];
}

#pragma mark - 清除日志
- (IBAction)clearLogAction:(NSButton *)sender {
    self.textView.string = @"Welcome!!!";
}

#pragma mark - 显示interaction
- (void)showInteraction {
    self.coverView.hidden = NO;
    [(CLLContainerView *)self.view setOffInteraction:YES];
}

#pragma mark - 隐藏interaction
- (void)hideInteraction {
    self.coverView.hidden = YES;
    [(CLLContainerView *)self.view setOffInteraction:NO];
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

@end
