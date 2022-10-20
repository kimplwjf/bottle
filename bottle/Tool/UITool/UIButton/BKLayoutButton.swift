//
//  BKLayoutButton.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

enum BKLayoutButtonStyle : Int {
    case leftImageRightTitle // 系统默认
    case leftTitleRightImage
    case upImageDownTitle
    case upTitleDownImage
}

// MARK: - 上图下文 上文下图 左图右文(系统默认) 右图左文
/// 重写layoutSubviews的方式实现布局，忽略imageEdgeInsets、titleEdgeInsets和contentEdgeInsets
class BKLayoutButton: UIButton {
    /// 布局方式
    var layoutStyle: BKLayoutButtonStyle = .leftImageRightTitle
    /// 图片和文字的间距，默认值5
    var midSpacing: CGFloat = 5.0
    /// 指定图片size
    var imageSize = CGSize.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageSize.equalTo(.zero) {
            imageView?.sizeToFit()
        } else {
            imageView?.frame = CGRect(x: imageView!.x, y: imageView!.y, width: imageSize.width, height: imageSize.height)
        }
        titleLabel?.sizeToFit()
        
        switch layoutStyle {
        case .leftImageRightTitle:
            layoutHorizontal(withLeftView: imageView, rightView: titleLabel)
        case .leftTitleRightImage:
            layoutHorizontal(withLeftView: titleLabel, rightView: imageView)
        case .upImageDownTitle:
            layoutVertical(withUp: imageView, downView: titleLabel)
        case .upTitleDownImage:
            layoutVertical(withUp: titleLabel, downView: imageView)
        }
        
    }
    
    func layoutHorizontal(withLeftView leftView: UIView?, rightView: UIView?) {
        guard var leftViewFrame = leftView?.frame,
            var rightViewFrame = rightView?.frame else { return }
        
        if imageSize.equalTo(.zero) && layoutStyle == .leftImageRightTitle {
            leftViewFrame = kCGRect(0, 0, 0, 0)
        }
        let totalWidth: CGFloat = leftViewFrame.width + midSpacing + rightViewFrame.width
        
        leftViewFrame.origin.x = (frame.width - totalWidth) / 2.0
        leftViewFrame.origin.y = (frame.height - leftViewFrame.height) / 2.0
        leftView?.frame = leftViewFrame
        
        rightViewFrame.origin.x = leftViewFrame.maxX + midSpacing
        rightViewFrame.origin.y = (frame.height - rightViewFrame.height) / 2.0
        rightView?.frame = rightViewFrame
    }
    
    func layoutVertical(withUp upView: UIView?, downView: UIView?) {
        guard var upViewFrame = upView?.frame,
            var downViewFrame = downView?.frame else { return }
        
        let totalHeight: CGFloat = upViewFrame.height + midSpacing + downViewFrame.height
        
        upViewFrame.origin.y = (frame.height - totalHeight) / 2.0
        upViewFrame.origin.x = (frame.width - upViewFrame.width) / 2.0
        upView?.frame = upViewFrame
        
        downViewFrame.origin.y = upViewFrame.maxY + midSpacing
        downViewFrame.origin.x = (frame.width - downViewFrame.width) / 2.0
        downView?.frame = downViewFrame
    }

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        setNeedsLayout()
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        setNeedsLayout()
    }
    
    func setMidSpacing(_ midSpacing: CGFloat) {
        self.midSpacing = midSpacing
        setNeedsLayout()
    }
    
    func setImageSize(_ imageSize: CGSize) {
        self.imageSize = imageSize
        setNeedsLayout()
    }
    
}
