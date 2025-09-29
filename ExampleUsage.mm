//
//  ExampleUsage.mm
//  Qt NSWindow Sheet Integration Example
//
//  Created on 2024
//

#import <Cocoa/Cocoa.h>
#import "QtSheetIntegration.h"

@interface ExampleViewController : NSViewController
@property (nonatomic, strong) QtSheetIntegration *qtIntegration;
@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化Qt集成
    self.qtIntegration = [QtSheetIntegration sharedIntegration];
}

#pragma mark - Example 1: 基本使用

- (IBAction)showBasicQtSheet:(id)sender {
    [self.qtIntegration showQtSheetWithTitle:@"Basic Qt Sheet"
                                       size:NSMakeSize(500, 400)
                           completionHandler:^(NSModalResponse result, NSString *userInput) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == NSModalResponseOK) {
                NSLog(@"用户点击了确定，输入内容：%@", userInput);
                [self showAlertWithTitle:@"成功" message:[NSString stringWithFormat:@"您输入的内容是：%@", userInput]];
            } else {
                NSLog(@"用户点击了取消");
                [self showAlertWithTitle:@"取消" message:@"操作已取消"];
            }
        });
    }];
}

#pragma mark - Example 2: 自定义Qt Widget

- (IBAction)showCustomQtSheet:(id)sender {
    // 这里可以创建你自己的Qt Widget
    // 然后通过showCustomQtSheet方法显示
    
    [self.qtIntegration showCustomQtSheet:nullptr // 你的Qt Widget指针
                                    title:@"Custom Qt Sheet"
                                     size:NSMakeSize(600, 500)
                         completionHandler:^(NSModalResponse result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == NSModalResponseOK) {
                NSLog(@"自定义Qt sheet被确认");
            } else {
                NSLog(@"自定义Qt sheet被取消");
            }
        });
    }];
}

#pragma mark - Example 3: 多个Sheet管理

- (IBAction)showMultipleSheets:(id)sender {
    // 显示第一个sheet
    [self.qtIntegration showQtSheetWithTitle:@"First Sheet"
                                       size:NSMakeSize(400, 300)
                           completionHandler:^(NSModalResponse result, NSString *userInput) {
        if (result == NSModalResponseOK) {
            // 第一个sheet确认后，显示第二个sheet
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.qtIntegration showQtSheetWithTitle:@"Second Sheet"
                                                   size:NSMakeSize(450, 350)
                                       completionHandler:^(NSModalResponse result2, NSString *userInput2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (result2 == NSModalResponseOK) {
                            NSLog(@"两个sheet都完成了");
                            [self showAlertWithTitle:@"完成" message:@"所有操作都已完成"];
                        }
                    });
                }];
            });
        }
    }];
}

#pragma mark - Example 4: 错误处理

- (IBAction)showSheetWithErrorHandling:(id)sender {
    // 检查Qt是否已初始化
    if (!self.qtIntegration.isQtInitialized) {
        [self showAlertWithTitle:@"错误" message:@"Qt未初始化，无法显示sheet"];
        return;
    }
    
    [self.qtIntegration showQtSheetWithTitle:@"Error Handling Example"
                                       size:NSMakeSize(500, 400)
                           completionHandler:^(NSModalResponse result, NSString *userInput) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (result) {
                case NSModalResponseOK:
                    if (userInput && userInput.length > 0) {
                        [self showAlertWithTitle:@"成功" message:@"输入验证通过"];
                    } else {
                        [self showAlertWithTitle:@"警告" message:@"请输入有效内容"];
                    }
                    break;
                    
                case NSModalResponseCancel:
                    [self showAlertWithTitle:@"取消" message:@"操作已取消"];
                    break;
                    
                default:
                    [self showAlertWithTitle:@"未知" message:@"未知的返回状态"];
                    break;
            }
        });
    }];
}

#pragma mark - Helper Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = message;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
}

@end

#pragma mark - 主应用示例

@interface ExampleAppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) NSWindow *mainWindow;
@property (nonatomic, strong) ExampleViewController *viewController;
@end

@implementation ExampleAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // 创建主窗口
    self.mainWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 800, 600)
                                                  styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
    
    self.mainWindow.title = @"Qt NSWindow Sheet Integration Example";
    
    // 创建视图控制器
    self.viewController = [[ExampleViewController alloc] init];
    self.mainWindow.contentViewController = self.viewController;
    
    // 创建按钮界面
    [self setupUI];
    
    // 显示窗口
    [self.mainWindow makeKeyAndOrderFront:nil];
}

- (void)setupUI {
    NSView *contentView = self.mainWindow.contentView;
    
    // 创建垂直布局
    NSStackView *stackView = [[NSStackView alloc] initWithFrame:contentView.bounds];
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.alignment = NSLayoutAttributeCenterX;
    stackView.distribution = NSStackViewDistributionFillEqually;
    stackView.spacing = 20;
    stackView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    // 添加按钮
    [stackView addView:[self createButtonWithTitle:@"显示基本Qt Sheet" action:@selector(showBasicQtSheet:)]];
    [stackView addView:[self createButtonWithTitle:@"显示自定义Qt Sheet" action:@selector(showCustomQtSheet:)]];
    [stackView addView:[self createButtonWithTitle:@"显示多个Sheet" action:@selector(showMultipleSheets:)]];
    [stackView addView:[self createButtonWithTitle:@"错误处理示例" action:@selector(showSheetWithErrorHandling:)]];
    
    [contentView addSubview:stackView];
}

- (NSButton *)createButtonWithTitle:(NSString *)title action:(SEL)action {
    NSButton *button = [[NSButton alloc] init];
    button.title = title;
    button.target = self.viewController;
    button.action = action;
    button.bezelStyle = NSBezelStyleRounded;
    button.font = [NSFont systemFontOfSize:16];
    [button sizeToFit];
    return button;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

#pragma mark - 主函数

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        ExampleAppDelegate *delegate = [[ExampleAppDelegate alloc] init];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}