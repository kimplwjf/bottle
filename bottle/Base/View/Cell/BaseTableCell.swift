//
//  BaseTableCell.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

class BaseTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .lightWhiteDark33
        contentView.backgroundColor = .lightWhiteDark33
        contentView.addSubviews([kTitleLabel, line])
        kTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.bottom.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        line.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    lazy var kTitleLabel = self.bk_addLabel(font: .systemFont(ofSize: 16), bgColor: .clear)
    
    lazy var line: UIView = {
        let line = self.bk_addLine()
        line.isHidden = true
        return line
    }()
    
}

// MARK: - Public
extension UITableViewCell {
    
    func setBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color
        contentView.backgroundColor = color
    }
    
}

typealias BKListModel = UITableViewCell.BKModel
extension UITableViewCell {
    
    class BKModel: NSObject {
        
        var title = ""
        var placeholder = ""
        var cellID = ""
        var subs = [Any]()
        var dataModel: AnyObject?
        
        init(title: String = "", placeholder: String = "", cellID: String = "", subs: [Any] = [Any]()) {
            super.init()
            self.title = title
            self.placeholder = placeholder
            self.cellID = cellID
            self.subs = subs
        }
        
    }
    
}
