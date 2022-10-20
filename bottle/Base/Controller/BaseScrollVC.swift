//
//  BaseScrollVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/1/12.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class BaseScrollVC: BaseVC {
    
    deinit {
        PPP("[\(NSStringFromClass(type(of: self)))]>>>已被释放")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    // MARK: - lazy
    private lazy var scrollView: BaseScrollView = {
        let view = BaseScrollView()
        return view
    }()
    
}

// MARK: - Public
extension BaseScrollVC {
    
    func reload(_ content: String) {
        scrollView.content = content
    }
    
}
