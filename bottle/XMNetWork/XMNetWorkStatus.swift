//
//  XMNetWorkStatus.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/11/11.
//  Copyright © 2021 王锦发. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

enum NetWorkStatus: String {
    case unknown      = "未知网络,请检查你的网络"
    case notReachable = "网络无连接,请检查你的网络"
    case cellular     = "蜂窝数据网络"
    case wifi         = "Wi-Fi网络"
}

// MARK: - 网络运行状态监听
class XMNetWorkStatus: NSObject {
    
    static let shared = XMNetWorkStatus()
    
    typealias NetWorkStatusCallback = (_ status: NetWorkStatus) -> Void
    
    /// 当前网络环境状态
    public var currentNetWorkStatus: NetWorkStatus = .wifi
    
    let reachabilityManager = NetworkReachabilityManager(host: "www.baidu.com")
    
    /// 监听网络运行状态
    public func startMonitoring() {
        self.detectNetWork { (status)  in
            PPP("网络状况: \(status.rawValue)")
        }
    }
    
    /// 监听当前网络环境
    public func monitor(_ block: ((_ status: NetWorkStatus) -> Void)?) {
        self.detectNetWork { (status) in
            block?(status)
        }
    }
    
    private func detectNetWork(netWork: @escaping NetWorkStatusCallback) {
        reachabilityManager?.startListening(onUpdatePerforming: { [weak self] (status) in
            if self?.reachabilityManager?.isReachable ?? false {
                switch status {
                case .notReachable:
                    self?.currentNetWorkStatus = .notReachable
                case .unknown:
                    self?.currentNetWorkStatus = .unknown
                case .reachable(.cellular):
                    self?.currentNetWorkStatus = .cellular
                case .reachable(.ethernetOrWiFi):
                    self?.currentNetWorkStatus = .wifi
                }
            } else {
                self?.currentNetWorkStatus = .notReachable
            }
            guard let newWorkStatus = self?.currentNetWorkStatus else { return }
            netWork(newWorkStatus)
        })
    }
    
}
