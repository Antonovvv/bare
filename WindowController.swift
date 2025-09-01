import Cocoa

class CustomWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let window = window else { return }
        
        // 设置 FullSizeContentView 和 titlebarAppearsTransparent
        window.styleMask.insert(.fullSizeContentView)
        window.titlebarAppearsTransparent = true
        
        // 获取红绿灯按钮的尺寸和位置信息
        let buttonSize = window.trafficLightButtonSize
        let buttonFrame = window.trafficLightButtonFrame
        let buttonsArea = window.trafficLightButtonsArea
        
        print("红绿灯按钮尺寸: \(buttonSize)")
        print("红绿灯按钮位置: \(buttonFrame)")
        print("红绿灯按钮区域: \(buttonsArea)")
        
        // 动态获取按钮尺寸
        if let dynamicSize = window.getDynamicTrafficLightButtonSize() {
            print("动态检测的按钮尺寸: \(dynamicSize)")
        }
        
        // 创建自定义视图，避免与红绿灯按钮重叠
        setupCustomContentView(window: window)
    }
    
    private func setupCustomContentView(window: NSWindow) {
        guard let contentView = window.contentView else { return }
        
        // 获取红绿灯按钮区域
        let trafficLightArea = window.trafficLightButtonsArea
        
        // 创建一个自定义视图，避免与红绿灯按钮重叠
        let customView = NSView()
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.wantsLayer = true
        customView.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        contentView.addSubview(customView)
        
        // 设置约束，确保不覆盖红绿灯按钮
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: trafficLightArea.maxY + 10),
            customView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            customView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            customView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // 添加标签显示红绿灯按钮信息
        let infoLabel = NSTextField(labelWithString: "红绿灯按钮尺寸: \(trafficLightArea.size)")
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = .labelColor
        
        contentView.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: customView.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
}