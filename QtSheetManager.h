//
//  QtSheetManager.h
//  Qt NSWindow Sheet Management
//
//  Created on 2024
//

#import <Cocoa/Cocoa.h>
#import "QtSheetContainer.h"

NS_ASSUME_NONNULL_BEGIN

@interface QtSheetManager : NSObject

@property (nonatomic, weak, readonly) NSWindow *parentWindow;
@property (nonatomic, strong, readonly) NSMutableArray<QtSheetContainer *> *activeSheets;

// 单例模式
+ (instancetype)sharedManager;

// 初始化
- (instancetype)initWithParentWindow:(NSWindow *)parentWindow;

// 创建并显示Qt sheet
- (QtSheetContainer *)showQtSheetWithSize:(NSSize)size 
                                    title:(NSString *)title 
                              qtWidget:(void *)qtWidget
                      completionHandler:(void(^)(NSModalResponse result))completionHandler;

// 关闭所有sheet
- (void)closeAllSheets;

// 关闭指定sheet
- (void)closeSheet:(QtSheetContainer *)sheet;

// 检查是否有活跃的sheet
- (BOOL)hasActiveSheets;

@end

NS_ASSUME_NONNULL_END