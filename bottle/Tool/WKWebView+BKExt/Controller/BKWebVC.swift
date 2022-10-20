//
//  BKWebVC.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit
import WebKit

fileprivate struct WebKey {
    static let progress = "estimatedProgress"
    static let title = "title"
}

class BKWebVC: UIViewController {
    
    deinit {
        webView.removeObserver(self, forKeyPath: WebKey.progress)
        webView.removeObserver(self, forKeyPath: WebKey.title)
    }
    
    var urlString: String? {
        didSet {
            guard let urlStr = urlString else { return }
            guard let url = URL(string: urlStr) else { return }
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20.0)
            if #available(iOS 13.0, *) {
                request.allowsExpensiveNetworkAccess = true
                request.allowsConstrainedNetworkAccess = true
            }
            self.webView.load(request)
        }
    }
    
    var h5Title: String? {
        didSet {
            self.title = self.h5Title
        }
    }
    
    var htmlString: String? {
        didSet {
            guard let str = htmlString else { return }
            self.webView.loadHTMLString(str, baseURL: nil)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []
        view.backgroundColor = .lightWhiteDark27
        
        if navigationItem.leftBarButtonItem == nil {
            let leftItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(leftItemAction))
            navigationItem.leftBarButtonItem = leftItem
        }
        
        view.addSubview(webView)
        view.addSubview(progressView)
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        progressView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(2)
        }
        
        webView.addObserver(self, forKeyPath: WebKey.progress, options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: WebKey.title, options: NSKeyValueObservingOptions.new, context: nil)
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.adapterDarkMode(with: webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc private func leftItemAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - lazy
    lazy var webView: WKWebView = {
        let webview = WKWebView(frame: .zero, configuration: WKWebView.wkWebConfig)
        webview.backgroundColor = .lightWhiteDark27
        webview.allowsBackForwardNavigationGestures = true
        webview.navigationDelegate = self
        webview.isHidden = true
        return webview
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0))
        progressView.tintColor = .blue
        progressView.trackTintColor = .lightGray
        return progressView
    }()
    
}

// MARK: - Private
extension BKWebVC {
    
    private func adapterDarkMode(with webView: WKWebView) {
        let bgColor: String
        let labelColor: String
        if BKDarkModeUtil.mode == .follow {
            bgColor = UIColor.webBgColor.toHexString
            labelColor = UIColor.webLabelColor.toHexString
        } else {
            bgColor = BKDarkModeUtil.mode == .light ? "#FFFFFF" : "#1B1B1B"
            labelColor = BKDarkModeUtil.mode == .light ? "#333333" : "#E6E9EE"
        }
        webView.evaluateJavaScript("document.getElementsByTagName('body')[0].style.backgroundColor='\(bgColor)'", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementsByTagName('body')[0].style.webkitTextFillColor='\(labelColor)'", completionHandler: nil)
    }
    
}

// MARK: - 监听
extension BKWebVC {
    
    /// 监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is WKWebView {
            let webview = object as! WKWebView
            if webview === webView {
                if keyPath == WebKey.progress {
                    let value = change![NSKeyValueChangeKey.newKey]
                    if value is CGFloat {
                        let myVal = value as! CGFloat
                        self.progressView.isHidden = false
                        self.progressView.setProgress(Float(myVal), animated: true)
                        if myVal == 1.0 {
                            self.progressView.isHidden = true
                            self.progressView.setProgress(0, animated: true)
                        }
                    }
                } else if keyPath == WebKey.title {
                    navigationItem.title = webView.title
                }
            }
        }
    }
    
}

// MARK: - WKNavigationDelegate代理
extension BKWebVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.adapterDarkMode(with: webView)
        
        // html页面与屏幕宽度不符问题
        webView.evaluateJavaScript("""
        var oMeta = document.createElement('meta');
        oMeta.content = 'width=device-width, initial-scale=1, user-scalable=0';
        oMeta.name = 'viewport';
        document.getElementsByTagName('head')[0].appendChild(oMeta);
        """, completionHandler: nil)
        
        // 图片缩放比例不正确问题
        webView.evaluateJavaScript("""
        var imgs = document.getElementsByTagName("img")
        for (var i = 0; i < imgs.length; i++) {
            imgs[i].setAttribute('width', '100%')
        }
        """, completionHandler: nil)
        
        // 视频无法在非全屏的状态下播放，视频比例不正确问题
        webView.evaluateJavaScript("""
        var videos = document.getElementsByTagName("video")
        for (var i = 0; i < videos.length; i++) {
            videos[i].setAttribute('width', '100%')
            videos[i].setAttribute('height', '56.25%')
            videos[i].setAttribute('controls', '')
            videos[i].setAttribute('playsinline', 'true')
            videos[i].setAttribute('webkit-playsinline', 'true')
        }
        """, completionHandler: nil)
        
        // 长按事件禁用
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)
        
        BKTaskUtil.delay(0.3) {
            self.webView.isHidden = false
        }
        
    }
    
}
