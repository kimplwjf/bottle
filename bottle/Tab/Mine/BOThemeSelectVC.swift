//
//  BOThemeSelectVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/10/9.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BOThemeSelectVC: BaseVC {
    
    deinit {
        PPP("[\(NSStringFromClass(type(of: self)))]>>>已被释放")
    }
    
    private var rows: [BKDarkModeUtil.Mode] = [.follow, .light, .dark]
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "外观设置"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let row = rows.firstIndex(of: BKDarkModeUtil.mode) ?? 0
        tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
    }
    
    // MARK: - lazy
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .lightWhiteDark17
        tv.estimatedRowHeight = 44
        tv.rowHeight = UITableView.automaticDimension
        tv.showsVerticalScrollIndicator = false
        tv.tableHeaderView = UIView(frame: kCGRect(0, 0, kScreenWidth, 10))
        tv.tableFooterView = UIView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(cellWithClass: BOThemeSelectCell.self)
        return tv
    }()
    
}

// MARK: - Private
extension BOThemeSelectVC {
    
    private func changeTheme() {
        guard let window = UIApplication.shared.keyWindow else { return }
        if #available(iOS 13.0, *) {
            // 增加转场动画
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
                // 重置系统模式
                window.overrideUserInterfaceStyle = BKDarkModeUtil.mode.style
            }
        }
    }
    
}

// MARK: - UITableView代理
extension BOThemeSelectVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: BOThemeSelectCell.self, for: indexPath)
        cell.kTitleLabel.text = rows[indexPath.row].des
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mode = rows[indexPath.row]
        BKDarkModeUtil.mode = mode
        self.changeTheme()
    }
    
}
