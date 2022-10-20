//
//  Hook.swift
//  dysd
//
//  Created by Penlon Kim on 2022/8/10.
//  Copyright © 2022 Kim. All rights reserved.
//

import Foundation

extension UIViewController {
    
    private static let onceToken = UUID().uuidString
    
    static func hook() {
        // 确保不是子类
        if self !== UIViewController.self {
            return
        }
        DispatchQueue.once(token: onceToken) {
            let needSwizzleSelectors = [
                #selector(viewDidAppear(_:)),
                #selector(viewDidDisappear(_:))
            ]
            
            for selector in needSwizzleSelectors {
                let newSelectorStr = "hook_" + selector.description
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(newSelectorStr)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    
    // MARK: - Method Swizzling viewDidAppear
    @objc func hook_viewDidAppear(_ animated: Bool) {
        if checkCustomClass(for: self.classForCoder) {
            let classString = NSStringFromClass(type(of: self))
            guard let className = classString.split(separator: ".").last else { return }
//            if !BKLogger.filterClassPrefix(with: String(className)) {
//                Log.verbose("\(String(className))出现")
//            }
        }
        hook_viewDidAppear(animated)
    }
    
    // MARK: - Method Swizzling viewDidDisappear
    @objc func hook_viewDidDisappear(_ animated: Bool) {
        if checkCustomClass(for: self.classForCoder) {
            let classString = NSStringFromClass(type(of: self))
            guard let className = classString.split(separator: ".").last else { return }
//            if !BKLogger.filterClassPrefix(with: String(className)) {
//                Log.verbose("\(String(className))消失")
//            }
        }
        hook_viewDidDisappear(animated)
    }
    
}
