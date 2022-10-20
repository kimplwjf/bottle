//
//  WKWebView+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/4/29.
//  Copyright © 2020 王锦发. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    
    static var wkWebConfig: WKWebViewConfiguration {
        // WKWebView自适应大小
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let wkUScript = WKUserScript(source: jScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(wkUScript)

        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.preferences = WKPreferences()
        wkWebConfig.preferences.minimumFontSize = 10
        wkWebConfig.preferences.javaScriptEnabled = true
        wkWebConfig.preferences.javaScriptCanOpenWindowsAutomatically = false
        wkWebConfig.processPool = WKProcessPool()
        wkWebConfig.applicationNameForUserAgent = kAppBundleId
        wkWebConfig.userContentController = wkUController
        return wkWebConfig
    }
    
}

extension WKWebView {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func loadWithURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20.0)
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        let dic = HTTPCookie.requestHeaderFields(with: cookies)
        req.allHTTPHeaderFields = dic
        self.load(req)
    }
    
    // iOS11以下通过js方法添加cookie
    func addCookies(cookies: [HTTPCookie]) {
        if #available(iOS 11.0, *) {
            
        } else {
            cookies.forEach { (cookie) in
                let jsCode = String(format: "app_setCookie('%@','%@')", cookie.name, cookie.value)
                self.evaluateJavaScript(jsCode, completionHandler: nil)
            }
        }
    }
    
    // iOS11以下获取处理cookies的js
    static func getCookiesUserScript() -> WKUserScript? {
        if #available(iOS 11.0, *) {
            return nil
        } else {
            guard let path = Bundle.main.path(forResource: "MMWKCookie", ofType: "js") else { return nil }
            do {
                let jsCode = try String(contentsOfFile: path, encoding: .utf8)
                let cookieInScript = WKUserScript(source: jsCode, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                return cookieInScript
            } catch _ { }
            return nil
        }
    }
    
}

// MARK: - WKWebView截图
extension WKWebView {
    
    // MARK: - public
    public func bk_contentCapture(_ completionHandler: @escaping (_ capturedImage: UIImage?) -> Void) {
        
        self.isCapturing = true
        
        let offset = self.scrollView.contentOffset
        
        // Put a fake Cover of View
        let snapShotView = self.snapshotView(afterScreenUpdates: true)
        snapShotView?.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: (snapShotView?.frame.size.width)!, height: (snapShotView?.frame.size.height)!)
        self.superview?.addSubview(snapShotView!)
        
        if self.frame.size.height < self.scrollView.contentSize.height {
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.frame.size.height)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.scrollView.contentOffset = CGPoint.zero
            
            self.swContentCaptureWithoutOffset { [weak self] (capturedImage) in
                let strongSelf = self!
                
                strongSelf.scrollView.contentOffset = offset
                
                snapShotView?.removeFromSuperview()
                
                strongSelf.isCapturing = false
                
                completionHandler(capturedImage)
            }
        }
        
    }
    
    // Simulate People Action, all the `fixed` element will be repeate
    // SwContentCapture will capture all content without simulate people action, more perfect.
    public func bk_contentScrollCapture(_ completionHandler: @escaping (_ capturedImage: UIImage?) -> Void) {
        
        self.isCapturing = true
        
        // Put a fake Cover of View
        let snapShotView = self.snapshotView(afterScreenUpdates: true)
        snapShotView?.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: (snapShotView?.frame.size.width)!, height: (snapShotView?.frame.size.height)!)
        self.superview?.addSubview(snapShotView!)
        
        // Backup
        let bakOffset = self.scrollView.contentOffset
        
        guard self.bounds.height != 0 else { return }
        // Divide
        let page = floorf(Float(self.scrollView.contentSize.height / self.bounds.height))
        
        UIGraphicsBeginImageContextWithOptions(self.scrollView.contentSize, false, UIScreen.main.scale)
        
        self.swContentScrollPageDraw(0, maxIndex: Int(page)) { [weak self] in
            let strongSelf = self
            
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Recover
            strongSelf?.scrollView.setContentOffset(bakOffset, animated: false)
            snapShotView?.removeFromSuperview()
            
            strongSelf?.isCapturing = false
            
            completionHandler(capturedImage)
        }
        
    }
    
    // MARK: - fileprivate
    fileprivate func swContentCaptureWithoutOffset(_ completionHandler: @escaping (_ capturedImage: UIImage?) -> Void) {
        let containerView  = UIView(frame: self.bounds)
        
        let bakFrame = self.frame
        let bakSuperView = self.superview
        let bakIndex = self.superview?.subviews.firstIndex(of: self)
        
        // remove WebView from superview & put container view
        self.removeFromSuperview()
        containerView.addSubview(self)
        
        let totalSize = self.scrollView.contentSize
        
        // Divide
        let page = floorf(Float(totalSize.height / containerView.bounds.height))
        
        self.frame = CGRect(x: 0, y: 0, width: containerView.bounds.size.width, height: self.scrollView.contentSize.height)
        
        UIGraphicsBeginImageContextWithOptions(totalSize, false, UIScreen.main.scale)
        
        self.swContentPageDraw(containerView, index: 0, maxIndex: Int(page)) { [weak self] in
            let strongSelf = self!
            
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Recover
            strongSelf.removeFromSuperview()
            bakSuperView?.insertSubview(strongSelf, at: bakIndex!)
            
            strongSelf.frame = bakFrame
            
            containerView.removeFromSuperview()
            
            completionHandler(capturedImage)
        }
        
    }
    
    fileprivate func swContentPageDraw(_ targetView: UIView, index: Int, maxIndex: Int, drawCallback: @escaping () -> Void) {
        
        // set up split frame of super view
        let splitFrame = CGRect(x: 0, y: CGFloat(index) * targetView.frame.size.height, width: targetView.bounds.size.width, height: targetView.frame.size.height)
        // set up webview frame
        var myFrame = self.frame
        myFrame.origin.y = -(CGFloat(index) * targetView.frame.size.height)
        self.frame = myFrame
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            targetView.drawHierarchy(in: splitFrame, afterScreenUpdates: true)
            
            if index < maxIndex {
                self.swContentPageDraw(targetView, index: index + 1, maxIndex: maxIndex, drawCallback: drawCallback)
            } else {
                drawCallback()
            }
        }
    }
    
    fileprivate func swContentScrollPageDraw(_ index: Int, maxIndex: Int, drawCallback: @escaping () -> Void) {
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(index) * self.scrollView.frame.size.height), animated: false)
        let splitFrame = CGRect(x: 0, y: CGFloat(index) * self.scrollView.frame.size.height, width: bounds.size.width, height: bounds.size.height)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.drawHierarchy(in: splitFrame, afterScreenUpdates: true)
            
            if index < maxIndex {
                self.swContentScrollPageDraw(index + 1, maxIndex: maxIndex, drawCallback: drawCallback)
            } else {
                drawCallback()
            }
        }
    }
    
}
