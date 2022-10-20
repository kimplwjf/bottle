//
//  BKMaskVC.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

/// 快速实现由下向上弹起的界面
class BKMaskVC: UIViewController {
    
    enum MaskStyle: Int {
        case `default`
        case blur
    }
    
    public var presentAlpha: CGFloat {
        return 0.5
    }
    
    public var maskColor: UIColor {
        return .lightBlackDarkWhite
    }
    
    public var maskStyle: MaskStyle {
        return .default
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.first?.view == view {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let ctrl = BKPresentationController(presentedViewController: presented, presenting: presenting)
        ctrl.presentAlpha = presentAlpha
        ctrl.maskColor = maskColor
        ctrl.maskStyle = maskStyle
        return ctrl
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate代理
extension UIViewController: UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let ctrl = UIPresentationController(presentedViewController: presented, presenting: presenting)
        return ctrl
    }
    
}

// MARK: - BKPresentationController
class BKPresentationController: UIPresentationController {
    
    public var presentAlpha: CGFloat = 0.5
    
    public var maskColor: UIColor = .black
    
    public var maskStyle: BKMaskVC.MaskStyle = .default
    
    lazy var visualView: UIVisualEffectView = {
        var rect = UIScreen.main.bounds
        if let container = containerView {
            rect = container.bounds
        }
        let visualView: UIVisualEffectView
        switch maskStyle {
        case .default:
            visualView = UIVisualEffectView(frame: rect)
        case .blur:
            visualView = UIVisualEffectView(effect: blurEffect)
            visualView.frame = rect
        }
        return visualView
    }()
    
    lazy var blurEffect: UIBlurEffect = {
        let style: UIBlurEffect.Style = .light
        let blur = UIBlurEffect(style: style)
        return blur
    }()
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        switch maskStyle {
        case .default:
            visualView.backgroundColor = maskColor.withAlphaComponent(presentAlpha)
        case .blur:
            break
        }
        containerView?.addSubview(visualView)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if !completed {
            visualView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        UIView.animate(withDuration: 0.2) {
            switch self.maskStyle {
            case .default:
                self.visualView.backgroundColor = .clear
            case .blur:
                self.visualView.alpha = 0
            }
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            visualView.removeFromSuperview()
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return UIScreen.main.bounds
    }
    
}
