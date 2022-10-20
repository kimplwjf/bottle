//
//  BaseRightCell.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/4/22.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BaseRightCell: BaseTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-6)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    lazy var rightLabel = self.bk_addLabel(font: .systemFont(ofSize: 16), bgColor: .clear, textColor: XMColor.gray153, align: .right)
    
}
