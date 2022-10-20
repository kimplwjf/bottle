//
//  BOCollectListVC.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/19.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit

class BOCollectListVC: BaseVC {
    
    private var collectModels = [DBCollectModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "已喜欢"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.reload()
        
    }
    
    // MARK: - lazy
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .lightWhiteDark27
        tv.estimatedRowHeight = 44
        tv.rowHeight = UITableView.automaticDimension
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        tv.register(cellWithClass: BOCollectListCell.self)
        return tv
    }()
    
}

// MARK: - Private
extension BOCollectListVC {
    
    private func reload() {
        let models: [DBCollectModel] = DB.shared.querys(table: .collect, where: DBCollectModel.Properties.userId == XMApp.kUserId)
        if models.isEmpty {
            self.showEmptyData(tableView)
        } else {
            collectModels = models
        }
        tableView.reloadData()
    }
    
    private func deleteCollect(by model: DBCollectModel) {
        UIAlertController.showTwoAlert(in: self, title: "确认删除吗?", okTitle: "确定") { [unowned self] _ in
            DB.shared.delete(table: .collect, where: DBCollectModel.Properties.userId == XMApp.kUserId && DBCollectModel.Properties.collect == model.collect)
            self.reload()
        }
    }
    
}

// MARK: - UITableView代理
extension BOCollectListVC: UITableViewDelegate, UITableViewDataSource {
    
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: BOCollectListCell.self, for: indexPath)
        if let model = collectModels[safe: indexPath.row] {
            cell.kTitleLabel.text = model.collect
        }
        return cell
        
    }
    
    // 实现这个方法后,在非编辑模式下,左滑 cell 会显示一个 delete 按钮
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let model = collectModels[indexPath.row]
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { [unowned self] (action, indexPath) in
            self.deleteCollect(by: model)
        }
        return [delete]
        
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let model = collectModels[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "删除") { (action, view, completion) in
            self.deleteCollect(by: model)
            completion(true)
        }
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
        
    }
    
}
