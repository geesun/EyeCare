/*
 * Copyright (c) 2025, Qixiang Xu. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

import SwiftUI
import Cocoa

// MARK: - 背景图片管理器
class BackgroundImageManager {
    static let shared = BackgroundImageManager()
    
    private init() {}
    
    // MARK: - 获取背景图片目录
    func getBackgroundDirectory() -> String {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        return "\(currentDirectory)/background/"
    }
    
    // MARK: - 获取指定索引的背景图片
    func getBackgroundImage(at index: Int) -> NSImage? {
        guard index >= 0 && index < 8 else { return nil }
        
        let bgDir = getBackgroundDirectory()
        let imagePath = "\(bgDir)bg\(index).jpg"
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imagePath) {
            return NSImage(contentsOfFile: imagePath)
        }
        return nil
    }
    
    // MARK: - 获取随机背景图片（完整的后备机制）
    func getRandomBackgroundImage() -> NSImage? {
        // 1. 随机选择一个索引 (0-7)
        let randomIndex = Int.random(in: 0..<8)
        
        // 2. 检查自定义背景图片是否存在
        if let customImage = getBackgroundImage(at: randomIndex) {
            print("使用自定义背景图片: bg\(randomIndex).jpg")
            return customImage
        }
        
        // 3. 如果自定义图片不存在，使用系统桌面图片
        if let systemImage = getSystemDesktopImage() {
            print("使用系统桌面图片")
            return systemImage
        }
        
        // 4. 如果都没有找到，返回 nil（让调用者使用默认渐变）
        print("没有找到背景图片，使用默认背景")
        return createGradientImage()
    }
    
    // MARK: - 获取系统桌面图片
    private func getSystemDesktopImage() -> NSImage? {
        let desktopPicturesPath = "/Library/Desktop Pictures"
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: desktopPicturesPath)
            for item in contents {
                // 检查是否是图片文件
                if item.hasSuffix(".jpg") || item.hasSuffix(".jpeg") || item.hasSuffix(".png") {
                    let fullPath = "\(desktopPicturesPath)/\(item)"
                    if let image = NSImage(contentsOfFile: fullPath) {
                        return image
                    }
                }
            }
        } catch {
            print("无法访问桌面图片目录: \(error)")
        }
        
        return nil
    }
    
    // MARK: - 加载所有背景图片（用于 BackgroundConfigView）
    func loadAllBackgroundImages() -> (images: [NSImage?], paths: [String]) {
        let bgDir = getBackgroundDirectory()
        let fileManager = FileManager.default
        
        // 确保背景目录存在
        if !fileManager.fileExists(atPath: bgDir) {
            try? fileManager.createDirectory(atPath: bgDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        var selectedImages: [NSImage?] = Array(repeating: nil, count: 8)
        var imagePaths: [String] = Array(repeating: "", count: 8)
        
        // 为每张图片检查并加载
        for i in 0..<8 {
            let imagePath = "\(bgDir)bg\(i).jpg"
            
            // 优先级1: 检查自定义背景图片
            if fileManager.fileExists(atPath: imagePath) {
                if let image = NSImage(contentsOfFile: imagePath) {
                    selectedImages[i] = image
                    imagePaths[i] = imagePath
                    continue  // 继续下一张图片
                }
            }
            
            // 优先级2: 使用默认背景图片
            if let defaultImage = getSystemDesktopImage() {
                selectedImages[i] = defaultImage
                // 注意：这里不设置 imagePath，因为是默认图片
            } else {
                // 优先级3: 使用渐变色作为后备
                selectedImages[i] = createGradientImage()
            }
        }
        
        return (selectedImages, imagePaths)
    }
    
    // MARK: - 保存图片到指定位置
    func saveImage(_ image: NSImage, atIndex index: Int) -> Bool {
        guard index >= 0 && index < 8 else { return false }
        
        let bgDir = getBackgroundDirectory()
        let bgFile = "\(bgDir)bg\(index).jpg"
        
        // 确保目录存在
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: bgDir) {
            try? fileManager.createDirectory(atPath: bgDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 将 NSImage 转换为 JPEG 数据
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData) {
            let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
            
            if let data = jpegData {
                do {
                    try data.write(to: URL(fileURLWithPath: bgFile))
                    print("图片已保存到: \(bgFile)")
                    return true
                } catch {
                    print("保存图片失败: \(error)")
                }
            }
        }
        
        return false
    }
    
    // MARK: - 创建渐变背景图片
    func createGradientImage() -> NSImage {
        let size = NSSize(width: 200, height: 120)
        let image = NSImage(size: size)
        
        image.lockFocus()
        let gradient = NSGradient(
            starting: NSColor.systemBlue,
            ending: NSColor.systemPurple
        )
        gradient?.draw(in: NSRect(origin: .zero, size: size), angle: 45)
        image.unlockFocus()
        
        return image
    }
}
