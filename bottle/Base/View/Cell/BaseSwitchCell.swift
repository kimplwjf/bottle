//
//  BaseSwitchCell.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/3/3.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BaseSwitchCell: BaseTableCell {
    
    /// 开关
    var switchIsOn: Bool = false {
        didSet {
            rightSwitch.isOn = switchIsOn
        }
    }
    
    typealias SwitchChangeCallback = (Bool) -> Void
    private var callback: SwitchChangeCallback?
    func switchChange(by callback: @escaping SwitchChangeCallback) {
        self.callback = callback
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(rightSwitch)
        rightSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(iPhone5_5s_SE() ? -10 : -16)
        }
        if iPhone5_5s_SE() {
            rightSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    private lazy var rightSwitch: UISwitch = {
        let sw = UISwitch()
        // 打开开关底部的颜色
        sw.onTintColor = .dark
        sw.tintColor = XMColor.gray153
        sw.addTarget(self, action: #selector(switchChange(_:)), for: .valueChanged)
        return sw
    }()
    
}

// MARK: - Private
extension BaseSwitchCell {
    
    @objc private func switchChange(_ sw: UISwitch) {
        sw.setOn(sw.isOn, animated: true)
        self.callback?(sw.isOn)
    }
    
}
