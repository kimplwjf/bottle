//
//  BOThrowTextView.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/18.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit

class BOThrowTextView: UIView {
    
    deinit {
        kTextView.bk_removeAllObservers()
    }
    
    private var block: ((UITextView) -> Void)?
    func textViewBlock(_ block: @escaping (UITextView) -> Void) {
        self.block = block
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews([kTitleLabel, kTextView])
        kTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.height.equalTo(40)
        }
        
        kTextView.snp.makeConstraints { make in
            make.top.equalTo(kTitleLabel.snp.bottom).offset(20)
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(kScreenWidth-32)
            make.centerX.equalToSuperview()
        }
        
        kTextView.bk_maxWordCount = 500
        kTextView.bk_placeholder = "say something~"
        kTextView.bk_placeholderLabel?.font = .systemFont(ofSize: 18)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    private lazy var kTitleLabel = self.bk_addLabel(text: "此刻，说你想说的话～", font: .systemFont(ofSize: 30, weight: .medium), bgColor: .clear, textColor: XMColor.black51)
    
    lazy var kTextView: UITextView = {
        let textView = UITextView()
        textView.bk_addCornerBorder(radius: 15, borderWidth: 0.1, borderColor: .clear)
        textView.backgroundColor = .lightWhiteDark27
        textView.textColor = .lightBlack51DarkLight230
        textView.font = .systemFont(ofSize: 15)
        return textView
    }()
    
}
