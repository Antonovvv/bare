# Mac 应用窗口重新打开示例

这个项目演示了如何实现Mac应用窗口关闭后，通过点击Dock图标重新打开窗口的功能。

## 功能特性

- ✅ 点击窗口关闭按钮时隐藏窗口而不是退出应用
- ✅ 点击Dock中的应用图标重新显示窗口
- ✅ 使用SwiftUI构建现代化界面
- ✅ 支持macOS 13.0+

## 核心实现原理

### 1. 窗口关闭行为控制
```swift
func windowShouldClose(_ sender: NSWindow) -> Bool {
    // 当用户点击关闭按钮时，隐藏窗口而不是关闭
    sender.orderOut(nil)
    return false
}
```

### 2. 应用重新打开处理
```swift
func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    // 当点击Dock图标时，如果没有可见窗口，则显示主窗口
    if !flag {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    return true
}
```

### 3. 防止应用自动退出
```swift
func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    // 当最后一个窗口关闭时，不自动退出应用
    return false
}
```

## 构建和运行

### 使用 Swift Package Manager
```bash
swift build
swift run
```

### 使用 Xcode
1. 在 Xcode 中打开项目
2. 选择目标设备为 Mac
3. 点击运行按钮

## 项目结构

- `ReopenMacAppApp.swift` - 主应用入口
- `ContentView.swift` - 主界面视图
- `AppDelegate.swift` - 应用委托，处理窗口生命周期
- `Info.plist` - 应用配置文件
- `Package.swift` - Swift Package Manager 配置

## 关键配置

### Info.plist 设置
- `LSUIElement`: 设置为 `false`，确保应用在Dock中显示
- `NSHighResolutionCapable`: 支持高分辨率显示
- `NSSupportsAutomaticGraphicsSwitching`: 支持自动图形切换

## 使用说明

1. 运行应用后，会显示一个包含关闭按钮的窗口
2. 点击窗口的关闭按钮（红色圆点），窗口会隐藏但应用不会退出
3. 点击Dock中的应用图标，窗口会重新显示
4. 应用会继续在后台运行，直到手动退出

## 注意事项

- 确保 `window.isReleasedWhenClosed = false` 以防止窗口被释放
- 使用 `NSApp.activate(ignoringOtherApps: true)` 确保窗口获得焦点
- 在 `applicationShouldTerminateAfterLastWindowClosed` 中返回 `false` 防止自动退出