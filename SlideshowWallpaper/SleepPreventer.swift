//
//  SleepPreventer.swift
//  SlideshowWallpaper
//
//  Created by Koko Lockerns on 2025/11/22.
//

import Foundation
import IOKit.pwr_mgt

class SleepPreventer {
    static let shared = SleepPreventer()
    
    private var assertionID: IOPMAssertionID = 0
    private var isPreventingSleep = false
    
    /// 开始阻止屏幕熄灭
    func preventSleep(reason: String = "应用正在运行关键任务（如视频播放、下载、计算等）") {
        guard !isPreventingSleep else { return }
        
        let cfReason = reason as CFString
        let success = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,   // 只阻止显示器睡眠
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            cfReason,
            &assertionID
        )
        
        if success == kIOReturnSuccess {
            isPreventingSleep = true
            print("已阻止屏幕熄灭: \(reason)")
        }
    }
    
    /// 允许屏幕再次熄灭
    func allowSleep() {
        guard isPreventingSleep else { return }
        
        IOPMAssertionRelease(assertionID)
        isPreventingSleep = false
        print("已允许屏幕熄灭")
    }
}
