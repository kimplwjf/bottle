//
//  BaseTextViewCell.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

class BaseTextViewCell: UITableViewCell {
    
    deinit {
        kTextView.bk_removeAllObservers()
    }
    
    var textViewH: CGFloat {
        return 100
    }
    
    private var block: ((UITextView) -> Void)?
    func textViewBlock(_ block: @escaping (UITextView) -> Void) {
        self.block = block
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .lightWhiteDark33
        contentView.backgroundColor = .lightWhiteDark33
        contentView.addSubview(kTextView)
        kTextView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(16)
            make.height.equalTo(textViewH)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    lazy var kTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .lightWhiteDark33
        textView.delegate = self
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .lightBlack51DarkLight230
        return textView
    }()

}

// MARK: - UITextViewDelegate代理
extension BaseTextViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        PPP(textView.text.count)
        self.block?(textView)
    }
    
}
