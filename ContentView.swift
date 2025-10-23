import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "macwindow")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Mac 窗口重新打开示例")
                .font(.title)
                .fontWeight(.bold)
            
            Text("关闭此窗口后，点击 Dock 中的应用图标可以重新打开")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("关闭窗口") {
                // 关闭窗口（隐藏应用）
                NSApplication.shared.hide(nil)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
}