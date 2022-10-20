//
//  Float+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/8.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation

// MARK: - Float扩展
/**
 单精度的随机数
 */
extension Float {
    public static func randomFloatNumber(lower: Float = 0, upper: Float = 100) -> Float {
        return (Float(arc4random()) / Float(UInt32.max)) * (upper - lower) + lower
    }
}

// MARK: - BinaryFloatingPoint扩展
extension BinaryFloatingPoint {
    
    ///    截取二进制浮点数
    ///
    ///    let num = 3.1415927
    ///    num.rounded(3, rule: .up) -> 3.142
    ///    num.rounded(3, rule: .down) -> 3.141
    ///    num.rounded(2, rule: .awayFromZero) -> 3.15
    ///    num.rounded(4, rule: .towardZero) -> 3.1415
    ///    num.rounded(-1, rule: .toNearestOrEven) -> 3
    ///
    /// - Parameters:
    ///   - places: The expected number of decimal places.
    ///   - rule: The rounding rule to use.
    /// - Returns: The rounded value.
    func rounded(_ places: Int, rule: FloatingPointRoundingRule = .up) -> Self {
        let factor = Self(pow(10.0, Double(max(0, places))))
        return (self * factor).rounded(rule) / factor
    }
    
}
