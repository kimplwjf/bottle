//
//  WRNavigationBar.swift
//  WRNavigationBar_swift
//
//  Created by wangrui on 2017/4/19.
//  Copyright © 2017年 wangrui. All rights reserved.
//
//  Github地址：https://github.com/wangrui460/WRNavigationBar_swift

import UIKit
import ObjectiveC

// MARK: - UINavigationBar
extension UINavigationBar: WRAwakeProtocol {
    
    fileprivate struct AssociatedKeys {
        static var backgroundView: UIView = UIView()
        static var backgroundImageView: UIImageView = UIImageView()
    }
    
    fileprivate var backgroundView: UIView? {
        get {
            guard let bgView = objc_getAssociatedObject(self, &AssociatedKeys.backgroundView) as? UIView else {
                return nil
            }
            return bgView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var backgroundImageView: UIImageView? {
        get {
            guard let bgImageView = objc_getAssociatedObject(self, &AssociatedKeys.backgroundImageView) as? UIImageView else {
                return nil
            }
            return bgImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundImageView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // set navigationBar backgroundImage
    fileprivate func wr_setBackgroundImage(image: UIImage) {
        backgroundView?.removeFromSuperview()
        backgroundView = nil
        if backgroundImageView == nil {
            // add a image(nil color) to _UIBarBackground make it clear
            setBackgroundImage(UIImage(), for: .default)
            backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kNavigationBarHeight))
            backgroundImageView?.autoresizingMask = .flexibleWidth
            // _UIBarBackground is first subView for navigationBar
            subviews.first?.insertSubview(backgroundImageView ?? UIImageView(), at: 0)
        }
        backgroundImageView?.image = image
    }
    
    // set navigationBar barTintColor
    fileprivate func wr_setBackgroundColor(color: UIColor) {
        backgroundImageView?.removeFromSuperview()
        backgroundImageView = nil
        if backgroundView == nil {
            // add a image(nil color) to _UIBarBackground make it clear
            setBackgroundImage(UIImage(), for: .default)
            backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kNavigationBarHeight))
            backgroundView?.autoresizingMask = .flexibleWidth
            // _UIBarBackground is first subView for navigationBar
            subviews.first?.insertSubview(backgroundView ?? UIView(), at: 0)
        }
        backgroundView?.backgroundColor = color
    }
    
    // set _UIBarBackground alpha (_UIBarBackground subviews alpha <= _UIBarBackground alpha)
    fileprivate func wr_setBackgroundAlpha(alpha: CGFloat) {
        if let barBackgroundView = subviews.first {
            if #available(iOS 11.0, *) {
                // sometimes we can't change _UIBarBackground alpha
                for view in barBackgroundView.subviews {
                    view.alpha = alpha
                }
            } else {
                barBackgroundView.alpha = alpha
            }
        }
    }
    
    // 设置导航栏所有BarButtonItem的透明度
    func wr_setBarButtonItemsAlpha(alpha: CGFloat, hasSystemBackIndicator: Bool) {
        for view in subviews {
            if hasSystemBackIndicator {
                // _UIBarBackground/_UINavigationBarBackground对应的view是系统导航栏，不需要改变其透明度
                if let _UIBarBackgroundClass = NSClassFromString("_UIBarBackground") {
                    if !view.isKind(of: _UIBarBackgroundClass) {
                        view.alpha = alpha
                    }
                }
                
                if let _UINavigationBarBackground = NSClassFromString("_UINavigationBarBackground") {
                    if !view.isKind(of: _UINavigationBarBackground) {
                        view.alpha = alpha
                    }
                }
            } else {
                // 这里如果不做判断的话，会显示 backIndicatorImage(系统返回按钮)
                if let _UINavigationBarBackIndicatorViewClass = NSClassFromString("_UINavigationBarBackIndicatorView"), !view.isKind(of: _UINavigationBarBackIndicatorViewClass) {
                    if let _UIBarBackgroundClass = NSClassFromString("_UIBarBackground") {
                        if !view.isKind(of: _UIBarBackgroundClass) {
                            view.alpha = alpha
                        }
                    }
                    
                    if let _UINavigationBarBackground = NSClassFromString("_UINavigationBarBackground") {
                        if !view.isKind(of: _UINavigationBarBackground) {
                            view.alpha = alpha
                        }
                    }
                }
            }
        }
    }
    
    /// 设置导航栏在垂直方向上平移多少距离
    func wr_setTranslationY(translationY: CGFloat) {
        transform = CGAffineTransform(translationX: 0, y: translationY)
    }
    
    func wr_getTranslationY() -> CGFloat {
        return transform.ty
    }
    
    // call swizzling methods active 主动调用交换方法
    private static let onceToken = UUID().uuidString
    public static func wrAwake() {
        DispatchQueue.once(token: onceToken) {
            let needSwizzleSelectorArr = [
                #selector(setter: titleTextAttributes)
            ]
            
            for selector in needSwizzleSelectorArr {
                let str = ("wr_" + selector.description)
                if let originalMethod = class_getInstanceMethod(self, selector),
                   let swizzledMethod = class_getInstanceMethod(self, Selector(str)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    
    @objc func wr_setTitleTextAttributes(_ newTitleTextAttributes: [String: Any]?) {
        guard var attributes = newTitleTextAttributes else { return }
        
        guard let originTitleTextAttributes = titleTextAttributes else {
            wr_setTitleTextAttributes(attributes)
            return
        }
        
        var titleColor: UIColor?
        var titleFont: UIFont?
        for attribute in originTitleTextAttributes {
            if attribute.key == .foregroundColor {
                titleColor = attribute.value as? UIColor
            }
            if attribute.key == .font {
                titleFont = attribute.value as? UIFont
            }
        }
        
        if let originTitleColor = titleColor, attributes[NSAttributedString.Key.foregroundColor.rawValue] == nil {
            attributes.updateValue(originTitleColor, forKey: NSAttributedString.Key.foregroundColor.rawValue)
        }
        
        if let originTitleFont = titleFont, attributes[NSAttributedString.Key.font.rawValue] == nil {
            attributes.updateValue(originTitleFont, forKey: NSAttributedString.Key.font.rawValue)
        }
        
        wr_setTitleTextAttributes(attributes)
    }
    
}

// MARK: - UINavigationController
extension UINavigationController: WRFatherAwakeProtocol {
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.statusBarStyle ?? WRNavigationBar.defaultStatusBarStyle
    }
    
    fileprivate func setNeedsNavigationBarUpdate(backgroundImage: UIImage) {
        navigationBar.wr_setBackgroundImage(image: backgroundImage)
    }
    
    fileprivate func setNeedsNavigationBarUpdate(barTintColor: UIColor) {
        navigationBar.wr_setBackgroundColor(color: barTintColor)
    }
    
    fileprivate func setNeedsNavigationBarUpdate(barBackgroundAlpha: CGFloat) {
        navigationBar.wr_setBackgroundAlpha(alpha: barBackgroundAlpha)
    }
    
    fileprivate func setNeedsNavigationBarUpdate(tintColor: UIColor) {
        navigationBar.tintColor = tintColor
    }
    
    fileprivate func setNeedsNavigationBarUpdate(hideShadowImage: Bool) {
        navigationBar.shadowImage = hideShadowImage ? UIImage() : nil
    }
    
    fileprivate func setNeedsNavigationBarUpdate(titleColor: UIColor) {
        guard let titleTextAttributes = navigationBar.titleTextAttributes else {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
            return
        }
        
        var newTitleTextAttributes = titleTextAttributes
        newTitleTextAttributes.updateValue(titleColor, forKey: NSAttributedString.Key.foregroundColor)
        navigationBar.titleTextAttributes = newTitleTextAttributes
    }
    
    fileprivate func setNeedsNavigationBarUpdate(titleFont: UIFont) {
        guard let titleTextAttributes = navigationBar.titleTextAttributes else {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font: titleFont]
            return
        }
        
        var newTitleTextAttributes = titleTextAttributes
        newTitleTextAttributes.updateValue(titleFont, forKey: NSAttributedString.Key.font)
        navigationBar.titleTextAttributes = newTitleTextAttributes
    }
    
    fileprivate func updateNavigationBar(fromVC: UIViewController?, toVC: UIViewController?, progress: CGFloat) {
        // change naviBarBarTintColor
        let fromBarTintColor = fromVC?.naviBarBarTintColor ?? WRNavigationBar.defaultNaviBarBarTintColor
        let toBarTintColor   = toVC?.naviBarBarTintColor ?? WRNavigationBar.defaultNaviBarBarTintColor
        let newBarTintColor  = WRNavigationBar.middleColor(fromColor: fromBarTintColor, toColor: toBarTintColor, percent: progress)
        setNeedsNavigationBarUpdate(barTintColor: newBarTintColor)
        
        // change naviBarTintColor
        let fromTintColor = fromVC?.naviBarTintColor ?? WRNavigationBar.defaultNaviBarTintColor
        let toTintColor = toVC?.naviBarTintColor ?? WRNavigationBar.defaultNaviBarTintColor
        let newTintColor = WRNavigationBar.middleColor(fromColor: fromTintColor, toColor: toTintColor, percent: progress)
        setNeedsNavigationBarUpdate(tintColor: newTintColor)
        
        // change navBar _UIBarBackground alpha
        let fromBarBackgroundAlpha = fromVC?.naviBarBackgroundAlpha ?? WRNavigationBar.defaultBackgroundAlpha
        let toBarBackgroundAlpha = toVC?.naviBarBackgroundAlpha ?? WRNavigationBar.defaultBackgroundAlpha
        let newBarBackgroundAlpha = WRNavigationBar.middleAlpha(fromAlpha: fromBarBackgroundAlpha, toAlpha: toBarBackgroundAlpha, percent: progress)
        setNeedsNavigationBarUpdate(barBackgroundAlpha: newBarBackgroundAlpha)
    }
    
    // call swizzling methods active 主动调用交换方法
    private static let onceToken = UUID().uuidString
    public static func fatherAwake() {
        DispatchQueue.once(token: onceToken) {
            let needSwizzleSelectorArr = [
                NSSelectorFromString("_updateInteractiveTransition:"),
                #selector(popViewController(animated:)),
                #selector(popToViewController(_:animated:)),
                #selector(popToRootViewController(animated:)),
                #selector(pushViewController(_:animated:))
            ]
            
            for selector in needSwizzleSelectorArr {
                // _updateInteractiveTransition:  =>  wr_updateInteractiveTransition:
                let str = ("wr_" + selector.description).replacingOccurrences(of: "__", with: "_")
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(str)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    
    struct popProperties {
        fileprivate static let popDuration = 0.13
        fileprivate static var displayCount = 0
        fileprivate static var popProgress: CGFloat {
            let all: CGFloat = CGFloat(60.0 * popDuration)
            let current = min(all, CGFloat(displayCount))
            return current / all
        }
    }
    
    // swizzling system method: popViewController
    @objc func wr_popViewControllerAnimated(_ animated: Bool) -> UIViewController? {
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(popNeedDisplay))
        displayLink?.add(to: .main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            popProperties.displayCount = 0
        }
        CATransaction.setAnimationDuration(popProperties.popDuration)
        CATransaction.begin()
        let vc = wr_popViewControllerAnimated(animated)
        CATransaction.commit()
        return vc
    }
    
    // swizzling system method: popToViewController
    @objc func wr_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        setNeedsNavigationBarUpdate(titleColor: viewController.naviBarTitleColor)
        setNeedsNavigationBarUpdate(titleFont: viewController.naviBarTitleFont)
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(popNeedDisplay))
        // UITrackingRunLoopMode: 界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
        // NSRunLoopCommonModes contains kCFRunLoopDefaultMode and UITrackingRunLoopMode
        displayLink?.add(to: .main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            popProperties.displayCount = 0
        }
        CATransaction.setAnimationDuration(popProperties.popDuration)
        CATransaction.begin()
        let vcs = wr_popToViewController(viewController, animated: animated)
        CATransaction.commit()
        return vcs
    }
    
    // swizzling system method: popToRootViewController
    @objc func wr_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(popNeedDisplay))
        displayLink?.add(to: .main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            popProperties.displayCount = 0
        }
        CATransaction.setAnimationDuration(popProperties.popDuration)
        CATransaction.begin()
        let vcs = wr_popToRootViewControllerAnimated(animated)
        CATransaction.commit()
        return vcs
    }
    
    // change navigationBar barTintColor smooth before pop to current VC finished
    @objc fileprivate func popNeedDisplay() {
        guard let topVC = topViewController, let coor = topVC.transitionCoordinator else { return }
        
        popProperties.displayCount += 1
        let popProgress = popProperties.popProgress
        // print("第\(popProperties.displayCount)次pop的进度：\(popProgress)")
        let fromVC = coor.viewController(forKey: .from)
        let toVC = coor.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: popProgress)
    }
    
    struct pushProperties {
        fileprivate static let pushDuration = 0.13
        fileprivate static var displayCount = 0
        fileprivate static var pushProgress: CGFloat {
            let all:CGFloat = CGFloat(60.0 * pushDuration)
            let current = min(all, CGFloat(displayCount))
            return current / all
        }
    }
    
    // swizzling system method: pushViewController
    @objc func wr_pushViewController(_ viewController: UIViewController, animated: Bool) {
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(pushNeedDisplay))
        displayLink?.add(to: .main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            pushProperties.displayCount = 0
            viewController.pushToCurrentVCFinished = true
        }
        CATransaction.setAnimationDuration(pushProperties.pushDuration)
        CATransaction.begin()
        wr_pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    // change navigationBar barTintColor smooth before push to current VC finished or before pop to current VC finished
    @objc fileprivate func pushNeedDisplay() {
        guard let topVC = topViewController, let coor = topVC.transitionCoordinator else { return }
        
        pushProperties.displayCount += 1
        let pushProgress = pushProperties.pushProgress
        // print("第\(pushProperties.displayCount)次push的进度：\(pushProgress)")
        let fromVC = coor.viewController(forKey: .from)
        let toVC = coor.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: pushProgress)
    }
    
}

// MARK: - UINavigationBarDelegate代理
extension UINavigationController: UINavigationBarDelegate {
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let topVC = topViewController, let coor = topVC.transitionCoordinator, coor.initiallyInteractive {
            if #available(iOS 10.0, *) {
                coor.notifyWhenInteractionChanges({ (context) in
                    self.dealInteractionChanges(context)
                })
            } else {
                coor.notifyWhenInteractionEnds({ (context) in
                    self.dealInteractionChanges(context)
                })
            }
            return true
        }
        
        let itemCount = navigationBar.items?.count ?? 0
        let n = viewControllers.count >= itemCount ? 2 : 1
        let popToVC = viewControllers[viewControllers.count - n]
        
        popToViewController(popToVC, animated: true)
        return true
    }
    
    // deal the gesture of return break off
    private func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        let animations: (UITransitionContextViewControllerKey) -> () = {
            let curColor = context.viewController(forKey: $0)?.naviBarBarTintColor ?? WRNavigationBar.defaultNaviBarBarTintColor
            let curAlpha = context.viewController(forKey: $0)?.naviBarBackgroundAlpha ?? WRNavigationBar.defaultBackgroundAlpha
            
            self.setNeedsNavigationBarUpdate(barTintColor: curColor)
            self.setNeedsNavigationBarUpdate(barBackgroundAlpha: curAlpha)
        }
        
        // after that, cancel the gesture of return
        if context.isCancelled {
            let cancelDuration: TimeInterval = context.transitionDuration * Double(context.percentComplete)
            UIView.animate(withDuration: cancelDuration) {
                animations(.from)
            }
        } else {
            // after that, finish the gesture of return
            let finishDuration: TimeInterval = context.transitionDuration * Double(1 - context.percentComplete)
            UIView.animate(withDuration: finishDuration) {
                animations(.to)
            }
        }
    }
    
    // swizzling system method: _updateInteractiveTransition
    @objc func wr_updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard let topVC = topViewController, let coor = topVC.transitionCoordinator else {
            wr_updateInteractiveTransition(percentComplete)
            return
        }
        
        let fromVC = coor.viewController(forKey: .from)
        let toVC = coor.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: percentComplete)
        
        wr_updateInteractiveTransition(percentComplete)
    }
    
}

// MARK: - UIViewController
extension UIViewController: WRAwakeProtocol {
    
    fileprivate struct AssociatedKeys {
        static var pushToCurrentVCFinished: Bool = false
        static var pushToNextVCFinished: Bool = false
        
        static var naviBarBackgroundImage: UIImage = UIImage()
        /// 导航栏默认背景颜色
        static var naviBarBarTintColor: UIColor = WRNavigationBar.defaultNaviBarBarTintColor
        /// 导航栏默认透明度
        static var naviBarBackgroundAlpha: CGFloat = WRNavigationBar.defaultBackgroundAlpha
        /// 导航栏所有按钮的默认颜色
        static var naviBarTintColor: UIColor = WRNavigationBar.defaultNaviBarTintColor
        /// 导航栏标题默认颜色
        static var naviBarTitleColor: UIColor = WRNavigationBar.defaultNaviBarTitleColor
        /// 导航栏标题默认字体
        static var naviBarTitleFont: UIFont = WRNavigationBar.defaultNaviBarTitleFont
        /// 状态栏样式
        static var statusBarStyle: UIStatusBarStyle = WRNavigationBar.defaultStatusBarStyle
        /// 导航栏底部分割线是否隐藏
        static var naviBarShadowImageHidden: Bool = WRNavigationBar.defaultShadowImageHidden
        
        static var customNaviBar: UINavigationBar = UINavigationBar()
    }
    
    // navigationBar barTintColor can not change by currentVC before fromVC push to currentVC finished
    fileprivate var pushToCurrentVCFinished: Bool {
        get {
            guard let isFinished = objc_getAssociatedObject(self, &AssociatedKeys.pushToCurrentVCFinished) as? Bool else {
                return false
            }
            return isFinished
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pushToCurrentVCFinished, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    // navigationBar barTintColor can not change by currentVC when currentVC push to nextVC finished
    fileprivate var pushToNextVCFinished: Bool {
        get {
            guard let isFinished = objc_getAssociatedObject(self, &AssociatedKeys.pushToNextVCFinished) as? Bool else {
                return false
            }
            return isFinished
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pushToNextVCFinished, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 设置导航栏背景图片
    var naviBarBackgroundImage: UIImage? {
        get {
            guard let bgImage = objc_getAssociatedObject(self, &AssociatedKeys.naviBarBackgroundImage) as? UIImage else {
                return WRNavigationBar.defaultNaviBarBackgroundImage
            }
            return bgImage
        }
        set {
            if customNaviBar.isKind(of: UINavigationBar.self) {
                let navBar = customNaviBar as! UINavigationBar
                navBar.wr_setBackgroundImage(image: newValue!)
            } else {
                objc_setAssociatedObject(self, &AssociatedKeys.naviBarBackgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /// 设置导航栏背景颜色
    var naviBarBarTintColor: UIColor {
        get {
            guard let barTintColor = objc_getAssociatedObject(self, &AssociatedKeys.naviBarBarTintColor) as? UIColor else {
                return WRNavigationBar.defaultNaviBarBarTintColor
            }
            return barTintColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.naviBarBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if customNaviBar.isKind(of: UINavigationBar.self) {
                let navBar = customNaviBar as! UINavigationBar
                navBar.wr_setBackgroundColor(color: newValue)
            } else {
                if canUpdatenaviBarBarTintColorOrBackgroundAlpha {
                    navigationController?.setNeedsNavigationBarUpdate(barTintColor: newValue)
                }
            }
        }
    }

    /// 设置导航栏透明度
    var naviBarBackgroundAlpha: CGFloat {
        get {
            guard let barBackgroundAlpha = objc_getAssociatedObject(self, &AssociatedKeys.naviBarBackgroundAlpha) as? CGFloat else {
                return WRNavigationBar.defaultBackgroundAlpha
            }
            return barBackgroundAlpha
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.naviBarBackgroundAlpha, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if customNaviBar.isKind(of: UINavigationBar.self) {
                let navBar = customNaviBar as! UINavigationBar
                navBar.wr_setBackgroundAlpha(alpha: newValue)
            } else {
                if canUpdatenaviBarBarTintColorOrBackgroundAlpha {
                    navigationController?.setNeedsNavigationBarUpdate(barBackgroundAlpha: newValue)
                }
            }
        }
    }
    
    private var canUpdatenaviBarBarTintColorOrBackgroundAlpha: Bool {
        get {
            let isRootViewController = self.navigationController?.viewControllers.first == self
            if (pushToCurrentVCFinished || isRootViewController) && !pushToNextVCFinished {
                return true
            } else {
                return false
            }
        }
    }
    
    /// 设置导航栏所有按钮的颜色
    var naviBarTintColor: UIColor {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &AssociatedKeys.naviBarTintColor) as? UIColor else {
                return WRNavigationBar.defaultNaviBarTintColor
            }
            return tintColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.naviBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if customNaviBar.isKind(of: UINavigationBar.self) {
                let navBar = customNaviBar as! UINavigationBar
                navBar.tintColor = newValue
            } else {
                if !pushToNextVCFinished {
                    navigationController?.setNeedsNavigationBarUpdate(tintColor: newValue)
                }
            }
        }
    }
    
    /// 设置导航栏标题颜色
    var naviBarTitleColor: UIColor {
        get {
            guard let titleColor = objc_getAssociatedObject(self, &AssociatedKeys.naviBarTitleColor) as? UIColor else {
                return WRNavigationBar.defaultNaviBarTitleColor
            }
            return titleColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.naviBarTitleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if customNaviBar.isKind(of: UINavigationBar.self) {
                let navBar = customNaviBar as! UINavigationBar
                navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: newValue]
            } else {
                if !pushToNextVCFinished {
                    navigationController?.setNeedsNavigationBarUpdate(titleColor: newValue)
                }
            }
        }
    }
    
    /// 设置导航栏标题字体
    var naviBarTitleFont: UIFont {
        get {
            guard let titleFont = objc_getAssociatedObject(self, &AssociatedKeys.naviBarTitleFont) as? UIFont else {
                return WRNavigationBar.defaultNaviBarTitleFont
            }
            return titleFont
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.naviBarTitleFont, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if customNaviBar.isKind(of: UINavigationBar.self) {
                let navBar = customNaviBar as! UINavigationBar
                navBar.titleTextAttributes = [NSAttributedString.Key.font: newValue]
            } else {
                if !pushToNextVCFinished {
                    navigationController?.setNeedsNavigationBarUpdate(titleFont: newValue)
                }
            }
        }
    }

    // statusBarStyle
    var statusBarStyle: UIStatusBarStyle {
        get {
            guard let style = objc_getAssociatedObject(self, &AssociatedKeys.statusBarStyle) as? UIStatusBarStyle else {
                return WRNavigationBar.defaultStatusBarStyle
            }
            return style
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.statusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // if you want shadowImage hidden,you can via hideShadowImage = true
    var naviBarShadowImageHidden: Bool {
        get {
            guard let isHidden = objc_getAssociatedObject(self, &AssociatedKeys.naviBarShadowImageHidden) as? Bool else {
                return WRNavigationBar.defaultShadowImageHidden
            }
            return isHidden
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.naviBarShadowImageHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
            navigationController?.setNeedsNavigationBarUpdate(hideShadowImage: newValue)
        }
    }
    
    // custom navigationBar
    var customNaviBar: UIView {
        get {
            guard let naviBar = objc_getAssociatedObject(self, &AssociatedKeys.customNaviBar) as? UINavigationBar else {
                return UIView()
            }
            return naviBar
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customNaviBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // swizzling two system methods: viewWillAppear(_:) and viewWillDisappear(_:)
    private static let onceToken = UUID().uuidString
    public static func wrAwake() {
        DispatchQueue.once(token: onceToken) {
            let needSwizzleSelectors = [
                #selector(viewWillAppear(_:)),
                #selector(viewWillDisappear(_:)),
                #selector(viewDidAppear(_:))
            ]
            
            for selector in needSwizzleSelectors {
                let newSelectorStr = "wr_" + selector.description
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(newSelectorStr)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    
    @objc func wr_viewWillAppear(_ animated: Bool) {
        if canUpdateNavigationBar() {
            pushToNextVCFinished = false
            navigationController?.setNeedsNavigationBarUpdate(tintColor: naviBarTintColor)
            navigationController?.setNeedsNavigationBarUpdate(titleColor: naviBarTitleColor)
            navigationController?.setNeedsNavigationBarUpdate(titleFont: naviBarTitleFont)
        }
        wr_viewWillAppear(animated)
    }
    
    @objc func wr_viewWillDisappear(_ animated: Bool) {
        if canUpdateNavigationBar() {
            pushToNextVCFinished = true
        }
        wr_viewWillDisappear(animated)
    }
    
    @objc func wr_viewDidAppear(_ animated: Bool) {
        if self.navigationController?.viewControllers.first != self {
            self.pushToCurrentVCFinished = true
        }
        if canUpdateNavigationBar() {
            if let navBarBgImage = naviBarBackgroundImage {
                navigationController?.setNeedsNavigationBarUpdate(backgroundImage: navBarBgImage)
            } else {
                navigationController?.setNeedsNavigationBarUpdate(barTintColor: naviBarBarTintColor)
            }
            navigationController?.setNeedsNavigationBarUpdate(barBackgroundAlpha: naviBarBackgroundAlpha)
            navigationController?.setNeedsNavigationBarUpdate(tintColor: naviBarTintColor)
            navigationController?.setNeedsNavigationBarUpdate(titleColor: naviBarTitleColor)
            navigationController?.setNeedsNavigationBarUpdate(titleFont: naviBarTitleFont)
            navigationController?.setNeedsNavigationBarUpdate(hideShadowImage: naviBarShadowImageHidden)
        }
        wr_viewDidAppear(animated)
    }
    
    func canUpdateNavigationBar() -> Bool {
        let viewFrame = view.frame
        let maxFrame = UIScreen.main.bounds
        let middleFrame = CGRect(x: 0, y: kNavigationBarHeight, width: kScreenWidth, height: kScreenHeight-kNavigationBarHeight)
        let minFrame = CGRect(x: 0, y: kNavigationBarHeight, width: kScreenWidth, height: kScreenHeight-kNavigationBarHeight-kTabBarHeight)
        // 蝙蝠🦇
        let isBat = viewFrame.equalTo(maxFrame) || viewFrame.equalTo(middleFrame) || viewFrame.equalTo(minFrame)
        if self.navigationController != nil && isBat {
            return true
        } else {
            return false
        }
    }
    
}

// MARK: - WRNavigationBar
class WRNavigationBar {
    
    fileprivate struct AssociatedKeys {
        static var defNaviBarBackgroundImage: UIImage = UIImage()
        /// 导航栏默认背景颜色
        static var defNaviBarBarTintColor: UIColor = .lightWhiteDark27
        /// 导航栏所有按钮的默认颜色
        static var defNaviBarTintColor: UIColor = .lightBlack51DarkLight230
        /// 导航栏标题默认颜色
        static var defNaviBarTitleColor: UIColor = .lightBlack51DarkLight230
        /// 导航栏标题默认字体
        static var defNaviBarTitleFont: UIFont = .systemFont(ofSize: 17, weight: .medium)
        /// 状态栏样式
        static var defStatusBarStyle: UIStatusBarStyle = .default
        /// 导航栏底部分割线是否隐藏
        static var defShadowImageHidden: Bool = true
    }
    
    class var defaultNaviBarBarTintColor: UIColor {
        get {
            guard let def = objc_getAssociatedObject(self, &AssociatedKeys.defNaviBarBarTintColor) as? UIColor else {
                return AssociatedKeys.defNaviBarBarTintColor
            }
            return def
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defNaviBarBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class var defaultNaviBarBackgroundImage: UIImage? {
        get {
            guard let def = objc_getAssociatedObject(self, &AssociatedKeys.defNaviBarBackgroundImage) as? UIImage else {
                return nil
            }
            return def
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defNaviBarBackgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class var defaultNaviBarTintColor: UIColor {
        get {
            guard let def = objc_getAssociatedObject(self, &AssociatedKeys.defNaviBarTintColor) as? UIColor else {
                return AssociatedKeys.defNaviBarTintColor
            }
            return def
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defNaviBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class var defaultNaviBarTitleColor: UIColor {
        get {
            guard let def = objc_getAssociatedObject(self, &AssociatedKeys.defNaviBarTitleColor) as? UIColor else {
                return AssociatedKeys.defNaviBarTitleColor
            }
            return def
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defNaviBarTitleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class var defaultNaviBarTitleFont: UIFont {
        get {
            guard let def = objc_getAssociatedObject(self, &AssociatedKeys.defNaviBarTitleFont) as? UIFont else {
                return AssociatedKeys.defNaviBarTitleFont
            }
            return def
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defNaviBarTitleFont, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class var defaultStatusBarStyle: UIStatusBarStyle {
        get {
            guard let def = objc_getAssociatedObject(self, &AssociatedKeys.defStatusBarStyle) as? UIStatusBarStyle else {
                return .default
            }
            return def
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defStatusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class var defaultShadowImageHidden: Bool {
        get {
            guard let def = objc_getAssociatedObject(self, &AssociatedKeys.defShadowImageHidden) as? Bool else {
                return false
            }
            return def
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defShadowImageHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    class var defaultBackgroundAlpha: CGFloat {
        return 1.0
    }
    
    // Calculate the middle Color with translation percent
    class fileprivate func middleColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        // get current color RGBA
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        // get to color RGBA
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        // calculate middle color RGBA
        let newRed = fromRed + (toRed - fromRed) * percent
        let newGreen = fromGreen + (toGreen - fromGreen) * percent
        let newBlue = fromBlue + (toBlue - fromBlue) * percent
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
    
    // Calculate the middle alpha
    class fileprivate func middleAlpha(fromAlpha: CGFloat, toAlpha: CGFloat, percent: CGFloat) -> CGFloat {
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return newAlpha
    }
    
}

public protocol WRAwakeProtocol: AnyObject {
    static func wrAwake()
}

public protocol WRFatherAwakeProtocol: AnyObject {
    static func fatherAwake()
}

class NothingToSeeHere {
    
    static func awake() {
        UINavigationBar.wrAwake()
        UIViewController.wrAwake()
        UINavigationController.fatherAwake()
    }
    
}
