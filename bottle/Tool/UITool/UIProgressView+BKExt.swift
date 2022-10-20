//
//  UIProgressView+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/4/11.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

// MARK: - 长条形进度条(可渐变)
class BKGradientProgressView: UIView {
    
    /** 进度条完成部分的渐变颜色，设置单个为纯色，设置多个为渐变色*/
    public var progressColors: [UIColor] = [.blue] {
        didSet {
            if progressColors.count == 0 {
                gradientLayer.colors = nil
            } else if progressColors.count == 1 {
                let color = progressColors[0]
                gradientLayer.bk_colors([color, color], with: self)
            } else {
                gradientLayer.bk_colors(progressColors, with: self)
            }
        }
    }
    
    /** 进度条完成部分的圆角半径*/
    public var progressCornerRadius: CGFloat = 0 {
        didSet {
            maskLayer.cornerRadius = progressCornerRadius
        }
    }
    
    /** 进度完成部分的内间距*/
    public var progressEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    /** 当前进度*/
    public var progress: Float {
        get { return privateProgress }
        set { setProgress(newValue, animated: false) }
    }
    
    // 渐变Layer
    public let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.anchorPoint = .zero
        layer.startPoint = .zero
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
        return layer
    }()
    
    /** 动画持续时间*/
    public var animationDuration: TimeInterval = 0.3
    
    /** 动画时间函数*/
    public var timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .default)
    
    /** 进度更新动画过程中的回调，在这里可以拿到当前进度及进度条的frame*/
    public var progressUpdating: ((Float, CGRect) -> ())?
    
    private var privateProgress: Float = 0
    
    private let maskLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.lightWhiteDark27.cgColor
        return layer
    }()
    
    // MARK: - Lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds.inset(by: progressEdgeInsets)
        var bounds = gradientLayer.bounds
        bounds.size.width *= CGFloat(progress)
        maskLayer.frame = bounds
    }
    
}

// MARK: - Selector
extension BKGradientProgressView {
    
    @objc private func displayLinkAction() {
        guard let frame = maskLayer.presentation()?.frame else { return }
        let progress = frame.size.width / gradientLayer.frame.size.width
        progressUpdating?(Float(progress), frame)
    }
    
}

// MARK: - Private
extension BKGradientProgressView {
    
    private func commonInit() {
        let color = progressColors[0]
        gradientLayer.bk_colors([color, color], with: self)
        gradientLayer.mask = maskLayer
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

// MARK: - Public
extension BKGradientProgressView {
    
    func setProgress(_ pro: Float, animated: Bool) {
        let validProgress = min(1.0, max(0.0, pro))
        if privateProgress == validProgress {
            return
        }
        privateProgress = validProgress
        
        //动画时长
        var duration = animated ? animationDuration : 0
        if duration < 0 {
            duration = 0
        }
        
        var displayLink: CADisplayLink?
        if duration > 0 {
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
            //使用common模式，使其在UIScrollView滑动时依然能得到回调
            displayLink?.add(to: .main, forMode: .common)
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        CATransaction.setCompletionBlock {
            //停止CADisplayLink
            displayLink?.invalidate()
            if duration == 0 {
                self.progressUpdating?(validProgress, self.maskLayer.frame)
            } else {
                if let _ = self.maskLayer.presentation() {
                    self.displayLinkAction()
                } else {
                    self.progressUpdating?(validProgress, self.maskLayer.frame)
                }
            }
        }
        
        //更新maskLayer的frame
        var bounds = self.gradientLayer.bounds
        bounds.size.width *= CGFloat(validProgress)
        self.maskLayer.frame = bounds
        
        CATransaction.commit()
    }
    
}

// MARK: - 圆形进度条(可渐变)
class BKCircleGradientProgressView: UIView {
    
    struct Style {
        /// 进度条宽度
        var lineWidth: CGFloat = 4.0
        /// 进度条颜色
        var progressColors = [UIColor.dark]
        /// 进度槽颜色
        var trackColor = XMColor.gray248
        /// 是否展示头部圆点图标
        var isShowArrow: Bool = false
    }
    
    /// 当前进度
    var progress: Int = 0 {
        didSet {
            if progress > 100 {
                progress = 100
            } else if progress < 0 {
                progress = 0
            }
        }
    }
    
    // 样式
    private var kStyle: Style = Style()
    // 进度槽
    private let trackLayer = CAShapeLayer()
    // 渐变进度条
    private let gradientLayer = CAGradientLayer()
    // 进度条的layer层
    private let progressLayer = CAShapeLayer()
    // 进度条路径(整个圆圈)
    private let path = UIBezierPath()
    // 头部圆点
    private var dot = UIView()
    // 头部圆点图标
    private var arrow = UIImageView(image: UIImage(named: "icon_progress_arrow"))
    
    // 进度条圆环中点
    private var progressCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // 进度条圆环radius
    private var radius: CGFloat {
        return bounds.size.width/2 - kStyle.lineWidth
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** 便利构造*/
    convenience init(frame: CGRect = .zero, style: Style) {
        self.init(frame: frame)
        kStyle = style
    }
    
    override func draw(_ rect: CGRect) {
        // 防止频繁调用draw(_ rect: CGRect)叠加绘制
        guard !subviews.contains(dot) else {
            trackLayer.strokeColor = kStyle.trackColor.cgColor
            if kStyle.progressColors.count == 1 {
                let color = kStyle.progressColors[0]
                gradientLayer.bk_colors([color, color], with: self)
            } else {
                gradientLayer.bk_colors(kStyle.progressColors, with: self)
            }
            return
        }
        // 获取整个进度条圆圈路径
        path.addArc(withCenter: progressCenter, radius: radius, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        
        // 绘制进度槽
        trackLayer.frame = bounds
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = kStyle.trackColor.cgColor
        trackLayer.lineWidth = kStyle.lineWidth
        trackLayer.path = path.cgPath
        layer.addSublayer(trackLayer)
        
        // 绘制渐变进度条
        gradientLayer.frame = bounds
        if kStyle.progressColors.count == 1 {
            let color = kStyle.progressColors[0]
            gradientLayer.bk_colors([color, color], with: self)
        } else {
            gradientLayer.bk_colors(kStyle.progressColors, with: self)
        }
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        layer.addSublayer(gradientLayer)
        
        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = kStyle.progressColors[0].cgColor
        progressLayer.lineWidth = kStyle.lineWidth
        progressLayer.lineCap = .round
        progressLayer.path = path.cgPath
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = CGFloat(progress)/100.0
        // 修改渐变layer层的遮罩
        gradientLayer.mask = progressLayer
//        layer.addSublayer(progressLayer)
        
        // 绘制进度条头部圆点
        dot.frame = CGRect(x: 0, y: 0, width: kStyle.lineWidth, height: kStyle.lineWidth)
        let dotPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: kStyle.lineWidth, height: kStyle.lineWidth)).cgPath
        let arc = CAShapeLayer()
        arc.lineWidth = 0
        arc.path = dotPath
        arc.strokeStart = 0
        arc.strokeEnd = 1
        arc.strokeColor = kStyle.progressColors[0].cgColor
        arc.fillColor = kStyle.progressColors[0].cgColor
        arc.shadowColor = UIColor.black.cgColor
        arc.shadowRadius = 2.0
        arc.shadowOpacity = 0.3
        arc.shadowOffset = .zero
        dot.layer.addSublayer(arc)
        addSubview(dot)
        
        if kStyle.isShowArrow {
            // 圆点中添加图标
            arrow.frame.size = CGSize(width: kStyle.lineWidth, height: kStyle.lineWidth)
            dot.addSubview(arrow)
        }
        
        // 设置圆点位置
        dot.layer.position = calculateCircleCoordinate(progressCenter, radius: radius, angle: CGFloat(-progress)/100*360+90)
    }
    
}

// MARK: - Public
extension BKCircleGradientProgressView {
    
    /// 设置进度(可以设置是否播放动画)
    func setProgress(_ pro: Int, animated flag: Bool) {
        setProgress(pro, animated: flag, duration: 0.5)
    }
    
    /// 设置进度(可以设置是否播放动画,以及动画时间)
    func setProgress(_ pro: Int, animated flag: Bool, duration: Double) {
        dot.isHidden = pro == 0
        var oldProgress = progress
        progress = pro
        
        // 进度条动画
        CATransaction.begin()
        CATransaction.setDisableActions(!flag)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        CATransaction.setAnimationDuration(duration)
        progressLayer.strokeEnd = CGFloat(progress)/100.0
        CATransaction.commit()
        
        if oldProgress == progress {
            oldProgress = 0
        }
        // 头部圆点动画
        let startAngle = angleToRadian(360*Double(oldProgress)/100 - 90)
        let endAngle = angleToRadian(360*Double(progress)/100 - 90)
        let clockWise = progress < oldProgress
        
        let _path = CGMutablePath()
        _path.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.size.width/2 - kStyle.lineWidth, startAngle: startAngle, endAngle: endAngle, clockwise: clockWise, transform: transform)
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = duration
        orbit.path = _path
        orbit.calculationMode = .paced
        orbit.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        orbit.rotationMode = .rotateAuto
        orbit.isRemovedOnCompletion = false
        orbit.fillMode = .forwards
        dot.layer.add(orbit, forKey: "Move")
    }
    
}

// MARK: - Private
extension BKCircleGradientProgressView {
    
    /// 将角度转为弧度
    fileprivate func angleToRadian(_ angle: Double) -> CGFloat {
        return CGFloat(angle/Double(180.0) * Double.pi)
    }
    
    /// 计算圆弧上点的坐标
    fileprivate func calculateCircleCoordinate(_ center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
        let _x = radius*CGFloat(cosf(Float(angle)*Float(Double.pi)/Float(180)))
        let _y = radius*CGFloat(sinf(Float(angle)*Float(Double.pi)/Float(180)))
        return CGPoint(x: center.x + _x, y: center.y - _y)
    }
    
}
