//
//  CGFloat+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/8.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CGFloat扩展
extension CGFloat {
    
    /// 截取小数位后多少位处理(四舍五入)
    func roundToDecimal(_ fractionDigits: Int) -> CGFloat {
        let multiplier = pow(10.0, CGFloat(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
}
