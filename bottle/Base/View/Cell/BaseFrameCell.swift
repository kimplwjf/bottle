//
//  BaseFrameCell.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/6/7.
//  Copyright © 2020 王锦发. All rights reserved.
//

import UIKit

class BaseFrameCell: UITableViewCell {
    
    var controllerWidth: CGFloat {
        return 16
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .lightWhiteDark33
        contentView.backgroundColor = .lightWhiteDark33
        
    }
    
    /// 重写frame
    override var frame: CGRect {
        get { return super.frame }
        set {
            var frame = newValue
            frame.origin.x += controllerWidth
            frame.size.width -= 2*controllerWidth
            super.frame = frame
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
