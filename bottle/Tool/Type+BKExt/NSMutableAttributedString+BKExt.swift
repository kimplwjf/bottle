//
//  NSMutableAttributedString+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/3/2.
//  Copyright © 2022 王锦发. All rights reserved.
//

import Foundation
import UIKit

// MARK: - NSMutableAttributedString扩展
extension NSMutableAttributedString {
    
    enum AttributedStringKeys {
        case text(String)
        case font(UIFont)
        case fontSize(CGFloat)
        case textColor(UIColor)
        case bgColor(UIColor)
        case kern(CGFloat)
        case paraStyle((CGFloat, NSTextAlignment))
    }
    
    static func string(by items: [[AttributedStringKeys]]) -> NSMutableAttributedString {
        let string = NSMutableAttributedString()
        for _items in items {
            let attributes = NSMutableDictionary()
            var str: String = ""
            for item in _items {
                switch item {
                case let .text(text):
                    str = text
                case let .font(font):
                    attributes[NSAttributedString.Key.font] = font
                case let .fontSize(fontSize):
                    attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: fontSize)
                case let .kern(kern):
                    attributes[NSAttributedString.Key.kern] = kern
                case let .textColor(textColor):
                    attributes[NSAttributedString.Key.foregroundColor] = textColor
                case let .bgColor(bgColor):
                    attributes[NSAttributedString.Key.backgroundColor] = bgColor
                case let .paraStyle((lineSpacing, align)):
                    let paraStyle = NSMutableParagraphStyle()
                    paraStyle.lineSpacing = lineSpacing
                    paraStyle.alignment = align
                    attributes[NSAttributedString.Key.paragraphStyle] = paraStyle
                }
            }
            let text = NSAttributedString(string: str, attributes: attributes as? [NSAttributedString.Key: Any])
            string.append(text)
        }
        return string
    }
    
    /// 设置在一个文本中所有特殊字符的高亮颜色
    ///
    /// - Parameters:
    ///   - allStr: 所有字符串
    ///   - highlightStr: 高亮字符
    ///   - color: 高亮颜色
    ///   - font: 高亮字体
    /// - Returns: 新字符串
    static func bk_highlight(allStr: String?,
                             highlightStr keyword: String,
                             color: UIColor = .dark,
                             font: UIFont = .systemFont(ofSize: 16, weight: .medium)) -> NSMutableAttributedString {
        guard let allStr = allStr, !keyword.isBlank() else {
            return NSMutableAttributedString(string: allStr ?? "")
        }
        let str = NSMutableAttributedString(string: allStr)
        for i in 0...keyword.count-1 {
            var searchRange = NSMakeRange(0, allStr.count)
            let singleStr = (keyword as NSString).substring(with: NSMakeRange(i, 1))
            // 忽略大小写
            var range = (allStr as NSString).range(of: singleStr, options: .caseInsensitive, range: searchRange)
            while range.location != NSNotFound {
                // 改变多次搜索时searchRange的位置
                searchRange = NSMakeRange(NSMaxRange(range), allStr.count - NSMaxRange(range))
                str.addAttribute(.foregroundColor, value: color, range: range)
                str.addAttribute(.font, value: font, range: range)
                range = (allStr as NSString).range(of: singleStr, options: [], range: searchRange)
            }
        }
        return str
    }
    
}
