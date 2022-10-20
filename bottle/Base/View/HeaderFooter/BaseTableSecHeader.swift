//
//  BaseTableSecHeader.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/3/2.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BaseTableSecHeader: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .lightWhiteDark33
        contentView.backgroundColor = .lightWhiteDark33
        contentView.addSubview(kTitleLabel)
        kTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    lazy var kTitleLabel = self.bk_addLabel(font: .systemFont(ofSize: 18, weight: .medium), bgColor: .clear, textColor: .lightBlack51DarkLight230)
    
}

// MARK: - Public
extension UITableViewHeaderFooterView {
    
    func setBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color
        contentView.backgroundColor = color
    }
    
}

// MARK: - Public
extension BaseTableSecHeader {
    
    func formStyle() {
        self.setBackgroundColor(.lightGray248Dark27)
        kTitleLabel.font = .systemFont(ofSize: 14)
        kTitleLabel.textColor = XMColor.gray153
    }
    
}
