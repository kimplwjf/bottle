//
//  BaseViewModel.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BaseViewModel: NSObject {
    
    /// 转子标识符
    private var identifier: String?
    
}

// MARK: - Public
extension BaseViewModel {
    
    /// 显示加载动画
    func showLoading(type: LoadingType = .default, isPassedDown: Bool = true) {
        identifier = BPM.showLoading(type: type, isPassedDown: isPassedDown)
    }
    
    /// 隐藏加载动画
    func hideLoading() {
        guard let id = identifier else {
            BPM.dismissAll()
            return
        }
        BPM.dismiss(id)
    }
    
}

// MARK: - 网络请求主方法
extension BaseViewModel {
    
    /// 发起get请求
    func getReq(path: String,
                params: Parameters? = nil,
                encoding: ParameterEncoding = URLEncoding.default,
                headers: [String: String]? = nil,
                loadingType: LoadingType = .default,
                isPassedDown: Bool = true,
                respData: Bool = false,
                handler: @escaping BKResultHandler) {
        self.mainReq(method: .get, path: path, params: params, encoding: encoding, headers: headers, loadingType: loadingType, isPassedDown: isPassedDown, respData: respData, handler: handler)
    }
    
    /// 发起post请求
    func postReq(path: String,
                 params: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: [String: String]? = nil,
                 loadingType: LoadingType = .default,
                 isPassedDown: Bool = true,
                 respData: Bool = false,
                 handler: @escaping BKResultHandler) {
        self.mainReq(method: .post, path: path, params: params, encoding: encoding, headers: headers, loadingType: loadingType, isPassedDown: isPassedDown, respData: respData, handler: handler)
    }
    
    /** 请求主方法*/
    func mainReq(method: HTTPMethod,
                 path: String,
                 params: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: [String: String]? = nil,
                 loadingType: LoadingType = .default,
                 isPassedDown: Bool = true,
                 respData: Bool = false,
                 handler: @escaping BKResultHandler) {
        if loadingType != .none {
            self.showLoading(type: loadingType, isPassedDown: isPassedDown)
        }
        var requestHeaders = XMNetWork.baseHeaders()
        if let xmHeader = headers {
            xmHeader.forEach { requestHeaders.add(name: $0.key, value: $0.value) }
        }
        XMNetWork.default.req(method: method, path: path, params: params, encoding: encoding, headers: requestHeaders, respData: respData, success: { (result) in
            
            if loadingType != .none {
                self.hideLoading()
            }
            if !respData {
                let json = JSON(result as Any)
                let ok = XMNetWork.success(json)
                let msg = json[XMNetMsgKey].stringValue
                let code = json[XMNetCodeKey].intValue
                let statusCode = NetWorkStatusCode(rawValue: code) ?? .reqTimeOut
                handler(ok, json, msg, statusCode)
            } else {
                handler(true, result, nil, .reqSuccess)
            }
            
        }) { (error, msg, code)  in
            if loadingType != .none {
                self.hideLoading()
            }
            PPP(error?.localizedDescription ?? "")
            handler(false, error, msg, code)
        }
    }
    
}
