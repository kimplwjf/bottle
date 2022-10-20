//
//  BaseVC.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/29.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit
import LXFProtocolTool

class BaseVC: UIViewController {
    
    deinit {
        self.removeNOC()
        self.bk_hideLoading()
        self.bk_removeFromSuperStatusBar()
    }
    
    var backBarButtonItemHidden: Bool {
        return false
    }
    
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
        get { return BKDarkModeUtil.mode.style }
        set {  }
    }
    
    /// 转子标识符
    private var identifier: String?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightWhiteDark27
        self.edgesForExtendedLayout = []
        
        if !backBarButtonItemHidden {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: .ArrowFork.icon_leftArrow, style: .done, target: self, action: #selector(goBack))
        }
        
        self.addNOC()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bk_setPopSwipe(true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
    
    // MARK: - lazy
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(.ArrowFork.icon_leftArrow, for: .normal)
        btn.bk_setEnlargeEdge(10)
        btn.bk_addTarget { [unowned self] (sender) in
            self.bk_autoBack()
        }
        return btn
    }()
    
}

// MARK: - Selector
extension BaseVC {
    
    @objc func goBack() {
        self.bk_autoBack()
    }
    
}

// MARK: - 通知
extension BaseVC {
    
    private func addNOC() {
        
    }
    
    private func removeNOC() {
        
    }
    
}

// MARK: - Public - Bar、手势、跳转
extension BaseVC {
    
    func bk_setNavigationBarHidden(_ hidden: Bool) {
        self.navigationController?.setNavigationBarHidden(hidden, animated: false)
    }
    
    func bk_changeNaviBarAnimate(_ clear: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.naviBarBackgroundAlpha = clear ? 0 : 1.0
        }
    }
    
    func bk_setLeftBarButtonItem(isHidden: Bool) {
        self.navigationItem.hidesBackButton = isHidden
        self.navigationItem.leftBarButtonItem = isHidden ? nil : UIBarButtonItem(image: .ArrowFork.icon_leftArrow, style: .done, target: self, action: #selector(goBack))
    }
    
    func bk_setPopSwipe(_ isEnabled: Bool) {
        if self.navigationController != nil {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
        }
    }
    
    func bk_autoBack() {
        guard let viewCtrls = self.navigationController?.viewControllers else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if viewCtrls.count > 1 {
            if self.navigationController?.topViewController == self {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func bk_present(_ viewControllerToPresent: UIViewController,
                    type: UIModalPresentationStyle = .fullScreen,
                    animated flag: Bool,
                    completion: (() -> Void)? = nil) {
        
        if #available(iOS 13.0, *) {
            viewControllerToPresent.modalPresentationStyle = type
            viewControllerToPresent.isModalInPresentation = true
        } else {
            viewControllerToPresent.modalPresentationStyle = type
        }
        self.bk_addSubStatusBar(for: viewControllerToPresent)
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        
    }
    
}

// MARK: - Public
extension BaseVC {
    
    /// 显示加载动画
    func bk_showLoading(type: LoadingType = .default, isPassedDown: Bool = true) {
        identifier = BPM.showLoading(type: type, isPassedDown: isPassedDown)
    }
    
    /// 隐藏加载动画
    func bk_hideLoading() {
        guard let id = identifier else {
            BPM.dismissAll()
            return
        }
        BPM.dismiss(id)
    }
    
}
