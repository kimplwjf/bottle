//
//  PKGCDTimer.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/9.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class PKGCDTimer: NSObject {
    
    deinit {
        self.cancel()
        PPP("[\(NSStringFromClass(type(of: self)))]>>>GCD定时器已销毁")
    }
    
    typealias ActionCallback = (Int) -> Void
    
    /// 执行时间
    private var interval: TimeInterval = 0
    /// 延迟时间
    private var delaySecs: TimeInterval = 0
    /// 列队
    private var serialQueue: DispatchQueue!
    /// 是否重复
    private var repeats: Bool = true
    /// 响应事件
    private var action: ActionCallback?
    /// 定时器
    private var timer: DispatchSourceTimer!
    /// 是否正在运行中
    private var isRuning: Bool = false
    /// 响应次数
    private(set) var actionTimes: Int = 0
    
    /// 创建定时器
    /// - Parameters:
    ///   - interval: 间隔时间
    ///   - delaySecs: 第一次执行延迟时间,默认为0
    ///   - queue: 定时器调用的列队,默认主列队
    ///   - repeats: 是否重复执行,默认true
    ///   - action: 响应事件
    init(interval: TimeInterval, delaySecs: TimeInterval = 0, queue: DispatchQueue = .main, repeats: Bool = true, action: ActionCallback?) {
        super.init()
        self.interval = interval
        self.delaySecs = delaySecs
        self.serialQueue = queue
        self.repeats = repeats
        self.action = action
        self.timer = DispatchSource.makeTimerSource(queue: self.serialQueue)
    }
    
    /// 替换旧响应
    func replaceOldAction(action: ActionCallback?) {
        guard let action = action else {
            return
        }
        self.action = action
    }
    
    /// 执行一次定时器响应
    func respOnce() {
        actionTimes += 1
        isRuning = true
        self.action?(actionTimes)
        isRuning = false
    }
    
}

// MARK: - Public
extension PKGCDTimer {
    
    /// 开始
    func start() {
        timer.schedule(deadline: .now() + delaySecs, repeating: interval)
        timer.setEventHandler { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.actionTimes += 1
            strongSelf.action?(strongSelf.actionTimes)
            if !strongSelf.repeats {
                strongSelf.cancel()
                strongSelf.action = nil
            }
        }
        self.resume()
    }
    
    /// 暂停
    func suspend() {
        if isRuning {
            PPP("GCD定时器已暂停")
            timer.suspend()
            isRuning = false
        }
    }
    
    /// 恢复
    func resume() {
        if !isRuning {
            PPP("GCD定时器已恢复")
            timer.resume()
            isRuning = true
        }
    }
    
    /// 取消
    func cancel() {
        if !isRuning {
            self.resume()
        }
        timer.cancel()
    }
    
}
