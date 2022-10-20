//
//  BKPopupManagerVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/25.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

// MARK: - 弹窗父类控制器
class BKPopupManagerVC: UIViewController {
    
    deinit {
        PPP("[\(NSStringFromClass(type(of: self)))]>>>已被释放")
    }
    
    /// 配置
    var configure: BKPopupManagerConfigure = BKPopupManagerConfigure()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        if let isHiddenStatusBar = UIApplication.shared.keyWindow?.rootViewController?.prefersStatusBarHidden {
            configure.isHiddenStatusBar = isHiddenStatusBar
        }
        if let statusBarStyle = UIApplication.shared.keyWindow?.rootViewController?.preferredStatusBarStyle {
            configure.statusBarStyle = statusBarStyle
        }
        if let interfaceOrientationMask = UIApplication.shared.keyWindow?.rootViewController?.supportedInterfaceOrientations {
            configure.interfaceOrientationMask = interfaceOrientationMask
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
        get { return BKDarkModeUtil.mode.style }
        set { super.overrideUserInterfaceStyle = newValue }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return configure.statusBarStyle
    }
    
    override var shouldAutorotate: Bool {
        return configure.isAutoRotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return configure.interfaceOrientationMask
    }
    
    override var prefersStatusBarHidden: Bool {
        return configure.isHiddenStatusBar
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
