//
//  BKWebViewPool.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/4/27.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

protocol BKWebViewPoolProtocol: NSObjectProtocol {
    func webViewWillLeavePool()
    func webViewWillEnterPool()
}

class BKWebViewPool: NSObject {
    
    deinit {
        // 清除Set
        self.clearAllReusableWebViews()
        NOC.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        NOC.default.removeObserver(self, name: .NotiKeyEnterApp.DidAppear, object: nil)
    }
    
    /// 当前已被页面持有的WebView
    fileprivate var visibleWebViewSet = Set<BKWebView>()
    /// 回收池中的WebView
    fileprivate var reusableWebViewSet = Set<BKWebView>()
    
    fileprivate let lock = DispatchSemaphore(value: 1)
    
    static let shared = BKWebViewPool()
    
    var justOneVisibleWebView: Bool {
        return visibleWebViewSet.count == 1
    }
    
    private override init() {
        super.init()
        
        NOC.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        NOC.default.addObserver(self, selector: #selector(mainCtrlInit), name: .NotiKeyEnterApp.DidAppear, object: nil)
        
    }
    
    @objc fileprivate func didReceiveMemoryWarning() {
        lock.wait()
        reusableWebViewSet.removeAll()
        lock.signal()
    }
    
    @objc func mainCtrlInit() {
        BKTaskUtil.delay(0.2) {
            self.prepareReuseWebView()
        }
    }
    
}

extension BKWebViewPool {
    
    /// 使用中的WebView持有者已销毁，则放回可复用池中
    func tryCompactWeakHolders() {
        lock.wait()
        let shouldReusedWebViewSet = visibleWebViewSet.filter { $0.holderObject == nil }
        for webView in shouldReusedWebViewSet {
            webView.webViewWillEnterPool()
            visibleWebViewSet.remove(webView)
            reusableWebViewSet.insert(webView)
        }
        lock.signal()
    }
    
    /// 预备一个空的WebView
    func prepareReuseWebView() {
        guard reusableWebViewSet.count <= 0 else { return }
        let webView = BKWebView(frame: .zero, configuration: BKWebView.defaultConfiguration())
        reusableWebViewSet.insert(webView)
    }
    
}

// MARK: - 复用池管理
extension BKWebViewPool {
    
    /// 获取可复用的WebView
    func getReusedWebView(for holder: AnyObject?) -> BKWebView {
        assert(holder != nil, "BKWebView holder不能为nil")
        guard let _holder = holder else {
            return BKWebView(frame: .zero, configuration: BKWebView.defaultConfiguration())
        }
        
        self.tryCompactWeakHolders()
        let webView: BKWebView
        lock.wait()
        if reusableWebViewSet.count > 0 {
            // 缓存池中有
            webView = reusableWebViewSet.randomElement()!
            reusableWebViewSet.remove(webView)
            visibleWebViewSet.insert(webView)
            // 出回收池前初始化
            webView.webViewWillLeavePool()
        } else {
            // 缓存池没有，创建新的
            webView = BKWebView(frame: .zero, configuration: BKWebView.defaultConfiguration())
            visibleWebViewSet.insert(webView)
        }
        
        webView.holderObject = _holder
        lock.signal()
        return webView
    }
    
    /// 回收可复用的WebView到复用池中
    func recycleReusedWebView(_ webView: BKWebView?) {
        guard let _webView = webView else { return }
        lock.wait()
        // 存在于当前使用中，则回收
        if visibleWebViewSet.contains(_webView) {
            // 进入回收池前清理
            _webView.webViewWillEnterPool()
            visibleWebViewSet.remove(_webView)
            reusableWebViewSet.insert(_webView)
        }
        lock.signal()
    }
    
    /// 移除并销毁所有复用池的WebView
    func clearAllReusableWebViews() {
        lock.wait()
        for webView in reusableWebViewSet {
            webView.webViewWillEnterPool()
        }
        reusableWebViewSet.removeAll()
        lock.signal()
    }
    
}
