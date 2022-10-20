//
//  BOThemeSelectCell.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/9.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BOThemeSelectCell: BaseTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        kTitleLabel.font = .systemFont(ofSize: 15)
        contentView.addSubview(checkRoundBtn)
        kTitleLabel.snp.updateConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(15)
        }
        
        checkRoundBtn.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkRoundBtn.isSelected = selected
    }
    
    // MARK: - lazy
    lazy var checkRoundBtn: UIButton = {
        let btn = self.bk_addImgSelectButton(iconNormal: "icon_check_greenround_normal", iconSelect: "icon_check_greenround_select")
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
}
