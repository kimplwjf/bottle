//
//  BaseNaviBarView.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/7/5.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class BaseNaviBarView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightWhiteDark27
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
