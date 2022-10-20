//
//  BOPersonalInfoVC.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/18.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit

class BOPersonalInfoVC: BaseVC {
    
    deinit {
        PPP("[\(NSStringFromClass(type(of: self)))]>>>已被释放")
    }
    
    enum ItemType: Int {
        case nickname = 0
        case sex
        case address
        
        var title: String {
            switch self {
            case .nickname: return "昵称"
            case .sex: return "性别"
            case .address: return "地区"
            }
        }
    }
    
    private var listModels = [BKListModel]()
    private var rows: [ItemType] = [.nickname, .sex, .address]
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "个人信息"
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.reloadModel()
        
    }
    
    // MARK: - lazy
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .lightWhiteDark27
        tv.estimatedRowHeight = 44
        tv.rowHeight = UITableView.automaticDimension
        tv.keyboardDismissMode = .onDrag
        tv.separatorStyle = .none
        tv.tableFooterView = UIView()
        tv.showsVerticalScrollIndicator = false
        tv.delegate = self
        tv.dataSource = self
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        tv.register(cellWithClass: BaseTextFieldCell.self)
        tv.register(cellWithClass: BaseRightCell.self)
        return tv
    }()
    
}

// MARK: - Private
extension BOPersonalInfoVC {
    
    private func reloadModel() {
        var row = BKListModel()
        rows.forEach { item in
            switch item {
            case .nickname: row = BKListModel(title: item.title, placeholder: "请输入\(item.title)")
            case .sex, .address: row = BKListModel(title: item.title, placeholder: "请选择\(item.title)")
            }
            listModels.append(row)
        }
        tableView.reloadData()
    }
    
    private func updateDB(by row: ItemType) {
        let email = XMApp.kUserModel?.email ?? ""
        let pwd = XMApp.kUserModel?.pwd ?? ""
        if let model: DBUserModel = DB.shared.query(table: .user, where: DBUserModel.Properties.email == email && DBUserModel.Properties.pwd == pwd) {
            switch row {
            case .nickname:
                model.nickname = XMApp.kNickname
                DB.shared.update(table: .user, on: [DBUserModel.Properties.nickname], with: model, where: DBUserModel.Properties.email == email && DBUserModel.Properties.pwd == pwd)
            case .sex:
                model.sex = XMApp.kSex ?? 1
                DB.shared.update(table: .user, on: [DBUserModel.Properties.sex], with: model, where: DBUserModel.Properties.email == email && DBUserModel.Properties.pwd == pwd)
            case .address:
                let userModel = XMApp.kUserModel
                model.province = userModel?.province ?? ""
                model.city = userModel?.city ?? ""
                model.area = userModel?.area ?? ""
                DB.shared.update(table: .user, on: [DBUserModel.Properties.province, DBUserModel.Properties.city, DBUserModel.Properties.area], with: model, where: DBUserModel.Properties.email == email && DBUserModel.Properties.pwd == pwd)
            }
        }
    }
    
    private func reloadRow(by row: ItemType) {
        tableView.bk_reloadRow(row.rawValue, inSection: 0, with: .none)
    }
    
}

// MARK: - UITableView代理
extension BOPersonalInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowModel = listModels[indexPath.row]
        let item = rows[indexPath.row]
        switch item {
        case .nickname:
            
            let cell = tableView.dequeueReusableCell(withClass: BaseTextFieldCell.self, for: indexPath)
            let model = XMApp.kUserModel
            cell.accessoryType = .disclosureIndicator
            cell.kTextField.bk_addPlaceholder(rowModel.placeholder, color: XMColor.light139)
            cell.reloadTitle(rowModel.title)
            cell.kTextField.textColor = XMColor.light139
            cell.kTextField.text = XMApp.kNickname
            cell.kTextField.bk_addTarget { tf in
                model?.nickname = tf.text ?? ""
                XMApp.kUserModel = model
                self.updateDB(by: .nickname)
            }
            return cell
            
        case .sex, .address:
            
            let cell = tableView.dequeueReusableCell(withClass: BaseRightCell.self, for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.kTitleLabel.text = rowModel.title
            cell.rightLabel.text = rowModel.placeholder
            if item == .sex {
                let sexType = SexType(rawValue: XMApp.kSex ?? 1) ?? .man
                cell.rightLabel.text = sexType.style.des
            } else {
                cell.rightLabel.text = "\(XMApp.kUserModel?.province ?? "") \(XMApp.kUserModel?.city ?? "") \(XMApp.kUserModel?.area ?? "")"
            }
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = rows[indexPath.row]
        switch item {
        case .sex:
            BKBRPickerView.bk_showStrPicker { [weak self] (index, value) in
                let model = XMApp.kUserModel
                model?.sex = index+1
                XMApp.kUserModel = model
                self?.reloadRow(by: .sex)
                self?.updateDB(by: .sex)
            }
        case .address:
            BKBRPickerView.bk_showAddressPicker { [weak self] (p, c, a) in
                guard let province = p.name, let city = c.name, let area = a.name else { return }
                let model = XMApp.kUserModel
                model?.province = province
                model?.city = city
                model?.area = area
                XMApp.kUserModel = model
                self?.reloadRow(by: .address)
                self?.updateDB(by: .address)
            }
        default:
            break
        }
        
    }
    
}
