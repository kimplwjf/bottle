//
//  BOSettingVC.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/5/10.
//  Copyright © 2020 王锦发. All rights reserved.
//

import UIKit

class BOSettingVC: BaseVC {
    
    deinit {
        PPP("[\(NSStringFromClass(type(of: self)))]>>>已被释放")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "设置"
        view.addSubview(settingView)
        
        settingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    // MARK: - lazy
    private lazy var settingView: BOSettingView = {
        let view = BOSettingView()
        view.delegate = self
        return view
    }()
    
}

// MARK: - BOSettingViewDelegate代理
extension BOSettingVC: BOSettingViewDelegate {
    
    func settingViewLogoutDidClick() {
        
    }
    
    func settingViewDidSelectAt(_ type: BOSettingView.RowType) {
        switch type {
        case .personalInfo:
            let vc = BOPersonalInfoVC()
            self.navigationController?.pushViewController(vc)
        case .theme:
            let vc = BOThemeSelectVC()
            self.navigationController?.pushViewController(vc)
        case .currentVersion:
            BPM.showResult(.success, msg: "当前已是最新版本")
        case .agreement, .privacy:
            let url = type == .agreement ? "https://maccms.luemoon.cc/pp" : "https://maccms.luemoon.cc/pp/yisi.html"
            let vc = BKWebViewVC(with: url)
            self.navigationController?.pushViewController(vc)
        case .logout:
            App.startLogout()
        case .closeAccount:
            UIAlertController.showTwoAlert(in: self, title: "确认注销该账号吗?", okTitle: "确定") { _ in
                let email = XMApp.kUserModel?.email ?? ""
                let pwd = XMApp.kUserModel?.pwd ?? ""
                if let model: DBUserModel = DB.shared.query(table: .user, where: DBUserModel.Properties.email == email && DBUserModel.Properties.pwd == pwd) {
                    model._state = .deleted
                    DB.shared.update(table: .user, on: [DBUserModel.Properties.state], with: model, where: DBUserModel.Properties.email == email && DBUserModel.Properties.pwd == pwd)
                    App.startLogout()
                }
            }
        }
    }
    
}
