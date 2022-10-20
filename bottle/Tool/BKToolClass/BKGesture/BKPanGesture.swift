//
//  BKPanGesture.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/12/29.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

typealias BKPanGestureHandler = (UIPanGestureRecognizer) -> Void

class BKPanGesture: UIPanGestureRecognizer {
    
    var gestureAction = BKGestureAction<UIPanGestureRecognizer>()
    
    init(config: @escaping BKPanGestureHandler) {
        super.init(target: gestureAction, action: #selector(gestureAction.gestureAction(_:)))
        config(self)
    }
    
}
