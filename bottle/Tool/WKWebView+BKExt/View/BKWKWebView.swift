//
//  BKWKWebView.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/3/18.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import WebKit

class BKWKWebView: BaseView {
    
    deinit {
        listViewDidScrollCallback = nil
    }
    
    private var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    var htmlString: String? {
        didSet {
            guard let str = htmlString else { return }
            webView.loadHTMLString(str, baseURL: nil)
        }
    }
    
    var urlString: String? {
        didSet {
            guard let url = urlString else { return }
            webView.loadWithURL(url)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.adapterDarkMode(with: webView)
    }
    
    // MARK: - lazy
    lazy var webView: WKWebView = {
        let webview = WKWebView(frame: .zero, configuration: WKWebView.wkWebConfig)
        webview.backgroundColor = .lightWhiteDark27
        webview.isHidden = true
        webview.scrollView.delegate = self
        webview.navigationDelegate = self
        return webview
    }()
    
}

// MARK: - Private
extension BKWKWebView {
    
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

// MARK: - WKNavigationDelegate代理
extension BKWKWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.adapterDarkMode(with: webView)
        
        webView.evaluateJavaScript("window.scrollTo(0,0)", completionHandler: nil)
        
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

// MARK: - UIScrollViewDelegate代理
extension BKWKWebView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
    
}
