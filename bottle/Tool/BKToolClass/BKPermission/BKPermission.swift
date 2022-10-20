//
//  BKPermission.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/10/6.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
import Photos
import MapKit
import EventKit
import Contacts
import Speech
import MediaPlayer
import CoreMotion
import Intents

class BKPermission: NSObject {
    
    enum BKPermissionType: String {
        case photoLibrary = "照片"
        case camera = "相机"
        case microphone = "麦克风"
        case location = "定位服务"
        case contacts = "通讯录权限"
        case cmMotion = "运动与健身"
        case siri = "Siri服务"
        case userNotifi = "消息推送"
        
        var msg: String {
            switch self {
            case .photoLibrary: return "请前往「设置—隐私—照片」中打开开关。"
            case .camera: return "请前往「设置—隐私—相机」中打开开关。"
            case .microphone: return "请前往「设置—隐私—麦克风」中打开开关。"
            case .location: return "想要更准确地记录你的运动记录。点击“设置”,开启定位服务。"
            case .contacts: return "请前往「设置—隐私—通讯录」中打开开关。"
            case .cmMotion: return "想要获取步数等数据。点击“设置”,开启运动与健身。"
            case .siri: return "想要通过Siri控制跑步。点击“设置”,开启Siri。"
            case .userNotifi: return "想要及时获取消息。点击“设置”,开启通知。"
            }
        }
    }
    
    /// 是否允许权限
    static func isAllowed(_ type: BKPermissionType) -> Bool {
        let manager = self.getManagerForPermission(type)
        return manager.isAuthorized
    }
    
    /// 是否拒绝权限
    static func isDenied(_ type: BKPermissionType) -> Bool {
        let manager = self.getManagerForPermission(type)
        return manager.isDenied
    }
    
    /// 是否是【下次询问或在我共享时】【允许一次】【每次询问】
    static func isNotDetermined(_ type: BKPermissionType) -> Bool {
        let manager = self.getManagerForPermission(type)
        return manager.isNotDetermined
    }
    
    /// 定位权限的精度是否是精确位置
    @available(iOS 14.0, *)
    static func isFullAccuracy() -> Bool {
        let manager = self.getManagerForPermission(.location) as! BKLocationPermission
        return manager.fullAccuracy
    }
    
    /// 请求权限
    static func request(_ type: BKPermissionType, completion callback: ((BKAuthorizationStatus) -> Void)? = nil) {
        let manager = self.getManagerForPermission(type)
        manager.request { status in
            DispatchQueue.main.async {
                if status.isNotSupport {
                    BPM.showAlert(.warning, msg: "当前设备不支持\(type.rawValue)!")
                }
                if status == .denied {
                    switch type {
                    case .location, .cmMotion:
                        self.openSettings(type)
                    case .photoLibrary, .camera, .microphone:
                        self.openSettings(type)
                    default:
                        break
                    }
                }
                callback?(status)
            }
        }
    }
    
}

// MARK: - Private
extension BKPermission {
    
    private static func getManagerForPermission(_ type: BKPermissionType) -> BKPermissionInterface {
        switch type {
        case .photoLibrary: return BKPhotoLibraryPermission()
        case .camera: return BKCameraPermission()
        case .microphone: return BKMicrophonePermission()
        case .location: return BKLocationPermission()
        case .contacts: return BKContactsPermission()
        case .cmMotion: return BKCMMotionPermission()
        case .siri: return BKSiriPermission()
        case .userNotifi: return BKUserNotifiPermission()
        }
    }
    
    private static func openSettings(_ type: BKPermissionType) {
        UIAlertController.showTwoAlertInRoot(title: "\(kAppName)\(type.rawValue)已关闭", msg: type.msg, okTitle: "设置") { _ in
            BKUtils.bk_openSettings()
        }
    }
    
}
