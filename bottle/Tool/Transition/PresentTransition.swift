//
//  PresentTransition.swift
//  dysd
//
//  Created by Penlon Kim on 2022/8/12.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit

class PresentTransition: NSObject {
    
    enum Animate {
        case scale // 缩放
        case gradient // 渐变
        case level // 层次
        case arc // 圆形扩散
        case fromLeft
        case fromRight
    }
    
    enum Transition {
        case present
        case dismiss
    }
    
    // 设置转场代理
    static private let transition = PresentTransition()
    
    static private var duration = 0.35
    static private var type: Animate = .scale
    static private var tran: Transition = .present
    static private var fromFrame: CGRect = .zero
    
    /// 带动画的present
    ///
    /// - Parameters:
    ///   - fromVC: 发起present操作的VC
    ///   - toVC: 即将被present出来的VC
    ///   - duration: 动画执行的时间
    ///   - animate: 需要哪种动画
    ///   - fromFrame: 发起present的位置frame
    ///   - modalStyle: 模态类型
    static func present(fromVC: UIViewController,
                        toVC: UIViewController,
                        duration: Double = 0.35,
                        animate: Animate = .scale,
                        fromFrame: CGRect = .zero,
                        modalStyle: UIModalPresentationStyle = .fullScreen) {
        PresentTransition.duration = duration
        PresentTransition.type = animate
        PresentTransition.fromFrame = fromFrame
        
        if #available(iOS 13.0, *) {
            toVC.modalPresentationStyle = modalStyle
            toVC.isModalInPresentation = true
        } else {
            toVC.modalPresentationStyle = modalStyle
        }
        toVC.transitioningDelegate = PresentTransition.transition
        fromVC.present(toVC, animated: true) { }
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension PresentTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return PresentTransition.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch PresentTransition.tran {
        case .present:
            presentTransition(transitionContext: transitionContext)
        case .dismiss:
            dismissTransition(transitionContext: transitionContext)
        }
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension PresentTransition: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PresentTransition.tran = .present
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PresentTransition.tran = .dismiss
        return PresentTransition()
    }
    
}

// MARK: - Private
extension PresentTransition {
    
    private func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        guard let fromView = fromVC?.view,
                let toView = toVC?.view else { return }
        
        transitionContext.containerView.addSubview(toView)
        
        switch PresentTransition.type {
        case .scale:
            scalePresent(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .gradient:
            gradientAnimate(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .level:
            levelPresent(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .arc:
            arcPresent(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .fromLeft:
            fromLeftPresent(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .fromRight:
            fromRightPresent(fromView: fromView, toView: toView, transitionContext: transitionContext)
        }
    }
    
    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        guard let fromView = fromVC?.view,
                let toView = toVC?.view else { return }
        
        transitionContext.containerView.addSubview(toView)
        
        switch PresentTransition.type {
        case .scale:
            scaleDismiss(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .gradient:
            gradientAnimate(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .level:
            levelDismiss(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .arc:
            arcDismiss(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .fromLeft:
            fromLeftDismiss(fromView: fromView, toView: toView, transitionContext: transitionContext)
        case .fromRight:
            fromRightDismiss(fromView: fromView, toView: toView, transitionContext: transitionContext)
        }
    }
    
}

// MARK: - CAAnimationDelegate
extension PresentTransition: CAAnimationDelegate {
    
    private func arcPresent(fromView: UIView,
                            toView: UIView,
                            transitionContext: UIViewControllerContextTransitioning) {
        let fromFrame = PresentTransition.fromFrame
        let start = CGPoint(x: fromFrame.origin.x+fromFrame.size.width/2,
                            y: fromFrame.origin.y + fromFrame.size.height/2)
        let maxRadius = sqrt(pow(kScreenHeight, 2) + pow(kScreenWidth, 2))
        let minRadius = 1
        
        let startCycle: UIBezierPath = UIBezierPath(arcCenter: start, radius: CGFloat(minRadius), startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        let endCycle: UIBezierPath = UIBezierPath(arcCenter: start, radius: maxRadius, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = endCycle.cgPath
        toView.layer.mask = maskLayer
        
        let maskBasicAnimation = CABasicAnimation(keyPath: "path")
        maskBasicAnimation.fromValue = startCycle.cgPath
        maskBasicAnimation.toValue = endCycle.cgPath
        maskBasicAnimation.duration = PresentTransition.duration
        maskBasicAnimation.delegate = self
        maskBasicAnimation.setValue(transitionContext, forKey: "trans")
        maskLayer.add(maskBasicAnimation, forKey: nil)
    }
    
    private func arcDismiss(fromView: UIView,
                            toView: UIView,
                            transitionContext: UIViewControllerContextTransitioning) {
        let fromFrame = PresentTransition.fromFrame
        let start = CGPoint(x: fromFrame.origin.x+fromFrame.size.width/2,
                            y: fromFrame.origin.y + fromFrame.size.height/2)
        let maxRadius = sqrt(pow(kScreenHeight, 2) + pow(kScreenWidth, 2))
        let minRadius = 1
        
        let startCycle: UIBezierPath = UIBezierPath(arcCenter: start, radius: maxRadius, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        
        let endCycle: UIBezierPath = UIBezierPath(arcCenter: start, radius: CGFloat(minRadius), startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = endCycle.cgPath
        transitionContext.containerView.addSubview(fromView)
        fromView.layer.mask = maskLayer
        
        let maskBasicAnimation = CABasicAnimation(keyPath: "path")
        maskBasicAnimation.fromValue = startCycle.cgPath
        maskBasicAnimation.toValue = endCycle.cgPath
        maskBasicAnimation.duration = PresentTransition.duration
        maskBasicAnimation.delegate = self
        maskBasicAnimation.setValue(transitionContext, forKey: "trans")
        maskLayer.add(maskBasicAnimation, forKey: nil)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let trans = anim.value(forKey: "trans") as! UIViewControllerContextTransitioning
        trans.completeTransition(!trans.transitionWasCancelled)
    }
    
}

// MARK: - 转场实现
extension PresentTransition {
    
    private func gradientAnimate(fromView: UIView,
                                 toView: UIView,
                                 transitionContext: UIViewControllerContextTransitioning) {
        fromView.alpha = 1.0
        toView.alpha = 0.0
        UIView.animate(withDuration: PresentTransition.duration, animations: {
            fromView.alpha = 0.0
            toView.alpha = 1.0
        }) { (_) in
            fromView.alpha = 1.0
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func scalePresent(fromView: UIView,
                              toView: UIView,
                              transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.containerView.bringSubviewToFront(toView)
        let fromFrame = PresentTransition.fromFrame
        let scaleX = fromFrame.size.width/toView.frame.size.width
        let scaleY = fromFrame.size.height/toView.frame.size.height
        let startTransform: CGAffineTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let endTransform: CGAffineTransform = .identity
        
        let startCenter = CGPoint(x: fromFrame.size.width/2+fromFrame.origin.x, y: fromFrame.size.height/2+fromFrame.origin.y)
        let endCenter = CGPoint(x: toView.frame.size.width/2+toView.frame.origin.x, y: toView.frame.size.height/2+toView.frame.origin.y)
        
        toView.transform = startTransform
        toView.center = startCenter
        UIView.animate(withDuration: PresentTransition.duration, animations: {
            toView.transform = endTransform
            toView.center = endCenter
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func scaleDismiss(fromView: UIView,
                              toView: UIView,
                              transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.containerView.bringSubviewToFront(fromView)
        let fromFrame = PresentTransition.fromFrame
        let scaleX = fromFrame.size.width/fromView.frame.size.width
        let scaleY = fromFrame.size.height/fromView.frame.size.height
        let startTransform: CGAffineTransform = .identity
        let endTransform: CGAffineTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        let startCenter = CGPoint(x: fromView.frame.size.width/2+fromView.frame.origin.x, y: fromView.frame.size.height/2+fromView.frame.origin.y)
        let endCenter = CGPoint(x: fromFrame.size.width/2+fromFrame.origin.x, y: fromFrame.size.height/2+fromFrame.origin.y)
        
        fromView.transform = startTransform
        fromView.center = startCenter
        UIView.animate(withDuration: PresentTransition.duration, animations: {
            fromView.transform = endTransform
            fromView.center = endCenter
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func levelPresent(fromView: UIView,
                              toView: UIView,
                              transitionContext: UIViewControllerContextTransitioning) {
        toView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight)
        UIView.animate(withDuration: 0.2) {
            fromView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: PresentTransition.duration) {
                toView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            } completion: { _ in
                fromView.transform = .identity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private func levelDismiss(fromView: UIView,
                              toView: UIView,
                              transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.containerView.addSubview(fromView)
        toView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        fromView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        UIView.animate(withDuration: PresentTransition.duration) {
            fromView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight)
        } completion: { _ in
            UIView.animate(withDuration: PresentTransition.duration) {
                toView.transform = .identity
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private func fromLeftPresent(fromView: UIView,
                                 toView: UIView,
                                 transitionContext: UIViewControllerContextTransitioning) {
        toView.frame = CGRect(x: -kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight)
        UIView.animate(withDuration: PresentTransition.duration, animations: {
            toView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            toView.layoutSubviews()
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func fromLeftDismiss(fromView: UIView,
                                 toView: UIView,
                                 transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: PresentTransition.duration, animations: {
            fromView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
            fromView.alpha = 0
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func fromRightPresent(fromView: UIView,
                                  toView: UIView,
                                  transitionContext: UIViewControllerContextTransitioning) {
        toView.frame = CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight)
        UIView.animate(withDuration: PresentTransition.duration, animations: {
            toView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            toView.layoutSubviews()
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func fromRightDismiss(fromView: UIView,
                                  toView: UIView,
                                  transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: PresentTransition.duration, animations: {
            fromView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
            fromView.alpha = 0
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
