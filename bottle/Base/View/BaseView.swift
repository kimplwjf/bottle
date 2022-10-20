//
//  BaseView.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit
import LXFProtocolTool

/** 自定义顶部navigationItem.titleView*/
class CustomTitleView: UIView {
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightWhiteDark27
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
