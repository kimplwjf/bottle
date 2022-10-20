//
//  XMStruct.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/5/21.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation
import UIKit
import SwifterSwift

// MARK: - 项目常用颜色
struct XMColor {
    
    static let light139 = kRGBColor(139, 139, 139)
    static let light230 = kRGBColor(230, 233, 238)
    static let dark17 = kRGBColor(17, 17, 17)
    static let dark27 = kRGBColor(27, 27, 27)
    static let dark33 = kRGBColor(33, 36, 40)
    
    static let black51 = kRGBColor(51, 51, 51)
    
    static let red233 = kRGBColor(233, 50, 30)
    
    static let gray102 = kRGBColor(102, 102, 102)
    static let gray153 = kRGBColor(153, 153, 153)
    static let gray201 = kRGBColor(201, 201, 201)
    static let gray229 = kRGBColor(229, 229, 229)
    static let gray230 = kRGBColor(230, 230, 230)
    static let gray241 = kRGBColor(241, 242, 246)
    static let gray248 = kRGBColor(248, 248, 248)
    static let gray250 = kRGBColor(250, 250, 250)
    
}

// MARK: - 沙盒
struct SANDBOX {
    struct File {
        static let Avatar = "Avatar/"
    }
}

// MARK: - LOGO
struct LOGO {
    static let APPICON = UIImage(named: "icon_logo_appicon")!
}

// MARK: - 自定义scheme
struct SCHEME {
    static let WKSCHEME  = "wkwebscheme"
}
