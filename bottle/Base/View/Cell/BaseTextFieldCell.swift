//
//  BaseTextFieldCell.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

class BaseTextFieldCell: UITableViewCell {
    
    private let _attributedString: BKAttributedString = { (value, dec) in
        let _value: String = value as! String
        let keys: [[NSMutableAttributedString.AttributedStringKeys]] = [
            [.text(_value), .textColor(.lightBlack51DarkLight230), .fontSize(16)],
            [.text("*"), .textColor(.red), .fontSize(16)]
        ]
        let attributedString = NSMutableAttributedString.string(by: keys)
        return attributedString
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .lightWhiteDark33
        contentView.backgroundColor = .lightWhiteDark33
        contentView.addSubviews([blankView, kTextField, line])
        blankView.addSubview(leftViewLabel)
        
        blankView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        
        leftViewLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(16)
        }
        
        kTextField.snp.makeConstraints { (make) in
            make.left.equalTo(blankView.snp.right)
            make.centerY.right.equalToSuperview()
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
    private lazy var blankView: UIView = {
        let view = UIView(color: .lightWhiteDark33)
        return view
    }()
    
    private lazy var leftViewLabel = self.bk_addLabel(font: .systemFont(ofSize: 16), bgColor: .clear, textColor: .lightBlack51DarkLight230)
    
    lazy var kTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .lightWhiteDark33
        tf.textColor = .lightBlack51DarkLight230
        tf.textAlignment = .right
        tf.font = .systemFont(ofSize: 16)
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    lazy var line: UIView = {
        let line = self.bk_addLine()
        line.isHidden = true
        return line
    }()
    
}

// MARK: - Public
extension BaseTextFieldCell {
    
    func reloadTitle(_ title: String, asterisk: Bool = false) {
        if asterisk {
            leftViewLabel.attributedText = _attributedString(title, "*")
        } else {
            leftViewLabel.text = title
        }
        let w = title.widthWithFont(font: 16, fixedHeight: 20)
        blankView.snp.updateConstraints { make in
            make.width.equalTo(w+32)
        }
    }
    
}
