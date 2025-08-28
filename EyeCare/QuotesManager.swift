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
            "Taking a break is for better progress! Try some stretches.",
            "Stand up and move around to get your blood flowing!",
            "Tired eyes? Follow the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.",
            "Stay healthy by starting with a break. Take a deep breath and relax for a moment.",
            "A short break can boost your productivity! Try drinking some water.",
            "Focus requires energy. Now's a great time to recharge.",
            "Studies show that regular breaks can make you more creative.",
            "Don't let your keyboard think it's a wrist pillow! Step away for a bit.",
            "The screen isn't going anywhere, but you should move around!",
            "Your keyboard wants a break-up. Go date the real world for a while!",
            "You're doing great! Now reward yourself with a moment of relaxation.",
            "Take a break and continue later; you'll feel more motivated!",
            "Don't forget, your health is more important than anything else!",
            "Look outside at nature and take a breath of fresh air.",
            "Listen to the sounds around you; you might find new inspiration!",
            "Get a drink and admire the beauty of sunshine or rain.",
            "Close your eyes, take a few deep breaths, and feel your body relax.",
            "Focus on the present and immerse yourself in a moment of tranquility.",
            "Try meditating for a minute to clear your mind and recharge for the next challenge."
        ]
    }
    
    private func loadChineseQuotes() -> [String] {
        return [
            "休息是为了更好地前行！来个伸展操吧。",
            "站起来走一走，让血液流动更顺畅！",
            "眼睛累了吗？记得每20分钟休息20秒，望向20英尺外。",
            "保持健康，从休息开始。深呼吸，放松片刻。",
            "短暂的休息能提高你的工作效率！尝试喝杯水吧。",
            "专注需要充足的精力，现在是补充能量的好时机。",
            "科学研究表明，定期休息可以让你更有创造力。",
            "别让键盘以为它是你的手腕枕！离开一会儿吧。",
            "屏幕不会跑掉，但你需要移动一下！",
            "键盘想和你分手了，去和真实的世界约会一下吧！",
            "你已经很棒了，现在是奖励自己片刻放松的时间！",
            "放松一下，稍后继续，你会发现自己更有动力！",
            "别忘了，你的健康比任何事情都重要！",
            "来看看窗外的大自然，呼吸点新鲜空气。",
            "倾听一下周围的声音，或许会有新的灵感！",
            "去喝点水，顺便观察一下阳光或雨天的美景。",
            "闭>上眼睛，深呼吸几次，感受身体的放松。",
            "关注当下，让自己沉浸在片刻的宁静中。",
            "尝试冥想一分钟，清空大脑，为接下来的挑战充电。"
        ]
    }
    
    private func loadTraditionalChineseQuotes() -> [String] {
        return [
            "休息是為了更好地前行！來個伸展操吧。",
            "站起來走一走，讓血液流動更順暢！",
            "眼睛累了嗎？記得每20分鐘休息20秒，望向20英尺外。",
            "保持健康，從休息開始。深呼吸，放鬆片刻。",
            "短暫的休息能提高你的工作效率！嘗試喝杯水吧。",
            "專注需要充足的精力，現在是補充能量的好時機。",
            "科學研究表明，定期休息可以讓你更有創造力。",
            "別讓鍵盤以為它是你的手腕枕！離開一會兒吧。",
            "螢幕不會跑掉，但你需要移動一下！",
            "鍵盤想和你分手了，去和真實的世界約會一下吧！",
            "你已經很棒了，現在是獎勵自己片刻放鬆的時間！",
            "放鬆一下，稍後繼續，你會發現自己更有動力！",
            "別忘了，你的健康比任何事情都重要！",
            "來看看窗外的大自然，呼吸點新鮮空氣。",
            "傾聽一下周圍的聲音，或許會有新的靈感！",
            "去喝點水，順便觀察一下陽光或雨天的美景。",
            "閉上眼睛，深呼吸幾次，感受身體的放鬆。",
            "關注當下，讓自己沉浸在片刻的寧靜中。",
            "嘗試冥想一分鐘，清空大腦，為接下來的挑戰充電。"
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
            return defaultQuotes.joined(separator: "\n")
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
