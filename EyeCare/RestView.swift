import SwiftUI

struct RestView: View {
    let isLongRest: Bool
    let duration: Int
    let backgroundImage: NSImage?
    let showQuotes: Bool
    let onDismiss: () -> Void
    let onSkip: () -> Void
    
    @State private var remainingTime: Int
    private var quote: String = ""
    @State private var countdownTimer: Timer? = nil  // 添加计时器状态
    
    init(isLongRest: Bool, duration: Int, backgroundImage: NSImage? = nil, showQuotes: Bool = true, onDismiss: @escaping () -> Void, onSkip: @escaping () -> Void) {
        self.isLongRest = isLongRest
        self.duration = duration
        self.backgroundImage = backgroundImage
        self.showQuotes = showQuotes
        self.onDismiss = onDismiss
        self.onSkip = onSkip
        self._remainingTime = State(initialValue: duration)
        self.quote = QuotesManager.shared.getCurrentRandomQuote() ?? "休息一下吧！"
        print("初始化的名言: \(self.quote)")
    }
    
    var body: some View {
        ZStack {
            // 背景 - 使用自定义背景图片
            if let image = backgroundImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Color.black.opacity(0.3) // 添加暗色遮罩以提高文字可读性
                    )
            } else {
                // 默认背景
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 30) {
                // 名言 - 只有当设置启用时才显示
                if showQuotes && !quote.isEmpty {
                    Text(quote)
                        .font(.system(size: 32, weight: .medium))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(radius: 2)
                }
                
                // 倒计时显示
                Text(formatTime(remainingTime))
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                // 进度条
                VStack(spacing: 8) {
                    // 正确的进度计算（已完成的进度）
                    // 调整进度条宽度为屏幕的一半
                    ProgressView(value: Double(duration - remainingTime), total: Double(duration))
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .frame(height: 40)  // 保持适当的高度
                        .frame(maxWidth: 300)  // 设置最大宽度为 300pt（大约是屏幕宽度的一半）
                    
                    // 显示时间文本
                    Text("\(formatTime(remainingTime)) / \(formatTime(duration))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // 跳过按钮
                Button(action: {
                    stopCountdown()  // 停止计时器
                    onSkip()        // 调用跳过回调
                }) {
                    Text(LocalizedStrings.skipThisTime)
                        .font(.title3)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            stopCountdown()  // 视图消失时清理计时器
        }
    }
    
    private func startCountdown() {
        stopCountdown()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // 更新剩余时间
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                // 时间结束
                timer.invalidate()
                self.onDismiss()
            }
        }
    }
    
    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
