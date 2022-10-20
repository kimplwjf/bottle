//
//  BKUtils.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/27.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class BKUtils: NSObject {
    
}

// MARK: - 常规跳转方法
extension BKUtils {
    
    static func bk_call(_ number: String, _ errorBlock: ((_ errDes: String) -> Void)?) {
        if number.isEmpty {
            errorBlock?("号码不能为空")
            return
        }
        let tel = "tel://" + number
        guard let url = URL(string: tel.removeAllSpace) else { return }
        self.bk_openURL(url) {
            errorBlock?("你的设备不支持打电话")
            return
        }
    }
    
    static func bk_openURL(_ url: URL, errBlock: (() -> Void)? = nil) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            errBlock?()
        }
    }
    
    /// 跳转App系统设置
    static func bk_openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        self.bk_openURL(url)
    }
    
}

// MARK: - 定位逆地理相关
extension BKUtils {
    
    /// 反编译GPS坐标点 判断坐标点位置是否在中国大陆
    ///
    /// - Parameters:
    ///   - location: GPS坐标点
    ///   - handler: errMsg: 出错 / inChina: 是否在中国大陆
    static func bk_reGeocodeInChinaMainland(by location: CLLocation, inChinaMainland handler: @escaping InChinaMainlandCallback) {
        let _geocoder = CLGeocoder()
        _geocoder.bk_reverseGeocodeWith(location: location, inChinaMainland: handler)
    }
    
    /// 反编译GPS坐标点 判断坐标点位置是否在港澳台
    ///
    /// - Parameters:
    ///   - location: GPS坐标点
    ///   - handler: errMsg: 出错 / inHMT: 是否在港澳台
    static func bk_reGeocodeInHMT(by location: CLLocation, inHMT handler: @escaping InHMTCallback) {
        let _geocoder = CLGeocoder()
        _geocoder.bk_reverseGeocodeWith(location: location, inHMT: handler)
    }
    
    /// 反编译GPS坐标点 判断坐标点位置所在地区
    ///
    /// placemark 内部属性: 四大直辖市的城市信息无法通过locality获得，只能通过获取省份(administrativeArea)的方法来获得（如果locality为空，则可知为直辖市）
    ///     administrativeArea >>> 广东省
    ///     country            >>> 中国
    ///     isoCountryCode     >>> CN
    ///     locality           >>> 广州市
    ///     name               >>> 螺旋四路1号
    ///     subLocality        >>> 海珠区
    ///     subThoroughfare    >>> 1号
    ///     thoroughfare       >>> 螺旋四路
    ///     timeZone           >>> Asia/Shanghai (current)
    ///
    /// - Parameters:
    ///   - location: GPS坐标点
    ///   - handler: errMsg: 出错 / placemark: 地标地区
    static func bk_reGeocodePlacemark(by location: CLLocation, placemark handler: @escaping CLPlacemarkCallback) {
        let _geocoder = CLGeocoder()
        _geocoder.bk_reverseGeocodeWith(location: location, placemark: handler)
    }
    
}

// MARK: - 获取自定义Bundle路径
extension BKUtils {
    
    enum BundleName: String {
        case Lottie
        case Voice
        case Select
    }
    
    /// 获取自定义Bundle路径
    ///
    /// - Parameters:
    ///   - name: 自定义bundle的名称
    /// - Returns: 自定义Bundle路径
    static func bk_getCustomBundle(name: BundleName) -> Bundle {
        guard let path = Bundle.main.path(forResource: name.rawValue, ofType: "bundle") else { return Bundle.main }
        let _bundle = Bundle(path: path)
        return _bundle ?? Bundle.main
    }
    
}

// MARK: - Utils for Dictionary
extension BKUtils {
    
    /// 替换源字典的key
    /// - Parameter dic: 源字典 [String: Any]
    /// - Parameter mapArray: 数组 [[oldkey : newKey]]
    static func bk_replaceDictionaryKeys(_ dic: [String: Any], by mapArray: [[String: String]]) -> [String: Any] {
        var newDic = dic
        // 遍历mapArray
        mapArray.forEach { (mapDic) in
            
            mapDic.forEach { (mapKey, mapValue) in
                // mapKey: 将被替换的key, mapValue: 新key
                // 遍历源字典
                dic.forEach { (dKey, dValue) in
                    if mapKey == dKey {
                        newDic[mapValue as String] = dValue
                        newDic.removeValue(forKey: dKey)
                    }
                }
            }
        }
        return newDic
    }
    
}

// MARK: - Utils for Clean Cache
extension BKUtils {
    
    /// 获取缓存大小
    /// - Parameter completionHandler: 结果回调
    class func bk_fileSizeOfCache(completionHandler: @escaping (_ size: String) -> Void) {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        // 取出文件夹下所有文件数组
        guard let fileArr = FileManager.default.subpaths(atPath: cachePath) else { return }
        
        let manager = FileManager.default
        
        // 开启子线程
        DispatchQueue.global().async {
            
            // 快速枚举出所有文件名 计算文件大小
            var size = 0
            for file in fileArr {
                // 把文件名拼接到路径中
                let path = cachePath + "/\(file)"
                // 取出文件属性
                let floder = try! manager.attributesOfItem(atPath: path)
                
                // 用元组取出文件大小属性
                for (key, value) in floder {
                    // 累加文件大小
                    if key == FileAttributeKey.size {
                        size += (value as AnyObject).integerValue
                    }
                }
            }
            
            // 换算
            var str: String = ""
            var realSize: Int = size
            if realSize < 1024 {
                str = str.appendingFormat("%dB", realSize)
            } else if size >= 1024 && size < 1024 * 1024 {
                realSize = realSize / 1024
                str = str.appendingFormat("%dKB", realSize)
            } else if size >= 1024 * 1024 && size < 1024 * 1024 * 1024 {
                realSize = realSize / 1024 / 1024
                str = str.appendingFormat("%dM", realSize)
            }
            
            DispatchQueue.main.async {
                completionHandler(str)
            }
        }
        
    }
    
    /// 清空缓存
    /// - Parameter completionHandler: 结果回调
    class func bk_clearCache(completionHandler: @escaping () -> Void) {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        // 取出文件夹下所有文件数组
        guard let fileArr = FileManager.default.subpaths(atPath: cachePath) else { return }
        
        let manager = FileManager.default
        // 开启子线程
        DispatchQueue.global().async {
            
            for file in fileArr {
                let path = cachePath + "/\(file)"
                if manager.fileExists(atPath: path) {
                    do {
                        try manager.removeItem(atPath: path)
                    } catch {
                        
                    }
                }
            }
            
            DispatchQueue.main.async {
                completionHandler()
            }
            
        }
        
    }
    
}
