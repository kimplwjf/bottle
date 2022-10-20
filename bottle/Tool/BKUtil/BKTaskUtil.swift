//
//  BKTaskUtil.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/6/10.
//  Copyright © 2022 王锦发. All rights reserved.
//

import Foundation

struct BKTaskUtil {
    
    typealias Task = () -> Void
    typealias SemaphoreTask = (DispatchSemaphore) -> Void
    typealias CancelTask = (_ cancel: Bool) -> Void
    
    /// 异步执行任务后回主线程
    ///
    /// - Parameters:
    ///   - label: 唯一的标签
    ///   - task: 异步任务
    ///   - mainTask: 主线程任务
    static func async(label: String,
                      task: @escaping Task,
                      mainTask: @escaping Task) {
        let workingGroup = DispatchGroup()
        let workingQueue = DispatchQueue(label: label)
        let semaphore = DispatchSemaphore(value: 0)
        
        workingQueue.async {
            workingGroup.enter()
            task()
            semaphore.signal()
            workingGroup.leave()
        }
        semaphore.wait()
        
        workingGroup.notify(queue: .main) {
            mainTask()
        }
    }
    
    /// 异步执行多任务后回主线程
    ///
    /// - Parameters:
    ///   - label: 唯一的标签
    ///   - task1: 异步任务1
    ///   - taks2: 异步任务2
    ///   - mainTask: 主线程任务
    static func async(label: String,
                      task1: @escaping SemaphoreTask,
                      task2: @escaping SemaphoreTask,
                      mainTask: @escaping Task) {
        let workingGroup = DispatchGroup()
        // 这个是并行列队，queue里面的任务会同时执行
        let workingQueue = DispatchQueue(label: label, qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        
        workingGroup.enter() // 开始
        workingQueue.async {
            let semaphore = DispatchSemaphore(value: 0)
            task1(semaphore)
            semaphore.wait() // 等待任务结束，否则一直阻塞
            workingGroup.leave() // 结束
        }
        
        workingGroup.enter() // 开始
        workingQueue.async {
            let semaphore = DispatchSemaphore(value: 0)
            task2(semaphore)
            semaphore.wait() // 等待任务结束，否则一直阻塞
            workingGroup.leave() // 结束
        }
        
        workingGroup.notify(queue: .main) {
            mainTask()
        }
    }
    
    /// 延迟执行
    ///
    /// - Parameters:
    ///   - seconds: 延迟时间
    ///   - qos: 要使用的全局QOS类(默认为 nil,表示主线程)
    ///   - task: 执行任务
    /// - Returns: CancelTask?
    @discardableResult
    static func delay(_ seconds: TimeInterval, qos: DispatchQoS.QoSClass? = nil, task: @escaping Task) -> CancelTask? {
        return _delay(seconds, qos, task)
    }
    
    /// 取消代码延时运行
    static func delayCancel(_ task: CancelTask?) {
        task?(true)
    }
    
    /// GCD定时器倒计时
    ///
    /// - Parameters:
    ///   - timeInterval: 间隔时间
    ///   - repeatCount: 重复次数
    ///   - handler: 循环事件,闭包参数: 1.timer 2.剩余执行次数
    static func dispatchTimer(timeInterval: Double, repeatCount: Int, handler: @escaping (DispatchSourceTimer?, Int) -> Void) {
        if repeatCount <= 0 {
            return
        }
        let timer = DispatchSource.makeTimerSource()
        var count = repeatCount
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            count -= 1
            DispatchQueue.main.async {
                handler(timer, count)
            }
            if count == 0 {
                timer.cancel()
            }
        }
        timer.resume()
    }
    
}

// MARK: - GCD
extension BKTaskUtil {
    
    /// 代码延迟运行
    ///
    /// - Parameters:
    ///   - delayTime: 延时时间。比如：.seconds(5)、.milliseconds(500)
    ///   - qosClass: 要使用的全局QOS类（默认为 nil，表示主线程）
    ///   - task: 延迟运行的代码
    /// - Returns: Task?
    @discardableResult
    fileprivate static func _delay(_ delayTime: TimeInterval,
                                   _ qosClass: DispatchQoS.QoSClass? = nil,
                                   _ task: @escaping Task) -> CancelTask? {
        
        func dispatch_later(block: @escaping () -> Void) {
            let dispatchQueue = qosClass != nil ? DispatchQueue.global(qos: qosClass!) : .main
            dispatchQueue.asyncAfter(deadline: .now() + delayTime, execute: block)
        }
        
        var closure: (() -> Void)? = task
        var result: CancelTask?
        
        let delayedClosure: CancelTask = { cancel in
            if let internalClosure = closure {
                if !cancel {
                    DispatchQueue.main.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        return result
        
    }
    
}
