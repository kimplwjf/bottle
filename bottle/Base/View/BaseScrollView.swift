//
//  BaseScrollView.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/1/12.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class BaseScrollView: BaseView {
    
    /// 内容
    var content: String = "" {
        didSet {
            contentLabel.text = content
            let h: CGFloat = content.heightWithFont(fixedWidth: kScreenWidth-32)
            contentLabel.snp.updateConstraints { make in
                make.height.equalTo(h+15)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentLabel)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(kScreenWidth-32)
            make.height.equalTo(0)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = self.bk_addLabel(bgColor: .clear)
        label.bk_enabledCopy = true
        return label
    }()
    
}
