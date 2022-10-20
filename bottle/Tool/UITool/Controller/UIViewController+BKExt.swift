//
//  UIViewController+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIViewController扩展
extension UIViewController {
    
    /// 是否正在展示
    var isCurrentVC: Bool {
        return isViewLoaded && view.window != nil
    }
    
    /// 添加灰色横线
    func bk_addLine(_ rgb: CGFloat = 229) -> UIView {
        let line = UIView()
        line.backgroundColor = rgb == 229 ? .lightGray229Dark33 : kRGBColor(rgb, rgb, rgb)
        return line
    }
    
    /// 添加可选和不可选按钮
    func bk_addDisabledButton(type: UIButton.ButtonType = .system,
                              title: String, disabledTitle: String,
                              color: UIColor, disabledColor: UIColor,
                              font: UIFont = .systemFont(ofSize: 15)) -> UIButton {
        
        let btn = UIButton(type: type)
        btn.setTitle(title, for: .normal)
        btn.setTitle(disabledTitle, for: .disabled)
        btn.setTitleColor(disabledColor, for: .disabled)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = font
        return btn
        
    }
    
    /// 添加Label
    func bk_addLabel(text: String? = nil,
                     font: UIFont = .systemFont(ofSize: 15),
                     bgColor: UIColor = .lightWhiteDark27,
                     textColor: UIColor = .lightBlackDarkWhite,
                     align: NSTextAlignment = .left) -> UILabel {
        
        let label = UILabel()
        label.backgroundColor = bgColor
        label.textColor = textColor
        label.text = text
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        label.font = font
        label.textAlignment = align
        return label
        
    }
    
    /// 添加UIButton
    func bk_addButton(type: UIButton.ButtonType = .system,
                      title: String,
                      font: UIFont = .systemFont(ofSize: 15),
                      bgColor: UIColor = .lightWhiteDark27,
                      titleColor: UIColor = .lightBlackDarkWhite,
                      borderW: CGFloat = 0.0,
                      radius: CGFloat = 0.0,
                      borderColor: UIColor = .clear,
                      edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 1.0, left: 5.0, bottom: 1.0, right: 5.0)) -> UIButton {
        
        let btn = UIButton(type: type)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = font
        btn.backgroundColor = bgColor
        btn.setTitleColor(titleColor, for: .normal)
        btn.layer.borderColor = borderColor.cgColor
        btn.layer.borderWidth = borderW
        btn.layer.cornerRadius = radius
        
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.contentEdgeInsets = edgeInsets
        return btn
        
    }
    
    /// 添加渐变色背景UIButton
    func bk_addGradientButton(title: String,
                              font: UIFont = .systemFont(ofSize: 15),
                              titleColor: UIColor = .lightBlackDarkWhite,
                              gradientType: UIImage.GradientType = .leftToRight,
                              gradientSize: CGSize,
                              colors: [UIColor],
                              isRounded: Bool = true,
                              corner: UIRectCorner = .allCorners,
                              radius: CGFloat = 0.0,
                              edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 1.0, left: 5.0, bottom: 1.0, right: 5.0)) -> UIButton {
        
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = font
        btn.setTitleColor(titleColor, for: .normal)
        var image = UIImage.bk_gradient(gradientType: gradientType, size: gradientSize, colors: colors)
        if isRounded {
            image = image?.bk_freeRoundingCorners(corner, radi: radius)
        }
        btn.setBackgroundImage(image, for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.contentEdgeInsets = edgeInsets
        return btn
        
    }
    
    func bk_addLayoutButton(style: BKLayoutButtonStyle = .leftImageRightTitle,
                            space: CGFloat = 5.0,
                            bgColor: UIColor = .lightWhiteDark27,
                            imageSize: CGSize, image: UIImage?,
                            titleFont: UIFont = .systemFont(ofSize: 15), title: String?, titleColor: UIColor = .lightBlackDarkWhite) -> BKLayoutButton {
        let btn = BKLayoutButton()
        btn.layoutStyle = style
        btn.backgroundColor = bgColor
        btn.setMidSpacing(space)
        btn.setImageSize(imageSize)
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = titleFont
        btn.setTitleColor(titleColor, for: .normal)
        btn.setTitle(title, for: .normal)
        return btn
    }
    
    func bk_addGradientLayoutButton(style: BKLayoutButtonStyle = .leftImageRightTitle,
                                    space: CGFloat = 5.0,
                                    bgColor: UIColor = .lightWhiteDark27,
                                    imageSize: CGSize, image: UIImage?,
                                    titleFont: UIFont = .systemFont(ofSize: 15), title: String?, titleColor: UIColor = .lightBlackDarkWhite,
                                    gradientType: UIImage.GradientType = .leftToRight,
                                    gradientSize: CGSize,
                                    colors: [UIColor],
                                    isRounded: Bool = true,
                                    corner: UIRectCorner = .allCorners,
                                    radius: CGFloat = 0.0) -> BKLayoutButton {
        let btn = self.bk_addLayoutButton(style: style,
                                          space: space,
                                          bgColor: bgColor,
                                          imageSize: imageSize, image: image,
                                          titleFont: titleFont, title: title, titleColor: titleColor)
        var image = UIImage.bk_gradient(gradientType: gradientType, size: gradientSize, colors: colors)
        if isRounded {
            image = image?.bk_freeRoundingCorners(corner, radi: radius)
        }
        btn.setBackgroundImage(image, for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        return btn
    }
    
    /// 类文件字符串转换为ViewController
    ///
    /// - Parameter childControllerName: VC的字符串
    /// - Returns: ViewController
    func bk_convertController(_ childControllerName: String) -> UIViewController? {
        
        // 1.获取命名空间
        // 通过字典的键来取值,如果键名不存在,那么取出来的值有可能就为没值.所以通过字典取出的值的类型为AnyObject?
        guard let clsName = Bundle.main.infoDictionary!["CFBundleExecutable"] else { return nil }
        // 2.通过命名空间和类名转换成类
        let cls : AnyClass? = NSClassFromString((clsName as! String) + "." + childControllerName)
        // 通过Class创建一个对象,必须告诉系统Class的类型
        guard let clsType = cls as? UIViewController.Type else { return nil }
        
        // 3.通过Class创建对象
        let childController = clsType.init()
        return childController
        
    }
    
    /// 自定义tabbar,使其不被系统亮蓝色所渲染
    func bk_customTabbar(vc: UIViewController,
                         title: String, titleColor: UIColor = .lightWhiteDark27,
                         imgName: String, selectedImgName: String) {
        
        vc.title = title
        // 设置 tabbarItem 选中状态的图片(不被系统默认渲染,显示图像原始颜色)
        vc.tabBarItem.image = UIImage(named: imgName)?.withRenderingMode(.alwaysOriginal)
        vc.tabBarItem.selectedImage = UIImage(named: selectedImgName)?.withRenderingMode(.alwaysOriginal)
        // 设置 tabbarItem 选中状态下的文字颜色(不被系统默认渲染,显示文字自定义颜色)
        let dictHome = [NSAttributedString.Key.foregroundColor: titleColor]
        vc.tabBarItem.setTitleTextAttributes(dictHome, for: .selected)
        
    }
    
}

// MARK: - 状态栏扩展
extension UIViewController {
    
    /// 控制器的状态栏唯一键
    var statusBarKey: String {
        return "\(self)"
    }
    
    /// 设置该控制器的状态栏状态
    func bk_setStatusBar(isHidden: Bool? = nil, style: UIStatusBarStyle? = nil, animation: UIStatusBarAnimation? = nil) {
        StatusBarManager.shared.setState(for: statusBarKey, isHidden: isHidden, style: style, animation: animation)
    }
    
    /// 添加一个子状态
    func bk_addSubStatusBar(for viewController: UIViewController) {
        let superKey = self.statusBarKey
        let subKey = viewController.statusBarKey
        StatusBarManager.shared.addSubState(with: subKey, root: superKey)
    }
    
    /// 批量添加子状态,树横向生长
    func bk_addSubStatusBars(for viewControllers: [UIViewController]) {
        viewControllers.forEach { (vc) in
            self.bk_addSubStatusBar(for: vc)
        }
    }
    
    /// 从整个状态树上删除当前状态
    func bk_removeFromSuperStatusBar() {
        let key = self.statusBarKey
        StatusBarManager.shared.removeState(with: key)
    }
    
    /// 设置当前状态下的所有子状态
    func bk_setSubStatusBars(for viewControllers: [UIViewController]?) {
        bk_clearSubStatusBars()
        if let vcs = viewControllers {
            bk_addSubStatusBars(for: vcs)
        }
    }
    
    /// 通过类似压栈的形式,压入一组状态,树纵向生长
    func bk_pushStatusBars(for viewControllers: [UIViewController]) {
        var lastVC: UIViewController? = self
        viewControllers.forEach { (vc) in
            if let superController = lastVC {
                superController.bk_addSubStatusBar(for: vc)
                lastVC = vc
            }
        }
    }
    
    /// 切换多个子状态的某个子状态
    func bk_showStatusBar(for viewController: UIViewController?) {
        guard let vc = viewController else { return }
        let superKey = self.statusBarKey
        let subKey = vc.statusBarKey
        StatusBarManager.shared.showState(for: subKey, root: superKey)
    }
    
    /// 清楚所有子状态
    func bk_clearSubStatusBars(isUpdate: Bool = true) {
        StatusBarManager.shared.clearSubStates(with: self.statusBarKey, isUpdate: isUpdate)
    }
    
}
