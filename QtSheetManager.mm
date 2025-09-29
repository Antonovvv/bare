//
//  QtSheetManager.mm
//  Qt NSWindow Sheet Management
//
//  Created on 2024
//

#import "QtSheetManager.h"

@interface QtSheetManager () <QtSheetContainerDelegate>
@property (nonatomic, weak) NSWindow *parentWindow;
@property (nonatomic, strong) NSMutableArray<QtSheetContainer *> *activeSheets;
@end

@implementation QtSheetManager

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static QtSheetManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QtSheetManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _activeSheets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithParentWindow:(NSWindow *)parentWindow {
    self = [self init];
    if (self) {
        _parentWindow = parentWindow;
    }
    return self;
}

#pragma mark - Public Methods

- (QtSheetContainer *)showQtSheetWithSize:(NSSize)size 
                                    title:(NSString *)title 
                                qtWidget:(void *)qtWidget
                        completionHandler:(void(^)(NSModalResponse result))completionHandler {
    
    if (!self.parentWindow) {
        NSLog(@"Error: No parent window set");
        return nil;
    }
    
    // 创建sheet容器
    QtSheetContainer *container = [[QtSheetContainer alloc] initWithParentWindow:self.parentWindow
                                                                     qtViewSize:size
                                                                          title:title];
    
    // 设置Qt视图
    if (qtWidget) {
        [container setQtView:qtWidget];
    }
    
    // 设置代理
    container.delegate = self;
    
    // 添加到活跃列表
    [self.activeSheets addObject:container];
    
    // 显示sheet
    [container showSheetWithCompletionHandler:^(NSModalResponse result) {
        // 从活跃列表中移除
        [self.activeSheets removeObject:container];
        
        // 调用完成回调
        if (completionHandler) {
            completionHandler(result);
        }
    }];
    
    return container;
}

- (void)closeAllSheets {
    // 创建副本避免在遍历时修改数组
    NSArray<QtSheetContainer *> *sheetsToClose = [self.activeSheets copy];
    
    for (QtSheetContainer *sheet in sheetsToClose) {
        [sheet dismissSheetWithResult:NSModalResponseCancel];
    }
}

- (void)closeSheet:(QtSheetContainer *)sheet {
    if ([self.activeSheets containsObject:sheet]) {
        [sheet dismissSheetWithResult:NSModalResponseCancel];
    }
}

- (BOOL)hasActiveSheets {
    return self.activeSheets.count > 0;
}

#pragma mark - QtSheetContainerDelegate

- (void)qtSheetContainer:(QtSheetContainer *)container didFinishWithResult:(NSModalResponse)result {
    NSLog(@"Qt sheet finished with result: %ld", (long)result);
}

- (void)qtSheetContainerDidCancel:(QtSheetContainer *)container {
    NSLog(@"Qt sheet was cancelled");
}

- (void)qtSheetContainerDidConfirm:(QtSheetContainer *)container {
    NSLog(@"Qt sheet was confirmed");
}

@end