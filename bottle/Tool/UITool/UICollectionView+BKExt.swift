//
//  UICollectionView+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

// MARK: UICollectionView 扩展
extension UICollectionView {
    
    /// 批量注册 Cell
    func bk_registerForCells<T: UICollectionViewCell>(_ cellClasses: [T.Type], isNib: Bool = true) {
        cellClasses.forEach { cellClass in
            bk_registerForCell(cellClass, isNib: isNib)
        }
    }
    
    /// 注册 Cell
    func bk_registerForCell<T: UICollectionViewCell>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let cellIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        } else {
            self.register(cellClass, forCellWithReuseIdentifier: cellIdentifier)
        }
    }
    
    /// 注册顶部视图
    func bk_registerForHeader<T: UICollectionReusableView>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let headerIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        } else {
            self.register(cellClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        }
    }
    
    /// 注册底部视图
    func bk_registerForFooter<T: UICollectionReusableView>(_ cellClass: T.Type, identifier: String? = nil, isNib: Bool = true) {
        let nibName = cellClass.className
        let footerIdentifier = identifier ?? nibName
        if isNib {
            self.register(UINib(nibName: nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        } else {
            self.register(cellClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        }
    }
    
    /// 从缓存池取出 Cell
    func bk_dequeueCell<T: UICollectionViewCell>(_ cellClass: T.Type, reuseIdentifier: String? = nil, indexPath: IndexPath) -> T {
        let identifier: String = reuseIdentifier ?? cellClass.className
        if let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T {
            return cell
        } else {
            return T()
        }
    }
    
    /// 从缓存池取出顶部或者底部实体
    func bk_dequeueSupplementaryView<T: UICollectionReusableView>(_ viewClass: T.Type, kind: String, indexPath: IndexPath) -> T {
        let identifier = viewClass.className
        if let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? T {
            return cell
        } else {
            return T()
        }
    }
    
    /// 滑动到第一个 Cell 位置，通过增加判断，防止奔溃
    func scrollToFirstCell(animated: Bool = true) {
        guard self.numberOfSections > 0 else { return }
        guard let count = self.dataSource?.collectionView(self, numberOfItemsInSection: 0) else { return }
        if count > 0 {
            if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
                if flowLayout.scrollDirection == .horizontal {
                    scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: animated)
                } else {
                    scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
                }
            }
        }
    }
    
}
