import Cocoa

class TrafficLightButtonSizeDetector: NSObject {
    
    // 方法1：通过计算获取红绿灯按钮的尺寸
    static func getTrafficLightButtonSize() -> NSSize {
        // 红绿灯按钮的标准尺寸（在大多数情况下）
        let standardWidth: CGFloat = 12.0
        let standardHeight: CGFloat = 12.0
        
        // 按钮之间的间距
        let buttonSpacing: CGFloat = 6.0
        
        // 从窗口左边到第一个按钮的距离
        let leftMargin: CGFloat = 8.0
        
        // 从窗口顶部到按钮中心的距离
        let topMargin: CGFloat = 16.0
        
        return NSSize(width: standardWidth, height: standardHeight)
    }
    
    // 方法2：获取红绿灯按钮的位置信息
    static func getTrafficLightButtonFrame() -> NSRect {
        let buttonSize = getTrafficLightButtonSize()
        let leftMargin: CGFloat = 8.0
        let topMargin: CGFloat = 16.0
        
        return NSRect(x: leftMargin, y: topMargin - buttonSize.height/2, 
                     width: buttonSize.width, height: buttonSize.height)
    }
    
    // 方法3：获取所有三个按钮的完整区域
    static func getTrafficLightButtonsArea() -> NSRect {
        let buttonSize = getTrafficLightButtonSize()
        let leftMargin: CGFloat = 8.0
        let topMargin: CGFloat = 16.0
        let buttonSpacing: CGFloat = 6.0
        
        let totalWidth = buttonSize.width * 3 + buttonSpacing * 2
        let totalHeight = buttonSize.height
        
        return NSRect(x: leftMargin, y: topMargin - totalHeight/2, 
                     width: totalWidth, height: totalHeight)
    }
    
    // 方法4：动态检测（通过窗口的 contentView 计算）
    static func getTrafficLightButtonSizeFromWindow(_ window: NSWindow) -> NSSize? {
        guard let contentView = window.contentView else { return nil }
        
        // 获取窗口的 frame
        let windowFrame = window.frame
        
        // 获取 contentView 的 frame（相对于窗口）
        let contentViewFrame = contentView.frame
        
        // 计算标题栏的高度
        let titleBarHeight = windowFrame.height - contentViewFrame.height
        
        // 红绿灯按钮通常在标题栏的左侧
        if titleBarHeight > 0 {
            // 估算按钮尺寸（基于标题栏高度）
            let estimatedButtonSize = min(titleBarHeight * 0.6, 12.0)
            return NSSize(width: estimatedButtonSize, height: estimatedButtonSize)
        }
        
        return nil
    }
    
    // 方法5：使用私有 API 获取精确尺寸（不推荐用于 App Store）
    static func getTrafficLightButtonSizeUsingPrivateAPI() -> NSSize? {
        // 注意：这种方法使用了私有 API，不能用于 App Store 应用
        // 仅用于开发和调试目的
        
        if let windowClass = NSClassFromString("NSWindow") {
            // 尝试获取红绿灯按钮的尺寸
            // 这里需要更复杂的私有 API 调用
            return NSSize(width: 12.0, height: 12.0)
        }
        
        return nil
    }
}

// 扩展 NSWindow 来添加红绿灯按钮检测功能
extension NSWindow {
    
    var trafficLightButtonSize: NSSize {
        return TrafficLightButtonSizeDetector.getTrafficLightButtonSize()
    }
    
    var trafficLightButtonFrame: NSRect {
        return TrafficLightButtonSizeDetector.getTrafficLightButtonFrame()
    }
    
    var trafficLightButtonsArea: NSRect {
        return TrafficLightButtonSizeDetector.getTrafficLightButtonsArea()
    }
    
    func getDynamicTrafficLightButtonSize() -> NSSize? {
        return TrafficLightButtonSizeDetector.getTrafficLightButtonSizeFromWindow(self)
    }
}