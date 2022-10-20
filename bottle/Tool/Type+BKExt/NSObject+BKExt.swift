//
//  NSObject+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation

// MARK: - NSObject扩展
extension NSObject {
    
    /**
    运行时对应的key值
    */
    private struct NSObjectAssociatedKeys {
        static var kPath: String = "kPath"
        static var kFlag: String = "kFlag"
    }
    
    /// 返回类名字符串
    static var className: String {
        return String(describing: self)
    }
    
    /// 返回类名字符串
    var className: String {
        return String(describing: type(of: self))
    }
    
    public var bk_path: String? {
        get { return objc_getAssociatedObject(self, &NSObjectAssociatedKeys.kPath) as? String }
        set { objc_setAssociatedObject(self, &NSObjectAssociatedKeys.kPath, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public var bk_flag: Int? {
        get { return objc_getAssociatedObject(self, &NSObjectAssociatedKeys.kFlag) as? Int }
        set { objc_setAssociatedObject(self, &NSObjectAssociatedKeys.kFlag, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
}
