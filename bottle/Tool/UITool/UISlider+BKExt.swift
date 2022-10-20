//
//  UISlider+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/12/9.
//  Copyright © 2020 王锦发. All rights reserved.
//

import Foundation
import UIKit

protocol BKCustomSliderDelegate: NSObjectProtocol {
    func currentValue(_ value: Float)
    func dragSlider(at isIn: Bool)
    func touchDown()
    func touchUp()
}

class BKCustomSlider: UISlider {
    
    weak var delegate: BKCustomSliderDelegate?
    
    var isVertical: Bool = false {
        didSet {
            if isVertical {
                self.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
        self.addTarget(self, action: #selector(sliderTouchDragInside(_:with:)), for: .touchDragInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: .zero, size: CGSize(width: bounds.size.width, height: bounds.size.height))
    }
        
    // MARK: - Selector
    @objc private func sliderTouchDown() {
        PPP("按下")
        self.delegate?.touchDown()
    }
    
    @objc private func sliderTouchUp() {
        PPP("抬起")
        self.delegate?.touchUp()
    }
    
    @objc private func sliderValueChange(_ slider: BKCustomSlider) {
        PPP("当前滑动数值 >>> \(slider.value)")
        self.delegate?.currentValue(slider.value)
    }
    
    @objc private func sliderTouchDragInside(_ slider: BKCustomSlider, with event: UIEvent) {
        let touch = event.allTouches?.first
        guard let point = touch?.location(in: slider) else { return }
        let isIn = slider.bounds.contains(point)
        PPP(isIn ? "IN" : "OUT")
        self.delegate?.dragSlider(at: isIn)
    }
    
}
