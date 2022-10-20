//
//  Double+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/8.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation

// MARK: - Double扩展
extension Double {
    
    /// 截取小数位后多少位处理(四舍五入)
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10.0, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    /**
    双精度的随机数
    */
    public static func randomDoubleNumber(lower: Double = 0,upper: Double = 100) -> Double {
          return (Double(arc4random())/Double(UInt32.max))*(upper - lower) + lower
    }
    
}
