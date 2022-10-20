//
//  XMApp.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/27.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit
import Foundation
import HandyJSON

// MARK: - typealias
typealias BKResultHandler = (_ ok: Bool, _ obj: Any?, _ msg: String?, _ code: NetWorkStatusCode) -> Void
typealias BKAttributedString = (_ value: Any, _ des: String) -> NSMutableAttributedString

// MARK: - XMApp
class XMApp: NSObject {
    
    enum Keys {
        static let UserKey = "UserKey"
    }
    
    /// 单例
    static let `default` = XMApp()
    
    /// 登录的用户信息model
    /// 1. 赋值不为空时保存到UserDefaults, 为空时, 从 UserDefaults 移除
    /// 2. 某个属性修改后, 需要重新赋值, 才能将属性的新值保存到 UserDefaults
    var userModel: DBUserModel? {
        get {
            let def = UserDefaults.standard
            guard let data = def.object(forKey: Keys.UserKey) else { return nil }
            
            var model: DBUserModel?
            do {
                model = try JSONDecoder().decode(DBUserModel.self, from: data as! Data)
            } catch { }
            return model
        }
        set {
            if let model = newValue {
                do {
                    let data = try JSONEncoder().encode(model)
                    self.saveUD(data: data, forKey: Keys.UserKey)
                } catch { }
            } else {
                self.removeUD(forKey: Keys.UserKey)
            }
        }
    }
    
    private override init() { }
    
}

// MARK: - 项目配置
extension XMApp {
    
    /** 验证是否已登录*/
    static func logined() -> Bool {
        if XMApp.kUserId == 0 {
            return false
        } else {
            return true
        }
    }
    
    /** 清空用户所有缓存信息*/
    static func clearAllUserCache() {
        XMApp.kUserModel = nil
    }
    
    /** 用户模型*/
    static var kUserModel: DBUserModel? {
        get { return XMApp.default.userModel }
        set { XMApp.default.userModel = newValue }
    }
    
    /** 用户userId*/
    static var kUserId: Int {
        return XMApp.kUserModel?.userId ?? 0
    }
    
    /** 用户昵称*/
    static var kNickname: String {
        return XMApp.kUserModel?.nickname ?? ""
    }
    
    /** 用户性别*/
    static var kSex: Int? {
        return XMApp.kUserModel?.sex
    }
    
}

// MARK: - UserDefaults配置
extension XMApp {
    
    /// 设置 Keys
    enum Setting_Keys: String {
        case appTheme
    }
    
    /// 用户 Keys
    enum User_Keys: String {
        case account
    }
    
    @UD(key: User_Keys.account.rawValue, defaultValue: "") static var account: String
    
}

// MARK: - Private
extension XMApp {
    
    private func saveUD(data: Data, forKey key: String) {
        let def = UserDefaults.standard
        def.set(data, forKey: key)
        def.synchronize()
    }
    
    private func removeUD(forKey key: String) {
        let def = UserDefaults.standard
        def.removeObject(forKey: key)
        def.synchronize()
    }
    
}
