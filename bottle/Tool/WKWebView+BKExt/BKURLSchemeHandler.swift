//
//  BKURLSchemeHandler.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/5/18.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import WebKit
import MobileCoreServices

// MARK: - 拦截类
class BKURLSchemeHandler: NSObject {
    
}

extension BKURLSchemeHandler: WKURLSchemeHandler {
    
    // 开始加载特定资源时调用
    @available(iOS 11.0, *)
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        // 文件名
        let fileName = urlSchemeTask.request.url?.lastPathComponent
        // 文件扩展名(文件类型)
        let pathExtension = urlSchemeTask.request.url?.pathExtension
        
        // 获取本地资源
        let fileURL = Bundle.main.url(forResource: fileName?.components(separatedBy: ".").first, withExtension: pathExtension)
        // 存在本地文件
        if let _fileURL = fileURL {
            do {
                let data: NSData = try Data(contentsOf: _fileURL) as NSData
                let _pathExtension = _fileURL.pathExtension
                let mime = self.mimeType(forPathExtension: _pathExtension)
                
                let resp: URLResponse = URLResponse(url: urlSchemeTask.request.url!, mimeType: mime, expectedContentLength: data.length, textEncodingName: nil)
                // 设置当前任务的response。每个 task 至少调用一次该方法。如果尝试在任务终止或完成后调用该方法，则会抛出异常。
                urlSchemeTask.didReceive(resp)
                // 设置接收到的数据。当接收到任务最后的 response 后，使用该方法发送数据。每次调用该方法时，新数据会拼接到先前收到的数据中。如果尝试在发送 response 前，或任务完成、终止后调用该方法，则会引发异常。
                urlSchemeTask.didReceive(data as Data)
                // 将任务标记为成功完成。如果尝试在发送 response 前，或将已完成、终止的任务标记为完成，则会引发异常。
                urlSchemeTask.didFinish()
            } catch {
                // 本地资源获取异常
                self.reqWebViewData(urlSchemeTask: urlSchemeTask)
            }
        } else {
            // 无本地资源
            self.reqWebViewData(urlSchemeTask: urlSchemeTask)
        }
        
    }
    
    // 停止载特定资源时调用
    @available(iOS 11.0, *)
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
    }
    
    /// 代替H5发出网络请求
    ///
    /// - Parameters:
    ///   - urlSchemeTask:
    @available(iOS 11.0, *)
    private func reqWebViewData(urlSchemeTask: WKURLSchemeTask) {
        let schemeUrl: String = urlSchemeTask.request.url?.absoluteString ?? ""
        // 换成原始的请求地址
        let replacedStr = schemeUrl.replacingOccurrences(of: SCHEME.WKSCHEME, with: "https")
        // 发出请求结果返回
        let req: URLRequest = URLRequest(url: URL(string: replacedStr)!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        session.dataTask(with: req) { data, resp, error in
            if let err = error {
                // 将任务标记为失败。如果尝试将已完成、失败，终止的任务标记为失败，则会引发异常。
                urlSchemeTask.didFailWithError(err)
            } else {
                guard let _data = data, let _resp = resp else { return }
                urlSchemeTask.didReceive(_resp)
                urlSchemeTask.didReceive(_data)
                urlSchemeTask.didFinish()
            }
        }.resume()
        
    }
    
    /// 获取文件类型
    ///
    /// - Parameter pathExtension:
    /// - Returns:
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
           let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue() {
            return contentType as String
        }
        // 文件资源类型如果不知道，传万能类型application/octet-stream，服务器会自动解析文件类
        return "application/octet-stream"
    }
    
}
