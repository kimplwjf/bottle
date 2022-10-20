//
//  BaseTableSecFooter.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/3/19.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BaseTableSecFooter: UITableViewHeaderFooterView {
    
    typealias LookMore = (_ more: Bool) -> Void
    private var lookMoreCallback: LookMore?
    func lookMore(by callback: @escaping LookMore) {
        self.lookMoreCallback = callback
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .lightWhiteDark33
        contentView.backgroundColor = .lightWhiteDark33
        contentView.addSubview(lookMoreBtn)
        lookMoreBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(20)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    lazy var lookMoreBtn: BKLayoutButton = {
        let btn = self.bk_addLayoutButton(style: .leftTitleRightImage, bgColor: .clear, imageSize: CGSize(width: 18, height: 18), image: UIImage(named: "icon_arrow_right_gray"), title: "查看更多", titleColor: XMColor.light139)
        btn.bk_addTarget { [unowned self] (sender) in
            self.lookMoreCallback?(true)
        }
        return btn
    }()
    
}
