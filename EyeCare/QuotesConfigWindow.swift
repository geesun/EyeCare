import SwiftUI
import Cocoa

class QuotesConfigWindow: NSWindowController, NSWindowDelegate {
    private var manager: EyeCareManager
    
    init(manager: EyeCareManager) {
        self.manager = manager
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = LocalizedStrings.customQuotesSettings
        window.center()
        window.isReleasedWhenClosed = false
        
        super.init(window: window)
        
        // 设置窗口代理
        window.delegate = self
        
        // 设置内容视图
        let contentView = QuotesConfigView(manager: manager) {
            self.closeWindow()
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
            NSApp.setActivationPolicy(.accessory)
            self.closeWindow()
            
        }
    }*/
    
    // 当窗口即将关闭时清理资源
    func windowWillClose(_ notification: Notification) {
        DispatchQueue.main.async {
                  NSApp.setActivationPolicy(.accessory)
        }
    }
}

struct QuotesConfigView: View {
    @ObservedObject var manager: EyeCareManager
    let onClose: () -> Void
    
    // Quotes 文本
    @State private var quotesText: String = ""
    @State private var isSaving = false
    @State private var isResetting = false
    @State private var showingResetConfirmation = false
    
    var body: some View {
         VStack(spacing: 20) {
             // 标题和提示
             VStack(spacing: 8) {
                 
                 Text(LocalizedStrings.customQuotesDescription)
                     .font(.title3)
                     .foregroundColor(.secondary)
                     .multilineTextAlignment(.center)
                     .fixedSize(horizontal: false, vertical: true)  // 固定大小以避免布局问题
             }
             .padding(.top, 20)
             .padding(.horizontal, 30)
             
             // 多行文本框容器
             VStack(spacing: 8) {
                 TextEditor(text: $quotesText)
                     .frame(minHeight: 300)
                     .padding(4)
                     .background(Color(NSColor.textBackgroundColor))  // 使用系统文本背景色
                     .cornerRadius(8)
                     .overlay(
                         RoundedRectangle(cornerRadius: 8)
                             .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                     )
                     .font(.body)  // 明确设置字体以避免 Metal 警告
             }
             .padding(.horizontal, 30)
             .padding(.top, 10)
             
             // 按钮区域
             HStack(spacing: 15) {
                 // 取消按钮
                 Button(LocalizedStrings.cancel) {
                     onClose()
                 }
                 .padding(.horizontal, 30)
                 .padding(.vertical, 12)
                 .background(Color.clear)  // 透明背景
                 .foregroundColor(.primary)
                 .cornerRadius(8)
                 
                 Spacer()
                 
                 // 重置按钮 - 添加确认对话框
                 Button(LocalizedStrings.reset) {
                     showingResetConfirmation = true  // 显示确认对话框
                 }
                 .padding(.horizontal, 30)
                 .padding(.vertical, 12)
                 .background(Color.clear)
                 .foregroundColor(.red)
                 .cornerRadius(8)
                 .disabled(isResetting || isSaving)
                 .alert(LocalizedStrings.confirmReset, isPresented: $showingResetConfirmation) {

                     Button(LocalizedStrings.reset, role: .destructive) {
                         resetToDefault()
                     }
                 } message: {
                     Text(LocalizedStrings.resetConfirmationMessage)
                 }
                 
                 Spacer()
                 
                 // 保存按钮
                 Button(LocalizedStrings.save) {
                     saveQuotes()
                 }
                 .padding(.horizontal, 30)
                 .padding(.vertical, 12)
                 .background(Color.clear)  // 透明背景
                 .foregroundColor(.blue)
                 .cornerRadius(8)
                 .disabled(isResetting || isSaving)
             }
             .padding(.horizontal, 30)
             .padding(.bottom, 20)
         }
         .frame(minWidth: 600, minHeight: 500)
         .onAppear {
             loadQuotesFromFile()
         }
         .background(Color(NSColor.windowBackgroundColor))  // 使用系统窗口背景色
     }
    
    // 从文件加载 Quotes
     private func loadQuotesFromFile() {
         quotesText = QuotesManager.shared.loadCustomQuotesFromFile()
     }
     
     // 保存 Quotes 到文件
     private func saveQuotes() {
         isSaving = true
         
         if QuotesManager.shared.saveCustomQuotesToFile(quotesText) {
             // 保存成功后关闭窗口
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 isSaving = false
                 onClose()
             }
         }
     }
    
    // 重置为默认设置
    private func resetToDefault() {
        isResetting = true
        showingResetConfirmation = false  // 关闭确认对话框
        
        if QuotesManager.shared.resetCustomQuotesToDefault() {
            // 重置成功后重新加载并关闭窗口
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.quotesText = QuotesManager.shared.loadCustomQuotesFromFile()  // 重新加载默认内容
                self.isResetting = false
                //self.onClose()
            }
        } else {
            isResetting = false
        }
    }
}

