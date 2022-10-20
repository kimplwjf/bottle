//
//  BKTapGesture.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/12/29.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

typealias BKTapGestureHandler = (UITapGestureRecognizer) -> Void

class BKTapGesture: UITapGestureRecognizer {
    
    var gestureAction = BKGestureAction<UITapGestureRecognizer>()
    
    init(handler: @escaping BKTapGestureHandler) {
        gestureAction.endedHandler = handler
        super.init(target: gestureAction, action: #selector(gestureAction.tapAction(_:)))
        
    }
    
    init(config: @escaping BKTapGestureHandler) {
        super.init(target: gestureAction, action: #selector(gestureAction.tapAction(_:)))
        config(self)
    }
    
}
