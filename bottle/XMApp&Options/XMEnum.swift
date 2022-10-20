//
//  XMEnum.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/5/21.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 加载loading类型
/** 加载loading类型*/
enum LoadingType {
    case `default`
    case logo
    case none
    
    var style: LottieType {
        switch self {
        case .default: return .gusto_loading_default
        case .logo: return .gusto_loading_logo
        case .none: return .none
        }
    }
}

// MARK: - Lottie类型
/** Lottie类型*/
enum LottieType: String {
    case gusto_sea
    case gusto_spotlight
    case gusto_throw
    case gusto_refresh
    case gusto_loading_default
    case gusto_loading_logo
    case gusto_result_success
    case gusto_result_error
    case gusto_alert_success
    case gusto_alert_warning
    case none
}

// MARK: - 男女类型
/** 男女类型*/
enum SexType: Int {
    case man = 1
    case female
    
    var style: (des: String, icon: String) {
        switch self {
        case .man: return ("男", "icon_space_man")
        case .female: return ("女", "icon_space_female")
        }
    }
}
