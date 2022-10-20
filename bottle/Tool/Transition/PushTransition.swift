//
//  PushTransition.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/8/15.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class PushTransition: NSObject {
    
    enum `Type` {
        case scale
        case fromTop
        case fromBottom
    }
    
    static private var duration = 0.35
    static private var type: Type = .scale
    // 设置转场代理
    static var transition = PushTransition()
    
    /// 带动画的push
    ///
    /// - Parameters:
    ///   - fromVC: 发起push操作的VC
    ///   - toVC: 即将被push出来的VC
    ///   - type: 需要哪种动画
    ///   - duration: 动画执行的时间
    static func push(fromVC: UIViewController,
                     toVC: UIViewController,
                     type: Type = .scale,
                     duration: Double = 0.35) {
        self.type = type
        self.duration = duration
        fromVC.navigationController?.delegate = PushTransition.transition
        fromVC.navigationController?.pushViewController(toVC, animated: true)
        fromVC.navigationController?.delegate = nil
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension PushTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return PushTransition.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        guard let fromView = fromVC?.view,
                let toView = toVC?.view else { return }
        
        switch PushTransition.type {
        case .scale:
            scale(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .fromTop:
            fromTop(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .fromBottom:
            fromBottom(fromView: fromView, toView: toView, transitionContext: transitionContext)
        }
    }
    
}

// MARK: - UINavigationControllerDelegate
extension PushTransition: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushTransition()
    }
    
}

// MARK: - 转场实现
extension PushTransition {
    
    /// 缩放的push
    ///
    /// - Parameters:
    ///   - fromView: 发起push操作的VC的View
    ///   - toView: 即将被push出来的VC的View
    ///   - transitionContext: 上下文
    private func scale(fromView: UIView,
                       toView: UIView,
                       transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.bringSubviewToFront(fromView)
        
        UIView.animate(withDuration: PushTransition.duration, animations: {
            fromView.alpha = 0
            fromView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            toView.alpha = 1.0
        }) { (_) in
            fromView.transform = CGAffineTransform(scaleX: 1, y: 1)
            transitionContext.completeTransition(true)
            fromView.alpha = 1.0
        }
    }
    
    /// 从上到下的push
    ///
    /// - Parameters:
    ///   - fromView: 发起push操作的VC的View
    ///   - toView: 即将被push出来的VC的View
    ///   - transitionContext: 上下文
    private func fromTop(fromView: UIView,
                         toView: UIView,
                         transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.containerView.addSubview(toView)
        toView.transform = CGAffineTransform(translationX: 0, y: -kScreenHeight)
        
        UIView.animate(withDuration: PushTransition.duration, animations: {
            toView.transform = CGAffineTransform(translationX: 0, y: 0)
            toView.alpha = 1.0
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    
    /// 从下往上的push
    ///
    /// - Parameters:
    ///   - fromView: 发起push操作的VC的View
    ///   - toView: 即将被push出来的VC的View
    ///   - transitionContext: 上下文
    private func fromBottom(fromView: UIView,
                            toView: UIView,
                            transitionContext:  UIViewControllerContextTransitioning) {
        transitionContext.containerView.addSubview(toView)
        toView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
        UIView.animate(withDuration: PushTransition.duration, animations: {
            toView.transform = CGAffineTransform(translationX: 0, y: 0)
            toView.alpha = 1.0
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    
}
