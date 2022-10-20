//
//  BKMomentumView.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/4/18.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class BKMomentumPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
}

class BKMomentumView: BKGradientLayerView {
    
    var closedTransform: CGAffineTransform = .identity {
        didSet {
            transform = closedTransform
        }
    }
    
    private(set) var isOpen: Bool = false
    private var animator = UIViewPropertyAnimator()
    private var animationProgress: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGestureRecognizer(panRecognizer)
        let color = UIColor(red: 229.0/255.0, green: 238.0/255.0, blue: 216.0/255.0, alpha: 1.0)
        colors = [color.cgColor, color.withAlphaComponent(0.3).cgColor]
        self.addSubview(handleView)
        handleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 6))
            make.top.equalTo(5)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    private lazy var panRecognizer: BKMomentumPanGestureRecognizer = {
        let pan = BKMomentumPanGestureRecognizer()
        pan.addTarget(self, action: #selector(panAction(_:)))
        return pan
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panRecognizer)
        return view
    }()
    
}

// MARK: - Selector
extension BKMomentumView {
    
    @objc private func panAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.startAnimationIfNeeded()
            animator.pauseAnimation()
            animationProgress = animator.fractionComplete
        case .changed:
            var fraction = -gesture.translation(in: self).y / closedTransform.ty
            if isOpen { fraction *= -1 }
            if animator.isReversed { fraction *= -1 }
            animator.fractionComplete = fraction + animationProgress
        case .ended, .cancelled:
            let yVelocity = gesture.velocity(in: self).y
            let shouldClose = yVelocity > 0
            if yVelocity == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
            if isOpen {
                if !shouldClose && !animator.isReversed { animator.isReversed.toggle() }
                if shouldClose && animator.isReversed { animator.isReversed.toggle() }
            } else {
                if shouldClose && !animator.isReversed { animator.isReversed.toggle() }
                if !shouldClose && animator.isReversed { animator.isReversed.toggle() }
            }
            let fractionRemaining = 1 - animator.fractionComplete
            let distanceRemaining = fractionRemaining * closedTransform.ty
            if distanceRemaining == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
            let relativeVelocity = min(abs(yVelocity)/distanceRemaining, 5)
            let timingParameters = UISpringTimingParameters(damping: 0.8, response: 0.3, initialVelocity: CGVector(dx: relativeVelocity, dy: relativeVelocity))
            let preferredDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
            let durationFactor = CGFloat(preferredDuration/animator.duration)
            animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
        default:
            break
        }
    }
    
}

// MARK: - Private
extension BKMomentumView {
    
    private func startAnimationIfNeeded() {
        if animator.isRunning {
            return
        }
        let timingParameters = UISpringTimingParameters(damping: 1, response: 0.4)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            self.transform = self.isOpen ? self.closedTransform : .identity
        }
        animator.addCompletion { position in
            if position == .end {
                self.isOpen.toggle()
            }
        }
        animator.startAnimation()
    }
    
}

class BKGradientLayerView: UIView {
    
    var colors: [CGColor] = [CGColor]() {
        didSet {
            guard let gradientLayer = self.layer as? CAGradientLayer else { return }
            gradientLayer.colors = colors
        }
    }
    
    var startPoint: CGPoint? {
        didSet {
            guard let gradientLayer = self.layer as? CAGradientLayer else { return }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        }
    }
    
    var endPoint: CGPoint? {
        didSet {
            guard let gradientLayer = self.layer as? CAGradientLayer else { return }
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
}
