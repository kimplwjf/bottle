//
//  BOCollectListCell.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/19.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit

class BOCollectListCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .lightWhiteDark27
        contentView.backgroundColor = .lightWhiteDark27
        contentView.addSubview(kTitleLabel)
        kTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.edges.equalToSuperview().inset(16)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    lazy var kTitleLabel = self.bk_addLabel(font: UIFont(name: "Helvetica-BoldOblique", size: 18)!, bgColor: .clear, textColor: .lightBlack51DarkLight230)
    
}
