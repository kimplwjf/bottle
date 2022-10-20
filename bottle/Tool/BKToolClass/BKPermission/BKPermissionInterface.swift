//
//  BKPermissionInterface.swift
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
import HealthKit

enum BKAuthorizationStatus {
    // 未知状态
    case unknown
    // 用户未选择
    case notDetermined
    // 用户没有权限
    case restricted
    // 拒绝
    case denied
    // 允许
    case authorized
    // 临时允许
    case provisional
    // 设备不支持
    case notSupport
    
    /// 是否可以访问
    var isAuthorized: Bool {
        return self == .authorized || self == .provisional
    }
    /// 是否不支持
    var isNotSupport: Bool {
        return self == .notSupport
    }
}

// MARK: - 权限协议
protocol BKPermissionInterface {
    /// 是否允许
    var isAuthorized: Bool { get }
    /// 是否拒绝
    var isDenied: Bool { get }
    /// 是否每次询问
    var isNotDetermined: Bool { get }
    /// 请求权限
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?)
}

// MARK: - 相册
/// 相册权限
struct BKPhotoLibraryPermission: BKPermissionInterface {
    
    var isAuthorized: Bool {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
        } else {
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
    }
    
    var isDenied: Bool {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .denied
        } else {
            return PHPhotoLibrary.authorizationStatus() == .denied
        }
    }
    
    var isNotDetermined: Bool {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined
        } else {
            return PHPhotoLibrary.authorizationStatus() == .notDetermined
        }
    }
    
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            var authStatue: BKAuthorizationStatus = .unknown
            if #available(iOS 14, *) {
                switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
                case .authorized: authStatue = .authorized
                case .notDetermined: authStatue = .notDetermined
                case .restricted: authStatue = .restricted
                case .denied: authStatue = .denied
                default: authStatue = .unknown
                }
                if authStatue == .notDetermined {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        if status == .authorized {
                            authStatue = .authorized
                        } else if status == .denied {
                            authStatue = .denied
                        }
                        callback?(authStatue)
                    }
                } else {
                    callback?(authStatue)
                }
            } else {
                switch PHPhotoLibrary.authorizationStatus() {
                case .authorized: authStatue = .authorized
                case .notDetermined: authStatue = .notDetermined
                case .restricted: authStatue = .restricted
                case .denied: authStatue = .denied
                default: authStatue = .unknown
                }
                if authStatue == .notDetermined {
                    PHPhotoLibrary.requestAuthorization { status in
                        if status == .authorized {
                            authStatue = .authorized
                        } else if status == .denied {
                            authStatue = .denied
                        }
                        callback?(authStatue)
                    }
                } else {
                    callback?(authStatue)
                }
            }
        } else {
            callback?(.notSupport)
        }
    }
    
}

// MARK: - 相机
/// 相机权限
struct BKCameraPermission: BKPermissionInterface {
    
    var isAuthorized: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    var isDenied: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .denied
    }
    
    var isNotDetermined: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }
    
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var authStatue: BKAuthorizationStatus = .unknown
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: authStatue = .authorized
            case .notDetermined: authStatue = .notDetermined
            case .restricted: authStatue = .restricted
            case .denied: authStatue = .denied
            default: authStatue = .unknown
            }
            if authStatue == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { authorized in
                    callback?(authorized ? .authorized : .denied)
                }
            } else {
                callback?(authStatue)
            }
        } else {
            callback?(.notSupport)
        }
    }
    
}

// MARK: - 麦克风
/// 麦克风权限
struct BKMicrophonePermission: BKPermissionInterface {
    
    var isAuthorized: Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    var isDenied: Bool {
        return AVAudioSession.sharedInstance().recordPermission == .denied
    }
    
    var isNotDetermined: Bool {
        return AVAudioSession.sharedInstance().recordPermission == .undetermined
    }
    
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?) {
        if AVAudioSession.sharedInstance().isInputAvailable {
            var authStatue: BKAuthorizationStatus = .unknown
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted: authStatue = .authorized
            case .undetermined: authStatue = .notDetermined
            case .denied: authStatue = .denied
            default: authStatue = .unknown
            }
            if authStatue == .notDetermined {
                AVAudioSession.sharedInstance().requestRecordPermission { authorized in
                    callback?(authorized ? .authorized : .denied)
                }
            } else {
                callback?(authStatue)
            }
        } else {
            callback?(.notSupport)
        }
    }
    
}

/// 全局变量定位授权才能正常弹窗
fileprivate var _locationManager = CLLocationManager()

// MARK: - 定位
/// 定位权限
struct BKLocationPermission: BKPermissionInterface {
    
    var isAuthorized: Bool {
        if #available(iOS 14.0, *) {
            return _locationManager.authorizationStatus == .authorizedWhenInUse || _locationManager.authorizationStatus == .authorizedAlways
        } else {
            return CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        }
    }
    
    var isDenied: Bool {
        if #available(iOS 14.0, *) {
            return _locationManager.authorizationStatus == .denied
        } else {
            return CLLocationManager.authorizationStatus() == .denied
        }
    }
    
    var isNotDetermined: Bool {
        if #available(iOS 14.0, *) {
            return _locationManager.authorizationStatus == .notDetermined
        } else {
            return CLLocationManager.authorizationStatus() == .notDetermined
        }
    }
    
    @available(iOS 14.0, *)
    var fullAccuracy: Bool {
        return _locationManager.accuracyAuthorization == .fullAccuracy
    }
    
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?) {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                var authStatue: BKAuthorizationStatus = .unknown
                if #available(iOS 14.0, *) {
                    switch _locationManager.authorizationStatus {
                    case .authorizedWhenInUse, .authorizedAlways: authStatue = .authorized
                    case .notDetermined: authStatue = .notDetermined
                    case .restricted: authStatue = .restricted
                    case .denied: authStatue = .denied
                    default: authStatue = .unknown
                    }
                } else {
                    switch CLLocationManager.authorizationStatus() {
                    case .authorizedWhenInUse, .authorizedAlways: authStatue = .authorized
                    case .notDetermined: authStatue = .notDetermined
                    case .restricted: authStatue = .restricted
                    case .denied: authStatue = .denied
                    default: authStatue = .unknown
                    }
                }
                if authStatue == .notDetermined {
                    _locationManager.requestWhenInUseAuthorization()
                }
                callback?(authStatue)
            } else {
                callback?(.notSupport)
            }
        }
    }
    
}

// MARK: - 通讯录
/// 通讯录权限
struct BKContactsPermission: BKPermissionInterface {
    
    var isAuthorized: Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    var isDenied: Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .denied
    }
    
    var isNotDetermined: Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .notDetermined
    }
    
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?) {
        var authStatue: BKAuthorizationStatus = .unknown
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: authStatue = .authorized
        case .notDetermined: authStatue = .notDetermined
        case .restricted: authStatue = .restricted
        case .denied: authStatue = .denied
        default: authStatue = .unknown
        }
        if authStatue == .notDetermined {
            CNContactStore().requestAccess(for: .contacts) { authorized, error in
                callback?(authorized ? .authorized : .denied)
            }
        } else {
            callback?(authStatue)
        }
    }
    
}

// MARK: - 运动与健身
/// 运动与健身权限
struct BKCMMotionPermission: BKPermissionInterface {
    
    var isAuthorized: Bool {
        return CMMotionActivityManager.authorizationStatus() == .authorized
    }
    
    var isDenied: Bool {
        return CMMotionActivityManager.authorizationStatus() == .denied
    }
    
    var isNotDetermined: Bool {
        return CMMotionActivityManager.authorizationStatus() == .notDetermined
    }
    
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?) {
        if CMMotionActivityManager.isActivityAvailable() {
            var authStatue: BKAuthorizationStatus = .unknown
            switch CMMotionActivityManager.authorizationStatus() {
            case .authorized: authStatue = .authorized
            case .notDetermined: authStatue = .notDetermined
            case .restricted: authStatue = .restricted
            case .denied: authStatue = .denied
            default: authStatue = .unknown
            }
            if authStatue == .notDetermined {
                let cmManager = CMMotionActivityManager()
                cmManager.startActivityUpdates(to: OperationQueue()) { _ in
                    callback?(.unknown)
                }
            } else {
                callback?(authStatue)
            }
        } else {
            callback?(.notSupport)
        }
    }
    
}

// MARK: - Siri
/// Siri权限
struct BKSiriPermission: BKPermissionInterface {
    
    var isAuthorized: Bool {
        return INPreferences.siriAuthorizationStatus() == .authorized
    }
    
    var isDenied: Bool {
        return INPreferences.siriAuthorizationStatus() == .denied
    }
    
    var isNotDetermined: Bool {
        return INPreferences.siriAuthorizationStatus() == .notDetermined
    }
    
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?) {
        var authStatue: BKAuthorizationStatus = .unknown
        switch INPreferences.siriAuthorizationStatus() {
        case .authorized: authStatue = .authorized
        case .notDetermined: authStatue = .notDetermined
        case .restricted: authStatue = .restricted
        case .denied: authStatue = .denied
        default: authStatue = .unknown
        }
        if authStatue == .notDetermined {
            INPreferences.requestSiriAuthorization { status in
                if status == .authorized {
                    authStatue = .authorized
                } else if status == .denied {
                    authStatue = .denied
                }
                callback?(authStatue)
            }
        } else {
            callback?(authStatue)
        }
    }
    
}

// MARK: - 通知
/// 通知权限
struct BKUserNotifiPermission: BKPermissionInterface {
    
    private let userNotification = UNUserNotificationCenter.current()
    
    private func getNotificationSettings() -> UNAuthorizationStatus {
        var status: UNAuthorizationStatus = .notDetermined
        userNotification.getNotificationSettings { settings in
            status = settings.authorizationStatus
        }
        return status
    }
    
    var isAuthorized: Bool {
        if #available(iOS 12.0, *) {
            return self.getNotificationSettings() == .authorized || self.getNotificationSettings() == .provisional
        } else {
            return self.getNotificationSettings() == .authorized
        }
    }
    
    var isDenied: Bool {
        return self.getNotificationSettings() == .denied
    }
    
    var isNotDetermined: Bool {
        return self.getNotificationSettings() == .notDetermined
    }
    
    func request(completion callback: ((BKAuthorizationStatus) -> Void)?) {
        var authStatue: BKAuthorizationStatus = .unknown
        userNotification.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized: authStatue = .authorized
            case .notDetermined: authStatue = .notDetermined
            case .provisional: authStatue = .provisional
            case .denied: authStatue = .denied
            default: authStatue = .unknown
            }
            if authStatue == .notDetermined {
                userNotification.requestAuthorization(options: [.badge, .alert, .sound]) { authorized, error in
                    callback?(authorized ? .authorized : .denied)
                }
            } else {
                callback?(authStatue)
            }
        }
    }
    
}
