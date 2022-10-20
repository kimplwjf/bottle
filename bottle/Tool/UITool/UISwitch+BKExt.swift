//
//  UISwitch+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

/// 开关点击事件
typealias BKSwitchValueChange = (Bool) -> ()

struct BKSwitchConfig {
    
    /// 关闭背景颜色
    var offBgColor = UIColor.lightWhiteDark27
    /// 打开背景颜色
    var onBgColor = UIColor.lightWhiteDark27
    
    /// 关闭圆点颜色
    var offPointColor = kRGBColor(153, 153, 153)
    /// 打开圆点颜色
    var onPointColor = kRGBColor(158, 0, 6)
    
    /// 关闭背景图片
    var offBgImage: UIImage?
    /// 打开背景图片
    var onBgImage: UIImage?
    
    /// 关闭圆点图片
    var offPointImage: UIImage?
    /// 打开圆点图片
    var onPointImage: UIImage?
    
    /// 背景View的上下边距
    var bgMargin: CGFloat = 0
    /// 圆点的上下边距
    var pointMargin: CGFloat = 5
    
}

class BKCustomSwitch: UIControl {
    
    /// 背景View
    private var bgView: UIView!
    
    /// 开关圆点View
    private var pointView: UIView!
    
    /// 配置
    var config: BKSwitchConfig! {
        didSet {
            updateUI()
        }
    }
    
    /// 开关状态
    var isOn: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    /// 是否圆角
    var isRounded: Bool = true {
        didSet {
            bgView.layer.cornerRadius = isRounded ? (frame.height - config.bgMargin * 2) * 0.5 : 0
            pointView.layer.cornerRadius = isRounded ? (frame.height - config.pointMargin * 2) * 0.5 : 0
        }
    }
    
    private var valueChangedHandle: BKSwitchValueChange?
    
    func bk_switchChange(_ callback: @escaping BKSwitchValueChange) {
        valueChangedHandle = callback
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 底部背景
        bgView = UIView()
        addSubview(bgView)
        bgView.layer.masksToBounds = true
        bgView.isUserInteractionEnabled = false
        
        // 开关按钮
        pointView = UIView()
        addSubview(pointView)
        pointView.layer.masksToBounds = true
        pointView.isUserInteractionEnabled = false
        
        isRounded = true
        config = BKSwitchConfig()
        
        addTarget(self, action: #selector(stateChanges), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 布局
        bgView.frame = CGRect(x: 0, y: config.bgMargin, width: frame.width, height: frame.height - config.bgMargin * 2)
        
        updateUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 响应事件
    @objc func stateChanges() {
        isOn ? changeToOffAnimation() : changeToOnAnimation()
        isOn = !isOn
        valueChangedHandle?(isOn)
    }
    
}

// MARK: - UI 逻辑
extension BKCustomSwitch {
    /// 设置圆角和背景色
    func updateUI() {
        
//        bgView.layer.cornerRadius = (frame.height - config.bgMargin * 2) * 0.5
        bgView.backgroundColor = config.offBgColor
//        pointView.layer.cornerRadius = (frame.height - config.pointMargin * 2) * 0.5
        pointView.backgroundColor = config.offPointColor
        
        let pointWidth = frame.height - config.pointMargin * 2
        if isOn {
            pointView.frame = CGRect(x: bgView.frame.maxX - pointView.frame.width - config.pointMargin, y: config.pointMargin, width: pointWidth, height: pointWidth)
            changeToOnPointViewStyle()
        } else {
            pointView.frame = CGRect(x: bgView.frame.minX + config.pointMargin, y: config.pointMargin, width: pointWidth, height: pointWidth)
            changeToOffPointViewStyle()
        }
    }
    
    private func changeToOnAnimation() {
        var frame: CGRect = pointView.frame
        frame.origin.x = bgView.frame.minX + config.pointMargin
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.pointView.frame = frame
            strongSelf.changeToOffPointViewStyle()
        })
    }
    
    
    private func changeToOffAnimation() {
        var frame: CGRect = pointView.frame
        frame.origin.x = bgView.frame.maxX - pointView.frame.width - config.pointMargin
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.pointView.frame = frame
            strongSelf.changeToOnPointViewStyle()
        })
    }
    
    private func changeToOnPointViewStyle() {
        bgView.backgroundColor = config.onBgColor
        pointView.backgroundColor = config.onPointColor
        if let img = config.onPointImage {
            pointView.layer.contents = img.cgImage
        }
        if let bgImg = config.onBgImage {
            bgView.layer.contents = bgImg.cgImage
        }
    }
    
    private func changeToOffPointViewStyle() {
        bgView.backgroundColor = config.offBgColor
        self.pointView.backgroundColor = config.offPointColor
        if let img = config.offPointImage {
            pointView.layer.contents = img.cgImage
        }
        if let bgImg = config.offBgImage {
            bgView.layer.contents = bgImg.cgImage
        }
    }
}
