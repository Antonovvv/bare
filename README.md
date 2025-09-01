# macOS 红绿灯按钮尺寸检测

这个项目展示了如何在 macOS 应用程序中检测红绿灯按钮（关闭、最小化、最大化按钮）的尺寸和位置，特别是在使用 `FullSizeContentView` 和 `titlebarAppearsTransparent` 的情况下。

## 功能特性

- 🎯 精确检测红绿灯按钮的尺寸和位置
- 🔄 动态监控窗口状态变化
- 📱 支持不同 macOS 版本的适配
- 🎨 自动避免 UI 元素与红绿灯按钮重叠
- 📊 提供多种检测方法

## 文件结构

```
├── TrafficLightButtonSizeDetector.swift  # 核心检测类
├── TrafficLightButtonObserver.swift      # 动态观察者
├── WindowController.swift                # 窗口控制器示例
├── AppDelegate.swift                     # 应用程序委托
└── README.md                            # 说明文档
```

## 使用方法

### 1. 基本检测

```swift
import Cocoa

class MyWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let window = window else { return }
        
        // 设置 FullSizeContentView 和 titlebarAppearsTransparent
        window.styleMask.insert(.fullSizeContentView)
        window.titlebarAppearsTransparent = true
        
        // 获取红绿灯按钮信息
        let buttonSize = window.trafficLightButtonSize
        let buttonFrame = window.trafficLightButtonFrame
        let buttonsArea = window.trafficLightButtonsArea
        
        print("按钮尺寸: \(buttonSize)")
        print("按钮位置: \(buttonFrame)")
        print("按钮区域: \(buttonsArea)")
    }
}
```

### 2. 动态观察

```swift
// 开始观察红绿灯按钮变化
window.startObservingTrafficLightButtons { newSize in
    print("按钮尺寸变化: \(newSize)")
    // 更新 UI 布局
    self.updateLayout(for: newSize)
}

// 获取当前尺寸
let currentSize = window.trafficLightObserver.getCurrentButtonSize()
let buttonsArea = window.trafficLightObserver.getButtonsArea()
```

### 3. 避免重叠

```swift
private func setupContentView() {
    guard let contentView = window.contentView else { return }
    
    // 获取红绿灯按钮区域
    let trafficLightArea = window.trafficLightButtonsArea
    
    // 创建自定义视图，确保不覆盖红绿灯按钮
    let customView = NSView()
    customView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(customView)
    
    // 设置约束，避免与红绿灯按钮重叠
    NSLayoutConstraint.activate([
        customView.topAnchor.constraint(equalTo: contentView.topAnchor, 
                                      constant: trafficLightArea.maxY + 10),
        customView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
        customView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        customView.heightAnchor.constraint(equalToConstant: 100)
    ])
}
```

## 检测方法说明

### 方法1：静态计算
- 使用预定义的尺寸和位置
- 适用于大多数标准情况
- 性能最好，但可能不够精确

### 方法2：动态检测
- 通过窗口的 `contentView` 计算
- 考虑窗口状态变化
- 平衡了性能和准确性

### 方法3：观察者模式
- 实时监控窗口状态变化
- 自动更新按钮信息
- 最准确但性能开销较大

## macOS 版本兼容性

| macOS 版本 | 按钮尺寸 | 位置调整 |
|------------|----------|----------|
| 10.14 及以下 | 12x12 | 8, 16 |
| 10.15 (Catalina) | 12x12 | 10, 17 |
| 11+ (Big Sur) | 12x12 | 12, 18 |

## 注意事项

1. **App Store 兼容性**: 避免使用私有 API，确保应用能通过 App Store 审核
2. **性能考虑**: 在不需要实时更新的情况下，使用静态方法
3. **内存管理**: 观察者会自动清理，但注意避免循环引用
4. **多显示器**: 考虑不同显示器的缩放因子

## 常见问题

### Q: 为什么检测的尺寸不准确？
A: 红绿灯按钮的尺寸可能因 macOS 版本、窗口状态、显示器缩放等因素而变化。建议使用观察者模式获取最准确的信息。

### Q: 如何避免 UI 元素与红绿灯按钮重叠？
A: 使用 `getButtonsArea()` 方法获取按钮区域，然后在设置约束时确保 UI 元素位于该区域下方。

### Q: 全屏模式下如何处理？
A: 全屏模式下红绿灯按钮通常不可见，检测方法会返回零尺寸。

## 扩展功能

你可以基于这个基础框架添加更多功能：

- 自定义红绿灯按钮样式
- 支持不同主题模式
- 多窗口管理
- 国际化支持

## 许可证

MIT License - 可自由使用和修改