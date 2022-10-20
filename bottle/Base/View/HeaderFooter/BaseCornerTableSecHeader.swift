//
//  BaseCornerTableSecHeader.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/3/2.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class BaseCornerTableSecHeader: BaseTableSecHeader {
    
    var controllerWidth: CGFloat {
        return 16
    }
    
    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.layer.mask = shapeLayer
        
        kTitleLabel.snp.updateConstraints { (make) in
            make.left.equalTo(10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        shapeLayer.path = bezierPath.cgPath
    }
    
    /// 重写frame
    override var frame: CGRect {
        get { return super.frame }
        set {
            var frame = newValue
            frame.origin.x += controllerWidth
            frame.origin.y += 12
            frame.size.width -= 2*controllerWidth
            frame.size.height -= 12
            super.frame = frame
        }
    }
    
}
