//
//  XMNetWork.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import HandyJSON
import SwiftyJSON

enum NetWorkStatusCode: Int {
    case serverNotStart    = -1004
    case serverError       = 500
    case apiNotExist       = 404
    case gatewayTimeOut    = 504
    case reqSuccess        = 200
    case reqTimeOut        = -1001
    case disconnectNetWork = -1009
    case errorSSL          = -999
    case tokenInvalid      = 5000
    case twoZeroFour       = 204
    
    var des: String {
        switch self {
        case .serverNotStart:    return "服务器没有启动"
        case .serverError:       return "服务器内部出错"
        case .apiNotExist:       return "接口不存在"
        case .gatewayTimeOut:    return "网关超时"
        case .reqSuccess:        return "请求成功"
        case .reqTimeOut:        return "请求超时"
        case .disconnectNetWork: return "网络失去连接"
        case .errorSSL:          return "SSL证书问题"
        case .tokenInvalid:      return "用户登录信息失效,请重新登录"
        case .twoZeroFour:       return ""
        }
    }
}

// MARK: - XMNetWork
class XMNetWork: NSObject {
    
    /// 网络请求成功回调
    typealias SuccessBlock = (Any?) -> Void
    
    /// 网络请求失败回调
    typealias FailureBlock = (Error?, _ msg: String?, _ status: NetWorkStatusCode) -> Void
    
    /// 进度回调
    typealias ProgressBlock = (Progress) -> Void
    
    /// _manager
    lazy var _manager: Session = {
        let session: Session
        session = Session(interceptor: XMNetWorkInterceptor())
        session.sessionConfiguration.timeoutIntervalForRequest = 15
        return session
    }()
    
    /// 单例
    static let `default` = XMNetWork()
    
    private override init() { }
    
    /// 判断请求数据是否成功
    ///
    /// - Parameter obj: 网络请求返回的数据
    /// - Returns: true or false
    static func success(_ obj: Any?) -> Bool {
        guard let _obj = obj else { return false }
        if let dic = _obj as? [String: Any], let code = dic[XMNetCodeKey] as? Int {
            if let value = NetWorkStatusCode(rawValue: code) {
                return value == .reqSuccess
            }
        } else if let json = _obj as? JSON {
            let code = json[XMNetCodeKey].intValue
            if let value = NetWorkStatusCode(rawValue: code) {
                return value == .reqSuccess
            }
        }
        return false
    }
    
}

extension XMNetWork {
    
    // MARK: - req请求
    ///
    /// - Parameters:
    ///   - method: 请求方法
    ///   - path: 路径
    ///   - params: 参数
    ///   - encoding: 编码方式
    ///   - headers: 请求头
    ///   - respData: 默认false;若true则直接拿resp.data数据处理
    ///   - success: 请求成功回调
    ///   - failure: 请求失败回调
    /// - Returns: DataRequest。接收该返回值，以便取消请求，如：let dataReq = 。。。; dataReq.cancel()
    @discardableResult
    func req(method: HTTPMethod,
             path: String,
             params: Parameters? = nil,
             encoding: ParameterEncoding = URLEncoding.default,
             headers: HTTPHeaders? = nil,
             respData: Bool = false,
             success: SuccessBlock?,
             failure: FailureBlock?) -> DataRequest? {
        
        let pathUrl = path
        
        // 判断网络是否可用
        if let reachabilityManager = XMNetWorkStatus.shared.reachabilityManager {
            if !reachabilityManager.isReachable {
                failure?(nil, XMNetWorkError, .disconnectNetWork)
                return nil
            }
        }
        
        return _manager.request(pathUrl,
                                method: method,
                                parameters: params,
                                encoding: encoding,
                                headers: headers).validate()
            .responseJSON { (resp) in
                
                guard let code = resp.response?.statusCode else {
                    failure?(nil, XMNetWorkError, .errorSSL)
                    return
                }
                
                if respData && code == NetWorkStatusCode.reqSuccess.rawValue {
                    success?(resp.data)
                } else {
                    let tuple = self.getStatusCode(by: code)
                    switch resp.result {
                    case .success(let result):
                        success?(result)
                    case .failure(let error):
                        failure?(error as? Error, tuple.msg, tuple.status)
                    }
                }
                
            }
        
    }
    
    // MARK: - upload上传
    /// 上传
    ///
    /// - Parameters:
    ///   - path: 服务器地址
    ///   - params: 参数
    ///   - headers: 请求头
    ///   - formData: formData
    ///   - progressBlock: 上传进度
    ///   - success: 成功闭包
    ///   - failture: 失败闭包
    func upload(path: String,
                params: Parameters? = nil,
                headers: [String: String]? = nil,
                formData: @escaping (MultipartFormData) -> Void,
                progressBlock: ProgressBlock?,
                success: SuccessBlock?,
                failure: FailureBlock?) {
        
        let pathUrl = path
        
        // 判断网络是否可用
        if let reachabilityManager = XMNetWorkStatus.shared.reachabilityManager {
            if !reachabilityManager.isReachable {
                failure?(nil, XMNetWorkError, .disconnectNetWork)
                return
            }
        }
        
        var requestHeaders = XMNetWork.baseHeaders()
        if let xmHeader = headers {
            xmHeader.forEach { requestHeaders.add(name: $0.key, value: $0.value) }
        }
        
        PPP("请求地址 = \(pathUrl)")
        PPP("参数 = \(params?.jsonString(prettify: true) ?? "没有参数")")
        PPP("请求头 = \n\(requestHeaders.description)")
        
        _manager.upload(multipartFormData: { (multipartFormData) in
            formData(multipartFormData)
        }, to: pathUrl,
           method: .post,
           headers: requestHeaders).uploadProgress { (progress) in
            progressBlock?(progress)
        }.responseJSON { (resp) in
            
            guard let code = resp.response?.statusCode else {
                failure?(nil, XMNetWorkError, .errorSSL)
                return
            }
            let tuple = self.getStatusCode(by: code)
            switch resp.result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error as? Error, tuple.msg, tuple.status)
            }
            
        }
        
    }
    
    // MARK: - download下载
    /// 下载 响应response
    ///
    /// - Parameters:
    ///   - url: 下载路径
    ///   - method: 请求方式
    ///   - params: 参数
    ///   - destination: 下载存储路径
    ///   - progressBlock: 下载进度
    ///   - success: 请求成功回调
    ///   - failure: 请求失败回调
    /// - Returns: DownloadRequest?
    @discardableResult
    func download(url: URL,
                  method: HTTPMethod = .get,
                  params: Parameters? = nil,
                  to destination: DownloadRequest.Destination? = nil,
                  progressBlock: ProgressBlock?,
                  success: SuccessBlock?,
                  failure: FailureBlock?) -> DownloadRequest? {
        
        // 判断网络是否可用
        if let reachabilityManager = XMNetWorkStatus.shared.reachabilityManager {
            if !reachabilityManager.isReachable {
                failure?(nil, XMNetWorkError, .disconnectNetWork)
            }
        }
        
        return _manager.download(url,
                                 method: method,
                                 parameters: params,
                                 to: destination).downloadProgress { (progress) in
            progressBlock?(progress)
        }.response { (resp) in
            
            guard let code = resp.response?.statusCode else {
                failure?(nil, XMNetWorkError, .errorSSL)
                return
            }
            let tuple = self.getStatusCode(by: code)
            PPP("下载存储路径 = \(resp.fileURL?.path ?? "")")
            switch resp.result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error as? Error, tuple.msg, tuple.status)
            }
            
        }
        
    }
    
    /// 下载 响应responseData
    ///
    /// - Parameters:
    ///   - url: 下载路径
    ///   - method: 请求方式
    ///   - params: 参数
    ///   - destination: 下载存储路径
    ///   - progressBlock: 下载进度
    ///   - success: 请求成功回调
    ///   - failure: 请求失败回调
    /// - Returns: DownloadRequest?
    @discardableResult
    func downloadData(url: URL,
                      method: HTTPMethod = .get,
                      params: Parameters? = nil,
                      to destination: DownloadRequest.Destination? = nil,
                      progressBlock: ProgressBlock?,
                      success: SuccessBlock?,
                      failure: FailureBlock?) -> DownloadRequest? {
        
        // 判断网络是否可用
        if let reachabilityManager = XMNetWorkStatus.shared.reachabilityManager {
            if !reachabilityManager.isReachable {
                failure?(nil, XMNetWorkError, .disconnectNetWork)
            }
        }
        
        return _manager.download(url,
                                 method: method,
                                 parameters: params,
                                 to: destination).downloadProgress { (progress) in
            progressBlock?(progress)
        }.responseData { (resp) in
            
            guard let code = resp.response?.statusCode else {
                failure?(nil, XMNetWorkError, .errorSSL)
                return
            }
            let tuple = self.getStatusCode(by: code)
            switch resp.result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error as? Error, tuple.msg, tuple.status)
            }
            
        }
        
    }
    
}

// MARK: - 取消请求
extension XMNetWork {
    
    /// 取消所有请求
    static func cancelAllTasks(completion: (() -> Void)? = nil) {
        Session.default.cancelAllRequests(completingOnQueue: .main) {
            completion?()
        }
    }
    
}

// MARK: - 获取Headers
extension XMNetWork {
    
    static func baseHeaders() -> HTTPHeaders {
        var header = [String: String]()
        header["client-device"] = UIDevice.bk_uuid
        header["client-version"] = kAppVersion
        header["client-brand"] = UIDevice.bk_brand
        header["client-source"] = UIDevice.bk_systemName
//        header["client-token"] = XMApp.kTOKEN
        header["client-uuid"] = XMApp.kUserId.string
        header["client-os"] = UIDevice.bk_systemVersion
        let headers = HTTPHeaders(header)
        return headers
    }
    
}

// MARK: - Private
extension XMNetWork {
    
    private func getStatusCode(by code: Int) -> (status: NetWorkStatusCode, msg: String?) {
        var status: NetWorkStatusCode = .reqTimeOut
        var msg: String?
        if let value = NetWorkStatusCode(rawValue: code) {
            if value == .reqSuccess {
                PPP("****** 状态码:\(code) \(value.des) ******")
            } else {
                msg = "错误码:\(code) \(value.des)"
            }
            status = value
        } else {
            msg = "错误码:\(code) \(XMNetBusy)"
        }
        return (status, msg)
    }
    
}

// MARK: - RequestRetrier请求重试机制
class XMNetWorkInterceptor: RequestInterceptor {
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < 3 else {
            completion(.doNotRetry)
            return
        }
        completion(.retryWithDelay(1.0))
    }
    
}
