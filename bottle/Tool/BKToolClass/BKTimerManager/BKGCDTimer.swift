//
//  BKGCDTimer.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/8/6.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BKGCDTimer: NSObject {
    
    deinit {
        // 对象在销毁前会销毁定时器，所以使用定时器应该设置全局的属性
        self.bk_invalidate()
        PPP("[\(NSStringFromClass(type(of: self)))]>>>GCD定时器已销毁")
    }
    
    /// GCD定时器
    private var gcdTimer: DispatchSourceTimer?
    /// GCD定时器的挂起状态
    private var isSuspend: Bool = false
    
    override init() {
        super.init()
        
    }
    
}

extension BKGCDTimer {
    
    /// 开始GCD定时器
    ///
    /// - Parameters:
    ///   - timeInterval: 间隔时间
    ///   - handler: 事件
    func bk_start(timeInterval: Double, handler: @escaping () -> Void) {
        if gcdTimer == nil {
            gcdTimer = DispatchSource.makeTimerSource(queue: .main)
            gcdTimer?.schedule(deadline: .now(), repeating: timeInterval)
            gcdTimer?.setEventHandler(handler: {
                DispatchQueue.main.async {
                    handler()
                }
            })
            gcdTimer?.resume()
        } else {
            self.bk_suspendOrResume(isPause: false)
        }
    }
    
    /// 暂停或重启定时器
    func bk_suspendOrResume(isPause: Bool) {
        guard isSuspend != isPause else { return }
        isPause ? PPP("定时器已暂停") : PPP("定时器已重启")
        isPause ? gcdTimer?.suspend() : gcdTimer?.resume()
        isSuspend = isPause
    }
    
    /// 销毁定时器
    func bk_invalidate() {
        if isSuspend {
            gcdTimer?.resume()
        }
        // 销毁前不能为suspend（挂起状态）
        gcdTimer?.cancel()
        gcdTimer = nil
    }
    
}
