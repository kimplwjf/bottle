//
//  UITableView+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/5/20.
//  Copyright © 2020 王锦发. All rights reserved.
//

import Foundation
import UIKit

struct BKSection {
    var headerTitles: String?
    var headerCls: AnyClass?
    var headerID: String?
    var headerHeight: CGFloat? = 0
    var rows: [BKRow]
}

struct BKRow {
    var cls: AnyClass
    var ID: String
}

// MARK: UITableView 扩展
extension UITableView {
    
    /// 自定义注册
    /// - Parameter bkSections:
    func bk_register(by bkSections: [BKSection]) {
        // 注册 headerView
        bkSections.forEach { [weak self] (tmpSection) in
            // 注册 headerView
            if let cls = tmpSection.headerCls, let id = tmpSection.headerID {
                self?.register(cls, forHeaderFooterViewReuseIdentifier: id)
            }
            // 注册 cell
            tmpSection.rows.forEach { (tmpRow) in
                self?.register(tmpRow.cls, forCellReuseIdentifier: tmpRow.ID)
            }
        }
    }
    
    func bk_reloadRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        self.reloadRows(at: [indexPath], with: animation)
    }
    
    func bk_reloadRow(_ row: Int, inSection: Int, with animation: UITableView.RowAnimation) {
        let toReload = IndexPath(row: row, section: inSection)
        self.bk_reloadRow(at: toReload, with: animation)
    }
    
    func bk_reloadSection(_ section: Int, with animation: UITableView.RowAnimation) {
        let indexSet = IndexSet(integer: section)
        self.reloadSections(indexSet, with: animation)
    }
    
    func bk_scrollToBottom(animated: Bool = true) {
        let section = numberOfSections
        if section > 0 {
            let row = numberOfRows(inSection: section-1)
            if row > 0 {
                self.scrollToRow(at: IndexPath(row: row-1, section: section-1), at: .bottom, animated: animated)
            }
        }
    }
    
}

// MARK: - 自适应Table Header Footer
extension UITableView {
    
    /// 设置自动撑开 Header Footer
    ///
    /// - Parameters:
    ///   - headerV: tableView 顶部的view
    ///   - footerV: tableView 底部的view
    func bk_setHeaderFooter(headerV: UIView?, footerV: UIView? = nil) {
        if let _headerV = headerV {
            self.setHeaderFooter(&tableHeaderView, contentV: _headerV)
        }
        if let _footerV = footerV {
            self.setHeaderFooter(&tableFooterView, contentV: _footerV)
        }
    }
    
    /// 更新headerFooterV 的 size
    func bk_updateHeaderFooterVSize() {
        self.updateSize(&tableHeaderView)
        self.updateSize(&tableFooterView)
    }
    
    /// 设置自动撑开 Header Footer View
    ///
    /// - Parameters:
    ///   - headerFooterV: headerView & FooterView
    ///   - contentV: 内容(通过约束自动撑开)
    private func setHeaderFooter(_ headerFooterV: inout UIView?, contentV: UIView) {
        let view = UIView()
        view.addSubview(contentV)
        contentV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        headerFooterV = view
        self.updateSize(&headerFooterV)
    }
    
    /// 更新 headerFooterV 的 size
    ///
    /// - Parameters:
    ///   - headerFooterV: 头部尾部的View
    private func updateSize(_ headerFooterV: inout UIView?) {
        guard let view = headerFooterV else { return }
        // 需要布局子视图
        view.setNeedsLayout()
        // 立马布局子视图
        view.layoutIfNeeded()
        
        let height = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = view.frame
        frame.size.height = height
        view.frame = frame
        // 重新设置headerFooterV
        headerFooterV = view
    }
    
}
