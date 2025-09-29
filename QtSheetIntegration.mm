//
//  QtSheetIntegration.mm
//  Complete Qt-NSWindow Sheet Integration
//
//  Created on 2024
//

#import "QtSheetIntegration.h"
#import <QtWidgets/QApplication>
#import <QtCore/QTimer>
#import <QtCore/QObject>
#import "QtSheetWidget.h"

@interface QtSheetIntegration () <QtSheetContainerDelegate>
@property (nonatomic, strong) QtSheetManager *sheetManager;
@property (nonatomic, assign) BOOL isQtInitialized;
@property (nonatomic, assign) QApplication *qtApplication;
@property (nonatomic, strong) NSMutableArray<QtSheetContainer *> *activeContainers;
@end

@implementation QtSheetIntegration

#pragma mark - Singleton

+ (instancetype)sharedIntegration {
    static QtSheetIntegration *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QtSheetIntegration alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _activeContainers = [[NSMutableArray alloc] init];
        _isQtInitialized = NO;
        _qtApplication = nullptr;
    }
    return self;
}

- (void)dealloc {
    [self cleanupQtApplication];
}

#pragma mark - Qt Application Management

- (BOOL)initializeQtApplication {
    if (self.isQtInitialized) {
        return YES;
    }
    
    // 检查是否已有QApplication实例
    if (QApplication::instance()) {
        self.qtApplication = QApplication::instance();
        self.isQtInitialized = YES;
        return YES;
    }
    
    // 创建QApplication实例
    int argc = 0;
    char **argv = nullptr;
    self.qtApplication = new QApplication(argc, argv);
    
    if (self.qtApplication) {
        self.isQtInitialized = YES;
        NSLog(@"Qt application initialized successfully");
        return YES;
    } else {
        NSLog(@"Failed to initialize Qt application");
        return NO;
    }
}

- (void)cleanupQtApplication {
    if (self.isQtInitialized && self.qtApplication) {
        // 关闭所有活跃的sheet
        [self closeAllSheets];
        
        // 清理Qt应用
        if (self.qtApplication != QApplication::instance()) {
            delete self.qtApplication;
        }
        self.qtApplication = nullptr;
        self.isQtInitialized = NO;
        NSLog(@"Qt application cleaned up");
    }
}

#pragma mark - Public Methods

- (QtSheetContainer *)showQtSheetWithTitle:(NSString *)title 
                                     size:(NSSize)size
                         completionHandler:(void(^)(NSModalResponse result, NSString *userInput))completionHandler {
    
    if (!self.isQtInitialized) {
        if (![self initializeQtApplication]) {
            NSLog(@"Error: Failed to initialize Qt application");
            return nil;
        }
    }
    
    // 创建Qt widget
    QtSheetWidget *qtWidget = new QtSheetWidget();
    
    // 创建sheet容器
    QtSheetContainer *container = [[QtSheetContainer alloc] initWithParentWindow:[NSApp mainWindow]
                                                                     qtViewSize:size
                                                                          title:title];
    
    // 设置Qt视图
    [container setQtView:qtWidget];
    container.delegate = self;
    
    // 添加到活跃列表
    [self.activeContainers addObject:container];
    
    // 连接Qt信号
    QObject::connect(qtWidget, &QtSheetWidget::okClicked, [=]() {
        [container dismissSheetWithResult:NSModalResponseOK];
    });
    
    QObject::connect(qtWidget, &QtSheetWidget::cancelClicked, [=]() {
        [container dismissSheetWithResult:NSModalResponseCancel];
    });
    
    // 显示sheet
    [container showSheetWithCompletionHandler:^(NSModalResponse result) {
        NSString *userInput = nil;
        if (result == NSModalResponseOK) {
            userInput = [NSString stringWithUTF8String:qtWidget->getUserInput().toUtf8().constData()];
        }
        
        // 从活跃列表中移除
        [self.activeContainers removeObject:container];
        
        // 清理Qt widget
        qtWidget->deleteLater();
        
        // 调用完成回调
        if (completionHandler) {
            completionHandler(result, userInput);
        }
    }];
    
    return container;
}

- (QtSheetContainer *)showCustomQtSheet:(void *)qtWidget
                                  title:(NSString *)title
                                   size:(NSSize)size
                       completionHandler:(void(^)(NSModalResponse result))completionHandler {
    
    if (!self.isQtInitialized) {
        if (![self initializeQtApplication]) {
            NSLog(@"Error: Failed to initialize Qt application");
            return nil;
        }
    }
    
    // 创建sheet容器
    QtSheetContainer *container = [[QtSheetContainer alloc] initWithParentWindow:[NSApp mainWindow]
                                                                     qtViewSize:size
                                                                          title:title];
    
    // 设置Qt视图
    [container setQtView:qtWidget];
    container.delegate = self;
    
    // 添加到活跃列表
    [self.activeContainers addObject:container];
    
    // 显示sheet
    [container showSheetWithCompletionHandler:^(NSModalResponse result) {
        // 从活跃列表中移除
        [self.activeContainers removeObject:container];
        
        // 调用完成回调
        if (completionHandler) {
            completionHandler(result);
        }
    }];
    
    return container;
}

- (void)closeAllSheets {
    NSArray<QtSheetContainer *> *containersToClose = [self.activeContainers copy];
    
    for (QtSheetContainer *container in containersToClose) {
        [container dismissSheetWithResult:NSModalResponseCancel];
    }
}

#pragma mark - QtSheetContainerDelegate

- (void)qtSheetContainer:(QtSheetContainer *)container didFinishWithResult:(NSModalResponse)result {
    NSLog(@"Qt sheet container finished with result: %ld", (long)result);
}

- (void)qtSheetContainerDidCancel:(QtSheetContainer *)container {
    NSLog(@"Qt sheet container was cancelled");
}

- (void)qtSheetContainerDidConfirm:(QtSheetContainer *)container {
    NSLog(@"Qt sheet container was confirmed");
}

@end