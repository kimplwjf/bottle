//
//  UIApplication+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/31.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation

// MARK: - UIApplication扩展
extension UIApplication {
    
    // 默认情况下keyWindow和delegate.window是同一个对象.但是当有系统弹窗出现的时候,keyWindow就变成了另外一个对象.
    // 建议将自定义view add到delegate.window而不是keyWindow上.
    func mainWindow() -> UIWindow? {
        return (delegate?.window)!
    }
    
    func visibleCtrl() -> UIViewController? {
        let rootVC = self.mainWindow()?.rootViewController
        return self.getVisibleViewController(from: rootVC)
    }
    
    func visibleNaviCtrl() -> UINavigationController? {
        return self.visibleCtrl()?.navigationController
    }
    
    private func getVisibleViewController(from vc: UIViewController?) -> UIViewController? {
        if let navi = vc as? UINavigationController {
            return getVisibleViewController(from: navi.visibleViewController)
        }
        if let tabbar = vc as? UITabBarController {
            return getVisibleViewController(from: tabbar.selectedViewController)
        }
        if vc?.presentedViewController != nil {
            return getVisibleViewController(from: vc?.presentedViewController)
        } else {
            return vc
        }
    }
    
}

// 让APP启动时只执行一次
extension UIApplication {
    
    // 使用静态属性以保证只调用一次(该属性是个方法)
    static let runOnce: Void = {
        UIViewController.hook()
        NothingToSeeHere.awake()
    }()
    
}
