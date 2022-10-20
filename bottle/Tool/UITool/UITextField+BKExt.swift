//
//  UITextField+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

//MARK: UITextField 扩展，添加闭包方式监听text
extension UITextField {
    
    struct AssociatedClosureClass {
        var eventClosure: (UITextField) -> Void
    }
    
    private struct AssociatedKeys {
        static var eventClosureObj: AssociatedClosureClass?
    }
    
    private var eventClosureObj: AssociatedClosureClass {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.eventClosureObj) as? AssociatedClosureClass)! }
        set { objc_setAssociatedObject(self, &AssociatedKeys.eventClosureObj, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @objc private func eventExcuate(_ sender: UITextField) {
        PPP(sender.text ?? "")
        eventClosureObj.eventClosure(sender)
    }
    
    /// 用闭包方式，监听text
    ///
    /// - Parameter action: 闭包
    func bk_addTarget(_ action: @escaping (UITextField) -> Void) {
        let eventObj = AssociatedClosureClass(eventClosure: action)
        eventClosureObj = eventObj
        addTarget(self, action: #selector(eventExcuate(_:)), for: .editingChanged)
    }
    
}

extension UITextField {
    
    /// 设置占位文字
    /// - Parameters:
    ///   - string: 字符串
    ///   - color: 颜色
    ///   - font: 字体
    func bk_addPlaceholder(_ string: String,
                           color: UIColor? = XMColor.gray153,
                           font: UIFont? = .systemFont(ofSize: 14)) {
        let attributedString = NSMutableAttributedString(string: string)
        if let color = color {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: string.count))
        }
        if let font = font {
            attributedString.addAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: string.count))
        }
        attributedPlaceholder = attributedString
    }
    
    func bk_addIconForLeftView(img: UIImage? = UIImage(named: "icon_magnifier1"),
                               viewSize: CGSize = CGSize(width: 36, height: 18),
                               imgSize: CGSize = CGSize(width: 18, height: 18)) {
        leftViewMode = .always
        let view = UIView(frame: kCGRect(0, 0, viewSize.width, viewSize.height))
        let iv = UIImageView(frame: kCGRect(10, 0, imgSize.width, imgSize.height))
        iv.image = img
        iv.contentMode = .scaleAspectFit
        view.addSubview(iv)
        leftView = view
    }
    
    func bk_addLabelForLeftView(text: String,
                                font: UIFont = .systemFont(ofSize: 15),
                                textColor: UIColor = .lightBlackDarkWhite,
                                offset: CGFloat = 16,
                                size: CGSize = CGSize(width: 100, height: 50)) {
        leftViewMode = .always
        let blankView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        blankView.backgroundColor = .clear
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = .left
        label.frame = CGRect(x: offset, y: blankView.height * 0.3, width: blankView.width, height: blankView.height * 0.4)
        blankView.addSubview(label)
        leftView = blankView
    }
    
    func bk_addBlankLeftView(width space: CGFloat) {
        leftViewMode = .always
        let blankView = UIView(frame: CGRect(x: 0, y: 0, width: space, height: 1))
        blankView.backgroundColor = .clear
        leftView = blankView
    }
    
}
