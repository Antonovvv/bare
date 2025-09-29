# Qt NSWindow Sheet Integration

一个完整的Qt视图嵌入NSWindow作为sheet的解决方案，提供了最佳实践和完整的生命周期管理。

## 功能特性

- ✅ 完整的Qt-NSWindow桥接
- ✅ 自动信号槽机制处理确定/取消按钮
- ✅ 完整的生命周期管理
- ✅ 错误处理和异常情况处理
- ✅ 多sheet管理
- ✅ 内存安全
- ✅ 线程安全

## 文件结构

```
├── QtSheetContainer.h/.mm     # Qt视图容器类
├── QtSheetManager.h/.mm       # Sheet管理器
├── QtSheetIntegration.h/.mm   # 完整集成类
├── QtSheetWidget.h/.cpp       # 示例Qt Widget
├── ExampleUsage.mm            # 使用示例
├── CMakeLists.txt             # 构建配置
├── Info.plist                 # macOS应用配置
└── README.md                  # 说明文档
```

## 快速开始

### 1. 基本使用

```objc
#import "QtSheetIntegration.h"

// 获取集成实例
QtSheetIntegration *integration = [QtSheetIntegration sharedIntegration];

// 显示Qt sheet
[integration showQtSheetWithTitle:@"My Qt Sheet"
                            size:NSMakeSize(500, 400)
                completionHandler:^(NSModalResponse result, NSString *userInput) {
    if (result == NSModalResponseOK) {
        NSLog(@"用户输入：%@", userInput);
    } else {
        NSLog(@"用户取消了操作");
    }
}];
```

### 2. 自定义Qt Widget

```objc
// 创建你的Qt Widget
MyCustomQtWidget *qtWidget = new MyCustomQtWidget();

// 显示自定义sheet
[integration showCustomQtSheet:qtWidget
                         title:@"Custom Sheet"
                          size:NSMakeSize(600, 500)
              completionHandler:^(NSModalResponse result) {
    // 处理结果
}];
```

### 3. 多Sheet管理

```objc
// 显示第一个sheet
[integration showQtSheetWithTitle:@"First Sheet"
                            size:NSMakeSize(400, 300)
                completionHandler:^(NSModalResponse result, NSString *userInput) {
    if (result == NSModalResponseOK) {
        // 显示第二个sheet
        [integration showQtSheetWithTitle:@"Second Sheet"
                                    size:NSMakeSize(450, 350)
                        completionHandler:^(NSModalResponse result2, NSString *userInput2) {
            // 处理两个sheet的结果
        }];
    }
}];
```

## 构建说明

### 依赖要求

- macOS 10.15+
- Qt 6.0+
- Xcode 12.0+
- CMake 3.16+

### 构建步骤

```bash
# 创建构建目录
mkdir build && cd build

# 配置CMake
cmake .. -DCMAKE_BUILD_TYPE=Release

# 编译
make -j$(nproc)

# 运行
./QtNSWindowSheetIntegration
```

## 核心组件说明

### QtSheetContainer

负责Qt视图与NSWindow的桥接，处理：
- Qt视图的嵌入
- 信号槽机制
- 窗口生命周期管理
- 内存管理

### QtSheetManager

管理多个sheet的生命周期：
- 创建和销毁sheet
- 跟踪活跃的sheet
- 批量关闭sheet

### QtSheetIntegration

提供高级API：
- Qt应用初始化
- 简化的sheet创建
- 错误处理
- 线程安全

## 最佳实践

### 1. 内存管理

```objc
// ✅ 正确：让系统自动管理
QtSheetContainer *container = [integration showQtSheetWithTitle:@"Test" size:size completionHandler:^(NSModalResponse result, NSString *userInput) {
    // 系统会自动清理container
}];

// ❌ 错误：不要手动retain
QtSheetContainer *container = [[QtSheetContainer alloc] init];
// 不要这样做，会导致内存泄漏
```

### 2. 线程安全

```objc
// ✅ 正确：在主线程调用
dispatch_async(dispatch_get_main_queue(), ^{
    [integration showQtSheetWithTitle:@"Test" size:size completionHandler:^(NSModalResponse result, NSString *userInput) {
        // 处理结果
    }];
});

// ❌ 错误：在后台线程调用
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [integration showQtSheetWithTitle:@"Test" size:size completionHandler:nil]; // 可能崩溃
});
```

### 3. 错误处理

```objc
// ✅ 正确：检查初始化状态
if (!integration.isQtInitialized) {
    NSLog(@"Qt未初始化");
    return;
}

[integration showQtSheetWithTitle:@"Test" size:size completionHandler:^(NSModalResponse result, NSString *userInput) {
    switch (result) {
        case NSModalResponseOK:
            // 处理成功
            break;
        case NSModalResponseCancel:
            // 处理取消
            break;
        default:
            // 处理其他情况
            break;
    }
}];
```

### 4. Qt信号连接

```cpp
// 在你的Qt Widget中
class MyQtWidget : public QWidget {
    Q_OBJECT
    
public slots:
    void onOkClicked() {
        emit okClicked(); // 这会自动触发sheet关闭
    }
    
    void onCancelClicked() {
        emit cancelClicked(); // 这会自动触发sheet关闭
    }
    
signals:
    void okClicked();
    void cancelClicked();
};
```

## 常见问题

### Q: 如何自定义Qt Widget的样式？
A: 在Qt Widget中使用QSS（Qt Style Sheets）或重写paintEvent方法。

### Q: 如何处理Qt Widget中的键盘事件？
A: 重写keyPressEvent方法，或者使用Qt的快捷键机制。

### Q: 如何在不同屏幕分辨率下保持一致性？
A: 使用Qt的DPI感知功能，或者根据屏幕分辨率动态调整大小。

### Q: 如何处理Qt Widget中的文件拖拽？
A: 重写dragEnterEvent和dropEvent方法，并设置acceptDrops(true)。

## 许可证

MIT License - 详见LICENSE文件

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。