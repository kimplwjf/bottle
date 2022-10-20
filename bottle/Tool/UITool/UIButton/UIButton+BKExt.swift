//
//  UIButton+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

// MARK: UIButton 扩展，添加闭包方式监听点击
extension UIButton {
    
    struct AssociatedClosureClass {
        var eventClosure: (UIButton) -> Void
    }
    
    private struct AssociatedKeys {
        static var eventClosureObj: AssociatedClosureClass?
    }
    
    private var eventClosureObj: AssociatedClosureClass {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.eventClosureObj) as? AssociatedClosureClass)! }
        set { objc_setAssociatedObject(self, &AssociatedKeys.eventClosureObj, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @objc private func eventExcuate(_ sender: UIButton) {
        eventClosureObj.eventClosure(sender)
    }
    
    /// 用闭包方式，监听点击
    ///
    /// - Parameter action: 闭包
    func bk_addTarget(_ action: @escaping (UIButton) -> Void) {
        let eventObj = AssociatedClosureClass(eventClosure: action)
        eventClosureObj = eventObj
        addTarget(self, action: #selector(eventExcuate(_:)), for: .touchUpInside)
    }
    
}

// MARK: - 扩大按钮的点击区域
private var TopNameKey = 0
private var RightNameKey = 0
private var BottomNameKey = 0
private var LeftNameKey = 0

extension UIButton {
    
    /// 扩大按钮可点击范围
    func bk_setEnlargeEdge(_ size: CGFloat) {
        objc_setAssociatedObject(self, &TopNameKey, NSNumber(value: Float(size)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &RightNameKey, NSNumber(value: Float(size)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &BottomNameKey, NSNumber(value: Float(size)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &LeftNameKey, NSNumber(value: Float(size)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    /// 扩大按钮可点击范围
    func bk_setEnlargeEdgeWith(top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat) {
        objc_setAssociatedObject(self, &TopNameKey, NSNumber(value: Float(top)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &RightNameKey, NSNumber(value: Float(right)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &BottomNameKey, NSNumber(value: Float(bottom)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &LeftNameKey, NSNumber(value: Float(left)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    private func enlargedRect() -> CGRect {
        let topEdge = objc_getAssociatedObject(self, &TopNameKey) as? NSNumber
        let rightEdge = objc_getAssociatedObject(self, &RightNameKey) as? NSNumber
        let bottomEdge = objc_getAssociatedObject(self, &BottomNameKey) as? NSNumber
        let leftEdge = objc_getAssociatedObject(self, &LeftNameKey) as? NSNumber
        if topEdge != nil && rightEdge != nil && bottomEdge != nil && leftEdge != nil {
            return CGRect(x: bounds.origin.x - CGFloat(leftEdge!.floatValue),
                          y: bounds.origin.y - CGFloat(topEdge!.floatValue),
                          width: bounds.size.width + CGFloat(leftEdge!.floatValue) + CGFloat(rightEdge!.floatValue),
                          height: bounds.size.height + CGFloat(topEdge!.floatValue) + CGFloat(bottomEdge!.floatValue))
        } else {
            return self.bounds
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = self.enlargedRect()
        if rect.equalTo(self.bounds) {
            return super.hitTest(point, with: event)
        }
        return rect.contains(point) ? self : nil
    }
    
}

// MARK: - 按钮添加动画
private var kAnimationTypeKey: UInt = 0
private var kAnimationColorKey: UInt = 1

extension UIButton: CAAnimationDelegate {
    
    enum BKAnimationType: String {
        case inner
        case outer
    }
    
    // MARK: - Public
    var bk_animationType: BKAnimationType? {
        get {
            if let type = objc_getAssociatedObject(self, &kAnimationTypeKey) as? String {
                return BKAnimationType(rawValue: type)
            }
            return nil
        }
        set {
            guard newValue != nil else { return }
            self.clipsToBounds = (newValue == .inner)
            objc_setAssociatedObject(self, &kAnimationTypeKey, newValue?.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var bk_animationColor: UIColor {
        get {
            if let color = objc_getAssociatedObject(self, &kAnimationColorKey) {
                return color as! UIColor
            }
            return .white
        }
        set {
            objc_setAssociatedObject(self, &kAnimationColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Override
    open override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        super.sendAction(action, to: target, for: event)
        
        if let type = bk_animationType {
            var rect: CGRect?
            var radius = self.layer.cornerRadius
            
            var pos = self.touchPoint(event)
            let smallerSize = min(self.frame.width, self.frame.height)
            let longgerSize = max(self.frame.width, self.frame.height)
            var scale = longgerSize / smallerSize + 0.5
            
            switch type {
            case .inner:
                radius = smallerSize / 2
                rect = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
            case .outer:
                scale = 2.5
                pos = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
                rect = CGRect(x: pos.x - self.bounds.width, y: pos.y - self.bounds.height, width: self.bounds.width, height: self.bounds.height)
            }
            
            let _layer = self.animateLayer(rect: rect!, radius: radius, position: pos)
            let group = self.animateGroup(scale)
            self.layer.addSublayer(_layer)
            group.setValue(_layer, forKey: "animatedLayer")
            _layer.add(group, forKey: "buttonAnimation")
        }
        
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let _layer = anim.value(forKey: "animatedLayer") as? CALayer {
            _layer.removeFromSuperlayer()
        }
    }
    
    // MARK: - Private
    private func touchPoint(_ event: UIEvent?) -> CGPoint {
        if let touch = event?.allTouches?.first {
            return touch.location(in: self)
        } else {
            return CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        }
    }
    
    private func animateLayer(rect: CGRect, radius: CGFloat, position: CGPoint) -> CALayer {
        let _layer = CAShapeLayer()
        _layer.lineWidth = 1
        _layer.position = position
        _layer.path = UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath
        
        switch bk_animationType {
        case .inner:
            _layer.fillColor = bk_animationColor.cgColor
            _layer.bounds = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        case .outer:
            _layer.strokeColor = bk_animationColor.cgColor
            _layer.fillColor = UIColor.clear.cgColor
        default:
            break
        }
        return _layer
    }
    
    private func animateGroup(_ scale: CGFloat) -> CAAnimationGroup {
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = NSNumber(value: 1)
        opacityAnim.toValue = NSNumber(value: 0)
        
        let scaleAnim = CABasicAnimation(keyPath: "transform")
        scaleAnim.fromValue = NSValue(caTransform3D: .identity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(scale, scale, scale))
        
        let group = CAAnimationGroup()
        group.animations = [opacityAnim, scaleAnim]
        group.duration = 0.5
        group.delegate = self
        group.fillMode = .both
        group.isRemovedOnCompletion = false
        return group
    }
    
}

// MARK: - BKBorderButton
class BKBorderButton: UIButton {
    
    var isShowBorder: Bool = false {
        willSet {
            if newValue {
                self.layer.borderColor = kColor.cgColor
                self.layer.borderWidth = 1.0
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0.0
            }
        }
    }
    
    private let kColor: UIColor
    
    init(frame: CGRect = .zero, color: UIColor = XMColor.gray153) {
        kColor = color
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
