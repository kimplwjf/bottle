//
//  IQKeyboardManager+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/6/23.
//  Copyright © 2022 王锦发. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

extension IQKeyboardManager {
    
    static func open() {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    
    static func close() {
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
    }
    
}
