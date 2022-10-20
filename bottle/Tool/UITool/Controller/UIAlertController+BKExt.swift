//
//  UIAlertController+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/6/12.
//  Copyright © 2020 王锦发. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIAlertController扩展
extension UIAlertController {
    
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach { addAction($0) }
    }
    
    // 在指定视图控制器上弹出普通消息提示框
    static func showNormalAlert(in viewController: UIViewController,
                                msg: String,
                                actionTitle: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default))
        viewController.present(alert, animated: true)
    }
    
    // 在根视图控制器上弹出普通消息提示框
    static func showNormalAlertInRoot(msg: String, actionTitle: String) {
        if let vc = UIApplication.shared.visibleCtrl() {
            self.showNormalAlert(in: vc, msg: msg, actionTitle: actionTitle)
        }
    }
    
}

extension UIAlertController {
    
    /// 在指定视图控制器上弹出普通消息提示框
    static func showOneAlert(in viewController: UIViewController,
                             title: String? = nil,
                             msg: String? = nil,
                             style: UIAlertController.Style = .alert,
                             okTitle: String,
                             okTitleColor: UIColor = .blue,
                             okStyle: UIAlertAction.Style = .default,
                             okHandler: ((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: style)
        let okAction = UIAlertAction(title: okTitle, style: okStyle, handler: okHandler)
        alert.addAction(okAction)
        okAction.bk_setTextColor(okTitleColor)
        viewController.present(alert, animated: true)
        
    }
    
    /// 在根视图控制器上弹出普通消息提示框
    static func showOneAlertInRoot(title: String? = nil,
                                   msg: String? = nil,
                                   style: UIAlertController.Style = .alert,
                                   okTitle: String,
                                   okTitleColor: UIColor = .blue,
                                   okStyle: UIAlertAction.Style = .default,
                                   okHandler: ((UIAlertAction) -> Void)?) {
        if let vc = UIApplication.shared.visibleCtrl() {
            self.showOneAlert(in: vc, title: title, msg: msg, style: style, okTitle: okTitle, okTitleColor: okTitleColor, okStyle: okStyle, okHandler: okHandler)
        }
    }
    
}

extension UIAlertController {
    
    /// 在指定视图控制器上弹框
    static func showTwoAlert(in viewController: UIViewController,
                             title: String? = nil,
                             msg: String? = nil,
                             style: UIAlertController.Style = .alert,
                             noTitle: String = "取消",
                             okTitle: String,
                             noTitleColor: UIColor = .blue,
                             okTitleColor: UIColor = .blue,
                             noStyle: UIAlertAction.Style = .cancel,
                             okStyle: UIAlertAction.Style = .default,
                             noHandler: ((UIAlertAction) -> Void)? = nil,
                             okHandler: ((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: style)
        let noAction = UIAlertAction(title: noTitle, style: noStyle, handler: noHandler)
        let okAction = UIAlertAction(title: okTitle, style: okStyle, handler: okHandler)
        alert.addAction(noAction)
        alert.addAction(okAction)
        noAction.bk_setTextColor(noTitleColor)
        okAction.bk_setTextColor(okTitleColor)
        viewController.present(alert, animated: true)
        
    }
    
    /// 在根视图控制器上弹框
    static func showTwoAlertInRoot(title: String? = nil,
                                   msg: String? = nil,
                                   style: UIAlertController.Style = .alert,
                                   noTitle: String = "取消",
                                   okTitle: String,
                                   noTitleColor: UIColor = .blue,
                                   okTitleColor: UIColor = .blue,
                                   noStyle: UIAlertAction.Style = .cancel,
                                   okStyle: UIAlertAction.Style = .default,
                                   noHandler: ((UIAlertAction) -> Void)? = nil,
                                   okHandler: ((UIAlertAction) -> Void)?) {
        if let vc = UIApplication.shared.visibleCtrl() {
            self.showTwoAlert(in: vc, title: title, msg: msg, style: style, noTitle: noTitle, okTitle: okTitle, noTitleColor: noTitleColor, okTitleColor: okTitleColor, noStyle: noStyle, okStyle: okStyle, noHandler: noHandler, okHandler: okHandler)
        }
    }
    
}

// MARK: - UIAlertAction扩展
extension UIAlertAction {
    
    func bk_setTextColor(_ color: UIColor) {
        self.setValue(color, forKey: "titleTextColor")
    }
    
}
