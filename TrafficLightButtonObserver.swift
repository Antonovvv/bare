import Cocoa

class TrafficLightButtonObserver: NSObject {
    
    private var window: NSWindow
    private var observation: NSKeyValueObservation?
    
    // 回调闭包类型
    typealias ButtonSizeChangedHandler = (NSSize) -> Void
    private var sizeChangedHandler: ButtonSizeChangedHandler?
    
    init(window: NSWindow) {
        self.window = window
        super.init()
        setupObservations()
    }
    
    deinit {
        observation?.invalidate()
    }
    
    // 设置观察者
    private func setupObservations() {
        // 观察窗口 frame 变化
        observation = window.observe(\.frame, options: [.new, .old]) { [weak self] _, _ in
            self?.handleWindowFrameChanged()
        }
        
        // 观察 contentView 变化
        if let contentView = window.contentView {
            contentView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        }
    }
    
    // 设置尺寸变化回调
    func onButtonSizeChanged(_ handler: @escaping ButtonSizeChangedHandler) {
        sizeChangedHandler = handler
    }
    
    // 处理窗口 frame 变化
    private func handleWindowFrameChanged() {
        let newSize = getCurrentButtonSize()
        sizeChangedHandler?(newSize)
    }
    
    // 获取当前按钮尺寸
    func getCurrentButtonSize() -> NSSize {
        // 根据 macOS 版本和窗口状态调整
        let macOSVersion = ProcessInfo.processInfo.operatingSystemVersion
        
        var buttonSize: NSSize
        
        if macOSVersion.majorVersion >= 11 {
            // macOS 11+ (Big Sur 及以上)
            buttonSize = NSSize(width: 12.0, height: 12.0)
        } else if macOSVersion.majorVersion >= 10 && macOSVersion.minorVersion >= 15 {
            // macOS 10.15 (Catalina)
            buttonSize = NSSize(width: 12.0, height: 12.0)
        } else {
            // macOS 10.14 及以下
            buttonSize = NSSize(width: 12.0, height: 12.0)
        }
        
        // 根据窗口状态调整
        if window.isFullScreen {
            // 全屏模式下按钮可能不可见或尺寸不同
            buttonSize = NSSize(width: 0, height: 0)
        } else if window.styleMask.contains(.fullSizeContentView) {
            // FullSizeContentView 模式下可能需要调整
            if let contentView = window.contentView {
                let titleBarHeight = window.frame.height - contentView.frame.height
                if titleBarHeight > 0 {
                    buttonSize = NSSize(width: min(titleBarHeight * 0.6, 12.0), 
                                      height: min(titleBarHeight * 0.6, 12.0))
                }
            }
        }
        
        return buttonSize
    }
    
    // 获取按钮的精确位置（考虑不同的 macOS 版本）
    func getButtonPosition() -> NSPoint {
        let buttonSize = getCurrentButtonSize()
        let macOSVersion = ProcessInfo.processInfo.operatingSystemVersion
        
        var x: CGFloat = 8.0
        var y: CGFloat = 16.0
        
        if macOSVersion.majorVersion >= 11 {
            // macOS 11+ 的调整
            x = 12.0
            y = 18.0
        } else if macOSVersion.majorVersion >= 10 && macOSVersion.minorVersion >= 15 {
            // macOS 10.15 的调整
            x = 10.0
            y = 17.0
        }
        
        // 考虑窗口的缩放因子
        let scaleFactor = window.screen?.backingScaleFactor ?? 1.0
        x *= scaleFactor
        y *= scaleFactor
        
        return NSPoint(x: x, y: y)
    }
    
    // 获取所有三个按钮的完整区域
    func getButtonsArea() -> NSRect {
        let buttonSize = getCurrentButtonSize()
        let position = getButtonPosition()
        let buttonSpacing: CGFloat = 6.0
        
        let totalWidth = buttonSize.width * 3 + buttonSpacing * 2
        let totalHeight = buttonSize.height
        
        return NSRect(x: position.x, 
                     y: position.y - totalHeight/2, 
                     width: totalWidth, 
                     height: totalHeight)
    }
    
    // KVO 观察者方法
    override func observeValue(forKeyPath keyPath: String?, 
                              of object: Any?, 
                              change: [NSKeyValueChangeKey : Any]?, 
                              context: UnsafeMutableRawPointer?) {
        
        if keyPath == "frame" {
            handleWindowFrameChanged()
        }
    }
}

// 扩展 NSWindow 添加观察者支持
extension NSWindow {
    
    private static var observerKey: UInt8 = 0
    
    var trafficLightObserver: TrafficLightButtonObserver {
        if let observer = objc_getAssociatedObject(self, &NSWindow.observerKey) as? TrafficLightButtonObserver {
            return observer
        } else {
            let observer = TrafficLightButtonObserver(window: self)
            objc_setAssociatedObject(self, &NSWindow.observerKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return observer
        }
    }
    
    // 开始观察红绿灯按钮变化
    func startObservingTrafficLightButtons(_ handler: @escaping (NSSize) -> Void) {
        trafficLightObserver.onButtonSizeChanged(handler)
    }
    
    // 停止观察
    func stopObservingTrafficLightButtons() {
        // 观察者会在 deinit 时自动清理
    }
}