//
//  BKTimerDownManager.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/8/19.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BKTimerDownManager: NSObject {
    
    var downTimer: BKTimer!
    var secondsToEnd: Int = 0
    
    override init() {
        super.init()
        
    }
    
    // MARK: - 倒计时自动结束跑步
    typealias TimeDownBlock = (Int) -> Void
    private var timeDownBlock: TimeDownBlock?
    
    func start(seconds: Int, block: @escaping TimeDownBlock) {
        self.stop()
        self.secondsToEnd = seconds
        downTimer = BKTimer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerdowning), userInfo: nil, repeats: true)
        self.timeDownBlock = block
    }
    
    func stop() {
        if downTimer != nil {
            downTimer.invalidate()
            downTimer = nil
        }
    }
    
    func destroy() {
        self.stop()
    }
    
}

// MARK: - Selector
extension BKTimerDownManager {
    
    @objc private func timerdowning() {
        secondsToEnd -= 1
        if secondsToEnd == 0 {
            downTimer.invalidate()
            downTimer = nil
        }
        timeDownBlock?(secondsToEnd)
    }
    
}
