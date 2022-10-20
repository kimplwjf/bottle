//
//  AppDelegate.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/14.
//

import UIKit

let App = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // 当前界面支持的方向（默认情况下只能竖屏，不能横屏显示）
    var interfaceOrientations: UIInterfaceOrientationMask = .portrait {
        didSet {
            if interfaceOrientations == [.portrait, .allButUpsideDown] {
                if #available(iOS 16.0, *) {
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            } else {
                if #available(iOS 16.0, *) {
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    // MARK: - Launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .lightWhiteDark27
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = BKDarkModeUtil.mode.style
        }
        
        // 启动配置
        DelayStartupManager.startupEventsOnAppDidFinishLaunching(application, launchOptions)
        
        if XMApp.logined() {
            self.startEnterApp()
        } else {
            self.startLogin()
        }
        
        UIApplication.runOnce
        self.setNaviBarAppearence()
        return true
        
    }
    
}

// MARK: - 登录
extension AppDelegate {
    
    /// 开始登录
    func startLogin() {
        self.showLoginVC()
    }
    
    /// 退出登录
    func startLogout() {
        XMApp.clearAllUserCache()
        self.showLoginVC()
    }
    
    /// 进入首页
    func startEnterApp() {
        let tabBar = BaseTabBarVC()
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()
    }
    
    func showLoginVC() {
        let vc = BOLoginVC()
        let navi = BaseNaviCtrl(rootViewController: vc)
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
    }
    
}

// MARK: - 导航栏配置
extension AppDelegate {
    
    func setNaviBarAppearence() {
        WRNavigationBar.defaultNaviBarBarTintColor = .lightWhiteDark27
        WRNavigationBar.defaultNaviBarTintColor = .lightBlack51DarkLight230
        WRNavigationBar.defaultNaviBarTitleColor = .lightBlack51DarkLight230
        WRNavigationBar.defaultNaviBarTitleFont = .systemFont(ofSize: 17, weight: .medium)
        WRNavigationBar.defaultStatusBarStyle = .default
        WRNavigationBar.defaultShadowImageHidden = true
    }
    
}

// MARK: - 设备界面朝向
extension AppDelegate {
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), keyWindow is BKPopupManagerWindow {
            return keyWindow.rootViewController?.supportedInterfaceOrientations ?? .portrait
        } else {
            return interfaceOrientations
        }
    }
    
}

// MARK: - 进入App处理url
extension AppDelegate {
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return self.handleOpenURL(url)
    }
    
    // iOS9.0以上使用以下方法
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.handleOpenURL(url)
    }
    
    // iOS9.0及以下使用以下方法
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.handleOpenURL(url)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
    
    private func handleOpenURL(_ url: URL) -> Bool {
        return true
    }
    
}

// MARK: Lifecycle
extension AppDelegate {
    
    // 应用程序将要变成不活跃状态／失去焦点
    func applicationWillResignActive(_ application: UIApplication) {
        PPP("app程序将要变成不活跃状态失去焦点")
    }
    
    // 应用程序进入后台
    func applicationDidEnterBackground(_ application: UIApplication) {
        PPP("app进入后台")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // 应用程序将要进入前台
    func applicationWillEnterForeground(_ application: UIApplication) {
        PPP("app将要进入前台")
        application.applicationIconBadgeNumber = 0
    }
    
    // 应用程序变成活跃状态
    func applicationDidBecomeActive(_ application: UIApplication) {
        PPP("app程序活跃获得焦点")
    }
    
    /**
     * 应用程序将要终止
     * 1、应用在前台，用户滑动kill应用，执行该方法
     * 2、应用在后台，用户滑动kill应用，执行该方法
     */
    func applicationWillTerminate(_ application: UIApplication) {
        PPP("app程序将要终止")
    }
    
    // 应用程序内存分配警告
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
    }
    
}
