//
//  CountdownManager.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation

/// 支持时间记忆的倒计时管理工具
/// 举例说明，A界面开启了倒计时当前是50秒，退出A界面后，过了5秒钟再重新进入A界面，此时倒计时显示的是45秒。
class CountdownManager {
    
    // 私有化init方法（只能通过sharedInstance()方法创建）
    private init() { }
    
    private static var _sharedInstance: CountdownManager?
    
    class func sharedInstance() -> CountdownManager {
        guard let instance = _sharedInstance else {
            _sharedInstance = CountdownManager()
            return _sharedInstance!
        }
        return instance
    }
    
    /// 销毁单例对象
    class func destroy() {
        _sharedInstance = nil
    }
    
    // MARK: - timer 的主要代码
    
    /// 计时器
    private var gcdTimer : DispatchSourceTimer?
    
    /// 倒计时model数组
    private var models = [CountDownModel]()
    
    /// 开始倒计时
    /// - Parameters:
    ///   - reuseId: 唯一id，一个倒计时要对应一个id
    ///   - count: 最大的秒数
    ///   - create: 如果 reuseId 不存在，是否需要创建
    ///   - block: 倒计时回调
    func start(reuseId: String, count: Int, create: Bool, block: @escaping ((_ count: Int) -> ())) {
        
        var contain = false
        var extistModel: CountDownModel?
        var extistIndex: Int = -1
        
        for (index, tmpModel) in models.enumerated() {
            if tmpModel.reuseId == reuseId {
                contain = true
                extistModel = tmpModel
                extistIndex = index
                break
            }
        }
        if !contain {
            // reuseId 不存在
            if create {
                // 需要创建才添加
                let model = CountDownModel(reuseId: reuseId, count: count, block: block)
                models.append(model)
            }
        } else {
            // reuseId 已经存在, 替换
            let model = CountDownModel(reuseId: reuseId, count: extistModel!.count, block: block)
            models[extistIndex] = model
            // 执行一次 block，当调用 start 时，可以马上显示。否则会有一秒的延迟
            model.block(model.count)
        }
        
        if gcdTimer == nil {
            gcdTimer = DispatchSource.makeTimerSource()
            gcdTimer?.schedule(deadline: .now(), repeating: .milliseconds(1000))
            gcdTimer?.setEventHandler(handler: {
                DispatchQueue.main.async { [weak self] in
                    if let modelArr = self?.models {
                        var tmpModels = [CountDownModel]()
                        /// 遍历倒计时的model数组
                        for (_, tmpModel) in modelArr.enumerated() {
                            let newCount = tmpModel.count - 1
                            let newModel = CountDownModel(reuseId: tmpModel.reuseId,
                                                          count: newCount,
                                                          block: tmpModel.block)
                            tmpModel.block(newCount)
                            
                            if newCount > 0 {
                                tmpModels.append(newModel)
                            }
                        }
                        
                        self?.models = tmpModels
                    }
                    
                    if self?.models.count == 0 {
                        // 所有倒计时都结束了, 取消 timer, 并置为 nil
                        self?.gcdTimer?.cancel()
                        self?.gcdTimer = nil
                    }
                }
            })
            gcdTimer?.resume()
        }
    }
    
}

// MARK: -  倒计时的model
struct CountDownModel {
    var reuseId : String
    var count : Int = 60
    var block : ((_ count: Int) -> ())
}
