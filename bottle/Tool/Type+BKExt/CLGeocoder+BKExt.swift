//
//  CLGeocoder+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/8/11.
//  Copyright © 2020 王锦发. All rights reserved.
//

import UIKit
import CoreLocation

typealias InChinaMainlandCallback = (_ errMsg: String?, _ inChinaMainland: Bool) -> Void
typealias InHMTCallback = (_ errMsg: String?, _ inHMT: Bool) -> Void
typealias CLPlacemarkCallback = (_ errMsg: String?, _ placemark: CLPlacemark?) -> Void

enum IsoCountryCode: String {
    case CN
    case HK
    case MO
    case TW
}

extension CLGeocoder {
    
    /// 反编译GPS坐标点 判断坐标点位置是否在中国大陆
    ///
    /// - Parameters:
    ///   - location: GPS坐标点
    ///   - handler: errMsg: 出错 / inChina: 是否在中国大陆
    func bk_reverseGeocodeWith(location: CLLocation, inChinaMainland handler: @escaping InChinaMainlandCallback) {
        self.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil || placemarks?.count == 0 {
                handler(error?.localizedDescription, false)
            } else {
                if let placemark = placemarks?.first {
                    if let iso = IsoCountryCode(rawValue: placemark.isoCountryCode ?? "") {
                        handler(nil, (iso == .CN || placemark.country == "中国"))
                    } else {
                        handler(nil, false)
                    }
                } else {
                    handler(error?.localizedDescription, false)
                }
            }
        }
    }
    
    /// 反编译GPS坐标点 判断坐标点位置是否在港澳台
    ///
    /// - Parameters:
    ///   - location: GPS坐标点
    ///   - handler: errMsg: 出错 / inHMT: 是否在港澳台
    func bk_reverseGeocodeWith(location: CLLocation, inHMT handler: @escaping InHMTCallback) {
        self.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil || placemarks?.count == 0 {
                handler(error?.localizedDescription, false)
            } else {
                if let placemark = placemarks?.first {
                    let iso = IsoCountryCode(rawValue: placemark.isoCountryCode ?? "") ?? .CN
                    handler(nil, (iso == .HK || iso == .MO || iso == .TW))
                } else {
                    handler(error?.localizedDescription, false)
                }
            }
        }
    }
    
    /// 反编译GPS坐标点 判断坐标点位置所在地区
    ///
    /// - Parameters:
    ///   - location: GPS坐标点
    ///   - handler: errMsg: 出错 / placemark: 地标地区
    func bk_reverseGeocodeWith(location: CLLocation, placemark handler: @escaping CLPlacemarkCallback) {
        self.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil || placemarks?.count == 0 {
                handler(error?.localizedDescription, nil)
            } else {
                let placemark = placemarks?.first
                handler(nil, placemark)
            }
        }
    }
    
}
