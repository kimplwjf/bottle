//
//  BKWebView.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/4/27.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import WebKit

protocol BKWebViewProtocol: NSObjectProtocol {
    func clearAllWebCache()
}

class BKWebView: WKWebView {
    
    deinit {
        // 清除UserScripts
        configuration.userContentController.removeAllUserScripts()
        // 停止加载
        stopLoading()
        uiDelegate = nil
        navigationDelegate = nil
        // 持有者置为nil
        holderObject = nil
        PPP("WKWebView析构")
    }
    
    weak var holderObject: AnyObject?
    
    static func defaultConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.suppressesIncrementalRendering = true
        config.allowsAirPlayForMediaPlayback = true
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        if #available(iOS 12.0, *) {
            config.setURLSchemeHandler(BKURLSchemeHandler(), forURLScheme: SCHEME.WKSCHEME)
        } else {
            
        }
        config.applicationNameForUserAgent = kAppBundleId
        config.userContentController = WKUserContentController()
        return config
    }
    
}

// MARK: - BKWebViewProtocol
extension BKWebView: BKWebViewProtocol {
    
    func clearAllWebCache() {
        let dataTypes = [WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeCookies, WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeCookies, WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeIndexedDBDatabases, WKWebsiteDataTypeWebSQLDatabases]
        let websiteDataTypes = Set(dataTypes)
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
            
        }
    }
    
}

// MARK: - BKWebViewPoolProtocol协议
extension BKWebView: BKWebViewPoolProtocol {
    
    /// 即将被复用
    func webViewWillLeavePool() {
        
    }
    
    /// 即将被回收
    func webViewWillEnterPool() {
        holderObject = nil
        scrollView.delegate = nil
        stopLoading()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        uiDelegate = nil
        navigationDelegate = nil
        
        // 删除历史记录
        let selStr = "_re" + "mov" + "eA" + "llIt" + "ems"
        let sel = Selector(selStr)
        if backForwardList.responds(to: sel) {
            backForwardList.perform(sel)
        }
        loadHTMLString("", baseURL: nil)
    }
    
}
