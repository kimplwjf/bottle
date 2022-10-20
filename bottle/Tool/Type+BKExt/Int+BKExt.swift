//
//  Int+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/8.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation

// MARK: - Int扩展
extension Int: RandomNumType {
    
    typealias Element = Int
    
    func random() -> Element {
        return Int(arc4random_uniform(UInt32(self)))
    }
    
    /*这是一个内置函数
     lower : 内置为 0，可根据自己要获取的随机数进行修改。
     upper : 内置为 UInt32.max 的最大值，这里防止转化越界，造成的崩溃。
     返回的结果： [lower,upper) 之间的半开半闭区间的数。
     */
    public static func randomIntNumber(lower: Int = 0, upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
    
    func stringValue() -> String {
        return String(describing: self)
    }
    
    /**
     生成6位随机数
     */
    static func random6Digit() -> String {
        let num = arc4random() % 1000000
        let randomStr = String(format: "%.6d", num)
        return randomStr
    }
    
    var stringW: String {
        if self > 10000 {
            let value = (Double(self)/10000).roundToDecimal(1)
            return String(format: "%.1f万", value)
        } else {
            return self.stringValue()
        }
    }
    
    var stringw: String {
        if self > 10000 {
            let value = (Double(self)/10000).roundToDecimal(1)
            return String(format: "%.1fw", value)
        } else {
            return self.stringValue()
        }
    }
    
    var stringDay: String {
        if self == 0 {
            return "--"
        } else {
            return self < 10 ? "0\(self)" : self.stringValue()
        }
    }
    
}
