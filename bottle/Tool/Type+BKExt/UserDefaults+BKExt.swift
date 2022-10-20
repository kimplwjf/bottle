//
//  UserDefaults+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation

protocol UserDefaultsSettable {
    associatedtype defaultKeys: RawRepresentable
}

// MARK: - 存储key
extension UserDefaults {
    
}

// 扩展中使用 where 子语句限制关联类型是字符串类型, 因为 UserDefaults 的 key 就是字符串类型
extension UserDefaultsSettable where defaultKeys.RawValue == String {
    
    // MARK: - 存储
    /// 字符串存储
    static func set(value: String?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 整型存储
    static func set(value: Int?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 日期存储
    static func set(value: Date?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 布尔值存储
    static func set(value: Bool?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 单精度浮点数存储
    static func set(value: Float?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 双精度浮点数存储
    static func set(value: Double?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 数组存储
    static func set(value: [Any]?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 字典存储
    static func set(value: [String: Any]?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 数据存储
    static func set(value: Data?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// URL存储
    static func set(value: URL?, forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.set(value, forKey: akey)
    }
    
    /// 数据编码归档存储
    @available(iOS 11.0, *)
    static func setArchiver(value: Any?, forKey key: defaultKeys) {
        let akey = key.rawValue
        if let object = value {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: akey)
            } catch {
                fatalError("Can't encode data: \(error)")
            }
        }
    }
    
    // MARK: - 提取
    /// 字符串提取
    static func string(forKey key: defaultKeys) -> String? {
        let akey = key.rawValue
        return UserDefaults.standard.string(forKey: akey)
    }
    
    /// 整型提取
    static func integer(forKey key: defaultKeys) -> Int {
        let akey = key.rawValue
        return UserDefaults.standard.integer(forKey: akey)
    }
    
    /// 日期提取
    static func date(forKey key: defaultKeys) -> Date? {
        let akey = key.rawValue
        return UserDefaults.standard.date(forKey: akey)
    }
    
    /// 布尔值提取
    static func bool(forKey key: defaultKeys) -> Bool {
        let akey = key.rawValue
        return UserDefaults.standard.bool(forKey: akey)
    }
    
    /// 单精度浮点数提取
    static func float(forKey key: defaultKeys) -> Float {
        let akey = key.rawValue
        return UserDefaults.standard.float(forKey: akey)
    }
    
    /// 双精度浮点数提取
    static func double(forKey key: defaultKeys) -> Double {
        let akey = key.rawValue
        return UserDefaults.standard.double(forKey: akey)
    }
    
    /// 数组提取
    static func array(forKey key: defaultKeys) -> [Any]? {
        let akey = key.rawValue
        return UserDefaults.standard.array(forKey: akey)
    }
    
    /// 字典提取
    static func dictionary(forKey key: defaultKeys) -> [String: Any]? {
        let akey = key.rawValue
        return UserDefaults.standard.dictionary(forKey: akey)
    }
    
    /// 数据提取
    static func data(forKey key: defaultKeys) -> Data? {
        let akey = key.rawValue
        return UserDefaults.standard.data(forKey: akey)
    }
    
    /// URL提取
    static func url(forKey key: defaultKeys) -> URL? {
        let akey = key.rawValue
        return UserDefaults.standard.url(forKey: akey)
    }
    
    /// 数据解码解归档提取
    @available(iOS 11.0, *)
    static func unarchiver(forKey key: defaultKeys, anyClass: [AnyClass]) -> Any? {
        let akey = key.rawValue
        var object : Any?
        if let data = UserDefaults.standard.data(forKey: akey) {
            do {
                object = try NSKeyedUnarchiver.unarchivedObject(ofClasses: anyClass, from: data)
            } catch {
                fatalError("Can't decode data: \(error)")
            }
        }
        return object
    }
    
    /// 移除数据
    static func removeObject(forKey key: defaultKeys) {
        let akey = key.rawValue
        UserDefaults.standard.removeObject(forKey: akey)
    }

}

// MARK: - 属性包装器(语法糖)
@propertyWrapper
struct UD<T> {
    private let key: String
    private let defaultValue: T
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}

//extension UserDefaults {
//    enum Keys: String {
//        case isFirstLaunch
//    }
//    @UD(key: Keys.isFirstLaunch.rawValue, defaultValue: false)
//    static var isFirstLaunch: Bool
//}

//@propertyWrapper
//struct Wrapper<T> {
//    var wrappedValue: T
//
//    var projectedValue: Wrapper<T> { return self }
//
//    func doSomething() { print("doSomething") }
//}
