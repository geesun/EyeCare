import Foundation

// MARK: - Quotes 管理器
class QuotesManager {
    static let shared = QuotesManager()
    
    private var customQuotes: [String] = []
    private var defaultQuotes: [String] = []  // 默认 quotes（当自定义文件不存在时使用）
    
    private init() {
        loadDefaultQuotes()  // 先加载默认 quotes
        loadCustomQuotes()   // 再尝试加载自定义 quotes
    }
    
    // 获取当前系统语言的随机 quote
    func getCurrentRandomQuote() -> String? {
        let languageCode = getCurrentLanguageCode()
        return getRandomQuote(for: languageCode)
    }
    
    // 获取指定语言的 quotes
    func getQuotes(for language: String) -> [String] {
        let quotes = customQuotes.isEmpty ? defaultQuotes : customQuotes
        return quotes
    }
    
    // 随机获取指定语言的 quote
    func getRandomQuote(for language: String) -> String? {
        let quotes = getQuotes(for: language)
        return quotes.randomElement()
    }
    
    // 获取当前系统语言代码
    func getCurrentLanguageCode() -> String {
        // 获取当前语言，兼容不同版本的 macOS
        #if os(macOS) && swift(>=5.7)
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        #else
        let languageCode = Locale.current.languageCode ?? "en"
        #endif
        
        // 标准化语言代码
        return normalizeLanguageCode(languageCode)
    }
    
    // 标准化语言代码
    private func normalizeLanguageCode(_ code: String) -> String {
        // 处理中文的不同变体
        if code.hasPrefix("zh-Hans") || code.hasPrefix("zh_CN") {
            return "zh-Hans"
        } else if code.hasPrefix("zh-Hant") || code.hasPrefix("zh_TW") {
            return "zh-Hant"
        } else {
            // 默认返回英语
            return "en"
        }
    }
    
    // 加载指定语言的 quotes
    private func loadQuotes(for language: String) -> [String] {
        switch language {
        case "zh-Hans": // 简体中文
            return loadChineseQuotes()
        case "zh-Hant": // 繁体中文
            return loadTraditionalChineseQuotes()
        default: // 默认英文
            return loadEnglishQuotes()
        }
    }
    
    // MARK: - 各语言的 Quotes (统一的 quotes 库)
    
    private func loadEnglishQuotes() -> [String] {
        return [
            "Rest is the power to go further.",
            "Proper rest is the key to success.",
            "Balance work and rest.",
            "Brief rest, lasting efficiency.",
            "Stop to go further.",
            "Eyes are the windows to the soul, treat them well.",
            "For every hour of work, rest your eyes for ten minutes.",
            "Take breaks regularly to maintain productivity.",
            "A rested mind is a creative mind.",
            "Rest when you're weary. Refresh and renew yourself.",
            "Blink and relax.",
            "Look into the distance, protect your vision.",
            "Brief rest, healthier eyes.",
            "Relax your eye muscles.",
            "Take a deep breath, relax your mind.",
            "Stretch your body, refresh your mind.",
            "Step away from the screen.",
            "Close your eyes for a moment.",
            "The best way to take care of the future is to take care of the present moment.",
            "Rest is not idleness, and to lie sometimes on the grass under trees is by no means a waste of time."
        ]
    }
    
    private func loadChineseQuotes() -> [String] {
        return [
            "休息是走更远路的力量。",
            "适当的休息是成功的关键。",
            "工作与休息要平衡。",
            "短暂的休息，长久的效率。",
            "停下来，是为了走得更远。",
            "眼睛是心灵的窗户，请善待它们。",
            "每工作一小时，让眼睛休息十分钟。",
            "劳逸结合，事半功倍。",
            "会休息的人才会工作。",
            "健康的身体是灵魂的客厅。",
            "静以修身，俭以养德。",
            "心静自然凉。",
            "眨眨眼，放松一下。",
            "看看远方，保护视力。",
            "短暂休息，眼睛更健康。",
            "放松眼部肌肉。",
            "深呼吸，放松身心。",
            "活动一下身体，清醒一下头脑。",
            "远离屏幕，让眼睛休息。",
            "闭上眼睛，静心片刻。",
            "欲速则不达。",
            "工欲善其事，必先利其器。"
        ]
    }
    
    private func loadTraditionalChineseQuotes() -> [String] {
        return [
            "休息是走更遠路的力量。",
            "適當的休息是成功的關鍵。",
            "工作與休息要平衡。",
            "短暫的休息，長久的效率。",
            "停下來，是為了走得更遠。",
            "眼睛是心靈的窗戶，請善待它們。",
            "每工作一小時，讓眼睛休息十分鐘。",
            "勞逸結合，事半功倍。",
            "會休息的人才會工作。",
            "健康的身體是靈魂的客廳。",
            "靜以修身，儉以養德。",
            "心靜自然涼。",
            "眨眨眼，放鬆一下。",
            "看看遠方，保護視力。",
            "短暫休息，眼睛更健康。",
            "放鬆眼部肌肉。",
            "深呼吸，放鬆身心。",
            "活動一下身體，清醒一下頭腦。",
            "遠離屏幕，讓眼睛休息。",
            "閉上眼睛，靜心片刻。",
            "欲速則不達。",
            "工欲善其事，必先利其器。"
        ]
    }

    // MARK: - 默认 Quotes 加载
    private func loadDefaultQuotes() {
        let languageCode = getCurrentLanguageCode()
        defaultQuotes = loadQuotes(for: languageCode)
        print("加载默认名言，共 \(defaultQuotes.count) 条")
    }
    
    // MARK: - 自定义 Quotes 管理
    private func readCustomQuotesFile() -> String? {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let quotesFilePath = "\(currentDirectory)/custom_quotes.txt"
        
        do {
            if fileManager.fileExists(atPath: quotesFilePath) {
                let content = try String(contentsOfFile: quotesFilePath, encoding: .utf8)
                print("成功读取自定义名言文件: \(quotesFilePath)")
                return content
            } else {
                print("自定义名言文件不存在: \(quotesFilePath)")
                return nil
            }
        } catch {
            print("读取自定义名言文件失败: \(error)")
            return nil
        }
    }
    
    // 加载自定义 Quotes
     private func loadCustomQuotes() {
         if let content = readCustomQuotesFile() {
             customQuotes = content.components(separatedBy: .newlines)
                 .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
             print("成功加载自定义名言，共 \(customQuotes.count) 条")
         } else {
             customQuotes = []  // 文件不存在时使用空数组
             print("自定义名言文件不存在，将使用默认名言")
         }
     }
    
    // 重新加载自定义 Quotes（当用户保存时调用）
    func reloadCustomQuotes() {
        loadCustomQuotes()
        // 清除缓存以便重新加载
        print("重新加载自定义名言")
    }
    
    // 从文件加载自定义 Quotes
    func loadCustomQuotesFromFile() -> String {
        if let content = readCustomQuotesFile() {
            return content
        } else {
            return ""
        }
    }
    
    // 保存自定义 Quotes 到文件
    func saveCustomQuotesToFile(_ content: String) -> Bool {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let quotesFilePath = "\(currentDirectory)/custom_quotes.txt"
        
        do {
            // 确保目录存在
            try fileManager.createDirectory(atPath: currentDirectory, withIntermediateDirectories: true, attributes: nil)
            
            // 保存文件
            try content.write(toFile: quotesFilePath, atomically: true, encoding: .utf8)
            print("成功保存自定义名言文件: \(quotesFilePath)")
            
            // 重新加载自定义 Quotes
            reloadCustomQuotes()
            
            return true
        } catch {
            print("保存自定义名言文件失败: \(error)")
            return false
        }
    }
}
