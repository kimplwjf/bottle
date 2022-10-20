//
//  MKMapView+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/10/16.
//  Copyright © 2020 王锦发. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    // 缩放级别
    var zoomLevel: CGFloat {
        get { return CGFloat(log2(360*(Double(frame.size.width/256)/region.span.longitudeDelta)) + 1) }
        set { self.bk_setCenterCoordinate(coordinate: centerCoordinate, zoomLevel: newValue, animated: false) }
    }
    
    // 缩放地图
    func bk_setZoomLevel(_ level: CGFloat, animated: Bool) {
        self.bk_setCenterCoordinate(coordinate: centerCoordinate, zoomLevel: level, animated: animated)
    }
    
    func bk_setAppleMap(interactive: Bool) {
        self.isScrollEnabled = interactive
        self.isZoomEnabled = interactive
        self.isRotateEnabled = interactive
    }
    
    /// 隐藏底部[法律信息]和[高德地图]
    func bk_hideMapLogo() {
        self.subviews.enumerated().forEach { i, obj in
            if obj is UIImageView {
                obj.alpha = 0
            }
            if obj.isKind(of: NSClassFromString("MKAttributionLabel") as! UIView.Type) {
                obj.alpha = 0
            }
        }
    }
    
    // 设置缩放级别时调用
    private func bk_setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: CGFloat, animated: Bool) {
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360/pow(2, Double(zoomLevel))*Double(frame.size.width)/256)
        self.setRegion(MKCoordinateRegion(center: centerCoordinate, span: span), animated: animated)
    }
    
}
