//
//  QtSheetContainer.h
//  Qt NSWindow Sheet Integration
//
//  Created on 2024
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QtSheetContainer;

@protocol QtSheetContainerDelegate <NSObject>
@optional
- (void)qtSheetContainer:(QtSheetContainer *)container didFinishWithResult:(NSModalResponse)result;
- (void)qtSheetContainerDidCancel:(QtSheetContainer *)container;
- (void)qtSheetContainerDidConfirm:(QtSheetContainer *)container;
@end

@interface QtSheetContainer : NSObject

@property (nonatomic, weak) id<QtSheetContainerDelegate> delegate;
@property (nonatomic, strong, readonly) NSWindow *sheetWindow;
@property (nonatomic, strong, readonly) NSView *qtContainerView;

// 初始化方法
- (instancetype)initWithParentWindow:(NSWindow *)parentWindow 
                        qtViewSize:(NSSize)size 
                           title:(NSString *)title;

// 显示sheet
- (void)showSheetWithCompletionHandler:(void(^)(NSModalResponse result))completionHandler;

// 关闭sheet
- (void)dismissSheetWithResult:(NSModalResponse)result;

// 设置Qt视图
- (void)setQtView:(void *)qtWidget;

// 获取Qt视图
- (void *)qtWidget;

@end

NS_ASSUME_NONNULL_END