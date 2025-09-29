//
//  QtSheetIntegration.h
//  Complete Qt-NSWindow Sheet Integration
//
//  Created on 2024
//

#import <Cocoa/Cocoa.h>
#import "QtSheetContainer.h"
#import "QtSheetManager.h"

NS_ASSUME_NONNULL_BEGIN

// Qt前向声明
class QApplication;
class QtSheetWidget;

@interface QtSheetIntegration : NSObject

@property (nonatomic, strong, readonly) QtSheetManager *sheetManager;
@property (nonatomic, assign, readonly) BOOL isQtInitialized;

// 单例
+ (instancetype)sharedIntegration;

// 初始化Qt应用
- (BOOL)initializeQtApplication;

// 清理Qt应用
- (void)cleanupQtApplication;

// 显示Qt sheet
- (QtSheetContainer *)showQtSheetWithTitle:(NSString *)title 
                                     size:(NSSize)size
                         completionHandler:(void(^)(NSModalResponse result, NSString *userInput))completionHandler;

// 显示自定义Qt sheet
- (QtSheetContainer *)showCustomQtSheet:(void *)qtWidget
                                  title:(NSString *)title
                                   size:(NSSize)size
                       completionHandler:(void(^)(NSModalResponse result))completionHandler;

// 关闭所有sheet
- (void)closeAllSheets;

@end

NS_ASSUME_NONNULL_END