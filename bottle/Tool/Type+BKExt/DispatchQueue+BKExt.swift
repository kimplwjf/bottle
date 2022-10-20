//
//  DispatchQueue+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/6/24.
//  Copyright © 2022 王锦发. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    private static var onceTracker = [String]()
    
    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
    }
    
}
