import Foundation

// MARK: - 应用配置管理器
class AppConfigManager {
    static let shared = AppConfigManager()
    
    private init() {
        loadAllSettings()
    }
    
    // MARK: - 用户默认键常量
    private enum Keys {
        // 基础设置
        static let isEnabled = "EyeCare_isEnabled"
        static let longIntervalMinutes = "EyeCare_longIntervalMinutes"
        static let longRestDuration = "EyeCare_longRestDuration"
        
        // 短休息设置
        static let shortRestEnabled = "EyeCare_shortRestEnabled"
        static let shortRestDuration = "EyeCare_shortRestDuration"
        static let shortRestCount = "EyeCare_shortRestCount"
        
        // 用户活动检测设置
        static let pauseDetectionMinutes = "EyeCare_pauseDetectionMinutes"
        static let stopDetectionMinutes = "EyeCare_stopDetectionMinutes"
        
        // 状态栏设置
        static let showStatusBarCountdown = "EyeCare_showStatusBarCountdown"
        
        // 休息界面设置
        static let showQuotesInRestView = "EyeCare_showQuotesInRestView"
    }
    
    // MARK: - 默认值
    private struct Defaults {
        static let isEnabled = true
        static let longIntervalMinutes = 90
        static let longRestDuration = 5
        static let shortRestEnabled = true
        static let shortRestDuration = 30
        static let shortRestCount = 1
        static let pauseDetectionMinutes = 1
        static let stopDetectionMinutes = 5
        static let showStatusBarCountdown = true
        static let showQuotesInRestView = true
    }
    
    // MARK: - 基础设置
    var isEnabled: Bool = Defaults.isEnabled {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Keys.isEnabled)
        }
    }
    
    var longIntervalMinutes: Int = Defaults.longIntervalMinutes {
        didSet {
            UserDefaults.standard.set(longIntervalMinutes, forKey: Keys.longIntervalMinutes)
        }
    }
    
    var longRestDuration: Int = Defaults.longRestDuration {
        didSet {
            UserDefaults.standard.set(longRestDuration, forKey: Keys.longRestDuration)
        }
    }
    
    // MARK: - 短休息设置
    var shortRestEnabled: Bool = Defaults.shortRestEnabled {
        didSet {
            UserDefaults.standard.set(shortRestEnabled, forKey: Keys.shortRestEnabled)
        }
    }
    
    var shortRestDuration: Int = Defaults.shortRestDuration {
        didSet {
            UserDefaults.standard.set(shortRestDuration, forKey: Keys.shortRestDuration)
        }
    }
    
    var shortRestCount: Int = Defaults.shortRestCount {
        didSet {
            UserDefaults.standard.set(shortRestCount, forKey: Keys.shortRestCount)
        }
    }
    
    // MARK: - 用户活动检测设置
    var pauseDetectionMinutes: Int = Defaults.pauseDetectionMinutes {
        didSet {
            UserDefaults.standard.set(pauseDetectionMinutes, forKey: Keys.pauseDetectionMinutes)
        }
    }
    
    var stopDetectionMinutes: Int = Defaults.stopDetectionMinutes {
        didSet {
            UserDefaults.standard.set(stopDetectionMinutes, forKey: Keys.stopDetectionMinutes)
        }
    }
    
    // MARK: - 状态栏设置
    var showStatusBarCountdown: Bool = Defaults.showStatusBarCountdown {
        didSet {
            UserDefaults.standard.set(showStatusBarCountdown, forKey: Keys.showStatusBarCountdown)
        }
    }
    
    // MARK: - 休息界面设置
    var showQuotesInRestView: Bool = Defaults.showQuotesInRestView {
        didSet {
            UserDefaults.standard.set(showQuotesInRestView, forKey: Keys.showQuotesInRestView)
        }
    }
    
    // MARK: - 加载所有设置
    private func loadAllSettings() {
        let defaults = UserDefaults.standard
        
        isEnabled = defaults.object(forKey: Keys.isEnabled) as? Bool ?? Defaults.isEnabled
        longIntervalMinutes = defaults.object(forKey: Keys.longIntervalMinutes) as? Int ?? Defaults.longIntervalMinutes
        longRestDuration = defaults.object(forKey: Keys.longRestDuration) as? Int ?? Defaults.longRestDuration
        
        shortRestEnabled = defaults.object(forKey: Keys.shortRestEnabled) as? Bool ?? Defaults.shortRestEnabled
        shortRestDuration = defaults.object(forKey: Keys.shortRestDuration) as? Int ?? Defaults.shortRestDuration
        shortRestCount = defaults.object(forKey: Keys.shortRestCount) as? Int ?? Defaults.shortRestCount
        
        pauseDetectionMinutes = defaults.object(forKey: Keys.pauseDetectionMinutes) as? Int ?? Defaults.pauseDetectionMinutes
        stopDetectionMinutes = defaults.object(forKey: Keys.stopDetectionMinutes) as? Int ?? Defaults.stopDetectionMinutes
        
        showStatusBarCountdown = defaults.object(forKey: Keys.showStatusBarCountdown) as? Bool ?? Defaults.showStatusBarCountdown
        showQuotesInRestView = defaults.object(forKey: Keys.showQuotesInRestView) as? Bool ?? Defaults.showQuotesInRestView
    }
    
    // MARK: - 重置为默认设置
    func resetToDefaults() {
        isEnabled = Defaults.isEnabled
        longIntervalMinutes = Defaults.longIntervalMinutes
        longRestDuration = Defaults.longRestDuration
        
        shortRestEnabled = Defaults.shortRestEnabled
        shortRestDuration = Defaults.shortRestDuration
        shortRestCount = Defaults.shortRestCount
        
        pauseDetectionMinutes = Defaults.pauseDetectionMinutes
        stopDetectionMinutes = Defaults.stopDetectionMinutes
        
        showStatusBarCountdown = Defaults.showStatusBarCountdown
        showQuotesInRestView = Defaults.showQuotesInRestView
    }
    
    // MARK: - 清理所有保存的设置
    func clearAllSettings() {
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: Keys.isEnabled)
        defaults.removeObject(forKey: Keys.longIntervalMinutes)
        defaults.removeObject(forKey: Keys.longRestDuration)
        defaults.removeObject(forKey: Keys.shortRestEnabled)
        defaults.removeObject(forKey: Keys.shortRestDuration)
        defaults.removeObject(forKey: Keys.shortRestCount)
        defaults.removeObject(forKey: Keys.pauseDetectionMinutes)
        defaults.removeObject(forKey: Keys.stopDetectionMinutes)
        defaults.removeObject(forKey: Keys.showStatusBarCountdown)
        defaults.removeObject(forKey: Keys.showQuotesInRestView)
    }
}
