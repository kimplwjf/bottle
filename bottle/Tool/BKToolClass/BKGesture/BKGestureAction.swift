//
//  BKGestureAction.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/12/29.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation
import UIKit

class BKGestureAction<T: UIGestureRecognizer> {
    
    typealias BKGestureHandler = (_ gestureRecognizer: T) -> Void
    
    var beganHandler: BKGestureHandler?
    var changedHandler: BKGestureHandler?
    var cancelledHandler: BKGestureHandler?
    var endedHandler: BKGestureHandler?
    var failedHandler: BKGestureHandler?
    
    @objc func gestureAction(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            beganHandler?(gesture as! T)
        case .changed:
            changedHandler?(gesture as! T)
        case .cancelled:
            cancelledHandler?(gesture as! T)
        case .ended:
            endedHandler?(gesture as! T)
        case .failed:
            failedHandler?(gesture as! T)
        case .possible:
            break
        default:
            break
        }
    }
    
    @discardableResult
    func whenBegan(handler: @escaping BKGestureHandler) -> BKGestureAction<T> {
        beganHandler = handler
        return self
    }
    
    @discardableResult
    func whenChanged(handler: @escaping BKGestureHandler) -> BKGestureAction<T> {
        changedHandler = handler
        return self
    }
    
    @discardableResult
    func whenCancelled(handler: @escaping BKGestureHandler) -> BKGestureAction<T> {
        cancelledHandler = handler
        return self
    }
    
    @discardableResult
    func whenEnded(handler: @escaping BKGestureHandler) -> BKGestureAction<T> {
        endedHandler = handler
        return self
    }
    
    @discardableResult
    func whenFailed(handler: @escaping BKGestureHandler) -> BKGestureAction<T> {
        failedHandler = handler
        return self
    }
    
    /// Tap手势
    func whenTaped(handler: @escaping BKTapGestureHandler) {
        endedHandler = handler as? (T) -> Void
    }
    
    @objc func tapAction(_ gesture: UITapGestureRecognizer) {
        if T.self is UITapGestureRecognizer.Type {
            (endedHandler as! ((UITapGestureRecognizer) -> Void))(gesture)
        }
    }
    
    /// Swipe手势
    func whenSwipe(handler: @escaping BKSwipeGestureHandler) {
        endedHandler = handler as? (T) -> Void
    }
    
    @objc func swipeAction(_ gesture: UISwipeGestureRecognizer) {
        if T.self is UISwipeGestureRecognizer.Type {
            (endedHandler as! ((UISwipeGestureRecognizer) -> Void))(gesture)
        }
    }
    
}

// MARK: - 给UIView快捷添加手势
extension UIView {
    
    /// Tap
    func whenTap(handler: @escaping BKTapGestureHandler) {
        self.isUserInteractionEnabled = true
        let tap = BKTapGesture(handler: handler)
        addGestureRecognizer(tap)
    }
    
    func newTap(config: @escaping BKTapGestureHandler) -> BKGestureAction<UITapGestureRecognizer> {
        self.isUserInteractionEnabled = true
        let tap = BKTapGesture(config: config)
        addGestureRecognizer(tap)
        return tap.gestureAction
    }
    
    /// Pan
    func newPan(config: @escaping BKPanGestureHandler = { _ in }) -> BKGestureAction<UIPanGestureRecognizer> {
        self.isUserInteractionEnabled = true
        let pan = BKPanGesture(config: config)
        addGestureRecognizer(pan)
        return pan.gestureAction
    }
    
    /// LongPress
    func newLongPress(config: @escaping BKLongPressGestureHandler = { _ in }) -> BKGestureAction<UILongPressGestureRecognizer> {
        self.isUserInteractionEnabled = true
        let longPress = BKLongPressGesture(config: config)
        addGestureRecognizer(longPress)
        return longPress.gestureAction
    }
    
    /// Swipe
    func newSwipe(config: @escaping BKSwipeGestureHandler) -> BKGestureAction<UISwipeGestureRecognizer> {
        self.isUserInteractionEnabled = true
        let swipe = BKSwipeGesture(config: config)
        addGestureRecognizer(swipe)
        return swipe.gestureAction
    }
    
}
