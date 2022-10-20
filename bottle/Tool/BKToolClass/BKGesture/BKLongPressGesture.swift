//
//  BKLongPressGesture.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/12/29.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

typealias BKLongPressGestureHandler = (UILongPressGestureRecognizer) -> Void

class BKLongPressGesture: UILongPressGestureRecognizer {
    
    var gestureAction = BKGestureAction<UILongPressGestureRecognizer>()
    
    init(config: @escaping BKLongPressGestureHandler) {
        super.init(target: gestureAction, action: #selector(gestureAction.gestureAction(_:)))
        config(self)
    }
    
}
