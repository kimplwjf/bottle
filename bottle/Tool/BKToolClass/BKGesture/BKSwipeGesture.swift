//
//  BKSwipeGesture.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/12/29.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

typealias BKSwipeGestureHandler = (UISwipeGestureRecognizer) -> Void

class BKSwipeGesture: UISwipeGestureRecognizer {
    
    var gestureAction = BKGestureAction<UISwipeGestureRecognizer>()
    
    init(config: @escaping BKSwipeGestureHandler) {
        super.init(target: gestureAction, action: #selector(gestureAction.swipeAction(_:)))
        config(self)
    }
    
}
