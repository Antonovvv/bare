//
//  QtSheetContainer.mm
//  Qt NSWindow Sheet Integration
//
//  Created on 2024
//

#import "QtSheetContainer.h"
#import <QtWidgets/QWidget>
#import <QtCore/QObject>
#import <QtCore/QMetaObject>

// Qt信号槽桥接类
class QtSignalBridge : public QObject {
    Q_OBJECT
    
public:
    QtSignalBridge(QtSheetContainer *container) : m_container(container) {}
    
public slots:
    void onOkClicked() {
        if (m_container) {
            [m_container qtOkClicked];
        }
    }
    
    void onCancelClicked() {
        if (m_container) {
            [m_container qtCancelClicked];
        }
    }
    
    void onQtWidgetDestroyed() {
        if (m_container) {
            [m_container qtWidgetDestroyed];
        }
    }
    
private:
    __weak QtSheetContainer *m_container;
};

// 私有接口
@interface QtSheetContainer () <NSWindowDelegate>
@property (nonatomic, strong) NSWindow *parentWindow;
@property (nonatomic, strong) NSWindow *sheetWindow;
@property (nonatomic, strong) NSView *qtContainerView;
@property (nonatomic, assign) void *qtWidget;
@property (nonatomic, strong) QtSignalBridge *signalBridge;
@property (nonatomic, copy) void(^completionHandler)(NSModalResponse);
@property (nonatomic, assign) BOOL isSheetVisible;
@end

@implementation QtSheetContainer

#pragma mark - Initialization

- (instancetype)initWithParentWindow:(NSWindow *)parentWindow 
                        qtViewSize:(NSSize)size 
                           title:(NSString *)title {
    self = [super init];
    if (self) {
        _parentWindow = parentWindow;
        _isSheetVisible = NO;
        
        [self setupSheetWindowWithSize:size title:title];
        [self setupQtContainerView];
        [self setupSignalBridge];
    }
    return self;
}

- (void)dealloc {
    [self cleanup];
}

#pragma mark - Setup Methods

- (void)setupSheetWindowWithSize:(NSSize)size title:(NSString *)title {
    // 创建sheet窗口
    self.sheetWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, size.width, size.height)
                                                   styleMask:NSWindowStyleMaskTitled | 
                                                           NSWindowStyleMaskClosable |
                                                           NSWindowStyleMaskResizable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    
    self.sheetWindow.title = title;
    self.sheetWindow.delegate = self;
    self.sheetWindow.level = NSModalPanelWindowLevel;
    
    // 设置窗口居中
    [self.sheetWindow center];
}

- (void)setupQtContainerView {
    // 创建容器视图
    self.qtContainerView = [[NSView alloc] initWithFrame:self.sheetWindow.contentView.bounds];
    self.qtContainerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    // 设置背景色
    self.qtContainerView.wantsLayer = YES;
    self.qtContainerView.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    
    // 添加到窗口
    [self.sheetWindow.contentView addSubview:self.qtContainerView];
}

- (void)setupSignalBridge {
    // 创建Qt信号桥接对象
    self.signalBridge = new QtSignalBridge(self);
}

#pragma mark - Public Methods

- (void)showSheetWithCompletionHandler:(void(^)(NSModalResponse result))completionHandler {
    if (self.isSheetVisible) {
        NSLog(@"Warning: Sheet is already visible");
        return;
    }
    
    self.completionHandler = completionHandler;
    self.isSheetVisible = YES;
    
    // 显示sheet
    [self.parentWindow beginSheet:self.sheetWindow 
                completionHandler:^(NSModalResponse returnCode) {
        self.isSheetVisible = NO;
        if (self.completionHandler) {
            self.completionHandler(returnCode);
        }
        [self notifyDelegateWithResult:returnCode];
    }];
}

- (void)dismissSheetWithResult:(NSModalResponse)result {
    if (!self.isSheetVisible) {
        NSLog(@"Warning: Sheet is not visible");
        return;
    }
    
    [self.parentWindow endSheet:self.sheetWindow returnCode:result];
}

- (void)setQtView:(void *)qtWidget {
    if (self.qtWidget) {
        [self disconnectQtSignals];
    }
    
    self.qtWidget = qtWidget;
    
    if (qtWidget) {
        QWidget *widget = static_cast<QWidget*>(qtWidget);
        
        // 设置Qt窗口为无边框
        widget->setWindowFlags(Qt::Widget);
        
        // 创建NSView包装Qt视图
        NSView *qtView = (__bridge NSView *)widget->winId();
        if (qtView) {
            qtView.frame = self.qtContainerView.bounds;
            qtView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
            [self.qtContainerView addSubview:qtView];
        }
        
        [self connectQtSignals];
    }
}

- (void *)qtWidget {
    return self.qtWidget;
}

#pragma mark - Qt Signal Handling

- (void)connectQtSignals {
    if (!self.qtWidget) return;
    
    QWidget *widget = static_cast<QWidget*>(self.qtWidget);
    
    // 连接Qt信号到我们的槽
    QObject::connect(widget, &QWidget::destroyed, 
                    self.signalBridge, &QtSignalBridge::onQtWidgetDestroyed);
    
    // 这里需要根据你的Qt界面具体实现来连接确定/取消按钮的信号
    // 例如：
    // QObject::connect(okButton, &QPushButton::clicked, 
    //                 self.signalBridge, &QtSignalBridge::onOkClicked);
    // QObject::connect(cancelButton, &QPushButton::clicked, 
    //                 self.signalBridge, &QtSignalBridge::onCancelClicked);
}

- (void)disconnectQtSignals {
    if (!self.qtWidget) return;
    
    QWidget *widget = static_cast<QWidget*>(self.qtWidget);
    QObject::disconnect(widget, nullptr, self.signalBridge, nullptr);
}

- (void)qtOkClicked {
    [self dismissSheetWithResult:NSModalResponseOK];
}

- (void)qtCancelClicked {
    [self dismissSheetWithResult:NSModalResponseCancel];
}

- (void)qtWidgetDestroyed {
    self.qtWidget = nullptr;
    if (self.isSheetVisible) {
        [self dismissSheetWithResult:NSModalResponseCancel];
    }
}

#pragma mark - NSWindowDelegate

- (BOOL)windowShouldClose:(NSWindow *)window {
    // 当用户点击关闭按钮时，以取消状态结束sheet
    [self dismissSheetWithResult:NSModalResponseCancel];
    return NO; // 返回NO，让endSheet处理关闭
}

- (void)windowWillClose:(NSNotification *)notification {
    // 清理资源
    [self cleanup];
}

#pragma mark - Private Methods

- (void)notifyDelegateWithResult:(NSModalResponse)result {
    if ([self.delegate respondsToSelector:@selector(qtSheetContainer:didFinishWithResult:)]) {
        [self.delegate qtSheetContainer:self didFinishWithResult:result];
    }
    
    switch (result) {
        case NSModalResponseOK:
            if ([self.delegate respondsToSelector:@selector(qtSheetContainerDidConfirm:)]) {
                [self.delegate qtSheetContainerDidConfirm:self];
            }
            break;
        case NSModalResponseCancel:
            if ([self.delegate respondsToSelector:@selector(qtSheetContainerDidCancel:)]) {
                [self.delegate qtSheetContainerDidCancel:self];
            }
            break;
        default:
            break;
    }
}

- (void)cleanup {
    [self disconnectQtSignals];
    
    if (self.signalBridge) {
        delete self.signalBridge;
        self.signalBridge = nullptr;
    }
    
    self.qtWidget = nullptr;
    self.completionHandler = nil;
}

@end

// Qt信号槽实现
#include "QtSheetContainer.moc"