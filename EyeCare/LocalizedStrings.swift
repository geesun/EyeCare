import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// 便捷方法
struct LocalizedStrings {
    // Menu Bar
    static let appName = "app_name".localized
    static let menuEnableReminder = "menu_enable_reminder".localized
    static let menuQuit = "menu_quit".localized
    
    // Long Rest Settings
    static let longRestSettings = "long_rest_settings".localized
    static let longRestInterval = "long_rest_interval".localized
    static let longRestDuration = "long_rest_duration".localized
    
    // Short Rest Settings
    static let shortRestSettings = "short_rest_settings".localized
    static let shortRestEnable = "short_rest_enable".localized
    static let shortRestDuration = "short_rest_duration".localized
    static let shortRestCount = "short_rest_count".localized
    
    // Activity Detection
    static let activityDetection = "activity_detection".localized
    static let pauseDetectionTime = "pause_detection_time".localized
    static let stopDetectionTime = "stop_detection_time".localized
    
    // Status Bar Settings
    static let statusBarSettings = "status_bar_settings".localized
    static let showStatusBarCountdown = "status_bar_countdown".localized
    
    // Background Settings
    static let backgroundSettings = "background_settings".localized
    static let clickImageToChangeBackground = "click_image_to_change_background".localized
    static let selectImage = "select_image".localized
    
    // Common
    static let minutes = "minutes".localized
    static let seconds = "seconds".localized
    static let times = "times".localized
    static let cancel = "cancel".localized
    static let done = "done".localized
    
    // Buttons
    static let testLongRest = "test_long_rest".localized
    static let testShortRest = "test_short_rest".localized
    static let skipThisTime = "skip_this_time".localized
    static let shortBreak = "short_break".localized
    
    // Rest View
    static let longRestTitle = "long_rest_title".localized
    static let shortRestTitle = "short_rest_title".localized
    
    // Rest View Settings
    static let restViewSettings = "rest_view_settings".localized
    static let showQuotes = "show_quotes".localized
    
    // Application Status
    static let disabled = "disabled".localized
    static let stop = "stop".localized
    static let pause = "pause".localized
      
    static let customQuotesSettings = "custom_quotes_settings".localized
    static let customQuotesDescription = "custom_quotes_description".localized
    static let save = "save".localized
    //static let cancel = "cancel".localized
    
}
