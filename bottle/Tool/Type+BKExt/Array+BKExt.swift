//
//  Array+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/8.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation
import CoreMIDI

// MARK: - Array扩展
extension Array: RandomNumType {
    
    /// 从数组中返回一个随机元素
    func random() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
    
    public var sample: Element? {
        //如果数组为空，则返回nil
        guard count > 0 else { return nil }
        let randomIndex = Int(arc4random_uniform(UInt32(count)))
        return self[randomIndex]
    }
    
    /// 从数组中从返回指定个数的元素
    ///
    /// - Parameters:
    ///   - size: 希望返回的元素个数
    ///   - noRepeat: 返回的元素是否不可以重复（默认为true，不可以重复）
    public func sample(size: Int, noRepeat: Bool = true) -> [Element]? {
        //如果数组为空，则返回nil
        guard !isEmpty else { return nil }
        
        var sampleElements: [Element] = []
        
        //返回的元素可以重复的情况
        if !noRepeat {
            for _ in 0..<size {
                sampleElements.append(sample!)
            }
        }
            //返回的元素不可以重复的情况
        else {
            //先复制一个新数组
            var copy = self.map { $0 }
            for _ in 0..<size {
                //当元素不能重复时，最多只能返回原数组个数的元素
                if copy.isEmpty { break }
                let randomIndex = Int(arc4random_uniform(UInt32(copy.count)))
                let element = copy[randomIndex]
                sampleElements.append(element)
                //每取出一个元素则将其从复制出来的新数组中移除
                copy.remove(at: randomIndex)
            }
        }
        
        return sampleElements
    }
    
}

extension Array where Element: Equatable {
    
    /// 数组元素随机打乱
    func upset() -> Array {
        var arry = self
        var result: [Element] = []
        for _ in 0 ..< arry.count{
            let element = arry.random()
            result.append(element)
            let index = arry.firstIndex(where: {$0 == element})
            if let index = index {
                arry.remove(at: index)
            }
        }
        return result
    }
    
}

extension Array {
    
    /// 取数组第一位
    var firstK: Element {
        return self[0]
    }
    
    /// 取数组最后一位
    var lastK: Element {
        return self[self.endIndex - 1]
    }
    
    /// 取数组倒数第二位
    var lastSecondK: Element {
        return self[self.endIndex - 2]
    }
    
    /// 取下标,防止数组越界
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// 取不固定范围的数组下标  如取index为0,2,3
    subscript(input: [Int]) -> ArraySlice<Element> {
        get {
            var result = ArraySlice<Element>()
            for i in input {
                assert(i < self.count, "Index out of range")
                result.append(self[i])
            }
            return result
        }
        set {
            for (index, i) in input.enumerated() {
                assert(i < self.count, "Index out of range")
                self[i] = newValue[index]
            }
        }
    }
    
    /// 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    
    func stride(by mod: Int) -> [Element] {
        if mod == 0 {
            return self
        }
        var arr = [Element]()
        if self.count > mod {
            for i in Swift.stride(from: 0, to: self.count, by: mod) {
                arr.append(self[i])
            }
            arr.append(self.lastK)
        }
        return arr
    }
    
}

extension Array {
    
    /// 获取数组中的元素,增加了数组越界的判断
    func safeIndex(_ i: Int) -> Array.Iterator.Element? {
        guard !isEmpty && self.count > abs(i) else {
            return nil
        }
        
        for item in self.enumerated() {
            if item.offset == i {
                return item.element
            }
        }
        return nil
    }
    
    /// 从前面取 N 个数组元素
    func limit(_ limitCount: Int) -> [Array.Iterator.Element] {
        let maxCount = self.count
        var resultCount: Int = limitCount
        if maxCount < limitCount {
            resultCount = maxCount
        }
        if resultCount <= 0 {
            return []
        }
        return self[0..<resultCount].map { $0 }
    }
    
    /// 从前面取 N 个数组元素
    func fill(_ fillCount: Int) -> [Array.Iterator.Element] {
        var items = self
        while items.count > 0 && items.count < fillCount {
            items = (items + items).limit(fillCount)
        }
        return items.limit(fillCount)
    }
    
    /// 双边遍历，从中间向两边进行遍历
    func bilateralEnumerated(_ beginIndex: Int, handler: (Int, Array.Iterator.Element) -> Void) {
        let arrayCount: Int = self.count
        var leftIndex: Int = Swift.max(0, Swift.min(beginIndex, arrayCount - 1))
        var rightIndex: Int = leftIndex + 1
        var currentIndex: Int = leftIndex
        var isLeftEnable: Bool = leftIndex >= 0 && leftIndex < arrayCount
        var isRightEnable: Bool = rightIndex >= 0 && rightIndex < arrayCount
        var isLeft: Bool = isLeftEnable ? true : isRightEnable
        while isLeftEnable || isRightEnable {
            currentIndex = isLeft ? leftIndex : rightIndex
            if let element = self.safeIndex(currentIndex) {
                handler(currentIndex, element)
            }
            if isLeft {
                leftIndex -= 1
            } else {
                rightIndex += 1
            }
            isLeftEnable = leftIndex >= 0 && leftIndex < arrayCount
            isRightEnable = rightIndex >= 0 && rightIndex < arrayCount
            if isLeftEnable && !isRightEnable {
                isLeft = true
            } else  if !isLeftEnable && isRightEnable {
                isLeft = false
            } else if isLeftEnable && isRightEnable {
                isLeft = !isLeft
            }
        }
    }
    
}

extension Array where Element: NSCopying {
    
    /// 返回元素支持拷贝数组的深拷贝
    var copy: [Element] {
        return self.map { $0.copy(with: nil) as! Element }
    }
    
}

/// 一维数组转二维数组
/// - Parameters:
///   - oneDArray: 一维数组
///   - rawCount: 被分割的个数
/// - Returns: 转换后的二维数组
func chunkToTwoDArray(oneDArray: [Any], rawCount: Int) -> [[Any]] {
    if rawCount == 0 {
        return [oneDArray]
    }
    let twoDArray = stride(from: 0, to: oneDArray.count, by: rawCount).map { (index) -> [Any] in
        if (index + rawCount) > oneDArray.count {
            return Array(oneDArray[index...])
        } else {
            return Array(oneDArray[index..<index + rawCount])
        }
    }
    print("转换后的二维数组\(twoDArray)")
    return twoDArray
}
