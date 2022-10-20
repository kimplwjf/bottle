//
//  BOSettingView.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/7/10.
//  Copyright © 2020 王锦发. All rights reserved.
//

import UIKit

protocol BOSettingViewDelegate: NSObjectProtocol {
    func settingViewDidSelectAt(_ type: BOSettingView.RowType)
}

class BOSettingView: BaseView {
    
    enum RowType: Int {
        case personalInfo = 0
        case theme
        case currentVersion
        case agreement
        case privacy
        case logout
        case closeAccount
        
        var des: String {
            switch self {
            case .personalInfo: return "个人信息"
            case .theme: return "外观设置"
            case .currentVersion: return "当前版本"
            case .agreement: return "用户协议"
            case .privacy: return "隐私政策"
            case .logout: return "退出登录"
            case .closeAccount: return "注销账号"
            }
        }
    }
    
    weak var delegate: BOSettingViewDelegate?
    private var sections: [[RowType]] = [
        [.personalInfo],
        [.theme, .currentVersion, .agreement, .privacy],
        [.logout, .closeAccount]
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *) {
            
        } else {
            sections[1].removeFirst()
        }
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.estimatedRowHeight = 44
        tv.rowHeight = UITableView.automaticDimension
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        tv.register(cellWithClass: BOSettingCell.self)
        return tv
    }()
    
}

// MARK: - UITableView代理
extension BOSettingView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sec = sections[indexPath.section]
        let row = sec[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: BOSettingCell.self, for: indexPath)
        cell.kTitleLabel.text = row.des
        cell.kTitleLabel.textColor = row == .logout || row == .closeAccount ? XMColor.red233 : .lightBlackDarkWhite
        cell.rightLabel.text = row == .currentVersion ? "V\(kAppVersion)" : ""
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sec = sections[indexPath.section]
        let row = sec[indexPath.row]
        self.delegate?.settingViewDidSelectAt(row)
    }
    
}
