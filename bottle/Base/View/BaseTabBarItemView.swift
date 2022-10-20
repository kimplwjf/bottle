//
//  BaseTabBarItemView.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/3/1.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class BaseTabBarItemView: ESTabBarItemContentView {
    
    public var duration = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textColor = XMColor.gray153
        highlightTextColor = .dark
        renderingMode = .alwaysOriginal
        itemContentMode = .alwaysOriginal
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }

    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
}

// MARK: - Private
extension BaseTabBarItemView {
    
    private func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
    
}
