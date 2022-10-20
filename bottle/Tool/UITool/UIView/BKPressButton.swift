//
//  BKPressButton.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/10/26.
//  Copyright © 2020 王锦发. All rights reserved.
//

import UIKit

enum BKProgressButtonStyle {
    case white
    case gray
    case black
}

enum BKProgressButtonState: String {
    case begin
    case moving
    case willCancel
    case didCancel
    case end
    case click
}

typealias PressActionStateCallback = (_ state: BKProgressButtonState) -> Void

class BKPressButton: UIView {
    
    deinit {
        PPP("BKPressButton >>> deinit")
        dpLink.remove(from: .current, forMode: .default)
        dpLink.invalidate()
    }
    
    /// 计时时长
    var interval: Float = 1.0
    
    /// 按钮样式
    var style: BKProgressButtonStyle = .white {
        didSet {
            switch style {
            case .white:
                centerLayer.fillColor = UIColor.white.cgColor
                ringLayer.fillColor = kRGBAColor(R: 255, G: 255, B: 255, A: 0.8).cgColor
            case .gray:
                centerLayer.fillColor = UIColor.gray.cgColor
                ringLayer.fillColor = kRGBAColor(R: 0, G: 0, B: 0, A: 0.8).cgColor
            case .black:
                centerLayer.fillColor = UIColor.black.cgColor
                ringLayer.fillColor = kRGBAColor(R: 0, G: 0, B: 0, A: 0.8).cgColor
            }
        }
    }
    
    /// 中间圆心颜色
    var centerColor: UIColor! {
        didSet { centerLayer.fillColor = centerColor.cgColor }
    }
    
    /// 圆环颜色
    var ringColor: UIColor! {
        didSet { ringLayer.fillColor = ringColor.cgColor }
    }
    
    /// 进度条颜色
    var progressColor: UIColor! {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }
    
    private var tmpInterval: Float = 0.0
    private var progress: Float = 0.0
    private var isTimeOut: Bool = false
    private var isPressed: Bool = false
    private var isCancel: Bool = false
    private var ringFrame: CGRect = .zero
    private var buttonAction: PressActionStateCallback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.layer.addSublayer(ringLayer)
        self.layer.addSublayer(centerLayer)
        self.layer.addSublayer(imageLayer)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        longPress.minimumPressDuration = 0.8
        self.addGestureRecognizer(longPress)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        self.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let w = self.bounds.width
        var mainW = w / 1.0 // w / 2.0
        var mainFrame = CGRect(x: 0, y: 0, width: mainW, height: mainW) // CGRect(x: mainW/2.0, y: mainW/2.0, width: mainW, height: mainW)
        
        imageLayer.frame = mainFrame
        
        var _ringFrame = mainFrame.insetBy(dx: -0.2*mainW/2.0, dy: -0.2*mainW/2.0)
        ringFrame = _ringFrame
        if isPressed {
            _ringFrame = mainFrame.insetBy(dx: -0.3*mainW/2.0, dy: -0.3*mainW/2.0) // -0.4
        }
        
        let ringPath = UIBezierPath(roundedRect: _ringFrame, cornerRadius: _ringFrame.width/2.0)
        ringLayer.path = ringPath.cgPath
        
        if isPressed {
            mainW *= 0.9 // 0.8
            mainFrame = CGRect(x: (w - mainW)/2.0, y: (w - mainW)/2.0, width: mainW, height: mainW)
            imageLayer.frame = mainFrame
        }
        
        let mainPath = UIBezierPath(roundedRect: mainFrame, cornerRadius: mainW/2.0)
        centerLayer.path = mainPath.cgPath
        
        if isPressed {
            let progressFrame = _ringFrame.insetBy(dx: 2.0, dy: 2.0)
            let progressPath = UIBezierPath(roundedRect: progressFrame, cornerRadius: progressFrame.width/2.0)
            progressLayer.path = progressPath.cgPath
            progressLayer.strokeEnd = CGFloat(progress)
        }
        
    }
    
    // MARK: - Public
    func bk_pressAction(_ callback: @escaping PressActionStateCallback) {
        self.buttonAction = callback
    }
    
    func bk_setImage(_ image: UIImage?) {
        centerLayer.fillColor = UIColor.clear.cgColor
        imageLayer.contents = image?.cgImage
    }
    
    // MARK: - Private
    private func stop() {
        
        isPressed = false
        tmpInterval = 0.0
        progress = 0.0
        
        progressLayer.strokeEnd = 0
        progressLayer.removeFromSuperlayer()
        dpLink.isPaused = true
        self.setNeedsDisplay()
        
    }
    
    // MARK: - lazy
    private lazy var imageLayer: CALayer = {
        let _layer = CALayer()
        _layer.backgroundColor = UIColor.clear.cgColor
        _layer.masksToBounds = true
        _layer.frame = self.bounds
        return _layer
    }()
    
    private lazy var centerLayer: CAShapeLayer = {
        let _layer = CAShapeLayer()
        _layer.frame = self.bounds
        _layer.fillColor = UIColor.white.cgColor
        return _layer
    }()
    
    private lazy var ringLayer: CAShapeLayer = {
        let _layer = CAShapeLayer()
        _layer.frame = self.bounds
        _layer.fillColor = kRGBAColor(R: 255, G: 255, B: 255, A: 0.8).cgColor
        return _layer
    }()
    
    private lazy var progressLayer: CAShapeLayer = {
        let _layer = CAShapeLayer()
        _layer.fillColor = UIColor.clear.cgColor
        _layer.strokeColor = kRGBColor(31, 185, 34).cgColor
        _layer.lineWidth = 4
        _layer.lineCap = .round
        return _layer
    }()
    
    private lazy var dpLink: CADisplayLink = {
        let link = CADisplayLink(target: self, selector: #selector(linkRun))
        link.preferredFramesPerSecond = 60
        link.add(to: .current, forMode: .default)
        link.isPaused = true
        return link
    }()
    
}

// MARK: - Selector
extension BKPressButton {
    
    @objc private func linkRun() {
        
        tmpInterval += 1/60.0
        progress = tmpInterval/interval
        
        if tmpInterval >= interval {
            self.stop()
            isTimeOut = true
            self.buttonAction?(.end)
        }
        self.setNeedsDisplay()
        
    }
    
    @objc private func longPressGesture(_ gest: UILongPressGestureRecognizer) {
        switch gest.state {
        case .began:
            
            dpLink.isPaused = false
            isPressed = true
            self.layer.addSublayer(progressLayer)
            self.buttonAction?(.begin)
            
        case .changed:
            
            let point = gest.location(in: self)
            if ringFrame.contains(point) {
                isCancel = false
                self.buttonAction?(.moving)
                if progress >= 0.95 {
                    self.buttonAction?(.end)
                }
            } else {
                isCancel = true
                self.buttonAction?(.willCancel)
            }
            
        case .ended:
            
            self.stop()
            if isCancel {
                self.buttonAction?(.didCancel)
            } else if !isTimeOut {
                self.buttonAction?(.didCancel)
            }
            isTimeOut = false
            
        default:
            
            self.stop()
            isCancel = true
            self.buttonAction?(.didCancel)
            
        }
        self.setNeedsDisplay()
    }
    
    @objc private func tapGesture() {
        self.buttonAction?(.click)
    }
    
}
