//
//  BaseTabBarVC.swift
//  diyisaidao
//
//  Created by 王锦发 on 2020/4/8.
//  Copyright © 2020 王锦发. All rights reserved.
//

import UIKit
import ESTabBarController_swift

enum TabBarKeys: String {
    case kTabBarVCType
    case kTabBarTitle
    case kTabBarImage
    case kTabBarImageSelect
}

enum TabBarItemType: String {
    case Collect
    case Throw
    case Mine
    
    var title: String {
        switch self {
        case .Collect: return "捞一捞"
        case .Throw: return "扔一扔"
        case .Mine: return "我的"
        }
    }
    
    var style: (vc: String, imgNormal: String, imgSelect: String) {
        return ("BO\(self.rawValue)VC", "icon_\(self.rawValue)_normal", "icon_\(self.rawValue)_select")
    }
}

class BaseTabBarVC: ESTabBarController {
    
    deinit {
        
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
        get {
            if let naviCtrl = selectedViewController as? UINavigationController {
                return naviCtrl.topViewController?.overrideUserInterfaceStyle ?? .light
            } else {
                return selectedViewController?.overrideUserInterfaceStyle ?? .light
            }
        }
        set { }
    }
    
    var tabBarItems: [TabBarItemType] = []
    
    private var tabBarItemArr: [[TabBarKeys: String]] {
        var arr = [[TabBarKeys: String]]()
        let items = ["Collect", "Throw", "Mine"]
        items.forEach { itemString in
            let item = TabBarItemType(rawValue: itemString) ?? .Mine
            let dic: [TabBarKeys: String] = [
                .kTabBarVCType: item.style.vc,
                .kTabBarTitle: item.title,
                .kTabBarImage: item.style.imgNormal,
                .kTabBarImageSelect: item.style.imgSelect
            ]
            arr.append(dic)
            tabBarItems.append(item)
        }
        return arr
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBar = self.tabBar as? ESTabBar {
            tabBar.backgroundColor = .lightWhiteDark27
        }
        self.bk_setSubStatusBars(for: viewControllers)
        self.delegate = self
        self.setupTabBar()
        
    }
    
}

// MARK: - Override
extension BaseTabBarVC {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        BKFeedbackUtil.bk_addImpact(.light)
    }
    
}

// MARK: - Public
extension BaseTabBarVC {
    
    func selectItem(by item: TabBarItemType) {
        let index = tabBarItems.firstIndex(of: item) ?? 2
        selectedIndex = index
    }
    
}

// MARK: - Private
extension BaseTabBarVC {
    
    private func setupTabBar() {
        var vcArr = [BaseNaviCtrl]()
        for (i, item) in tabBarItemArr.enumerated() {
            // 字符串转换类名
            guard let clsName = item[.kTabBarVCType],
                let vc = self.bk_convertController(clsName) else { return }
            vc.tabBarItem = ESTabBarItem(BaseTabBarItemView(),
                                         title: item[.kTabBarTitle],
                                         image: UIImage(named: item[.kTabBarImage]!),
                                         selectedImage: UIImage(named: item[.kTabBarImageSelect]!),
                                         tag: i)
            let navi = BaseNaviCtrl(rootViewController: vc)
            vcArr.append(navi)
        }
        
        viewControllers = vcArr
        self.selectItem(by: .Mine)
        
        if #available(iOS 15.0, *) {
            let bar = UITabBarAppearance()
            bar.backgroundColor = .lightWhiteDark27
            bar.shadowImage = UIImage.bk_fill(.clear)
            tabBar.scrollEdgeAppearance = bar
            tabBar.standardAppearance = bar
        } else {
            tabBar.backgroundImage = UIImage.bk_fill(.clear)
            tabBar.shadowImage = UIImage.bk_fill(.clear)
        }
        
    }
    
}

// MARK: - UITabBarControllerDelegate代理
extension BaseTabBarVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        bk_showStatusBar(for: viewController)
    }
    
}
