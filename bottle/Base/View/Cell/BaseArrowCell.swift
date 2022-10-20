//
//  BaseArrowCell.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/5/30.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class BaseArrowCell: BaseTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        kTitleLabel.textColor = .lightBlack51DarkLight230
        contentView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.size.equalTo(18)
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    private lazy var arrowImgView = UIImageView(image: UIImage(named: "icon_arrow_right_gray"))
    
}
