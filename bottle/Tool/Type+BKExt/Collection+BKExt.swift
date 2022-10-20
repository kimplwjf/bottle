//
//  Collection+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/11/9.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation

extension Collection {
    
    subscript(safe index: Self.Index) -> Iterator.Element? {
        (startIndex..<endIndex).contains(index) ? self[index] : nil
    }
    
}
