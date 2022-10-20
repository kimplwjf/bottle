//
//  BKPopoverView.swift
//  dysaidao
//
//  Created by 王锦发 on 2022/4/4.
//  Copyright © 2022 王锦发. All rights reserved.
//

import Foundation
import UIKit

enum PopoverOption {
    case arrowSize(CGSize)
    case animationIn(TimeInterval)
    case animationOut(TimeInterval)
    case popoverCornerRadius(CGFloat)
    case sideEdge(CGFloat)
    case blackOverlayColor(UIColor)
    case overlayBlur(UIBlurEffect.Style)
    case type(PopoverType)
    case color(UIColor)
    case dismissOnBlackOverlayTap(Bool)
    case showBlackOverlay(Bool)
    case springDamping(CGFloat)
    case initialSpringVelocity(CGFloat)
    case sideOffset(CGFloat)
    case popoverBorderColor(UIColor)
    case showShadow(Bool)
    case arrowPositionRatio(CGFloat)
    case highlightFromView(Bool)
    case highlightCornerRadius(CGFloat)
}

enum PopoverType: Int {
    case up
    case down
    case left
    case right
    case auto
}

class BKPopoverView: UIView {
    
    /// 箭头大小
    var arrowSize: CGSize = CGSize(width: 10.0, height: 6.0)
    /// 动画显现时间
    var animationIn: TimeInterval = 0.35
    /// 动画消失时间
    var animationOut: TimeInterval = 0.35
    /// 气泡圆角
    var popoverCornerRadius: CGFloat = 8.0
    /// 最小边距
    var sideEdge: CGFloat = 10.0
    /// 遮罩颜色
    var blackOverlayColor: UIColor = UIColor(white: 0.0, alpha: 0.3)
    /// 模糊
    var overlayBlur: UIBlurEffect?
    /// 气泡方向
    var popoverType: PopoverType = .down
    /// 气泡颜色
    var popoverColor: UIColor = .white
    /// 遮罩是否允许点击消失
    var dismissOnBlackOverlayTap: Bool = true
    /// 是否显示遮罩
    var showBlackOverlay: Bool = true
    /// 动画阻尼
    var springDamping: CGFloat = 0.7
    /// 动画初始速度
    var initialSpringVelocity: CGFloat = 3
    /// 气泡水平展示边距
    var sideOffset: CGFloat = 6.0
    /// 气泡边框颜色
    var popoverBorderColor: UIColor?
    /// 是否显示阴影
    var showShadow: Bool = true
    /// 箭头所在位置比例
    var arrowPositionRatio: CGFloat = 0.5
    /// 高亮FromView
    var highlightFromView: Bool = false
    /// 高亮FromView圆角
    var highlightCornerRadius: CGFloat = 0
    
    var willShowHandler: (() -> Void)?
    var willDismissHandler: (() -> Void)?
    var didShowHandler: (() -> Void)?
    var didDismissHandler: (() -> Void)?
    
    fileprivate(set) var blackOverlay: UIControl = UIControl()
    fileprivate var containerView: UIView!
    fileprivate var contentView: UIView!
    fileprivate var arrowShowPoint: CGPoint!
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.accessibilityViewIsModal = true
    }
    
    init(showHandler: (() -> Void)?, dismissHandler: (() -> Void)?) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.didShowHandler = showHandler
        self.didDismissHandler = dismissHandler
        self.accessibilityViewIsModal = true
    }
    
    init(options: [PopoverOption], showHandler: (() -> Void)? = nil, dismissHandler: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.setOptions(options)
        self.didShowHandler = showHandler
        self.didDismissHandler = dismissHandler
        self.accessibilityViewIsModal = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
    
    override func accessibilityPerformEscape() -> Bool {
        self.dismiss()
        return true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let arrow = UIBezierPath()
        let color = popoverColor
        let arrowPoint = containerView.convert(arrowShowPoint, to: self)
        switch popoverType {
        case .up:
            arrow.move(to: CGPoint(x: arrowPoint.x, y: bounds.height))
            arrow.addLine(to: CGPoint(
                x: arrowPoint.x - arrowSize.width*0.5,
                y: isCornerLeftArrow ? arrowSize.height : bounds.height - arrowSize.height
            ))
            
            arrow.addLine(to: CGPoint(x: popoverCornerRadius, y: bounds.height - arrowSize.height))
            arrow.addArc(withCenter: CGPoint(
                x: popoverCornerRadius,
                y: bounds.height - arrowSize.height - popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(90),
            endAngle: self.radians(180),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: popoverCornerRadius))
            arrow.addArc(withCenter: CGPoint(
                x: popoverCornerRadius,
                y: popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(180),
            endAngle: self.radians(270),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(x: bounds.width - popoverCornerRadius, y: 0))
            arrow.addArc(withCenter: CGPoint(
                x: bounds.width - popoverCornerRadius,
                y: popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(270),
            endAngle: self.radians(0),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(x: bounds.width, y: bounds.height - arrowSize.height - popoverCornerRadius))
            arrow.addArc(withCenter: CGPoint(
                x: bounds.width - popoverCornerRadius,
                y: bounds.height - arrowSize.height - popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(0),
            endAngle: self.radians(90),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(
                x: arrowPoint.x + arrowSize.width*0.5,
                y: isCornerRightArrow ? arrowSize.height : bounds.height - arrowSize.height
            ))
        case .down, .auto:
            arrow.move(to: CGPoint(x: arrowPoint.x, y: 0))
            if isCloseToCornerRightArrow && !isCornerRightArrow {
                if !isBehindCornerRightArrow {
                    arrow.addLine(to: CGPoint(x: bounds.width - popoverCornerRadius, y: arrowSize.height))
                    arrow.addArc(
                        withCenter: CGPoint(x: bounds.width - popoverCornerRadius, y: arrowSize.height + popoverCornerRadius),
                        radius: popoverCornerRadius,
                        startAngle: self.radians(270),
                        endAngle: self.radians(0),
                        clockwise: true)
                } else {
                    arrow.addLine(to: CGPoint(x: bounds.width, y: arrowSize.height + popoverCornerRadius))
                    arrow.addLine(to: CGPoint(x: bounds.width, y: arrowSize.height))
                }
            } else {
                arrow.addLine(to: CGPoint(
                    x: isBehindCornerLeftArrow ? frame.minX - arrowSize.width*0.5 : arrowPoint.x + arrowSize.width*0.5,
                    y: isCornerRightArrow ? arrowSize.height + bounds.height : arrowSize.height
                ))
                arrow.addLine(to: CGPoint(x: bounds.width - popoverCornerRadius, y: arrowSize.height))
                arrow.addArc(withCenter: CGPoint(
                    x: bounds.width - popoverCornerRadius,
                    y: arrowSize.height + popoverCornerRadius
                ),
                radius: popoverCornerRadius,
                startAngle: self.radians(270),
                endAngle: self.radians(0),
                clockwise: true)
            }
            
            arrow.addLine(to: CGPoint(x: bounds.width, y: bounds.height - popoverCornerRadius))
            arrow.addArc(withCenter: CGPoint(
                x: bounds.width - popoverCornerRadius,
                y: bounds.height - popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(0),
            endAngle: self.radians(90),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: bounds.height))
            arrow.addArc(withCenter: CGPoint(
                x: popoverCornerRadius,
                y: bounds.height - popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(90),
            endAngle: self.radians(180),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: arrowSize.height + popoverCornerRadius))
            
            if !isBehindCornerLeftArrow {
                arrow.addArc(withCenter: CGPoint(
                    x: popoverCornerRadius,
                    y: arrowSize.height + popoverCornerRadius
                ),
                radius: popoverCornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            }
            
            if isBehindCornerRightArrow {
                arrow.addLine(to: CGPoint(
                    x: bounds.width - arrowSize.width*0.5,
                    y: isCornerLeftArrow ? arrowSize.height + bounds.height : arrowSize.height
                ))
            } else if isCloseToCornerLeftArrow && !isCornerLeftArrow {
                
            } else {
                arrow.addLine(to: CGPoint(
                    x: arrowPoint.x - arrowSize.width*0.5,
                    y: isCornerLeftArrow ? arrowSize.height + bounds.height : arrowSize.height
                ))
            }
        case .left:
            arrow.move(to: CGPoint(x: bounds.width, y: arrowPoint.y))
            arrow.addLine(to: CGPoint(
                x: bounds.width - arrowSize.width,
                y: arrowPoint.y + arrowSize.height*0.5
            ))
            
            arrow.addLine(to: CGPoint(x: bounds.width - arrowSize.width, y: bounds.height - popoverCornerRadius))
            arrow.addArc(withCenter: CGPoint(
                x: bounds.width - arrowSize.width - popoverCornerRadius,
                y: bounds.height - popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(0),
            endAngle: self.radians(90),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(x: popoverCornerRadius, y: bounds.height))
            arrow.addArc(withCenter: CGPoint(
                x: popoverCornerRadius,
                y: bounds.height - popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(90),
            endAngle: self.radians(180),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: popoverCornerRadius))
            arrow.addArc(withCenter: CGPoint(
                x: popoverCornerRadius,
                y: popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(180),
            endAngle: self.radians(270),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(x: bounds.width - arrowSize.width - popoverCornerRadius, y: 0))
            arrow.addArc(withCenter: CGPoint(
                x: bounds.width - arrowSize.width - popoverCornerRadius,
                y: popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(270),
            endAngle: self.radians(0),
            clockwise: true)
            
            arrow.addLine(to: CGPoint(
                x: bounds.width - arrowSize.width,
                y: arrowPoint.y - arrowSize.height*0.5
            ))
        case .right:
            arrow.move(to: CGPoint(x: arrowPoint.x, y: arrowPoint.y))
            arrow.addLine(to: CGPoint(
                x: arrowPoint.x + arrowSize.width,
                y: arrowPoint.y + arrowSize.height*0.5
            ))
            
            arrow.addLine(to: CGPoint(x: arrowPoint.x + arrowSize.width, y: bounds.height - popoverCornerRadius))
            arrow.addArc(withCenter: CGPoint(
                x: arrowPoint.x + arrowSize.width + popoverCornerRadius,
                y: bounds.height - popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(180),
            endAngle: self.radians(90),
            clockwise: false)
            
            arrow.addLine(to: CGPoint(x: bounds.width + arrowPoint.x - popoverCornerRadius, y: bounds.height))
            arrow.addArc(withCenter: CGPoint(
                x: bounds.width + arrowPoint.x - popoverCornerRadius,
                y: bounds.height - popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(90),
            endAngle: self.radians(0),
            clockwise: false)
            
            arrow.addLine(to: CGPoint(x: bounds.width + arrowPoint.x, y: popoverCornerRadius))
            arrow.addArc(withCenter: CGPoint(
                x: bounds.width + arrowPoint.x - popoverCornerRadius,
                y: popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(0),
            endAngle: self.radians(-90),
            clockwise: false)
            
            arrow.addLine(to: CGPoint(x: arrowPoint.x + arrowSize.width - popoverCornerRadius, y: 0))
            arrow.addArc(withCenter: CGPoint(
                x: arrowPoint.x + arrowSize.width + popoverCornerRadius,
                y: popoverCornerRadius
            ),
            radius: popoverCornerRadius,
            startAngle: self.radians(-90),
            endAngle: self.radians(-180),
            clockwise: false)
            
            arrow.addLine(to: CGPoint(
                x: arrowPoint.x + arrowSize.width,
                y: arrowPoint.y - arrowSize.height*0.5
            ))
        }
        
        color.setFill()
        arrow.fill()
        if let popoverBorderColor = popoverBorderColor {
            popoverBorderColor.setStroke()
            arrow.stroke()
        }
    }
    
}

// MARK: - Public
extension BKPopoverView {
    
    func showDialog(_ contentView: UIView) {
        guard let rootView = UIApplication.shared.keyWindow else { return }
        self.showDialog(contentView, inView: rootView)
    }
    
    func showDialog(_ contentView: UIView, inView: UIView) {
        arrowSize = .zero
        let point = CGPoint(x: inView.center.x, y: inView.center.y - contentView.frame.height/2)
        self.show(contentView, point: point, inView: inView)
    }
    
    func show(_ contentView: UIView, fromView: UIView) {
        guard let rootView = UIApplication.shared.keyWindow else { return }
        self.show(contentView, fromView: fromView, inView: rootView)
    }
    
    func show(_ contentView: UIView, fromView: UIView, inView: UIView) {
        let point: CGPoint
        if popoverType == .auto {
            if let point = fromView.superview?.convert(fromView.frame.origin, to: nil), point.y + fromView.frame.height + arrowSize.height + contentView.frame.height > inView.frame.height {
                popoverType = .up
            } else {
                popoverType = .down
            }
        }
        
        switch popoverType {
        case .up:
            point = inView.convert(CGPoint(
                x: fromView.frame.origin.x + fromView.frame.size.width/2,
                y: fromView.frame.origin.y
            ), from: fromView.superview)
        case .down, .auto:
            point = inView.convert(CGPoint(
                x: fromView.frame.origin.x + fromView.frame.size.width/2,
                y: fromView.frame.origin.y + fromView.frame.size.height
            ), from: fromView.superview)
        case .left:
            point = inView.convert(CGPoint(
                x: fromView.frame.origin.x - sideOffset,
                y: fromView.frame.origin.y + 0.5*fromView.frame.height
            ), from: fromView.superview)
        case .right:
            point = inView.convert(CGPoint(
                x: fromView.frame.origin.x + fromView.frame.size.width + sideOffset,
                y: fromView.frame.origin.y + 0.5*fromView.frame.height
            ), from: fromView.superview)
        }
        
        if highlightFromView {
            self.createHighlightLayer(fromView: fromView, inView: inView)
        }
        self.show(contentView, point: point, inView: inView)
    }
    
    func show(_ contentView: UIView, point: CGPoint) {
        guard let rootView = UIApplication.shared.keyWindow else { return }
        self.show(contentView, point: point, inView: rootView)
    }
    
    func show(_ contentView: UIView, point: CGPoint, inView: UIView) {
        if dismissOnBlackOverlayTap || showBlackOverlay {
            blackOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blackOverlay.frame = inView.bounds
            inView.addSubview(blackOverlay)
            
            if showBlackOverlay {
                if let overlayBlur = overlayBlur {
                    let effectView = UIVisualEffectView(effect: overlayBlur)
                    effectView.frame = blackOverlay.bounds
                    effectView.isUserInteractionEnabled = false
                    blackOverlay.addSubview(effectView)
                } else {
                    if !highlightFromView {
                        blackOverlay.backgroundColor = blackOverlayColor
                    }
                    blackOverlay.alpha = 0
                }
            }
            
            if dismissOnBlackOverlayTap {
                blackOverlay.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
            }
        }
        
        containerView = inView
        self.contentView = contentView
        self.contentView.backgroundColor = .clear
        self.contentView.layer.cornerRadius = popoverCornerRadius
        self.contentView.layer.masksToBounds = true
        self.arrowShowPoint = point
        self.show()
    }
    
    @objc func dismiss() {
        if superview != nil {
            self.willDismissHandler?()
            UIView.animate(withDuration: animationOut, delay: 0, options: UIView.AnimationOptions()) {
                self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
                self.blackOverlay.alpha = 0
            } completion: { _ in
                self.contentView.removeFromSuperview()
                self.blackOverlay.removeFromSuperview()
                self.removeFromSuperview()
                self.transform = .identity
                self.didDismissHandler?()
            }
        }
    }
    
}

// MARK: - Private
private extension BKPopoverView {
    
    var isCloseToCornerLeftArrow: Bool {
        return arrowShowPoint.x < frame.origin.x + arrowSize.width/2 + popoverCornerRadius
    }
    
    var isCloseToCornerRightArrow: Bool {
        return arrowShowPoint.x > (frame.origin.x + bounds.width)-arrowSize.width/2-popoverCornerRadius
    }
    
    var isCornerLeftArrow: Bool {
        return arrowShowPoint.x == frame.origin.x
    }
    
    var isCornerRightArrow: Bool {
        return arrowShowPoint.x == frame.origin.x + bounds.width
    }
    
    var isBehindCornerLeftArrow: Bool {
        return arrowShowPoint.x < frame.origin.x
    }
    
    var isBehindCornerRightArrow: Bool {
        return arrowShowPoint.x > frame.origin.x + bounds.width
    }
    
    func radians(_ degress: CGFloat) -> CGFloat {
        return CGFloat.pi * degress / 180
    }
    
    func setOptions(_ options: [PopoverOption]) {
        for option in options {
            switch option {
            case .arrowSize(let cGSize):
                arrowSize = cGSize
            case .animationIn(let timeInterval):
                animationIn = timeInterval
            case .animationOut(let timeInterval):
                animationOut = timeInterval
            case .popoverCornerRadius(let cGFloat):
                popoverCornerRadius = cGFloat
            case .sideEdge(let cGFloat):
                sideEdge = cGFloat
            case .blackOverlayColor(let uIColor):
                blackOverlayColor = uIColor
            case .overlayBlur(let style):
                overlayBlur = UIBlurEffect(style: style)
            case .type(let type):
                popoverType = type
            case .color(let uIColor):
                popoverColor = uIColor
            case .dismissOnBlackOverlayTap(let bool):
                dismissOnBlackOverlayTap = bool
            case .showBlackOverlay(let bool):
                showBlackOverlay = bool
            case .springDamping(let cGFloat):
                springDamping = cGFloat
            case .initialSpringVelocity(let cGFloat):
                initialSpringVelocity = cGFloat
            case .sideOffset(let cGFloat):
                sideOffset = cGFloat
            case .popoverBorderColor(let uIColor):
                popoverBorderColor = uIColor
            case .showShadow(let bool):
                showShadow = bool
            case .arrowPositionRatio(let cGFloat):
                arrowPositionRatio = cGFloat
            case .highlightFromView(let bool):
                highlightFromView = bool
            case .highlightCornerRadius(let cGFloat):
                highlightCornerRadius = cGFloat
            }
        }
    }
    
    func create() {
        var _frame = contentView.frame
        
        switch popoverType {
        case .up, .down, .auto:
            _frame = self.dealPopoverViewFrameInHorizontal(_frame)
        case .left, .right:
            _frame.origin.y = arrowShowPoint.y - _frame.size.height * arrowPositionRatio
        }
        frame = _frame
        
        let arrowPoint = containerView.convert(arrowShowPoint, to: self)
        var anchorPoint: CGPoint
        var shadowOffset: CGSize = .zero
        switch popoverType {
        case .up:
            _frame.origin.y = arrowShowPoint.y - _frame.height - arrowSize.height
            anchorPoint = CGPoint(x: arrowPoint.x/_frame.size.width, y: 1)
            shadowOffset = CGSize(width: 2, height: 0)
        case .down, .auto:
            _frame.origin.y = arrowShowPoint.y
            anchorPoint = CGPoint(x: arrowPoint.x/_frame.size.width, y: 0)
            shadowOffset = CGSize(width: 2, height: 0)
        case .left:
            _frame.origin.x = arrowShowPoint.x - _frame.size.width - arrowSize.width
            anchorPoint = CGPoint(x: 1, y: arrowPoint.y/_frame.size.height)
            shadowOffset = CGSize(width: 0, height: 2)
        case .right:
            _frame.origin.x = arrowShowPoint.x
            anchorPoint = CGPoint(x: 0, y: arrowPoint.y/_frame.size.height)
            shadowOffset = CGSize(width: 0, height: 2)
        }
        
        if arrowSize == .zero {
            anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
        
        let lastAnchor = self.layer.anchorPoint
        self.layer.anchorPoint = anchorPoint
        let x = self.layer.position.x + (anchorPoint.x - lastAnchor.x)*self.layer.bounds.size.width
        let y = self.layer.position.y + (anchorPoint.y - lastAnchor.y)*self.layer.bounds.size.height
        self.layer.position = CGPoint(x: x, y: y)
        
        switch popoverType {
        case .up, .down, .auto:
            _frame.size.height += arrowSize.height
        case .left, .right:
            _frame.size.width += arrowSize.width
        }
        frame = _frame
        
        if showShadow {
            self.layer.cornerRadius = 4
            self.layer.shadowColor = UIColor(red: 32.0/255.0, green: 32.0/255.0, blue: 32.0/255.0, alpha: 0.5).cgColor
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowOpacity = 1
            self.layer.shadowRadius = 4
        }
    }
    
    func dealPopoverViewFrameInHorizontal(_ frame: CGRect) -> CGRect {
        var _frame = frame
        _frame.origin.x = arrowShowPoint.x - _frame.size.width * arrowPositionRatio
        var _sideEdge: CGFloat = 0.0
        if _frame.size.width < containerView.frame.size.width {
            _sideEdge = sideEdge
        }
        
        let outerSideEdge = _frame.maxX - containerView.bounds.size.width
        if outerSideEdge > 0 {
            _frame.origin.x -= (outerSideEdge + _sideEdge)
        } else if _frame.minX < 0 {
            _frame.origin.x += abs(_frame.minX) + _sideEdge
        }
        return _frame
    }
    
    func createHighlightLayer(fromView: UIView, inView: UIView) {
        let path = UIBezierPath(rect: inView.bounds)
        let highlightRect = inView.convert(fromView.frame, to: fromView.superview)
        let highlightPath = UIBezierPath(roundedRect: highlightRect, cornerRadius: highlightCornerRadius)
        path.append(highlightPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = blackOverlayColor.cgColor
        blackOverlay.layer.addSublayer(fillLayer)
    }
    
    func show() {
        self.setNeedsDisplay()
        switch popoverType {
        case .up:
            contentView.frame.origin.y = 0.0
        case .down, .auto:
            contentView.frame.origin.y = arrowSize.height
        case .left:
            contentView.frame.origin.x = 0.0
        case .right:
            contentView.frame.origin.x = arrowSize.width
        }
        self.addSubview(contentView)
        containerView.addSubview(self)
        
        self.create()
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.willShowHandler?()
        UIView.animate(withDuration: animationIn,
                       delay: 0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: initialSpringVelocity,
                       options: UIView.AnimationOptions()) {
            self.transform = .identity
        } completion: { _ in
            self.didShowHandler?()
        }
        UIView.animate(withDuration: animationIn/3, delay: 0, options: .curveLinear) {
            self.blackOverlay.alpha = 1
        }
    }
    
}
