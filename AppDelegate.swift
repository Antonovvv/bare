import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    var windowController: CustomWindowController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 创建窗口
        createMainWindow()
        
        // 设置红绿灯按钮观察者
        setupTrafficLightButtonObserver()
    }
    
    private func createMainWindow() {
        // 创建窗口
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // 设置窗口属性
        window.title = "红绿灯按钮检测示例"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = false
        window.center()
        
        // 创建窗口控制器
        windowController = CustomWindowController(window: window)
        windowController.showWindow(nil)
        
        // 设置窗口为关键窗口
        window.makeKeyAndOrderFront(nil)
    }
    
    private func setupTrafficLightButtonObserver() {
        // 开始观察红绿灯按钮变化
        window.startObservingTrafficLightButtons { [weak self] newSize in
            print("红绿灯按钮尺寸变化: \(newSize)")
            self?.updateUIForButtonSize(newSize)
        }
        
        // 立即获取当前尺寸
        let currentSize = window.trafficLightObserver.getCurrentButtonSize()
        print("当前红绿灯按钮尺寸: \(currentSize)")
        
        let buttonsArea = window.trafficLightObserver.getButtonsArea()
        print("红绿灯按钮区域: \(buttonsArea)")
    }
    
    private func updateUIForButtonSize(_ size: NSSize) {
        // 在主线程更新 UI
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 更新窗口内容，避免与红绿灯按钮重叠
            self.updateWindowLayout(for: size)
        }
    }
    
    private func updateWindowLayout(for buttonSize: NSSize) {
        guard let contentView = window.contentView else { return }
        
        // 获取红绿灯按钮区域
        let buttonsArea = window.trafficLightObserver.getButtonsArea()
        
        // 更新所有子视图的约束，确保不覆盖红绿灯按钮
        for subview in contentView.subviews {
            if let constraints = subview.constraints {
                for constraint in constraints {
                    if constraint.firstAttribute == .top && constraint.firstItem === subview {
                        // 更新顶部约束，确保在红绿灯按钮下方
                        constraint.constant = max(constraint.constant, buttonsArea.maxY + 10)
                    }
                }
            }
        }
        
        // 强制更新布局
        contentView.needsLayout = true
        contentView.layoutSubtreeIfNeeded()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // 停止观察
        window.stopObservingTrafficLightButtons()
    }
    
    // 添加菜单项来测试不同的窗口状态
    @IBAction func toggleFullScreen(_ sender: Any) {
        window.toggleFullScreen(sender)
    }
    
    @IBAction func toggleTitlebarTransparency(_ sender: Any) {
        window.titlebarAppearsTransparent.toggle()
        
        // 重新获取红绿灯按钮信息
        let newSize = window.trafficLightObserver.getCurrentButtonSize()
        print("切换标题栏透明度后，红绿灯按钮尺寸: \(newSize)")
    }
}