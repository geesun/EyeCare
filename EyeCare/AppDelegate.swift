/*
 * Copyright (c) 2025, Qixiang Xu. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 应用启动完成后设置为 accessory 模式
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 对于菜单栏应用，通常不需要在窗口关闭后退出
        return false
    }
}
