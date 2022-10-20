//
//  BKTimer.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

class BKTimer: NSObject {
    
    deinit {
        PPP("计时器已销毁")
    }
    
    private(set) var _timer: Timer!
    fileprivate weak var _aTarget: AnyObject!
    fileprivate var _aSelector: Selector!
    var fireDate: Date {
        get { return _timer.fireDate }
        set { _timer.fireDate = newValue }
    }
    
    class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: AnyObject, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> BKTimer {
        let timer = BKTimer()
        timer._aTarget = aTarget
        timer._aSelector = aSelector
        timer._timer = Timer.scheduledTimer(timeInterval: ti, target: timer, selector: #selector(bk_timerRun), userInfo: userInfo, repeats: yesOrNo)
        timer._timer.tolerance = ti*0.1
        return timer
    }
    
    func fire() {
        _timer.fire()
    }
    
    func invalidate() {
        _timer.invalidate()
    }
    
    @objc func bk_timerRun() {
        //如果崩在这里，说明你没有在使用Timer的VC里面的deinit方法里调用invalidate()方法
        _ = _aTarget.perform(_aSelector)
    }
    
}
