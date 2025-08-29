import SwiftUI
import Cocoa

class BackgroundConfigWindow: NSWindowController, NSWindowDelegate {
    private var manager: EyeCareManager
    private var isFileChooserOpen = false  // 添加状态标记
    
    init(manager: EyeCareManager) {
        self.manager = manager
      
        // 获取屏幕尺寸
        let screenSize = NSScreen.main?.frame.size ?? NSSize(width: 1000, height: 800)

        // 窗口尺寸：宽度是屏幕的一半，高度也是屏幕的一半
        let windowWidth = screenSize.width * 0.5
        let windowHeight = screenSize.height * 0.5

        let windowRect = NSRect(
            x: (screenSize.width) / 2,
            y: (screenSize.height) / 2,
            width: windowWidth,
            height: windowHeight
        )

        let window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = LocalizedStrings.backgroundSettings
        window.isReleasedWhenClosed = false

        super.init(window: window)
        
        // 设置窗口代理
        window.delegate = self
        
        // 设置内容视图
        let contentView = BackgroundConfigView(manager: manager) {
            self.closeWindow()
        } onImageSelectionStart: {
            // 当开始选择图片时，设置标记
            self.isFileChooserOpen = true
        } onImageSelectionEnd: {
            // 当图片选择结束时，清除标记
            self.isFileChooserOpen = false
        }
        window.contentView = NSHostingView(rootView: contentView)
        
        // 让窗口成为关键窗口
        window.makeKeyAndOrderFront(nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func close() {
        self.window?.close()
    }
    
    private func closeWindow() {
        self.close()
    }
    
    override func showWindow(_ sender: Any?) {
          super.showWindow(sender)
        
          // 关键：临时激活应用以便显示窗口
          DispatchQueue.main.async {
              // 临时设置为 regular 模式以显示窗口
              NSApp.setActivationPolicy(.regular)
              // 显示并激活窗口
              self.window?.center()
              self.window?.makeKeyAndOrderFront(nil)
              NSApp.activate(ignoringOtherApps: true)

          }
      }
    
    // MARK: - NSWindowDelegate
    // 当窗口失去焦点时自动关闭（但排除文件选择对话框的情况）
    /*
    func windowDidResignKey(_ notification: Notification) {
        // 延迟检查，避免文件选择对话框导致的误关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 只有当不是文件选择对话框导致失去焦点时才关闭
            if !self.isFileChooserOpen {
                NSApp.setActivationPolicy(.accessory)
                self.closeWindow()
            }
        }
    }
    */
    
    // 当窗口即将关闭时清理资源
    func windowWillClose(_ notification: Notification) {
        DispatchQueue.main.async {
                  NSApp.setActivationPolicy(.accessory)
        }
    }
}

struct BackgroundConfigView: View {
    @ObservedObject var manager: EyeCareManager
    let onClose: () -> Void
    let onImageSelectionStart: () -> Void  // 添加回调
    let onImageSelectionEnd: () -> Void    // 添加回调
    
    // 默认背景图片
    @State private var defaultBackgroundImage: NSImage? = nil
    // 存储每张图片的选中状态
    @State private var selectedImages: [NSImage?] = Array(repeating: nil, count: 8)
    // 存储图片文件路径
    @State private var imagePaths: [String] = Array(repeating: "", count: 8)
    
        
        var body: some View {
            VStack(spacing: 12) {
                // 提示文字
                
                Text(LocalizedStrings.clickImageToChangeBackground)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)  // 固定大小以避免布局问题
                
                
                // 8张图片网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(0..<8, id: \.self) { index in
                        BackgroundImageView(
                            image: selectedImages[index] ?? defaultBackgroundImage,
                            index: index,
                            onTap: {
                                selectBackgroundImage(for: index)
                            }
                        )
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                
                // 退出按钮
                Button(LocalizedStrings.done) {
                    onClose()
                }
                .padding(.bottom, 12)
                .keyboardShortcut(.defaultAction)
            }
            .frame(minWidth: 450, minHeight: 320)
            .onAppear {
                loadBackgroundImages()
            }
        }
    private func selectBackgroundImage(for index: Int) {
                let panel = NSOpenPanel()
                panel.canChooseFiles = true
                panel.canChooseDirectories = false
                panel.allowsMultipleSelection = false
                panel.allowedContentTypes = [.png, .jpeg, .tiff, .gif]
                panel.prompt = LocalizedStrings.selectImage
                
                // 使用 completion handler 确保状态管理正确
                onImageSelectionStart()
                panel.begin { response in
                    DispatchQueue.main.async {
                        // 无论成功与否都要结束选择状态
                        self.onImageSelectionEnd()
                        
                        if response == .OK {
                            if let url = panel.url {
                                if let image = NSImage(contentsOf: url) {
                                    // 保存图片到指定目录
                                    self.saveImage(image, atIndex: index)
                                }
                            }
                        }
                    }
                }
            }
    
    private func loadBackgroundImages() {
        let result = BackgroundImageManager.shared.loadAllBackgroundImages()
        selectedImages = result.images
        imagePaths = result.paths
    }

    private func saveImage(_ image: NSImage, atIndex index: Int) {
        if BackgroundImageManager.shared.saveImage(image, atIndex: index) {
            // 更新状态
            selectedImages[index] = image
            imagePaths[index] = "\(BackgroundImageManager.shared.getBackgroundDirectory())bg\(index).jpg"
            print("图片已保存到索引 \(index)")
        }
    }
}

// 单个背景图片视图
struct BackgroundImageView: View {
    let image: NSImage?
    let index: Int
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // 背景容器
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    Group {
                        if let nsImage = image {
                            // 显示图片
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            // 显示默认背景（渐变色）
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .overlay(
                    // 显示索引号
                    Text("\(index + 1)")
                        .foregroundColor(image == nil ? .primary : .white)
                        .font(.headline)
                        .shadow(color: image != nil ? .black.opacity(0.5) : .clear, radius: 1)
                )
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            onTap()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
