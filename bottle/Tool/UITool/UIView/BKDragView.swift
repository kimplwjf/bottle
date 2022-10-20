//
//  BKDragView.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/3/8.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class BKDragView: UIView {
    
    enum DragDirection: Int {
        case any
        case horizontal
        case vertical
    }
    
    /// 是否能拖拽，默认为true
    var dragEnable: Bool = true
    
    /**
     * 活动范围，默认为父视图的frame范围内（因为拖出父视图后无法点击，也没意义）
     * 如果设置了，则会在给定的范围内活动
     * 如果没设置，则会在父视图范围内活动
     * 注意：设置的frame不要大于父视图范围
     * 注意：设置的frame为0，0，0，0表示活动的范围为默认的父视图frame，如果想要不能活动，请设置dragEnable这个属性为false
     *
     **/
    var freeRect: CGRect = .zero
    
    /// 拖拽方向
    var dragDirection: DragDirection = .any
    
    /// 是否总保持在父视图边界，默认为true,开启黏贴边界效果
    var isKeepBounds: Bool = true
    
    /// 是否禁止拖出父类Rect
    var forbidOutFree: Bool = true
    
    /// 是否禁止进入导航栏
    var forbidEnterNavigation: Bool = true
    
    /// 是否禁止进入状态栏
    var forbidEnterStatusBar: Bool = true
    
    /**
     * 父类是否是UIViewController
     * 若为true，则forbidEnterNavigation和forbidEnterStatusBar生效
     * 若为false，则上下可贴边
     **/
    var fatherIsCtrl: Bool = false
    
    /// 是否开启点击事件
    var canTapGesture: Bool = true
    
    /// 点击回调
    var clickCallback: ((BKDragView) -> Void)?
    /// 开始拖动回调
    var beginDragCallback: ((BKDragView) -> Void)?
    /// 拖动中回调
    var draggingCallback: ((BKDragView) -> Void)?
    /// 结束拖动回调
    var endDragCallback: ((BKDragView) -> Void)?
    
    /// 动画时长
    private var animationTime: TimeInterval = 0.5
    private var startPoint: CGPoint = .zero
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    /// 禁止拖出父控件动画时长
    private var endAnimationTime: TimeInterval = 0.2
    
    init(canTap: Bool = true) {
        canTapGesture = canTap
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let superView = self.superview {
            freeRect = CGRect(origin: .zero, size: superView.bounds.size)
        }
        contentView.frame = CGRect(origin: .zero, size: self.bounds.size)
        btn.frame = CGRect(origin: .zero, size: self.bounds.size)
        imgView.frame = CGRect(origin: .zero, size: self.bounds.size)
    }
    
    // MARK: - lazy
    /**
     * contentView内部懒加载的一个UIImageView
     * 外部也可以自定义控件添加到本view中
     * 注意：最好不要同时使用内部的imgView和btn
     */
    lazy var imgView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        contentView.addSubview(iv)
        return iv
    }()
    
    /**
     * contentView内部懒加载的一个UIButton
     * 外部也可以自定义控件添加到本view中
     * 注意：最好不要同时使用内部的imgView和btn
     */
    lazy var btn: UIButton = {
        let btn = UIButton()
        btn.bk_addTarget { [unowned self] sender in
            self.clickCallback?(self)
        }
        btn.clipsToBounds = true
        contentView.addSubview(btn)
        return btn
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        self.addSubview(view)
        return view
    }()
    
}

// MARK: - Private
extension BKDragView {
    
    private func setup() {
        // 默认为父视图的frame范围内
        if let superView = self.superview {
            freeRect = CGRect(origin: .zero, size: superView.bounds.size)
        }
        self.clipsToBounds = true
        if canTapGesture {
            let tap = UITapGestureRecognizer(target: self, action: #selector(clickAction))
            self.addGestureRecognizer(tap)
        } else {
            imgView.removeFromSuperview()
            btn.removeFromSuperview()
        }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragAction(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    /// 黏贴边界效果
    private func keepBounds() {
        // 中心点判断
        let _centerX: CGFloat = freeRect.origin.x + (freeRect.size.width - frame.size.width)*0.5
        var rect: CGRect = self.frame
        if isKeepBounds { // 自动贴边
            if frame.origin.x < _centerX { // 向左贴边
                UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut) {
                    rect.origin.x = self.freeRect.origin.x
                    self.frame = rect
                }
            } else { // 向右贴边
                UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut) {
                    rect.origin.x = self.freeRect.origin.x + self.freeRect.size.width - self.frame.size.width
                    self.frame = rect
                }
            }
        } else { // 没有贴边效果
            if frame.origin.x < freeRect.origin.x {
                UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut) {
                    rect.origin.x = self.freeRect.origin.x
                    self.frame = rect
                }
            } else if freeRect.origin.x + freeRect.size.width < frame.origin.x + frame.size.width {
                UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut) {
                    rect.origin.x = self.freeRect.origin.x + self.freeRect.size.width - self.frame.size.width
                    self.frame = rect
                }
            }
        }
        
        if frame.origin.y < freeRect.origin.y {
            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut) {
                rect.origin.y = self.freeRect.origin.y
                self.frame = rect
            }
        } else if freeRect.origin.y + freeRect.size.height < frame.origin.y + frame.size.height {
            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut) {
                rect.origin.y = self.freeRect.origin.y + self.freeRect.size.height - self.frame.size.height
                self.frame = rect
            }
        }
    }
    
}

// MARK: - Selector
extension BKDragView {
    
    @objc private func clickAction() {
        PPP("点击拖拽视图BKDragView")
        self.clickCallback?(self)
    }
    
    @objc private func dragAction(_ pan: UIPanGestureRecognizer) {
        if !dragEnable {
            return
        }
        switch pan.state {
        case .began:
            self.beginDragCallback?(self)
            // 注意完成移动后，将translation重置为0十分重要。否则translation每次都会叠加
            pan.setTranslation(.zero, in: self)
            // 保存触摸起始点位置
            startPoint = pan.translation(in: self)
        case .changed:
            self.draggingCallback?(self)
            
            // 禁止拖动到父类之外区域
            if forbidOutFree && (frame.origin.x < 0 || frame.origin.x > freeRect.size.width - frame.size.width || frame.origin.y < 0 || frame.origin.y > freeRect.size.height - frame.size.height) {
                var newframe: CGRect = self.frame
                if frame.origin.x < 0 {
                    newframe.origin.x = 0
                } else if frame.origin.x > freeRect.size.width - frame.size.width {
                    newframe.origin.x = freeRect.size.width - frame.size.width
                }
                if frame.origin.y < 0 {
                    newframe.origin.y = 0
                } else if frame.origin.y > freeRect.size.height - frame.size.height {
                    newframe.origin.y = freeRect.size.height - frame.size.height
                }
                
                UIView.animate(withDuration: endAnimationTime) {
                    self.frame = newframe
                }
            }
            
            // 如果父类是控制器View，则底部有安全边距
            if fatherIsCtrl && frame.origin.y > freeRect.size.height - frame.size.height - kBottomSafeHeight {
                var newframe: CGRect = self.frame
                newframe.origin.y = freeRect.size.height - frame.size.height - kBottomSafeHeight
                UIView.animate(withDuration: endAnimationTime) {
                    self.frame = newframe
                }
            }
            
            // 如果父类是控制器View且禁止进入状态栏
            if fatherIsCtrl && forbidEnterNavigation && frame.origin.y < kStatusBarHeight {
                var newframe: CGRect = self.frame
                newframe.origin.y = kStatusBarHeight
                UIView.animate(withDuration: endAnimationTime) {
                    self.frame = newframe
                }
            }
            
            // 如果父类是控制器View且禁止进入导航栏
            if fatherIsCtrl && forbidEnterNavigation && frame.origin.y < kNavigationBarHeight {
                var newframe: CGRect = self.frame
                newframe.origin.y = kNavigationBarHeight
                UIView.animate(withDuration: endAnimationTime) {
                    self.frame = newframe
                }
            }
            
            // 计算位移 = 当前位置 - 起始位置
            let point: CGPoint = pan.translation(in: self)
            var dx: CGFloat = 0.0
            var dy: CGFloat = 0.0
            switch dragDirection {
            case .any:
                dx = point.x - startPoint.x
                dy = point.y - startPoint.y
            case .horizontal:
                dx = point.x - startPoint.x
                dy = 0
            case .vertical:
                dx = 0
                dy = point.y - startPoint.y
            }
            
            // 计算移动后的view中心点
            let newCenter: CGPoint = CGPoint(x: center.x + dx, y: center.y + dy)
            // 移动view
            center = newCenter
            // 注意完成上述移动后，将translation重置为0十分重要。否则translation每次都会叠加
            pan.setTranslation(.zero, in: self)
        case .ended:
            self.keepBounds()
            self.endDragCallback?(self)
        default:
            break
        }
    }
    
}
