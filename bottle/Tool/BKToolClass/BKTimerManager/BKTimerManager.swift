//
//  BKTimerManager.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation

class BKTimerManager: NSObject {
    
    var tickTimer: BKTimer!
    
    /** 时间记录单位均为秒*/
    private var startTime: UInt = 0
    private var pauseAccumulatedTime: UInt = 0 // 暂停时的累积时间
    
    /// 获取总时间
    var getTotalTime: UInt {
        return pauseAccumulatedTime
    }
    
    /// 当前累积的时间
    var currentAccumulatedTime: UInt {
        get {
            if startTime == 0 { return 0 }
            let currentTime = UInt(CFAbsoluteTimeGetCurrent())
            let elapsedTime = currentTime - startTime // 运行时间
            return pauseAccumulatedTime + elapsedTime
        }
        set { pauseAccumulatedTime = newValue }
    }
    
    // MARK: - 跑步计时器
    typealias TimerTickCallback = ((_ seconds: Int) -> Void)
    private var timerTickCallback: TimerTickCallback?
    
    func start(callback: @escaping TimerTickCallback) {
        self.stop()
        startTime = UInt(CFAbsoluteTimeGetCurrent())
        tickTimer = BKTimer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(clockTick), userInfo: nil, repeats: true)
        self.timerTickCallback = callback
    }
    
    func pause() {
        if tickTimer != nil {
            tickTimer.invalidate()
            tickTimer = nil
            
            let currentTime = UInt(CFAbsoluteTimeGetCurrent())
            let elapsedTime = currentTime - startTime // 运行时间
            pauseAccumulatedTime += elapsedTime
        }
    }
    
    func stop() {
        if tickTimer != nil {
            tickTimer.invalidate()
            tickTimer = nil
        }
    }
    
    func destroy() {
        self.stop()
    }
    
    override init() {
        super.init()
        
    }
    
}

// MARK: - Selector
extension BKTimerManager {
    
    @objc private func clockTick() {
        timerTickCallback?(Int(currentAccumulatedTime))
    }
    
}
