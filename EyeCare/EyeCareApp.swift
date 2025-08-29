/*
 * Copyright (c) 2025, Qixiang Xu. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

import SwiftUI

@main
struct EyeCareApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var eyeCareManager = EyeCareManager()
    
    var body: some Scene {
        MenuBarExtra {
            EyeCareMenuView(manager: eyeCareManager)
        } label: {
            HStack(spacing: 4) {
                Image("status").resizable()
                        .frame(width: 32, height: 32)
                
                // 只有启用且有倒计时时才显示时间
                if !eyeCareManager.isEnabled {
                    Text(LocalizedStrings.disabled)
                        .font(.system(size: 12))
                } else if eyeCareManager.statusBarTitle == "Stop"  {
                    Text(LocalizedStrings.stop)
                        .font(.system(size: 12))
                } else if eyeCareManager.statusBarTitle == "Pause" {
                    Text(LocalizedStrings.pause)
                        .font(.system(size: 12))
                } else {
                    Text(eyeCareManager.statusBarTitle)
                        .font(.system(size: 12))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
