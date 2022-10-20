//
//  LXFProtocolTool+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/2/28.
//  Copyright © 2022 王锦发. All rights reserved.
//

import Foundation
import LXFProtocolTool
import UIKit

extension UIView: LXFEmptyDataSetable {
    
    /// 展示空数据页
    func showEmptyData(_ scroll: UIScrollView,
                       tip: String = .emptyContent,
                       tipImg: UIImage = UIImage(named: "LXFEmptyDataPic")!,
                       offset: CGFloat = -50) {
        self.lxf_EmptyDataSet(scroll) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            return [.tipStr: tip,
                    .tipImage: tipImg,
                    .tipColor: XMColor.light139,
                    .verticalOffset: offset]
        }
    }
    
}

extension UIViewController: LXFEmptyDataSetable {
    
    /// 展示空数据页
    func showEmptyData(_ scroll: UIScrollView,
                       tip: String = .emptyContent,
                       tipImg: UIImage = UIImage(named: "LXFEmptyDataPic")!,
                       offset: CGFloat = -50) {
        self.lxf_EmptyDataSet(scroll) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            return [.tipStr: tip,
                    .tipImage: tipImg,
                    .tipColor: XMColor.light139,
                    .verticalOffset: offset]
        }
    }
    
}
