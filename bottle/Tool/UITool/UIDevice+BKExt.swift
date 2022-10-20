//
//  UIDevice+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/8/10.
//  Copyright © 2020 王锦发. All rights reserved.
//

import Foundation
import UIKit

enum BKDeviceType: Int {
    case unknown = 0
    case iPhone
    case iPad
    case iPod
}

fileprivate let Device_brand       = "devicebrand"       // 设备类型名称, eg: "iPhone, iPod touch"
fileprivate let Device_detailBrand = "devicedetailbrand" // 设备的具体型号, eg: "iPhone X, iPhone XS"
fileprivate let Device_source      = "devicesource"      // 设备的系统名称, eg: "iOS"
fileprivate let Device_version     = "deviceversion"     // 设备的系统版本号, eg: "13.1.2"
fileprivate let Device_uuid        = "deviceuuid"        // 设备的唯一识别码uuid, eg: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"

// MARK: - UIDevice扩展
extension UIDevice {
    
    /**
     * 获取当前的运行手机的详细信息
     */
    static func bk_appInfo() -> [String] {
        var info = [String]()
        info.append("Device Name: \(bk_settingName)")
        info.append("Bundle Identifier: \(kAppBundleId)")
        info.append("Host App Version: \(kAppVersion).\(kAppBuildVersion)")
        info.append("Identifier For Vendor: \(bk_uuid)")
        info.append("System Version: \(bk_systemVersion)")
        info.append("Model: \(bk_detailBrand)")
        info.append("Total Disk Space(MB): \(UIDevice.current.totalDiskSpaceInMB)")
        info.append("Free Disk Space(MB): \(UIDevice.current.freeDiskSpaceInMB)")
        let lastRestarted = Date(timeIntervalSince1970: TimeInterval(Date().timeStamp - uptime()))
        info.append("Uptime: \(uptime())/\(lastRestarted)")
        return info
    }
    
    /** uptime in seconds */
    class func uptime() -> Int {
        var currentTime = time_t()
        var bootTime = timeval()
        var mib = [CTL_KERN, KERN_BOOTTIME]
        
        var size = MemoryLayout<timeval>.stride
        
        var uptime: time_t = -1
        time(&currentTime)
        
        if sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0) != -1 && bootTime.tv_sec != 0 {
            if currentTime < bootTime.tv_sec {
                return uptime
            }
            uptime = currentTime - bootTime.tv_sec
        }
        return uptime
    }
    
    /**
     * 获取当前的运行手机的详细信息
     */
    static var bk_deviceInfo: Dictionary<String, String> {
        var info = Dictionary<String, String>()
        info[Device_brand] = UIDevice.bk_brand
        info[Device_detailBrand] = UIDevice.bk_detailBrand
        info[Device_source] = UIDevice.bk_systemName
        info[Device_version] = UIDevice.bk_systemVersion
        info[Device_uuid] = UIDevice.bk_uuid
        return info
    }
    
    /**
     * 获取当前的运行手机的系统版本号
     * eg: "13.1.2"
     * return 系统版本
     */
    static var bk_systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /**
     * 获取当前设备的手机系统名称
     * eg: "iOS"
     * return 手机系统名称
     */
    static var bk_systemName: String {
        return UIDevice.current.systemName
    }
    
    /**
     * 获取当前设备类型名称
     * eg: "iPhone, iPod touch, iPad"
     * return 设备类型的名称
     */
    static var bk_brand: String {
        return UIDevice.current.model
    }
    
    /**
     * 获取当前设备的唯一识别码uuid
     * ⚠️删除应用程序，再重新安装，则uuid会发生改变
     */
    static var bk_uuid: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    /**
     * 获取当前设备用户设置的名称, 设置->通用->关于本机->名称
     * eg: "My iPhone"
     * return 用户设置的本机名称
     */
    static var bk_settingName: String {
        return UIDevice.current.name
    }
    
    /**
     * 获取当前电池电量百分比，取值范围 0 至 1.0，如果返回 -1.0 表示无法识别电池
     * return 0.53 表示剩余电量 53%
     */
    static var bk_batteryLevel: CGFloat {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return CGFloat(UIDevice.current.batteryLevel)
    }
    
    /**
     * 获取当前电池充电状态
     */
    static var bk_batteryIsCharging: Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryState.rawValue > 1
    }
    
    static var bk_isiPhone: Bool {
        return UIDevice.getDeviceType() == .iPhone
    }
    
    static var bk_isiPad: Bool {
        return UIDevice.getDeviceType() == .iPad
    }
    
    static var bk_isiPod: Bool {
        return UIDevice.getDeviceType() == .iPod
    }
    
    /**
     * 获取当前设备类型
     * eg: BKDeviceType
     * return 当前设备类型的枚举
     */
    private static func getDeviceType() -> BKDeviceType {
        let type = UIDevice.current.model
        let isiPhone = type.contains("iPhone")
        let isiPad = type.contains("iPad")
        let isiPod = type.contains("iPod")
        if isiPhone {
            return .iPhone
        } else if isiPad {
            return .iPad
        } else if isiPod {
            return .iPod
        } else {
            return .unknown
        }
    }
    
    /**
     * 获取当前设备的具体型号
     * eg: "iPhone X, iPhone XS"
     * return 设备的具体型号
     */
    static var bk_detailBrand: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { unsafePointer in
            return String(cString: unsafePointer)
        }
        switch platform {
        case "iPhone1,1":                           return "iPhone 2G"
        case "iPhone1,2":                           return "iPhone 3G"
        case "iPhone2,1":                           return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1":                           return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":              return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":              return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":              return "iPhone 5s"
        case "iPhone7,1":                           return "iPhone 6 Plus"
        case "iPhone7,2":                           return "iPhone 6"
        case "iPhone8,1":                           return "iPhone 6s"
        case "iPhone8,2":                           return "iPhone 6s Plus"
        case "iPhone8,4":                           return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":              return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":              return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":            return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":            return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":            return "iPhone X"
        case "iPhone11,2":                          return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":            return "iPhone XS Max"
        case "iPhone11,8":                          return "iPhone XR"
        case "iPhone12,1":                          return "iPhone 11"
        case "iPhone12,3":                          return "iPhone 11 Pro"
        case "iPhone12,5":                          return "iPhone 11 Pro Max"
        case "iPhone12,8":                          return "iPhone SE 2nd Gen"
        case "iPhone13,1":                          return "iPhone 12 mini"
        case "iPhone13,2":                          return "iPhone 12"
        case "iPhone13,3":                          return "iPhone 12 Pro"
        case "iPhone13,4":                          return "iPhone 12 Pro Max"
        case "iPhone14,4":                          return "iPhone 13 mini"
        case "iPhone14,5":                          return "iPhone 13"
        case "iPhone14,2":                          return "iPhone 13 Pro"
        case "iPhone14,3":                          return "iPhone 13 Pro Max"
        case "iPhone14,6":                          return "iPhone SE 3rd Gen"
        case "iPhone14,7":                          return "iPhone 14"
        case "iPhone14,8":                          return "iPhone 14 Plus"
        case "iPhone15,2":                          return "iPhone 14 Pro"
        case "iPhone15,3":                          return "iPhone 14 Pro Max"
        
        case "iPod1,1": return "iPod Touch 1G"
        case "iPod2,1": return "iPod Touch 2G"
        case "iPod3,1": return "iPod Touch 3G"
        case "iPod4,1": return "iPod Touch 4G"
        case "iPod5,1": return "iPod Touch 5G"
        case "iPod7,1": return "iPod Touch 6G"
        case "iPod9,1": return "iPod Touch 7G"
        
        case "iPad1,1":                                  return "iPad 1G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":            return "iPad 4"
        case "iPad6,11":                                 return "iPad 5 (WiFi)"
        case "iPad6,12":                                 return "iPad 5 (Cellular)"
        case "iPad7,5":                                  return "iPad 6th Gen (WiFi)"
        case "iPad7,6":                                  return "iPad 6th Gen (WiFi+Cellular)"
        case "iPad7,11", "iPad7,12":                     return "iPad 7"
        case "iPad11,6", "iPad11,7":                     return "iPad 8"
        
        case "iPad6,3", "iPad6,4":                       return "iPad Pro 9.7"
        case "iPad6,7", "iPad6,8":                       return "iPad Pro 12.9"
        case "iPad7,1":                                  return "iPad Pro 12.9 inch 2nd gen (WiFi)"
        case "iPad7,2":                                  return "iPad Pro 12.9 inch 2nd gen (Cellular)"
        case "iPad7,3":                                  return "iPad Pro 10.5 inch (WiFi)"
        case "iPad7,4":                                  return "iPad Pro 10.5 inch (Cellular)"
        case "iPad8,1":                                  return "iPad Pro 3rd Gen (11 inch, WiFi)"
        case "iPad8,2":                                  return "iPad Pro 3rd Gen (11 inch, 1TB, WiFi)"
        case "iPad8,3":                                  return "iPad Pro 3rd Gen (11 inch, WiFi+Cellular)"
        case "iPad8,4":                                  return "iPad Pro 3rd Gen (11 inch, 1TB, WiFi+Cellular)"
        case "iPad8,9", "iPad8,10":                      return "iPad Pro 3rd Gen (11 inch 2nd gen)"
        case "iPad8,5":                                  return "iPad Pro 3rd Gen (12.9 inch, WiFi)"
        case "iPad8,6":                                  return "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi)"
        case "iPad8,7":                                  return "iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)"
        case "iPad8,8":                                  return "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi+Cellular)"
        case "iPad8,11", "iPad8,12":                     return "iPad Pro 4th Gen (12.9 inch)"
        
        case "iPad4,1", "iPad4,2", "iPad4,3":            return "iPad Air"
        case "iPad5,3", "iPad5,4":                       return "iPad Air 2"
        case "iPad11,3":                                 return "iPad Air 3rd Gen (WiFi)"
        case "iPad11,4":                                 return "iPad Air 3rd Gen"
        case "iPad13,1", "iPad13,2":                     return "iPad Air 4"
        
        case "iPad2,5", "iPad2,6", "iPad2,7":            return "iPad mini 1G"
        case "iPad4,4", "iPad4,5", "iPad4,6":            return "iPad mini 2G"
        case "iPad4,7", "iPad4,8", "iPad4,9":            return "iPad mini 3"
        case "iPad5,1":                                  return "iPad mini 4 (WiFi)"
        case "iPad5,2":                                  return "iPad mini 4 (LTE)"
        case "iPad11,1":                                 return "iPad mini 5th Gen (WiFi)"
        case "iPad11,2":                                 return "iPad mini 5th Gen"
        
        case "AppleTV2,1":               return "Apple TV 2"
        case "AppleTV3,1", "AppleTV3,2": return "Apple TV 3"
        case "AppleTV5,3":               return "Apple TV 4"
            
        case "i386", "x86_64":           return "iPhone Simulator"
        default: return platform
        }
    }
    
}

extension UIDevice {
    
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    // MARK: Get String Value
    var totalDiskSpaceInGB: String {
        return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var freeDiskSpaceInGB: String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var usedDiskSpaceInGB: String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var totalDiskSpaceInMB: String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB: String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB: String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    // MARK: Get raw value
    var totalDiskSpaceInBytes: Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    var freeDiskSpaceInBytes: Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
    
}
