import SwiftUI
import Cocoa

// MARK: - 应用状态枚举
enum EyeCareAppState {
    case normal      // 正常状态
    case inShortRest // 短休息状态
    case inLongRest  // 长休息状态
    case pause       // 暂停状态
    case stop        // 停止状态
}

class EyeCareManager: ObservableObject {
    // 使用配置管理器
    private let configManager = AppConfigManager.shared
    
    // MARK: - 应用状态
    @Published var appState: EyeCareAppState = .normal {
        didSet {
            print("应用查看状态变更: \(oldValue) -> \(appState)")
            handleAppStateChange()
        }
    }
    
    // MARK: - 基础设置
    @Published var isEnabled = true {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.isEnabled = isEnabled
            handleConfigurationChange()
        }
    }
    
    @Published var longIntervalMinutes: Int = 30 {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.longIntervalMinutes = longIntervalMinutes
            handleConfigurationChange()
        }
    }
    
    @Published var longRestDuration: Int = 5 {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.longRestDuration = longRestDuration
        }
    }
    
    // MARK: - 短休息设置
    @Published var shortRestEnabled = true {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.shortRestEnabled = shortRestEnabled
            handleConfigurationChange()
        }
    }
    
    @Published var shortRestDuration: Int = 30 {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.shortRestDuration = shortRestDuration
        }
    }
    
    @Published var shortRestCount: Int = 1 {  // 这个参数决定短休息次数
        didSet {
            guard !isLoadingSettings else { return }
            configManager.shortRestCount = shortRestCount
            handleConfigurationChange()
        }
    }
    
    // MARK: - 用户活动检测设置
    @Published var pauseDetectionMinutes: Int = 1 {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.pauseDetectionMinutes = pauseDetectionMinutes
        }
    }
    
    @Published var stopDetectionMinutes: Int = 5 {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.stopDetectionMinutes = stopDetectionMinutes
        }
    }
    
    // MARK: - 状态栏设置
    @Published var showStatusBarCountdown = true {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.showStatusBarCountdown = showStatusBarCountdown
            updateStatusBarTitle()
        }
    }

    // 休息界面设置
    @Published var showQuotesInRestView = true {
        didSet {
            guard !isLoadingSettings else { return }
            configManager.showQuotesInRestView = showQuotesInRestView
        }
    }
    
    // 内部状态
    private var mainTimer: Timer?        // 主计时器（每秒触发）
    private var restWindows: [NSWindow] = []
    private var idleSeconds: Int = 0     // 空闲秒数
    private var isLoadingSettings = false
    
    // 倒计时相关
    private var nextRestSeconds: Int = 0
    @Published var statusBarTitle: String = ""
    
    // 全局事件监控器
    private var globalEventMonitor: Any?
    
    // 调试模式标志
    private let isDebugMode = false
    private let debugInterval = 30
    private let debugShortReset = 5
    private let debugLongReset = 10
    private let debugPauseInterval = 50
    private let debugStopInterval = 200
    
    // 休息计数
    private var currentShortRestIndex: Int = 0  // 当前短休息索引
    
    init() {
        loadSettingsFromConfig()
        nextRestSeconds = calculateNextRestTime()
        setupGlobalEventMonitoring()
        startMainTimer()
    }
    
    // MARK: - 从配置管理器加载设置
    private func loadSettingsFromConfig() {
        isLoadingSettings = true
        isEnabled = configManager.isEnabled
        longIntervalMinutes = configManager.longIntervalMinutes
        longRestDuration = configManager.longRestDuration
        shortRestEnabled = configManager.shortRestEnabled
        shortRestDuration = configManager.shortRestDuration
        shortRestCount = configManager.shortRestCount
        pauseDetectionMinutes = configManager.pauseDetectionMinutes
        stopDetectionMinutes = configManager.stopDetectionMinutes
        showStatusBarCountdown = configManager.showStatusBarCountdown
        showQuotesInRestView = configManager.showQuotesInRestView
        isLoadingSettings = false
    }
    
    // MARK: - 处理应用状态变更
    private func handleAppStateChange() {
        switch appState {
        case .normal:
            print("应用查看进入正常状态")
            updateStatusBarTitle()
            
        case .inShortRest:
            print("应用查看进入短休息状态")
            showShortRestView()
            
        case .inLongRest:
            print("应用查看进入长休息状态")
            showLongRestView()
            
        case .pause:
            print("应用查看进入暂停状态")
            updateStatusBarTitle()
            
        case .stop:
            print("应用查看进入停止状态")
            updateStatusBarTitle()
        }
    }
    
    // MARK: - 处理配置变更
    private func handleConfigurationChange() {
        if isEnabled && (appState == .normal || appState == .pause) {
            currentShortRestIndex = 0
            nextRestSeconds = calculateNextRestTime()
        }
    }
    
    // MARK: - 全局事件监控设置
    private func setupGlobalEventMonitoring() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [
                .mouseMoved, .leftMouseDown, .leftMouseUp, .rightMouseDown,
                .rightMouseUp, .otherMouseDown, .otherMouseUp, .scrollWheel,
                .keyDown, .keyUp, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged
            ]
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateLastActivityTime()
            }
        }
    }
    
    // 更新最后活动时间
    private func updateLastActivityTime() {
        idleSeconds = 0  // 重置空闲时间
        
        // 用户重新活跃
        switch appState {
        case .stop:
            // 从停止状态恢复到正常状态
            appState = .normal
            currentShortRestIndex = 0
            nextRestSeconds = calculateNextRestTime()
            print("用户活动，从停止状态恢复到正常状态")
            
        case .pause:
            // 从暂停状态恢复到正常状态
            appState = .normal
            print("用户活动，从暂停状态恢复到正常状态")
            
        default:
            break
        }
    }
    
    // MARK: - 主计时器管理
    func startMainTimer() {
        
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.tick()
        }
        print("主计时器已启动")
       
    }
    
    private func stopMainTimer() {
        if mainTimer != nil {
            mainTimer?.invalidate()
            mainTimer = nil
            print("主计时器已停止")
        }
    }
    
    
    // MARK: - 每秒触发的主逻辑
    private func tick() {
        guard isEnabled else { return }
        
        checkUserActivity()
        // 根据当前状态处理逻辑
        if appState  == .normal {
            // 倒计时递减
            if nextRestSeconds > 0 {
                nextRestSeconds -= 1
                
                // 倒计时结束，触发休息
                if nextRestSeconds == 0 {
                    triggerRest()
                }
                
                // 更新状态栏
                updateStatusBarTitle()
            }
        }
    }
    
    // MARK: - 用户活动检测
    private func checkUserActivity() {
        let pauseSeconds = isDebugMode ? debugPauseInterval : pauseDetectionMinutes * 60
        let stopSeconds = isDebugMode ? debugStopInterval : stopDetectionMinutes * 60
        
        // 增加空闲时间
        idleSeconds += 1
        
        switch appState {
        case .normal:
            // 正常状态下检测是否应该暂停
            if idleSeconds > pauseSeconds {
                appState = .pause
                print("用户无活动超过 \(pauseSeconds) 秒，进入暂停状态")
            }
            
        case .pause:
            // 暂停状态下检测是否应该停止
            if idleSeconds > stopSeconds {
                appState = .stop
                print("用户无活动超过 \(stopSeconds) 秒，进入停止状态")
            }
            
        default:
            break
        }
    }
    
    // MARK: - 触发休息
    private func triggerRest() {
        // 计算当前应该触发哪种休息
        if shouldTriggerShortRest() {
            // 触发短休息
            appState = .inShortRest
            currentShortRestIndex += 1
            
        } else {
            // 触发长休息
            appState = .inLongRest
            currentShortRestIndex = 0  // 重置短休息计数
        }
    }
    
    // 判断是否应该触发短休息
    private func shouldTriggerShortRest() -> Bool {
        guard shortRestEnabled && shortRestCount > 0 else {
            return false
        }
        
        // 根据当前短休息索引判断
        return currentShortRestIndex < shortRestCount
    }
    
    // 计算下次休息时间
    private func calculateNextRestTime() -> Int {
        let totalInterval = isDebugMode ? debugInterval : longIntervalMinutes * 60
        
        if shortRestEnabled && shortRestCount > 0 {
            // 启用短休息：将总时间分成 (shortRestCount + 1) 段
            return Int(Double(totalInterval) / Double(shortRestCount + 1))
        } else {
            // 不启用短休息：直接返回完整间隔时间
            return totalInterval
        }
    }
    
    // MARK: - 休息视图显示
    private func showLongRestView() {
        let duration = isDebugMode ? debugLongReset : longRestDuration * 60
        showRestView(isLongRest: true, duration: duration)
    }
    
    private func showShortRestView() {
        let duration = isDebugMode ? debugShortReset : shortRestDuration
        showRestView(isLongRest: false, duration: duration)
    }
    
    private func showRestView(isLongRest: Bool, duration: Int) {
        // 获取所有屏幕
        let screens = NSScreen.screens
        
        // 清除现有窗口
        dismissAllViews()
        
        // 为每个屏幕创建全屏窗口
        for screen in screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.titled, .borderless, .fullSizeContentView],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            
            window.isReleasedWhenClosed = false
            window.level = .screenSaver
            window.collectionBehavior = [.fullScreenPrimary, .canJoinAllSpaces]
            window.backgroundColor = NSColor.clear
            window.isOpaque = false
            window.ignoresMouseEvents = false
            window.toggleFullScreen(nil)

            let restView = RestView(
                isLongRest: isLongRest,
                duration: duration,
                backgroundImage: BackgroundImageManager.shared.getRandomBackgroundImage(),
                showQuotes: showQuotesInRestView,
                onDismiss: {
                    self.dismissAllViews()
                    // 休息结束，重新开始倒计时
                    self.resumeAfterRest()
                },
                onSkip: {
                    self.dismissAllViews()
                    // 跳过休息，重新开始倒计时
                    self.resumeAfterRest()
                }
            )
            
            window.contentView = NSHostingView(rootView: restView)
            window.makeKeyAndOrderFront(nil)
            
            restWindows.append(window)
        }
        
    }
    
    // 休息结束后恢复
    private func resumeAfterRest() {
        // 设置为暂停状态，等待用户活动恢复
        appState = .pause
        nextRestSeconds = calculateNextRestTime()
    }
    
    func dismissAllViews() {
        restWindows.forEach { $0.close() }
        restWindows.removeAll()
    }
    
    
    private func updateStatusBarTitle() {
        
        switch appState {
            case .normal:
                if showStatusBarCountdown && isEnabled {
                    if nextRestSeconds > 0 {
                        statusBarTitle = formatTimeForStatusBar(nextRestSeconds)
                    } else {
                        statusBarTitle = ""
                    }
                }else{
                    statusBarTitle = ""
                }
                
            case .pause:
                statusBarTitle = "Pause"
                
            case .stop:
                statusBarTitle = "Stop"
                
            default:
                statusBarTitle = ""
        }
       
    }
    
    // 格式化时间用于状态栏显示
    private func formatTimeForStatusBar(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", secs))"
        } else {
            return "\(secs)s"
        }
    }
    
    deinit {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        stopMainTimer()
    }
}
