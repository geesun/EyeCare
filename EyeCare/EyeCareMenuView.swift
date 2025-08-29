/*
 * Copyright (c) 2025, Qixiang Xu. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

import SwiftUI

struct EyeCareMenuView: View {
    @ObservedObject var manager: EyeCareManager
    
    @State private var showingBackgroundConfig = false
    @State private var isHoveringBackgroundSetting = false
    @State private var isHoveringQuotesSetting = false
    @State private var isHoveringQuit = false
    @State private var backgroundConfigWindow: BackgroundConfigWindow? = nil

    @State private var quotesConfigWindow: QuotesConfigWindow? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    // 长休息间隔时间选项（分钟）
    private let longIntervalOptions = [30, 45, 60, 75, 90, 105, 120]
    
    // 长休息时长选项（分钟）
    private let longDurationOptions = [ 2, 3, 4, 5, 8, 10, 15]
    
    // 暂停检测时间选项（分钟）
    private let pauseDetectionOptions = [1, 2]
    
    // 停止检测时间选项（分钟）
    private let stopDetectionOptions = [3, 5, 8, 10]
    
    // 短休息时长选项（秒）
    private let shortDurationOptions = [
        ShortRestDurationOption(seconds: 30, label: "30 " + "seconds".localized),
        ShortRestDurationOption(seconds: 45, label: "45 " + "seconds".localized),
        ShortRestDurationOption(seconds: 60, label: "1 " + "minutes".localized)
    ]
    
    // 短休息次数选项
    private let shortCountOptions = [
        ShortRestCountOption(count: 1, label: "1 " + "times".localized),
        ShortRestCountOption(count: 2, label: "2 " + "times".localized)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 主开关 - 左右对齐
            HStack {
                Text(LocalizedStrings.menuEnableReminder)
                Spacer()
                Toggle("", isOn: $manager.isEnabled)
                    .toggleStyle(.switch)
                    .frame(width: 50)
            }
            
            // 只有当主开关启用时才显示其他配置
            if manager.isEnabled {
                Divider()
                
                // 下一个休息信息 - 新增的显示区域
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStrings.nextRestInfo)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if manager.isNextResetShortRest() {
                        HStack {
                            Text(LocalizedStrings.nextRestType)
                            Spacer()
                            Text(getNextRestTypeText())
                                .fontWeight(.medium)
                                .foregroundColor(getNextRestTypeColor())
                        }
                    }
                    
                    HStack {
                        Text(LocalizedStrings.nextRestTime)
                        Spacer()
                        Text(manager.statusBarTitle)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
                
                Divider()
                
                // 长休息设置
                Text(LocalizedStrings.longRestSettings)
                    .font(.headline)
                
                // 长休息间隔时间 - 使用选择器
                HStack {
                    Text(LocalizedStrings.longRestInterval)
                    Spacer()
                    Picker("", selection: $manager.longIntervalMinutes) {
                        ForEach(longIntervalOptions, id: \.self) { minutes in
                            Text("\(minutes) " + LocalizedStrings.minutes).tag(minutes)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
                
                // 长休息时长 - 使用选择器
                HStack {
                    Text(LocalizedStrings.longRestDuration)
                    Spacer()
                    Picker("", selection: $manager.longRestDuration) {
                        ForEach(longDurationOptions, id: \.self) { minutes in
                            Text("\(minutes) " + LocalizedStrings.minutes).tag(minutes)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
                
                Divider()
                
                // 短休息设置 - 左右对齐
                HStack {
                    Text(LocalizedStrings.shortRestEnable)
                    Spacer()
                    Toggle("", isOn: $manager.shortRestEnabled)
                        .toggleStyle(.switch)
                        .frame(width: 50)
                }
                
                // 只有当短休息开关启用时才显示短休息配置
                if manager.shortRestEnabled {
                    // 短休息次数 - 使用结构化选项
                    HStack {
                        Text(LocalizedStrings.shortRestCount)
                        Spacer()
                        Picker("", selection: $manager.shortRestCount) {
                            ForEach(shortCountOptions, id: \.count) { option in
                                Text(option.label).tag(option.count)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                    
                    // 短休息时长 - 使用结构化选项
                    HStack {
                        Text(LocalizedStrings.shortRestDuration)
                        Spacer()
                        Picker("", selection: $manager.shortRestDuration) {
                            ForEach(shortDurationOptions, id: \.seconds) { option in
                                Text(option.label).tag(option.seconds)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                    
                }
                
                Divider()
                
                // 用户活动检测设置
                Text(LocalizedStrings.activityDetection)
                    .font(.headline)
                
                // 暂停检测时间 - 使用选择器
                HStack {
                    Text(LocalizedStrings.pauseDetectionTime)
                    Spacer()
                    Picker("", selection: $manager.pauseDetectionMinutes) {
                        ForEach(pauseDetectionOptions, id: \.self) { minutes in
                            Text("\(minutes) " + LocalizedStrings.minutes).tag(minutes)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
                
                // 停止检测时间 - 使用选择器
                HStack {
                    Text(LocalizedStrings.stopDetectionTime)
                    Spacer()
                    Picker("", selection: $manager.stopDetectionMinutes) {
                        ForEach(stopDetectionOptions, id: \.self) { minutes in
                            Text("\(minutes) " + LocalizedStrings.minutes).tag(minutes)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
                
                Divider()
                
                // 状态栏设置
                Text(LocalizedStrings.statusBarSettings)
                    .font(.headline)
                
                HStack {
                    Text(LocalizedStrings.showStatusBarCountdown)
                    Spacer()
                    Toggle("", isOn: $manager.showStatusBarCountdown)
                        .toggleStyle(.switch)
                        .frame(width: 50)
                }
                
                Divider()
                
                // 休息界面设置 - 新增的设置组
                Text(LocalizedStrings.restViewSettings)
                    .font(.headline)
                
                // 显示名言设置
                HStack {
                    Text(LocalizedStrings.showQuotes)
                    Spacer()
                    Toggle("", isOn: $manager.showQuotesInRestView)
                        .toggleStyle(.switch)
                        .frame(width: 50)
                }
                
                if manager.showQuotesInRestView {
                    
                    Text(LocalizedStrings.customQuotesSettings)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showQuotesConfigWindow()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 0)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(isHoveringQuotesSetting ? 0.15 : 0))
                                .padding(.horizontal, -12)
                        )
                        .onHover { hovering in
                            isHoveringQuotesSetting = hovering
                        }
                }
                // 背景设置 - 独占一行的可点击文本
                Text(LocalizedStrings.backgroundSettings)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // 使用独立窗口而不是 sheet
                        showBackgroundConfigWindow()
                        
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 0)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(isHoveringBackgroundSetting ? 0.15 : 0))
                            .padding(.horizontal, -12)
                    )
                    .onHover { hovering in
                        isHoveringBackgroundSetting = hovering
                    }
                
            }
            
            Divider()
            
            // 退出按钮 - 居中显示
            Text(LocalizedStrings.menuQuit)
                .foregroundColor(.primary)  // 红色突出显示
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    NSApplication.shared.terminate(nil)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 0)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(isHoveringQuit ? 0.15 : 0))
                        .padding(.horizontal, -12)
                )
                .onHover { hovering in
                    isHoveringQuit = hovering
                }
            /*
            // 测试按钮 - 只有当主开关启用时才显示，并放在退出按钮后面
            if manager.isEnabled {
                Divider()
                
                HStack {
                    Button(LocalizedStrings.testLongRest) {
                        manager.showLongRestView()
                    }
                    
                    Spacer()
                    
                    Button(LocalizedStrings.testShortRest) {
                        manager.showShortRestView()
                    }
                }
            }*/
        }
        .padding()
        .frame(width: 300)
    }
    
    // 获取下一个休息类型文本
    private func getNextRestTypeText() -> String {
        if manager.isNextResetShortRest() {
            return LocalizedStrings.shortRestType
           
        } else {
            return  LocalizedStrings.longRestType
        }
    }
    
    // 获取下一个休息类型颜色
    private func getNextRestTypeColor() -> Color {
       
        return manager.isNextResetShortRest() ? .green : .blue
    }
    
    private func showBackgroundConfigWindow() {
        dismiss()
        // 关闭已存在的窗口
        backgroundConfigWindow?.close()
        backgroundConfigWindow = nil  // 清空引用
        // 延迟创建新窗口，确保菜单完全关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
         backgroundConfigWindow = BackgroundConfigWindow(manager: manager)
         backgroundConfigWindow?.showWindow(nil)
         
         // 确保窗口获得焦点
         DispatchQueue.main.async {
             backgroundConfigWindow?.window?.makeKeyAndOrderFront(nil)
         }
        }
    }
    
    // 添加显示 Quotes 配置窗口的方法
    private func showQuotesConfigWindow() {
        dismiss()
        // 关闭已存在的窗口
        quotesConfigWindow?.close()
        quotesConfigWindow = nil
        
        // 延迟创建新窗口，确保菜单完全关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            quotesConfigWindow = QuotesConfigWindow(manager: manager)
            quotesConfigWindow?.showWindow(nil)
         
         // 确保窗口获得焦点
         DispatchQueue.main.async {
             quotesConfigWindow?.window?.makeKeyAndOrderFront(nil)
         }
        }
    }
    
}



// 短休息时长选项结构体
struct ShortRestDurationOption: Identifiable {
    let id = UUID()
    let seconds: Int
    let label: String
}

// 短休息次数选项结构体
struct ShortRestCountOption: Identifiable {
    let id = UUID()
    let count: Int
    let label: String
}
