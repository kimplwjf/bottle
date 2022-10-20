//
//  UIRippleAnimationView.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/1/14.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class UIRippleAnimationView: UIView {
    
    enum RippleAnimationType: Int {
        case withBackground
        case withoutBackground
    }
    
    /// 扩散倍数,默认1.423
    private var multiple: CGFloat = 1.423
    /// 脉冲圈个数
    private var pulseCount = 3
    /// 单个脉冲圈动画时长
    private var animationDuration: TimeInterval = 3.0
    /// 扩散颜色
    private var pulseColors: [UIColor] = [
        kRGBAColor(R: 255, G: 216, B: 87, A: 0.5),
        kRGBAColor(R: 255, G: 231, B: 152, A: 0.5),
        kRGBAColor(R: 255, G: 241, B: 197, A: 0.5),
        kRGBAColor(R: 255, G: 241, B: 197, A: 0)
    ]
    
    private let kAnimationType: RippleAnimationType
    
    init(frame: CGRect = .zero, animationType: RippleAnimationType = .withBackground) {
        kAnimationType = animationType
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        multiple = animationType == .withBackground ? 1.423 : 1.523
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let animationLayer = CALayer()
        for i in 0..<pulseCount {
            let animationArr = self.animationArray()
            let animationGroup = self.animationGroup(animations: animationArr, index: i)
            let pulsingLayer = self.pulsingLayer(rect: rect, animationGroup: animationGroup)
            animationLayer.addSublayer(pulsingLayer)
        }
        self.layer.addSublayer(animationLayer)
    }
    
}

// MARK: - Private
extension UIRippleAnimationView {
    
    private func animationArray() -> [CAAnimation] {
        let animationArr: [CAAnimation]
        switch kAnimationType {
        case .withBackground:
            let scaleAnimation = self.scaleAnimation()
            let borderColorAnimation = self.borderColorAnimation()
            let backgroundColorAnimation = self.backgroundColorAnimation()
            animationArr = [scaleAnimation, backgroundColorAnimation, borderColorAnimation]
        case .withoutBackground:
            let scaleAnimation = self.scaleAnimation()
            let blackBorderColorAnimation = self.blackBorderColorAnimation()
            animationArr = [scaleAnimation, blackBorderColorAnimation]
        }
        return animationArr
    }
    
    private func animationGroup(animations: [CAAnimation], index: Int) -> CAAnimationGroup {
        let defaultCurve: CAMediaTimingFunction = CAMediaTimingFunction(name: .default)
        let animationGroup = CAAnimationGroup()
        animationGroup.fillMode = .backwards
        animationGroup.beginTime = CACurrentMediaTime() + Double(index)*animationDuration/Double(pulseCount)
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = HUGE
        animationGroup.timingFunction = defaultCurve
        animationGroup.animations = animations
        animationGroup.isRemovedOnCompletion = false
        return animationGroup
    }
    
    private func pulsingLayer(rect: CGRect, animationGroup: CAAnimationGroup) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        switch kAnimationType {
        case .withBackground:
            pulsingLayer.backgroundColor = pulseColors.first?.cgColor
            pulsingLayer.borderWidth = 0.5
        case .withoutBackground:
            pulsingLayer.borderWidth = 1.0
        }
        pulsingLayer.backgroundColor = pulseColors.first?.cgColor
        pulsingLayer.cornerRadius = rect.size.height/2
        pulsingLayer.add(animationGroup, forKey: "pulsing")
        return pulsingLayer
    }
    
    private func scaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = multiple
        return scaleAnimation
    }
    
    private func backgroundColorAnimation() -> CAKeyframeAnimation {
        let backgroundColorAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.values = pulseColors.map { $0.cgColor }
        backgroundColorAnimation.keyTimes = [0.3, 0.6, 0.9, 1]
        return backgroundColorAnimation
    }
    
    private func borderColorAnimation() -> CAKeyframeAnimation {
        let borderColorAnimation = CAKeyframeAnimation(keyPath: "borderColor")
        borderColorAnimation.values = pulseColors.map { $0.cgColor }
        borderColorAnimation.keyTimes = [0.3, 0.6, 0.9, 1]
        return borderColorAnimation
    }
    
    private func blackBorderColorAnimation() -> CAKeyframeAnimation {
        let borderColorAnimation = CAKeyframeAnimation(keyPath: "borderColor")
        borderColorAnimation.values = [UIColor.black.withAlphaComponent(0.4).cgColor,
                                       UIColor.black.withAlphaComponent(0.4).cgColor,
                                       UIColor.black.withAlphaComponent(0.1).cgColor,
                                       UIColor.black.withAlphaComponent(0).cgColor]
        borderColorAnimation.keyTimes = [0.3, 0.6, 0.9, 1]
        return borderColorAnimation
    }
    
}
