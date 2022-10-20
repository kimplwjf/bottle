//
//  BKFeedbackUtil.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/1/11.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 添加震动反馈
struct BKFeedbackUtil {
    
    /// 系统震动
    static func bk_addSystemShake() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
     // MARK: - UINotificationFeedbackGenerator
    static func bk_addNotifi(_ type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    // MARK: - UIImpactFeedbackGenerator
    static func bk_addImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    @available(iOS 13.0, *)
    static func bk_addNewImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .rigid) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - UISelectionFeedbackGenerator
    static func bk_addSelect() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
}
