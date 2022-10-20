//
//  BOSettingCell.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/5/10.
//  Copyright © 2020 王锦发. All rights reserved.
//

import UIKit

class BOSettingCell: BaseTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews([rightLabel, arrowImgView])
        kTitleLabel.snp.updateConstraints { make in
            make.top.bottom.equalToSuperview().inset(19)
        }
        
        arrowImgView.snp.makeConstraints { make in
            make.size.equalTo(18)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(arrowImgView.snp.left).offset(-10)
            make.left.equalTo(kTitleLabel.snp.right).offset(10)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    lazy var rightLabel = self.bk_addLabel(bgColor: .clear, textColor: XMColor.light139, align: .right)
    
    private lazy var arrowImgView = UIImageView(image: UIImage(named: "icon_arrow_right_gray"))
    
}
