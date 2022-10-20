//
//  BKPopupManager.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/25.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

// MARK: - 弹窗配置
class BKPopupManagerConfigure: NSObject {
    /// 唯一标识符
    fileprivate(set) var identifier: String = ""
    /// 顶掉前面弹窗弹窗
    var isDissmissBefore: Bool = false
    /// 向下传递手势
    var isPassedDown: Bool = false
    /// 是否自动旋转
    var isAutoRotate: Bool = false
    /// 是否隐藏状态栏
    var isHiddenStatusBar: Bool = false
    /// 是否等待
    var isWait: Bool = true
    /// 状态栏颜色
    var statusBarStyle: UIStatusBarStyle = .lightContent
    /// 支持方向
    var interfaceOrientationMask: UIInterfaceOrientationMask = .portrait
}

// MARK: - 弹窗Window
class BKPopupManagerWindow: UIWindow {
    
    deinit {
        PPP("[\(NSStringFromClass(type(of: self)))]>>>已被释放")
    }
    
    /// 向下传递手势
    var isPassedDown: Bool = false
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == rootViewController?.view {
            return isPassedDown ? nil : view
        }
        return view
    }
    
}

typealias BPM = BKPopupManager

// MARK: - 弹窗管理者
class BKPopupManager: NSObject {
    
    deinit {
        PPP("[\(NSStringFromClass(type(of: self)))]>>>已被释放")
    }
    
    private static let ID = "BKPopupManager.queue"
    private static var manager: BKPopupManager?
    
    private class var shared: BKPopupManager {
        guard let sharedManager = manager else {
            manager = BKPopupManager()
            manager?.semaphore.signal()
            return manager!
        }
        return sharedManager
    }
    
    private var removedArray: Array<String> = Array()
    private var windowDictionary = [String: BKPopupManagerWindow]()
    
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    private var currentWait: Int = 0 {
        didSet {
            if oldValue != currentWait, currentWait == 0 {
//                BKPopupManager.manager = nil
            }
        }
    }
    private var queue: DispatchQueue = DispatchQueue(label: BKPopupManager.ID, attributes: .concurrent)
    
    private override init() {
        super.init()
        
    }
    
}

// MARK: - Public
extension BKPopupManager {
    
    /// 显示自定义弹窗
    class func show(_ ctrl: BKPopupManagerVC) {
        shared.queue.async {
            if shared.windowDictionary.isEmpty, !ctrl.configure.isWait {
                shared.semaphore.wait()
            }
            if ctrl.configure.isDissmissBefore {
                shared.windowDictionary.removeAll()
                shared.removedArray.removeAll()
                shared.semaphore = DispatchSemaphore(value: 0)
                shared.semaphore.signal()
                shared.currentWait = 1
            } else if ctrl.configure.isWait {
                shared.currentWait += 1
            }
            if ctrl.configure.isWait || ctrl.configure.isDissmissBefore {
                shared.semaphore.wait()
            }
            DispatchQueue.main.async {
                if shared.removedArray.contains(ctrl.configure.identifier) {
                    shared.removedArray.removeAll(where: { $0 == ctrl.configure.identifier })
                    shared.semaphore.signal()
                    shared.currentWait -= 1
                } else {
                    let window = BKPopupManagerWindow(frame: kScreenBounds)
                    window.isPassedDown = ctrl.configure.isPassedDown
                    window.windowLevel = .statusBar
                    window.isUserInteractionEnabled = true
                    window.rootViewController = ctrl
                    window.makeKeyAndVisible()
                    shared.windowDictionary[ctrl.configure.identifier] = window
                }
            }
        }
    }
    
    /// 隐藏所有弹窗
    class func dismissAll() {
        guard BKPopupManager.manager != nil else { return }
        shared.queue.async {
            shared.windowDictionary.removeAll()
            shared.removedArray.removeAll()
            shared.semaphore = DispatchSemaphore(value: 0)
            shared.semaphore.signal()
            shared.currentWait = 0
        }
    }
    
    /// 隐藏指定弹窗
    class func dismiss(_ id: String) {
        guard BKPopupManager.manager != nil else { return }
        DispatchQueue.main.async {
            if let ctrl = shared.windowDictionary[id]?.rootViewController as? BKPopupManagerVC {
                shared.windowDictionary.removeValue(forKey: id)
                shared.queue.async {
                    if ctrl.configure.isWait || ctrl.configure.isDissmissBefore {
                        shared.semaphore.signal()
                        shared.currentWait -= 1
                    }
                    if shared.windowDictionary.isEmpty, !ctrl.configure.isWait {
                        shared.semaphore.signal()
                    }
                }
            } else {
                shared.removedArray.append(id)
            }
        }
    }
    
}

// MARK: - Public - 弹窗
extension BKPopupManager {
    
    /// 显示加载动画
    @discardableResult
    static func showLoading(type: LoadingType, isPassedDown: Bool = true, configCallback: ((BKPopupManagerConfigure) -> Void)? = nil) -> String {
        let identifier: String = dateRandomString
        DispatchQueue.main.async {
            let ctrl = BKPopupLoadingVC(type: type)
            ctrl.configure.isDissmissBefore = true
            ctrl.configure.isPassedDown = isPassedDown
            ctrl.configure.identifier = identifier
            configCallback?(ctrl.configure)
            self.show(ctrl)
        }
        return identifier
    }
    
    /// 显示通知弹窗
    @discardableResult
    static func showNotifi(title: String?, body: String?, tapCallback: ((String) -> Void)?, configCallback: ((BKPopupManagerConfigure) -> Void)? = nil) -> String {
        let identifier: String = dateRandomString
        DispatchQueue.main.async {
            let ctrl = BKPopupNotifiVC()
            ctrl.configure.isPassedDown = true
            ctrl.configure.identifier = identifier
            ctrl.text = title
            ctrl.body = body
            ctrl.tapHandler = tapCallback
            configCallback?(ctrl.configure)
            self.show(ctrl)
        }
        return identifier
    }
    
    /// 显示返回结果弹窗
    @discardableResult
    static func showResult(_ type: BKPopupResultVC.ResultType, msg: String? = nil, duration: TimeInterval = 1.2, configCallback: ((BKPopupManagerConfigure) -> Void)? = nil) -> String {
        let identifier: String = dateRandomString
        DispatchQueue.main.async {
            let ctrl = BKPopupResultVC(type: type)
            ctrl.configure.isDissmissBefore = true
            ctrl.configure.isPassedDown = true
            ctrl.configure.identifier = identifier
            ctrl.duration = duration
            ctrl.text = msg
            configCallback?(ctrl.configure)
            self.show(ctrl)
        }
        return identifier
    }
    
    /// 显示警告信息弹窗
    @discardableResult
    static func showAlert(_ type: BKPopupAlertVC.AlertType, position: BKPopupAlertVC.PositionType = .top, msg: String?, duration: TimeInterval = 1.5, configCallback: ((BKPopupManagerConfigure) -> Void)? = nil) -> String {
        let identifier: String = dateRandomString
        DispatchQueue.main.async {
            let ctrl = BKPopupAlertVC(type: type, position: position)
            ctrl.configure.isDissmissBefore = true
            ctrl.configure.isPassedDown = true
            ctrl.configure.identifier = identifier
            ctrl.duration = duration
            ctrl.text = msg
            configCallback?(ctrl.configure)
            self.show(ctrl)
        }
        return identifier
    }
    
    /// 显示进度弹窗
    @discardableResult
    static func showProgress(msg: String? = nil, limit: Int = 1, configCallback: ((BKPopupManagerConfigure) -> Void)? = nil) -> BKPopupProgressVC {
        let identifier: String = dateRandomString
        let ctrl = BKPopupProgressVC()
        DispatchQueue.main.async {
            ctrl.configure.isPassedDown = true
            ctrl.configure.identifier = identifier
            ctrl.limitCount = limit
            ctrl.text = msg
            configCallback?(ctrl.configure)
            self.show(ctrl)
        }
        return ctrl
    }
    
    /// 显示可拖拽弹窗
    @discardableResult
    static func showDrag(contentView: UIView, configCallback: ((BKPopupManagerConfigure) -> Void)? = nil) -> String {
        let identifier: String = dateRandomString
        DispatchQueue.main.async {
            let ctrl = BKPopupMomentumVC(contentView: contentView)
            ctrl.configure.identifier = identifier
            configCallback?(ctrl.configure)
            self.show(ctrl)
        }
        return identifier
    }
    
}
