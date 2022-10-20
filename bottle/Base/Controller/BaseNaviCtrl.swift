//
//  BaseNaviCtrl.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/29.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

class BaseNaviCtrl: UINavigationController {
    
    override var prefersStatusBarHidden: Bool {
        return StatusBarManager.shared.isHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusBarManager.shared.style
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return StatusBarManager.shared.animation
    }
    
    @available(iOS 13.0, *)
    override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
        get { return topViewController?.overrideUserInterfaceStyle ?? .light }
        set {  }
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        bk_clearSubStatusBars(isUpdate: false)
        bk_pushStatusBars(for: viewControllers)
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    /// 修改导航栏返回按钮
    override func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        self.bk_setStatusBar(isHidden: false)
        if self.viewControllers.count > 0 {
            let leftItem = UIBarButtonItem(image: .ArrowFork.icon_leftArrow, style: .done, target: self, action: #selector(back))
            viewController.navigationItem.leftBarButtonItem = leftItem
            if self.viewControllers.count == 1 {
                viewController.hidesBottomBarWhenPushed = true
            }
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        topViewController?.bk_addSubStatusBar(for: viewController)
        super.pushViewController(viewController, animated: animated)
    }
    
    @objc private func back() {
        self.popViewController(animated: true)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        /**
         自定义UINavigationController，需要重写childForStatusBarStyle。
         否则preferredStatusBarStyle不执行。
         */
        return topViewController
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bk_pushStatusBars(for: viewControllers)
        self.interactivePopGestureRecognizer?.delegate = self
        
    }
    
}

// MARK: - 导航返回协议
@objc protocol NavigationProtocol {
    @objc optional func navigationShouldPopMethod() -> Bool
}

extension UIViewController: NavigationProtocol {
    func navigationShouldPopMethod() -> Bool {
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate代理
extension UINavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if children.count == 1 {
            return false
        } else {
            if topViewController?.responds(to: #selector(navigationShouldPopMethod)) != nil {
                return topViewController!.navigationShouldPopMethod()
            }
            return true
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /******处理侧滑手势与scrollview手势冲突*******/
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
}
