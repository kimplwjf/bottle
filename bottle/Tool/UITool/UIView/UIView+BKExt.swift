//
//  UIView+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit
import WebKit

enum BKBorder {
    case none
    case top
    case bottom
    case left
    case right
}

// MARK: - 便利构造
extension UIView {
    
    /// 便利构造有color的UIView
    ///
    /// - Parameters:
    ///   - color: UIColor
    convenience init(color: UIColor) {
        self.init()
        backgroundColor = color
    }
    
}

// MARK: - 根据类型查找控制器
extension UIView {
    
    var ctrl: UIViewController? {
        return self.bk_findController(with: UIViewController.self)
    }
    
    var naviCtrl: UINavigationController? {
        return self.bk_findController(with: UINavigationController.self)
    }
    
    var tabBarCtrl: UITabBarController? {
        return self.bk_findController(with: UITabBarController.self)
    }
    
    func bk_findController<T: UIViewController>(with class: T.Type) -> T? {
        var responder = next
        while responder != nil {
            if responder!.isKind(of: `class`) {
                return responder as? T
            }
            responder = responder?.next
        }
        return nil
    }
    
    /// 设置新的frame
    func bk_setNewFrame(_ frame: CGRect) {
        if self.frame != frame {
            self.frame = frame
        }
    }
    
}

extension UIView {
    
    func bk_bringSubviewsToFront(_ subviews: [UIView]) {
        subviews.forEach { bringSubviewToFront($0) }
    }
    
    func bk_sendSubviewsToBack(_ subviews: [UIView]) {
        subviews.forEach { sendSubviewToBack($0) }
    }
    
}

// MARK: - 动画
extension UIView {
    
    /// 上下浮动
    func bk_spring() {
        UIView.animate(withDuration: 0.5) {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y+5, width: self.bounds.size.width, height: self.bounds.size.height)
        }
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut) {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y-5, width: self.bounds.size.width, height: self.bounds.size.height)
        } completion: { _ in
            self.bk_spring()
        }
    }
    
    /// 缩放变小
    func bk_zoomOut() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0,0.9]
        animation.duration = 0.3
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        self.layer.add(animation, forKey: "zoomOut")
    }
    
    /// 缩放变大
    func bk_zoomIn() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0.9, 1.0]
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 0.3
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        self.layer.add(animation, forKey: "zoomIn")
    }
    
    /// 缩放显现动画
    func bk_scaleAnimate() {
        self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
}

extension UIView {
    
    ///圆角
    struct BKCornerRadius {
        var topLeft: CGFloat = 0
        var topRight: CGFloat = 0
        var bottomLeft: CGFloat = 0
        var bottomRight: CGFloat = 0
    }
    
    /// 设置圆角
    /// - Parameters:
    ///   - radius: 圆角
    ///   - borderLayer: 边框 Layer
    func bk_setCornerRadius(with radius: BKCornerRadius, borderLayer: CAShapeLayer? = nil) {
        let maskBezierPath = UIBezierPath()
        maskBezierPath.addArc(withCenter: CGPoint(x: bounds.minX + radius.topLeft, y: bounds.minY + radius.topLeft), radius: radius.topLeft, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
        maskBezierPath.addArc(withCenter: CGPoint(x: bounds.maxX - radius.topRight, y: bounds.minY + radius.topRight), radius: radius.topRight, startAngle: .pi * 1.5, endAngle: 0, clockwise: true)
        maskBezierPath.addArc(withCenter: CGPoint(x: bounds.maxX - radius.bottomRight, y: bounds.maxY - radius.bottomRight), radius: radius.bottomRight, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
        maskBezierPath.addArc(withCenter: CGPoint(x: bounds.minX + radius.bottomLeft, y: bounds.maxY - radius.bottomLeft), radius: radius.bottomLeft, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
        maskBezierPath.close()
        if let borderLayer = borderLayer {
            borderLayer.frame = bounds
            borderLayer.path = maskBezierPath.cgPath
            layer.addSublayer(borderLayer)
        }
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskBezierPath.cgPath
        layer.mask = maskLayer
    }
    
}

extension UIView {
    
    /// 快速添加镂空View
    ///
    /// - Parameters:
    ///   - radius: 圆角半径(nil: 默认半径)
    ///   - color: 背景颜色(nil: 默认父控件的)
    ///   - corners: 切除部分(nil: 默认切4角)
    func addHollowOutView(radius: CGFloat? = nil, color: UIColor? = nil, corners: UIRectCorner? = nil) {
        let rect = bounds
        let backgroundView = UIView(frame: rect) // 创建背景View
        backgroundView.isUserInteractionEnabled = false // 不接收事件 不然会阻挡原始事件触发
        var currentcolor = color ?? backgroundColor // 设置颜色
        if currentcolor == nil { // 如果没设置背景色
            if let superView = self.superview { // 看看父控件是否存在 存在直接用父控件背景色
                currentcolor = superView.backgroundColor
            } else { // 不然给定白色
                currentcolor = UIColor.white
            }
        }
        backgroundView.backgroundColor = currentcolor
        let currentradius: CGFloat = radius ?? rect.size.height*0.5 // 设置圆角半径
        self.addSubview(backgroundView) // 添加遮罩层
        self.bringSubviewToFront(backgroundView) // 放置到最顶层
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd //  奇偶层显示规则
        let basicPath = UIBezierPath(rect: rect) // 底色
        
        let radii = CGSize(width: currentradius, height: currentradius)
        let currentcorners: UIRectCorner = corners ?? [.allCorners]
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: currentcorners, cornerRadii: radii) // 镂空路径
        basicPath.append(maskPath) // 重叠
        maskLayer.path = basicPath.cgPath
        backgroundView.layer.mask = maskLayer
    }
    
}

// MARK: - UIButton
extension UIView {
    
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
        btn.bk_layerBorderColor(borderColor)
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
    
    /// 添加图片复选框
    func bk_addImgSelectButton(iconNormal: String, iconSelect: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: iconNormal), for: .normal)
        btn.setImage(UIImage(named: iconSelect), for: .selected)
        return btn
    }
    
    /// 添加选中和未选中按钮
    func bk_addSelectedButton(font: UIFont = .systemFont(ofSize: 15),
                              title: String,
                              selectTitle: String,
                              titleColor: UIColor = .lightWhiteDark27,
                              selectTitleColor: UIColor = .lightBlackDarkWhite) -> UIButton {
        let btn = UIButton()
        btn.titleLabel?.font = font
        btn.setTitle(title, for: .normal)
        btn.setTitle(selectTitle, for: .selected)
        btn.setTitleColor(titleColor, for: .normal)
        btn.setTitleColor(selectTitleColor, for: .selected)
        return btn
    }
    
    /// 添加选中和未选中渐变色按钮
    func bk_addSelectedGradientButton(font: UIFont = .systemFont(ofSize: 15),
                                      title: String,
                                      selectTitle: String,
                                      titleColor: UIColor = .lightWhiteDark27,
                                      selectTitleColor: UIColor = .lightBlackDarkWhite,
                                      gradientType: UIImage.GradientType = .leftToRight,
                                      gradientSize: CGSize,
                                      colors: [UIColor],
                                      selectColors: [UIColor],
                                      isRounded: Bool = true,
                                      corner: UIRectCorner = .allCorners,
                                      radius: CGFloat = 0.0) -> BKBorderButton {
        let btn = BKBorderButton()
        btn.backgroundColor = .clear
        btn.titleLabel?.font = font
        btn.setTitle(title, for: .normal)
        btn.setTitle(selectTitle, for: .selected)
        btn.setTitleColor(titleColor, for: .normal)
        btn.setTitleColor(selectTitleColor, for: .selected)
        var normalImage = UIImage.bk_gradient(gradientType: gradientType, size: gradientSize, colors: colors)
        var selectImage = UIImage.bk_gradient(gradientType: gradientType, size: gradientSize, colors: selectColors)
        if isRounded {
            normalImage = normalImage?.bk_freeRoundingCorners(corner, radi: radius)
            selectImage = selectImage?.bk_freeRoundingCorners(corner, radi: radius)
        }
        btn.setBackgroundImage(normalImage, for: .normal)
        btn.setBackgroundImage(selectImage, for: .selected)
        btn.layer.cornerRadius = radius
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        return btn
    }
    
}

// MARK: - UIView扩展
extension UIView {
    
    /// 添加渐变imageView
    func bk_addGradientView(gradientType: UIImage.GradientType = .leftToRight,
                            size: CGSize,
                            colors: [UIColor],
                            locations: [CGFloat] = [0.0, 1.0]) -> UIImageView {
        let gradientView = UIImage.bk_gradient(gradientType: gradientType, size: size, colors: colors, locations: locations)
        let iv = UIImageView(image: gradientView)
        return iv
    }
    
    /// 添加灰色线
    func bk_addLine(_ rgb: CGFloat = 229) -> UIView {
        let line = UIView()
        line.backgroundColor = rgb == 229 ? .lightGray229Dark33 : kRGBColor(rgb, rgb, rgb)
        return line
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
        label.font = font
        label.textAlignment = align
        label.sizeToFit()
        return label
        
    }
    
}

// MARK: - 添加边框、圆角
extension UIView {
    
    /// 添加边框(四边框，可以设置任意圆角半径)
    ///
    /// - Parameters:
    ///   - radius: 圆角弧度半径
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    ///   - corners: 需要处理圆角的方向
    func bk_addRoundCorners(radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor, corners: UIRectCorner = .allCorners) {
        self.layoutIfNeeded()
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let tempLayer = CAShapeLayer()
        tempLayer.lineWidth = borderWidth
        tempLayer.fillColor = UIColor.clear.cgColor
        tempLayer.strokeColor = borderColor.cgColor
        tempLayer.frame = bounds
        tempLayer.path = path.cgPath
        self.layer.addSublayer(tempLayer)
        
        let mask = CAShapeLayer(layer: tempLayer)
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /// 添加边框(四边框，可以设置圆角半径)
    ///
    /// - Parameters:
    ///   - radius: 圆角弧度半径
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    func bk_addCornerBorder(radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
        layer.borderWidth = borderWidth
        self.bk_layerBorderColor(borderColor)
    }
    
    /// 添加任意圆角
    ///
    /// - Parameters:
    ///   - radius: 圆角弧度半径
    ///   - corners: 需要处理圆角的方向
    func bk_addRandomCorners(radius: CGFloat = 5, corners: UIRectCorner = .allCorners) {
        self.layoutIfNeeded()
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 绘制线条
    ///
    /// - Parameters:
    ///   - rect: 线条的rect
    ///   - color: 线条颜色
    func bk_drawLine(rect: CGRect, color: UIColor) {
        let line = UIBezierPath(rect: rect)
        let lineShape = CAShapeLayer()
        lineShape.path = line.cgPath
        lineShape.bk_fillColor(color, with: self)
        self.layer.addSublayer(lineShape)
    }
    
    /// 添加任意直线边框
    ///
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - size: 边框尺寸
    ///   - bkBorders: 上下左右边框数组
    func bk_addBorder(color: UIColor, size: CGFloat = 0.5, bkBorders: [BKBorder] = [BKBorder.none]) {
        self.layoutIfNeeded()
        let viewRect = self.bounds
        for type in bkBorders {
            
            var rect = CGRect(x: 0, y: 0, width: 0, height: 0)
            
            switch type {
            case .none:
                break
            case .top:
                rect = CGRect(x: 0, y: 0, width: viewRect.size.width, height: size)
            case .bottom:
                rect = CGRect(x: 0, y: viewRect.size.height-size, width: viewRect.size.width, height: size)
            case .left:
                rect = CGRect(x: 0, y: 0, width: size, height: viewRect.size.height)
            case .right:
                rect = CGRect(x: viewRect.size.width-size, y: 0, width: size, height: viewRect.size.height)
            }
            self.bk_drawLine(rect: rect, color: color)
        }
    }
    
    /// 添加黑色遮罩
    ///
    /// - Parameters:
    ///   - alpha: 透明度
    func bk_addMask(alpha: CGFloat = 0.5) {
        let _view = UIView()
        _view.backgroundColor = UIColor.lightBlackDarkWhite.withAlphaComponent(alpha)
        _view.frame = self.bounds
        self.addSubview(_view)
    }
    
}

// MARK: - 同时添加圆角、阴影的基类View
class BKCornersShadowView: UIControl {
    
    var bk_radius: CGFloat = 5 {
        willSet {
            layer.cornerRadius = newValue
            _contentView?.layer.cornerRadius = newValue
        }
    }
    
    var bk_contentView: UIView? {
        return _contentView
    }
    
    func bk_addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
    
    private var _contentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initViews()
        self.initConstraints()
        
    }
    
    override func addSubview(_ view: UIView) {
        _contentView?.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.backgroundColor = .lightWhiteDark27
        layer.shadowOpacity = 0.3
        layer.bk_shadowColor(.lightBlackDarkWhite, with: self)
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 1, height: 2)
        
        _contentView = UIView()
        _contentView?.translatesAutoresizingMaskIntoConstraints = false
        _contentView?.layer.masksToBounds = true
        self.bk_radius = 5
        if let _view = _contentView {
            super.addSubview(_view)
        }
    }
    
    private func initConstraints() {
        _contentView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        _contentView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        _contentView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _contentView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}

// MARK: - 截图-对当前视图进行快照
extension UIView {
    
    /** 是否正在截屏*/
    public var isCapturing: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kCapturing) else {
                return false
            }
            guard let boolValue = value as? Bool else {
                return false
            }
            return boolValue
        }
        set { objc_setAssociatedObject(self, &UIViewAssociatedKeys.kCapturing, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /**  是否包含了WKWebView*/
    public func isContainWKWebView() -> Bool {
        if self.isKind(of: WKWebView.self) {
            return true
        } else {
            for view in self.subviews {
                return view.isContainWKWebView()
            }
        }
        return false
    }
    
    /** 快照回调*/
    public typealias BKCaptureCompletion = (UIImage?) -> Void
    
    /// 对视图进行快照
    ///
    /// - Parameter completion: 回调
    public func bk_captureCurrent(_ completion: BKCaptureCompletion) {
        self.isCapturing = true
        let captureFrame = self.bounds
        
        UIGraphicsBeginImageContextWithOptions(captureFrame.size, true, kScreenScale)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.translateBy(x: -bk_x, y: -bk_y)
        
        if self.isContainWKWebView() {
            self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        } else {
            self.layer.render(in: context!)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        self.isCapturing = false
        completion(image)
    }
    
}

// MARK: - 截图
extension UIView {
    
    /// 生成视图的截图 - bounds
    ///
    /// - Parameters:
    ///   - opaque: alpha通道 true:不透明 / false透明
    ///   - scale: 缩放清晰度
    /// - Returns: 截图
    func bk_generateBoundsScreenshot(_ opaque: Bool = false, scale: CGFloat = 0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, scale)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    /// 生成视图的截图 - frame
    ///
    /// - Returns: 截图
    func bk_generateFrameScreenshot() -> UIImage {
        let imageSize = self.frame.size
        let orientation = UIApplication.shared.statusBarOrientation
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            context.translateBy(x: center.x, y: center.y)
            context.concatenate(transform)
            context.translateBy(x: -bounds.size.width * layer.anchorPoint.x, y: -bounds.size.height * layer.anchorPoint.y)
            if orientation == .landscapeLeft {
                context.rotate(by: .pi / 2)
                context.translateBy(x: 0, y: -imageSize.width)
            } else if orientation == .landscapeRight {
                context.rotate(by: -.pi / 2)
                context.translateBy(x: -imageSize.height, y: 0)
            } else if orientation == .portraitUpsideDown {
                context.rotate(by: .pi)
                context.translateBy(x: -imageSize.width, y: -imageSize.height)
            }
            if self.responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
                self.drawHierarchy(in: bounds, afterScreenUpdates: true)
            } else {
                layer.render(in: context)
            }
            context.restoreGState()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
}

extension UIView {
    
    // MARK: - 添加渐变色图层
    /**
     * point的位置  左上角0,0  右上角1,0  左下角0,1  右下角1,1
     *  0,0     0.5,0     1,0
     *   ******************
     *   *                *
     *   *                *
     *   *                *
     *   *                *
     *   *                *
     *   *                *
     *   ******************
     *  0,1     0.5,1     1,1
     */
    func bk_gradientLayer(_ bounds: CGRect = kScreenRect, sp startPoint: CGPoint, ep endPoint: CGPoint, colors: [UIColor], locations: [NSNumber] = [0.0, 1.0]) {
        guard startPoint.x >= 0, startPoint.x <= 1, startPoint.y >= 0, startPoint.y <= 1, endPoint.x >= 0, endPoint.x <= 1, endPoint.y >= 0, endPoint.y <= 1 else {
            return
        }
        
        self.layoutIfNeeded()
        self.bk_removeGradientLayer()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.bk_colors(colors, with: self)
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        self.layer.addSublayer(gradientLayer)
    }
    
    /// 添加透明渐变过渡层
    func bk_gradientClearMask(bounds: CGRect, sp startPoint: CGPoint, ep endPoint: CGPoint, colors: [UIColor], locations: [NSNumber] = [0.0, 1.0]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.rasterizationScale = kScreenScale
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        self.layer.mask = gradientLayer
    }
    
    // MARK: 添加渐变色图层(例如添加至label上)
    func bk_gradientColor(_ startPoint: CGPoint, _ endPoint: CGPoint, _ colors: [UIColor], locations: [NSNumber] = [0.0, 1.0]) {
        guard startPoint.x >= 0, startPoint.x <= 1, startPoint.y >= 0, startPoint.y <= 1, endPoint.x >= 0, endPoint.x <= 1, endPoint.y >= 0, endPoint.y <= 1 else {
            return
        }
        
        // 外界如果改变了self的大小，需要先刷新
        self.layoutIfNeeded()
        self.bk_removeGradientLayer()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.layer.bounds
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.bk_colors(colors, with: self)
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.masksToBounds = true
        // 渐变图层插入到最底层，避免在uibutton上遮盖文字图片
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.backgroundColor = .clear
        // self如果是UILabel，masksToBounds设为true会导致文字消失
        self.layer.masksToBounds = false
    }
    
    // MARK: 移除渐变图层
    //（当希望只使用backgroundColor的颜色时，需要先移除之前加过的渐变图层）
    public func bk_removeGradientLayer() {
        if let sl = self.layer.sublayers {
            for layer in sl {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
}

// MARK: - 圆角、阴影、边框设置、毛玻璃方法
@IBDesignable
extension UIView {
    
    /**
    运行时对应的key值
    */
    private struct UIViewAssociatedKeys {
        static var kCapturing: String = "kCapturing"
        static var kShadowOpacity: String = "kShadowOpacity"
        static var kShadowColor: String = "kShadowColor"
        static var kShadowOffset: String = "kShadowOffset"
        static var kShadowRadius: String = "kShadowRadius"
        static var kCornerRadius: String = "kCornerRadius"
        static var kBorderColor: String = "kBorderColor"
        static var kBorderWidth: String = "kBorderWidth"
        static var kRoundCorners: String = "kRoundCorners"
    }
    
    public enum ShadowStyle: Int {
        case deep = 0 // default
        case shallow
        case all
        case top
        case left
        case right
        case bottom
    }
    
    /** 阴影不透明度*/
    @IBInspectable
    public var bk_shadowOpacity: Float {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kShadowOpacity) else {
                return 0
            }
            guard let opacity = value as? Float else {
                return 0
            }
            return opacity
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.kShadowOpacity, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.shadowOpacity = newValue
        }
    }
    
    /** 阴影颜色*/
    @IBInspectable
    public var bk_shadowColor: UIColor? {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kShadowColor) else {
                return nil
            }
            guard let shadowColor = value as? UIColor else {
                return nil
            }
            return shadowColor
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &UIViewAssociatedKeys.kShadowColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.bk_layerShadowColor(newValue)
            }
        }
    }
    
    /** 阴影偏移*/
    @IBInspectable
    public var bk_shadowOffset: CGSize {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kShadowOffset) else {
                return CGSize.zero
            }
            guard let shadowOffset = value as? CGSize else {
                return CGSize.zero
            }
            return shadowOffset
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.kShadowOffset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.shadowOffset = newValue
        }
    }
    
    /** 阴影弧度*/
    @IBInspectable
    public var bk_shadowRadius: CGFloat {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kShadowRadius) else {
                return 0
            }
            guard let shadowRadius = value as? CGFloat else {
                return 0
            }
            return shadowRadius
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.kShadowRadius, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.shadowRadius = newValue
        }
    }
    
    /** 圆角弧度*/
    @IBInspectable
    public var bk_cornerRadius: CGFloat {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kCornerRadius) else {
                return 0
            }
            guard let cornerRadius = value as? CGFloat else {
                return 0
            }
            return cornerRadius
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.kCornerRadius, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.cornerRadius = newValue
        }
    }
    
    /** 边框颜色*/
    @IBInspectable
    public var bk_borderColor: UIColor? {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kBorderColor) else {
                return nil
            }
            guard let borderColor = value as? UIColor else {
                return nil
            }
            return borderColor
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &UIViewAssociatedKeys.kBorderColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.bk_layerBorderColor(newValue)
            }
        }
    }
    
    /** 边框宽度*/
    @IBInspectable
    public var bk_borderWidth: CGFloat {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kBorderWidth) else {
                return 0.000001
            }
            guard let borderWidth = value as? CGFloat else {
                return 0.000001
            }
            return borderWidth
        }
        set {
            let borderWidth: CGFloat = newValue < 0.000001 ? 0.000001 : newValue
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.kBorderWidth, borderWidth , .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.borderWidth = newValue
        }
    }
    
    /** 需要处理的圆角，默认四个角都处理*/
    public var bk_roundCorner: UIRectCorner {
        get {
            guard let value = objc_getAssociatedObject(self, &UIViewAssociatedKeys.kRoundCorners) else {
                return .allCorners
            }
            guard let corners = value as? UIRectCorner else {
                return .allCorners
            }
            return corners
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedKeys.kRoundCorners, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.layer.masksToBounds = false
            
            let cornerLayer = CAShapeLayer()
            cornerLayer.frame = self.bounds
            cornerLayer.backgroundColor = self.backgroundColor?.cgColor
            
            let cornerRadius = bk_cornerRadius > 0 ? bk_cornerRadius : 0
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: newValue, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.shouldRasterize = true
            shapeLayer.rasterizationScale = kScreenScale
            cornerLayer.mask = shapeLayer
            
            self.layer.addSublayer(cornerLayer)
        }
    }
    
    /** UIView样式扩展*/
    public func bk_addShadowStyleWith(cornerRadius: CGFloat?,
                                      corners: UIRectCorner? = .allCorners,
                                      with style: ShadowStyle = .deep,
                                      shadowColor: UIColor = .lightBlackDarkWhite,
                                      shadowOffset: CGFloat = 2) {
        switch style {
        case .deep:
            self.bk_addStyleWith(cornerRadius: cornerRadius, corners: corners, shadowRadius: 3, shadowOffset: CGSize(width: 1, height: 2), shadowOpacity: 0.5, shadowColor: .lightBlackDarkWhite)
        case .shallow:
            self.bk_addStyleWith(cornerRadius: cornerRadius, corners: corners, shadowRadius: 5, shadowOffset: CGSize(width: 0, height: 2), shadowOpacity: 0.5, shadowColor: .lightBlackDarkWhite.withAlphaComponent(0.3))
        default:
            var offset: CGSize = .zero
            switch style {
            case .all: offset = CGSize(width: 0, height: 0)
            case .top: offset = CGSize(width: 0, height: -shadowOffset)
            case .left: offset = CGSize(width: -shadowOffset, height: 0)
            case .right: offset = CGSize(width: shadowOffset, height: 0)
            case .bottom: offset = CGSize(width: 0, height: shadowOffset)
            default: break
            }
            self.bk_addStyleWith(cornerRadius: cornerRadius, corners: corners, shadowRadius: 3, shadowOffset: offset, shadowOpacity: 0.5, shadowColor: shadowColor)
        }
    }
    
    /// 使用方法添加圆角、边框、阴影样式, 不需要的属性，设置为nil即可
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角弧度半径
    ///   - corners: 需要处理圆角的方向
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    ///   - shadowRadius: 阴影弧度半径
    ///   - shadowOffset: 阴影偏移
    ///   - shadowOpacity: 阴影的不透明度
    ///   - shadowColor: 阴影颜色
    public func bk_addStyleWith(cornerRadius: CGFloat?,
                                corners: UIRectCorner?,
                                borderWidth: CGFloat? = nil,
                                borderColor: UIColor? = nil,
                                shadowRadius: CGFloat? = nil,
                                shadowOffset: CGSize? = nil,
                                shadowOpacity: Float? = nil,
                                shadowColor: UIColor? = nil) {
        
        if let kCornerRadius = cornerRadius {
            self.bk_cornerRadius = kCornerRadius
        }
        if let kCorners = corners {
            self.bk_roundCorner = kCorners
        }
        if let kBorderWidth = borderWidth {
            self.bk_borderWidth = kBorderWidth
        } else {
            self.bk_borderWidth = 0
        }
        if let kBorderColor = borderColor {
            self.bk_borderColor = kBorderColor
        }
        if let kShadowRadius = shadowRadius {
            self.bk_shadowRadius = kShadowRadius
        }
        if let kShadowColor = shadowColor {
            self.bk_shadowColor = kShadowColor
        }
        if let kShadowOffset = shadowOffset {
            self.bk_shadowOffset = kShadowOffset
        }
        if let kShadowOpacity = shadowOpacity {
            self.bk_shadowOpacity = kShadowOpacity
        }
        
    }
    
    /// 添加毛玻璃效果
    ///
    /// - Parameters:
    ///   - style: 毛玻璃风格
    ///   - alpha: 透明度
    func bk_addBlur(style: UIBlurEffect.Style, alpha: CGFloat) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.alpha = alpha
        self.insertSubview(blurView, at: 0)
    }
    
    /// 添加毛玻璃效果背景
    ///
    /// - Parameters:
    ///   - img: 背景图片
    func bk_addFrostBackground(img: UIImage?, style: UIBlurEffect.Style) {
        let blurImageView = UIImageView(frame: CGRect(x: -self.width/2, y: -self.height/2, width: 2*width, height: 2*height))
        blurImageView.contentMode = .scaleAspectFill
        blurImageView.image = img
        // 创建毛玻璃效果层
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        visualEffectView.frame = blurImageView.frame
        blurImageView.addSubview(visualEffectView)
        self.insertSubview(blurImageView, belowSubview: self)
    }
    
}

extension UIView {
    
    var x: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    var width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }
    
    var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }
    
    var widthB: CGFloat {
        get { return bounds.size.width }
        set { bounds.size.width = newValue }
    }
    
    var heightB: CGFloat {
        get { return bounds.size.height }
        set { bounds.size.height = newValue }
    }
    
    var viewCenter: CGPoint {
        return CGPoint(x: width * 0.5, y: height * 0.5)
    }
    
    var centerX: CGFloat {
        get { return width * 0.5 }
        set { center.x = newValue }
    }
    
    var setCenterY: CGFloat {
        get { return height * 0.5 }
        set { center.y = newValue }
    }
    
    var centerY: CGFloat {
        get { return height * 0.5 }
        set { center.y = newValue }
    }
    
    var inSuperViewCenterY: CGFloat {
        return y + centerY
    }
    
    var left: CGFloat {
        get { return self.x }
        set { x = newValue }
    }
    
    var right: CGFloat {
        get { return self.x + self.width }
        set { x = newValue - self.width }
    }
    
    var top: CGFloat {
        get { return self.y }
        set { y = newValue }
    }
    
    var bottom: CGFloat {
        get { return self.y + self.height }
        set { y = newValue - self.height }
    }
    
    /// 判断一个View是否在主窗口上
    var isShowingOnKeyWindow: Bool {
        let keyWindow = UIApplication.shared.keyWindow
        if let superview = self.superview, let windowBounds = keyWindow?.bounds {
            let newFrame: CGRect = superview.convert(self.frame, to: keyWindow)
            let intersects = newFrame.intersects(windowBounds)
            // 判断一个控件是否真正显示在窗口范围内
            return !self.isHidden && self.alpha > 0.01 && intersects && self.window == keyWindow
        } else {
            return false
        }
    }
    
    /// 判断一个View是否在窗口上
    var isShowingOnDelegateWindow: Bool {
        let mainWindow = UIApplication.shared.mainWindow()
        if let superview = self.superview, let windowBounds = mainWindow?.bounds {
            let newFrame: CGRect = superview.convert(self.frame, to: mainWindow)
            let intersects = newFrame.intersects(windowBounds)
            // 判断一个控件是否真正显示在窗口范围内
            return !self.isHidden && self.alpha > 0.01 && intersects && self.window == mainWindow
        } else {
            return false
        }
    }
    
    /** 对浮点数取整*/
    private func bk_pixelIntegerValue(with pointValue: CGFloat) -> CGFloat {
        return round((pointValue * kScreenScale) / kScreenScale)
    }
    
    /// x轴起点
    var bk_x: CGFloat {
        get { return self.frame.minX }
        set {
            var tempFrame = self.frame
            tempFrame.origin.x = bk_pixelIntegerValue(with: newValue)
            self.frame = tempFrame
        }
    }
    
    /// y轴起点
    var bk_y: CGFloat {
        get { return self.frame.minY }
        set {
            var tempFrame = self.frame
            tempFrame.origin.y = bk_pixelIntegerValue(with: newValue)
            self.frame = tempFrame
        }
    }
    
    /// 宽
    var bk_width: CGFloat {
        get { return self.frame.width }
        set {
            var tempFrame = self.frame
            tempFrame.size.width = bk_pixelIntegerValue(with: newValue)
            self.frame = tempFrame
        }
    }
    
    /// 高
    var bk_height: CGFloat {
        get { return self.frame.height }
        set {
            var tempFrame = self.frame
            tempFrame.size.height = bk_pixelIntegerValue(with: newValue)
            self.frame = tempFrame
        }
    }
    
    /// 起始点
    var bk_origin: CGPoint {
        get { return self.frame.origin }
        set {
            var tempFrame = self.frame
            tempFrame.origin.x = bk_pixelIntegerValue(with: newValue.x)
            tempFrame.origin.y = bk_pixelIntegerValue(with: newValue.y)
            self.frame = tempFrame
        }
    }
    
    /** 尺寸*/
    var bk_size: CGSize {
        get { return self.frame.size }
        set {
            var tempFrame = self.frame
            tempFrame.size.width = bk_pixelIntegerValue(with: newValue.width)
            tempFrame.size.height = bk_pixelIntegerValue(with: newValue.height)
            self.frame = tempFrame
        }
    }
    
    /** 中心点x*/
    var bk_centerX: CGFloat {
        get { return self.center.x }
        set { self.center.x = bk_pixelIntegerValue(with: newValue) }
    }
    
    /** 中心点y*/
    var bk_centerY: CGFloat {
        get { return self.center.y }
        set { self.center.y = bk_pixelIntegerValue(with: newValue) }
    }
    
    /** 中心点*/
    var bk_center: CGPoint {
        get { return self.center }
        set { self.center = CGPoint(x: bk_pixelIntegerValue(with: newValue.x), y: bk_pixelIntegerValue(with: newValue.y)) }
    }
    
    /** 视图右边值*/
    var bk_right: CGFloat {
        get { return bk_x + bk_width }
        set { bk_x = newValue - bk_width }
    }
    
    /** 视图底部值*/
    var bk_bottom: CGFloat {
        get { return bk_y + bk_height }
        set { bk_y = newValue - bk_height }
    }
    
}
