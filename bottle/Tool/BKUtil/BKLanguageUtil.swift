//
//  BKLanguageUtil.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

/**
 工程配置
 1、Xcode --> 选择你的项目 --> PROJECT --> info --> Localizations --> 添加要支持的语言
 2、新建Localizable.strings文件（Localizable固定值）
 3、选择Localizable.strings --> 在Xcode右边的 Inspectors（Xcode右上角的按钮）--> 找到 Localizations -->  勾选需要的语言，此时Xcode会在你的Localizable.strings里面生成对应的文件。
 4、在对应的语言文件里添加
    "Home_follow" = "关注";
    ...
 5、使用BKLanguage类，管理语言的切换。
 */


/**
 BKLanguage 的使用方法
1、设置语言
 BKLanguageUtil.shared.language = .ChineseHans
2、根据key获取语言包中对应的文本
 BKLocalized(forKey:"Home_follow")
3、监听语言切换
 1）开发者可以监听 LanguageDidChangedKey，最后记得移除监听。
 2）本文件扩展了 UIViewController，开发者也可以使用 bk_observerLangauge 来监听，使用 bk_removeObserverLangauge 来移除监听。
*/

// MARK: - 多语言调用此方法
func BKLocalized(forKey key: String) -> String {
    return BKLanguageUtil.shared.text(forKey: key)
}

// Noti Key: 语言已切换
fileprivate let LanguageDidChangedKey = BKLanguageUtil.didChangedKey 

// MARK: - BKLanguageUtil 语言切换管理类
class BKLanguageUtil: NSObject {
    
    enum Language: String {
        case ChineseHans = "zh-Hans"
        case ChineseHant = "zh-Hant"
        case English = "en"
        
        var des: String {
            switch self {
            case .ChineseHans: return "简体中文"
            case .ChineseHant: return "繁体中文"
            case .English: return "English"
            }
        }
    }
    
    static let shared = BKLanguageUtil()
    
    fileprivate static let didChangedKey = NSNotification.Name("LanguageDidChanged")
    private let LanguageKey: String = "MyLanguage"
    
    var language: Language {
        get {
            if let lang = UserDefaults.standard.value(forKey: LanguageKey) as? Language {
                return lang
            } else {
                return .ChineseHans
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LanguageKey)
            UserDefaults.standard.synchronize()
            // 发通知，语言已发生改变
            NOC.default.post(name: LanguageDidChangedKey, object: nil)
        }
    }
    
    func text(forKey key: String) -> String {
        guard let path = Bundle.main.path(forResource: BKLanguageUtil.shared.language.rawValue, ofType: "lproj"), let bundle = Bundle(path: path) else {
            guard let path = Bundle.main.path(forResource: "Base", ofType: "lproj"), let bundle = Bundle(path: path) else { return "" }
            return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
    
    private override init() { }
    
}

// MARK: - 扩展UIViewController
/** 
 1、增加方法快速监听语言切换
 2、增加方法快速移动监听
 */
extension UIViewController {
    
    private static let key = "BLOCKL_KEY"
    private typealias ChangedBlock = () -> Void
    // 动态添加block属性
    private var block: ChangedBlock? {
        get { return objc_getAssociatedObject(self, UIViewController.key) as? ChangedBlock }
        set { objc_setAssociatedObject(self, UIViewController.key, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    
    @objc private func notiLanguageChange(_ noti: Notification) {
        block?()
    }
    
    /// 监听切换语言
    func bk_observerLanguage(didChanged block: @escaping () -> Void) {
        self.block = block
        NOC.default.addObserver(self, selector: #selector(notiLanguageChange(_:)), name: LanguageDidChangedKey, object: nil)
    }
    
    /// 移除监听
    func bk_removeObserverLanguage() {
        NOC.default.removeObserver(self, name: LanguageDidChangedKey, object: self)
    }
    
}
