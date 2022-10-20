//
//  BaseRightBtnTableSecHeader.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/2/23.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BaseRightBtnTableSecHeader: BaseTableSecHeader {
    
    typealias RightBtnAction = () -> Void
    private var callback: RightBtnAction?
    func clickRightBtn(by callback: @escaping RightBtnAction) {
        self.callback = callback
    }
    
    func setRightBtn(title: String, color: UIColor = XMColor.light139) {
        rightBtn.setTitle(title, for: .normal)
        rightBtn.setTitleColor(color, for: .normal)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    lazy var rightBtn: UIButton = {
        let btn = self.bk_addButton(title: "更多", font: .systemFont(ofSize: 14), bgColor: .clear, titleColor: XMColor.gray153)
        btn.bk_addTarget { [unowned self] (sender) in
            self.callback?()
        }
        return btn
    }()
    
    lazy var lookMoreBtn: BKLayoutButton = {
        let btn = self.bk_addLayoutButton(style: .leftTitleRightImage, bgColor: .clear, imageSize: CGSize(width: 18, height: 18), image: UIImage(named: "icon_arrow_right_gray"), titleFont: .systemFont(ofSize: 14), title: "查看更多", titleColor: XMColor.gray153)
        btn.bk_addTarget { [unowned self] (sender) in
            self.callback?()
        }
        return btn
    }()
    
}

// MARK: - Public
extension BaseRightBtnTableSecHeader {
    
    func addLookMoreBtn() {
        rightBtn.removeFromSuperview()
        contentView.addSubview(lookMoreBtn)
        lookMoreBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func setLookMoreBtn(title: String, imgName: String) {
        lookMoreBtn.setTitle(title, for: .normal)
        lookMoreBtn.setImage(UIImage(named: imgName), for: .normal)
    }
    
}
