//
//  XMNotifiConstant.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

/// 导入第三方库，使用 @_exported 来修饰，导入一次，可以全局调用
@_exported import SnapKit
@_exported import SwiftyJSON
@_exported import Alamofire
@_exported import HandyJSON
@_exported import WCDBSwift
@_exported import IQKeyboardManagerSwift
@_exported import SDWebImage
@_exported import ZLPhotoBrowser
@_exported import CryptoSwift
@_exported import LXFProtocolTool
@_exported import SwifterSwift
@_exported import Lottie
@_exported import BRPickerView
@_exported import ESTabBarController_swift

typealias NOC = NotificationCenter

// MARK: - Noti Key
extension NSNotification.Name {
    
    /// 进入App通知Key
    struct NotiKeyEnterApp {
        static let DidAppear = NSNotification.Name("NotiKeyEnterApp_DidAppear") // 进入App初始化成功回调通知key
    }
    
}
