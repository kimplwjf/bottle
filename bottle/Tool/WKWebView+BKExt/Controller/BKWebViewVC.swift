//
//  BKWebViewVC.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit
import WebKit
import SystemConfiguration
import HandyJSON

struct WebViewKey {
    static let progress = "estimatedProgress"
    static let title = "title"
}

protocol EnumeratableEnum {
    static var allValues: [Self] { get }
}

/** H5调用App的交互方法名 */
enum BKWebViewJSName: String {
    case popToRootWindow
    case goback
    case openNewWindow
    case closeWindow
    case saveLocalStorage
    case getToken
    case share
    case logout
    case saveImage
    case openWXMiniprogram
    case getUserDeviceInfo
    case shareAll
    case evaluateApp
}

/** H5调用App传入的jumpKey(可带参) */
enum EvaluateAppJumpKey: String {
    case addApplyPeople       // 添加报名人
    case editApplyPeople      // 编辑报名人
    case pullLogin            // 拉起登录
    case call                 // 拨打电话
    case sharePhoto           // 分享图片
    case runSetting           // 跳转App相关设置
    case openFeedback         // 打开意见反馈
    case jumpTabBar           // 跳转到指定tab
    case openEditInfo         // 打开编辑个人资料
    case openPersonalInfo     // 打开个人主页
    case openTrainActivity    // 打开训练活动
    case openHabitActivity    // 打开习惯养成活动
    case pullWXService        // 拉起企微客服
    case myCert               // 打开我的证书
    case myMatch              // 打开我的赛事
    case orderList            // 打开订单列表
}

/** App调用H5的方法名 */
enum EvaluateJSMethod: String {
    case pageReload // 刷新当前页
    case sessionStorageClear = "sessionStorage.clear" // 清空session
}

enum ShareAllType: Int {
    case wechat_h5 = 11
    case wechat_image = 12
    case wechat_text = 13
    case timeline_h5 = 21
    case timeline_image = 22
    case timeline_text = 23
}

extension BKWebViewJSName: EnumeratableEnum {
    static var allValues: [BKWebViewJSName] {
        return [
            .popToRootWindow, .goback, .openNewWindow, .closeWindow,
            .saveLocalStorage, .getToken, .share, .logout, .saveImage,
            .openWXMiniprogram, .getUserDeviceInfo, .shareAll, .evaluateApp
        ]
    }
}

struct DYWebShareModel: HandyJSON {
    var title: String = ""
    var content: String = ""
    var url: String = ""
    var callback: String = ""
    var cover: String = ""
    var photo: String = ""
    var base64: String = ""
}

/** 防止添加js方法时引起的内存泄漏*/
class BKWebViewScriptMessageHanlder: NSObject,WKScriptMessageHandler {
    
    deinit {
        PPP("BKWebViewScriptMessageHanlder is deinit")
    }
    
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler?) {
        self.delegate = delegate
        super.init()
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
    
}

protocol BKWebViewDelegate: NSObjectProtocol {
    /** JS交互时JS调用原生方法时收到的消息，以及内容*/
    func runJavaScriptReceiveMessage(message: WKScriptMessage)
}

extension BKWebViewDelegate {
    func runJavaScriptReceiveMessage(message: WKScriptMessage) { }
}

class BKWebViewVC: BaseVC {
    
    // MARK: - deinit
    deinit {
        /** 移除js方法，防止内存泄漏*/
        if webView != nil {
            webView.removeObserver(self, forKeyPath: WebViewKey.progress)
            webView.removeObserver(self, forKeyPath: WebViewKey.title)
            /** 修复pop返回可能会引起的崩溃*/
            webView.scrollView.delegate = nil
        }
        
        self.removeNOC()
        self.removeScriptMessageHandler()
        BKWebViewPool.shared.tryCompactWeakHolders()
        PPP("[\(NSStringFromClass(type(of: self)))]>>>已被释放")
    }
    
    enum H5Type: Int {
        case GUSTO_H5
        case GUSTO_INC
        case GUSTO_INC_EARLY
        case MP_WEIXIN
        case `default`
    }
    
    enum WebType {
        case H5
        case APP(AppMark)
        
        enum AppMark {
            case authWatches
            case mall
            case scan
            case showNavi
            case `default`
        }
    }
    
    enum ShareStyle: Int {
        case `default`
        case canNotSave
    }
    
    /** 网页视图*/
    public var webView: BKWebView!
    /** 代理*/
    public weak var delegate: BKWebViewDelegate?
    /** JS交互时JS调用原生方法时收到的消息，以及内容*/
    public var runJavaScriptReceiveMessageBlock: ((WKScriptMessage) -> Void)?
    /** 自动改变标题，根据url的标题*/
    public var autoChangeTitle: Bool = true
    /** 自定义标题*/
    public var customNaviTitle: String = ""
    /** 是否下拉重新加载*/
    public var canDownRefresh: Bool = true
    /** 当前网页加载地址*/
    public var urlString: String = ""
    /** 标记类型*/
    public var webType: WebType = .APP(.default)
    /** 聊天用户头像*/
    public var otherAvatar: String = ""
    /** 分享内容id*/
    public var contentId: Int = 0
    /** 是否可以分享*/
    public var canShare: Bool = false
    /** 分享封面图*/
    public var shareCover: String = ""
    
//    private var userContentController: WKUserContentController!
    
    /** 自定义的scheme*/
    private var url_scheme: String = ""
    /** 网页来源标记标签*/
    private var memoLabel: UILabel!
    /** 进度条*/
    private var progressView: BKGradientProgressView!
    /** 容器视图*/
    private var containerView: UIScrollView!
    /** js交互的方法名集合*/
    private var scriptMessageHandlerNames = [BKWebViewJSName]()
    /** h5网页类型*/
    private var h5Type: H5Type = .default
    /** wkwebview高度*/
    private var webViewHeight: CGFloat = 0.0
    /** 分享图片*/
    private var shareImage: UIImage = UIImage()
    /** 是否隐藏系统NavigationBar*/
    private var naviBarHidden: Bool = false
    /** 标记是否已经展示过网络开小差*/
    private var isShowedNetWorkError: Bool = false
    /** 分享展示样式*/
    private var shareStyle: ShareStyle = .default
    /** 分享交互的数据*/
    private var webShareModel: DYWebShareModel = DYWebShareModel()
    
    // MARK: - convenience init
    /// 初始化WKWebView控制器
    ///
    /// - Parameters:
    ///   - urlString: 当前网页加载地址
    ///   - type: 标记从什么类型跳转打开
    convenience init(with urlString: String, type: WebType = .APP(.default)) {
        self.init()
        self.urlString = urlString
        self.webType = type
        
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightWhiteDark27
        
        self.loadUI()
        self.showLeftBarButtonItem()
        self.updateWebViewLayout()
        
        if canShare {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分享", style: .done, target: self, action: #selector(shareAction))
        }
        
        // 监听当前网络状态
        XMNetWorkStatus.shared.monitor { (status) in
            switch status {
            case .wifi, .cellular:
                self.hideNetWorkErrorView()
                self.loadURL()
            default:
                if self.isShowedNetWorkError {
                    BPM.showAlert(.warning, msg: status.rawValue)
                } else {
                    self.showNetWorkErrorView()
                }
            }
        }
        
        self.addNOC()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = naviBarHidden
        // 可能白屏
        if webView.title == nil {
            webView.reload()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let canPop: Bool
        switch webType {
        case .H5: canPop = false
        case .APP: canPop = true
        }
        self.bk_setPopSwipe(canPop)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bk_setPopSwipe(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - lazy
    lazy var vm: BaseViewModel = {
        let vm = BaseViewModel()
        return vm
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(wkWebViewReload), for: .valueChanged)
        return refresh
    }()
    
    private lazy var backBarButtonItem: UIBarButtonItem = {
        let barItem = UIBarButtonItem(image: .ArrowFork.icon_leftArrow, style: .done, target: self, action: #selector(wkWebViewGoback))
        return barItem
    }()
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let barItem = UIBarButtonItem(image: .ArrowFork.icon_fork, style: .done, target: self, action: #selector(goBack))
        return barItem
    }()
    
    private lazy var netWorkErrorImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon_networkerror"))
        return iv
    }()
    
    private lazy var netWorkErrorLabel: UILabel = {
        let label = self.bk_addLabel(text: "网络开小差啦\n无法连接到网络", bgColor: .clear, textColor: XMColor.light139, align: .center)
        return label
    }()
    
    // MARK: - 加载UI
    private func loadUI() {
        
        containerView = UIScrollView(frame: view.bounds)
        containerView.backgroundColor = .lightWhiteDark27
        containerView.showsVerticalScrollIndicator = false
        containerView.showsHorizontalScrollIndicator = false
        containerView.isScrollEnabled = false
        view.addSubview(containerView)
        
//        self.addScriptMessageHandler()
//        let config = WKWebViewConfiguration()
//        config.preferences = WKPreferences()
//        config.preferences.javaScriptEnabled = true
//        config.preferences.javaScriptCanOpenWindowsAutomatically = true
//        config.allowsAirPlayForMediaPlayback = true
//        config.allowsInlineMediaPlayback = true
//        config.allowsPictureInPictureMediaPlayback = true
//        config.userContentController = userContentController
//
//        webView = WKWebView(frame: kCGRect(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight), configuration: config)
        webView = BKWebViewPool.shared.getReusedWebView(for: self)
        webView.frame = kCGRect(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight)
        self.addScriptMessageHandler()
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isExclusiveTouch = false
        webView.scrollView.delegate = self
        webView.scrollView.decelerationRate = .normal
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
        if canDownRefresh {
            webView.scrollView.refreshControl = refreshControl
        }
        
        webView.addObserver(self, forKeyPath: WebViewKey.progress, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: WebViewKey.title, options: .new, context: nil)
        containerView.addSubview(webView)
        
        memoLabel = UILabel(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 20))
        memoLabel.textAlignment = .center
        memoLabel.font = .systemFont(ofSize: 12)
        memoLabel.textColor = .gray
        memoLabel.alpha = 0.0 // 1.0
        containerView.addSubview(memoLabel)
        
        progressView = BKGradientProgressView(frame: kCGRect(0, 0, view.frame.width, 3))
        progressView.backgroundColor = .clear
        progressView.progressCornerRadius = 1.5
        progressView.progressColors = [UIColor.dark]
        progressView.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressView.alpha = 0.0
        containerView.addSubview(progressView)
        
    }
    
    // MARK: - KVO监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == WebViewKey.progress {
            progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.progressView.alpha = 0.0
                }) { [weak self] (_) in
                    guard let strongSelf = self else { return }
                    strongSelf.progressView.setProgress(0, animated: false)
                }
            }
        } else if keyPath == WebViewKey.title {
            if !customNaviTitle.isBlank() {
                navigationItem.title = customNaviTitle
            } else {
                let _title = webView.title ?? ""
                if _title.contains("jpg") || _title.contains("png") {
                    navigationItem.title = _title.prefixUpTo(range: ".")
                } else {
                    navigationItem.title = webView.title
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}

// MARK: - 通知
extension BKWebViewVC {
    
    private func addNOC() {
//        NOC.default.addObserver(self, selector: #selector(sessionStorageClear), name: .NotiKeyLogin.Success, object: nil)
//        NOC.default.addObserver(self, selector: #selector(sessionStorageClear), name: .NotiKeyLogout.Success, object: nil)
    }
    
    private func removeNOC() {
//        NOC.default.removeObserver(self, name: .NotiKeyLogin.Success, object: nil)
//        NOC.default.removeObserver(self, name: .NotiKeyLogout.Success, object: nil)
    }
    
}

// MARK: - Selector
extension BKWebViewVC {
    
    @objc private func sessionStorageClear() {
        let backList = webView.backForwardList.backList
        if !backList.isEmpty, let item = backList.first {
            webView.go(to: item)
        } else if webView.canGoBack {
            while webView.canGoBack {
                webView.goBack()
            }
        }
        self.callJSMethod(by: .sessionStorageClear)
        webView.reload()
    }
    
    @objc func wkWebViewReload() {
        webView.reload()
        if refreshControl.isRefreshing {
            BKTaskUtil.delay(1.0) {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func wkWebViewGoback() {
        self.goback()
    }
    
    @objc private func shareAction() {
        webShareModel.title = navigationItem.title ?? ""
        webShareModel.url = urlString
        webShareModel.cover = shareCover
        shareStyle = .canNotSave
//        let vc = DYShareBaseVC()
//        vc.delegate = self
//        self.present(vc, animated: true)
    }
    
}

// MARK: - Private
extension BKWebViewVC {
    
    private func showNetWorkErrorView() {
        containerView.addSubviews([netWorkErrorImageView, netWorkErrorLabel])
        containerView.bk_bringSubviewsToFront([netWorkErrorImageView, netWorkErrorLabel])
        netWorkErrorImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-kStatusBarHeight)
        }
        netWorkErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(netWorkErrorImageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        isShowedNetWorkError = true
    }
    
    private func hideNetWorkErrorView() {
        if containerView.subviews.contains([netWorkErrorImageView, netWorkErrorLabel]) {
            netWorkErrorImageView.removeFromSuperview()
            netWorkErrorLabel.removeFromSuperview()
        }
    }
    
    private func addScriptMessageHandler() {
        let jsNames = BKWebViewJSName.allValues
//        userContentController = WKUserContentController()
        let msgHandler = BKWebViewScriptMessageHanlder(delegate: self)
        scriptMessageHandlerNames += jsNames
        jsNames.forEach { (name) in
            webView.configuration.userContentController.add(msgHandler, name: name.rawValue)
//            userContentController.add(msgHandler, name: name.rawValue)
        }
    }
    
    private func removeScriptMessageHandler() {
        for script in scriptMessageHandlerNames {
            webView.configuration.userContentController.removeScriptMessageHandler(forName: script.rawValue)
        }
    }
    
    private func setWebviewMemo(_ memo: String?) {
        guard let promtMessage = memo, promtMessage.count > 0 else { return }
        if memoLabel != nil {
            memoLabel.text = "此网页由 "+promtMessage+" 提供"
        }
    }
    
    private func showLeftBarButtonItem() {
        if webView.canGoBack {
            self.navigationItem.leftBarButtonItems = [backBarButtonItem, closeBarButtonItem]
        } else {
            self.navigationItem.leftBarButtonItem = backBarButtonItem
        }
    }
    
    private func updateWebViewLayout() {
        guard urlString.count > 0 else { return }
        
        let height: CGFloat
        switch h5Type {
        case .GUSTO_H5:
            switch webType {
            case .APP(let mark):
                switch mark {
                case .mall:
                    naviBarHidden = false
                    height = kScreenHeight-kNavigationBarHeight-kBottomSafeHeight
                case .scan:
                    naviBarHidden = true
                    height = kScreenHeight-kStatusBarHeight
                case .showNavi, .authWatches:
                    naviBarHidden = false
                    height = kScreenHeight-kNavigationBarHeight
                case .default:
                    naviBarHidden = true
                    height = kScreenHeight-kStatusBarHeight
                }
            case .H5:
                naviBarHidden = false
                height = kScreenHeight-kNavigationBarHeight-44-kTabBarHeight
            }
        case .GUSTO_INC_EARLY:
            naviBarHidden = true
            height = kScreenHeight-kStatusBarHeight
        case .GUSTO_INC, .MP_WEIXIN, .default:
            naviBarHidden = false
            height = kScreenHeight-kNavigationBarHeight
        }
        webView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: height)
    }
    
    // MARK: - 加载URL
    private func loadURL() {
        guard let url = URL(string: urlString) else { return }
        if webView.isLoading {
            webView.stopLoading()
        }
        self.loadReq(url, h5Type)
    }
    
    private func loadReq(_ url: URL, _ type: H5Type) {
        
        /**
         * .useProtocolCachePolicy                 ---> 默认的cache policy,使用Protocol协议定义
         * .reloadIgnoringCacheData                ---> 忽略缓存直接从原始地址下载
         * .returnCacheDataDontLoad                ---> 只使用cache数据,如果不存在cache,请求失败；用于没有建立网络连接离线模式
         * .returnCacheDataElseLoad                ---> 只有在cache中不存在data时才从原始地址下载
         * .reloadIgnoringLocalAndRemoteCacheData  ---> 忽略本地和远程的缓存数据,直接从原始地址下载
         * .reloadRevalidatingCacheData            ---> 验证本地数据与远程数据是否相同，如果不同则下载远程数据，否则使用本地数据
         */
        
        switch type {
        case .GUSTO_H5, .GUSTO_INC, .GUSTO_INC_EARLY:
            /**
             * ETag：服务器验证令牌，文件内容hash。
             * Last-Modified：响应头标识了资源的最后修改时间。
             * If-None-Match：比较ETag是否不一致。
             * If-Modified-Since：比较资源最后修改的时间是否一致
             */
            var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20.0)
            // 判断是否有更新,只请求responseHeader
            req.httpMethod = "HEAD"
            // 获取记录的response headers
            let cacheHeaders = UserDefaults.standard.object(forKey: url.absoluteString) as? [String: Any]
            // 设置request headers
            if cacheHeaders != nil {
                if let etag = cacheHeaders?["Etag"] as? String {
                    req.setValue(etag, forHTTPHeaderField: "If-None-Match")
                }
                if let lastModified = cacheHeaders?["Last-Modified"] as? String {
                    req.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
                }
            }
            
            self.bk_showLoading()
            URLSession.shared.dataTask(with: req) { (data, resp, error) in
                guard let httpResp = resp as? HTTPURLResponse else { return }
                PPP("WKWebView StatusCode == \(httpResp.statusCode)")
                if httpResp.statusCode == 304 || httpResp.statusCode == 0 {
                    // 如果状态码为304或者0(网络不通)，则设置request的缓存策略为读取本地缓存
                    req.cachePolicy = .returnCacheDataElseLoad
                } else {
                    // 如果状态码为200，则保存本次的response headers，并设置request的缓存策略为忽略本地缓存，重新请求数据
                    UserDefaults.standard.set(httpResp.allHeaderFields, forKey: req.url?.absoluteString ?? "")
                    req.cachePolicy = .reloadIgnoringLocalCacheData
                }
                DispatchQueue.main.async {
                    self.bk_hideLoading()
                    req.httpMethod = "GET"
                    self.webView.load(req)
                }
            }.resume()
        case .MP_WEIXIN, .default:
            let urlReq = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20.0)
            webView.load(urlReq)
        }
        
    }
    
}

// MARK: - Public
extension BKWebViewVC {
    
    static func initWithURLString(_ urlString: String) -> BKWebViewVC {
        let webView = BKWebViewVC()
        webView.urlString = urlString
        return webView
    }
    
    func callJSMethod(by jsString: EvaluateJSMethod, _ completion: ((Any?, Error?) -> Void)? = nil) {
        
    }
    
    /** 控制WebView的侧滑返回*/
    func allowBackWithGestures(_ isAllow: Bool) {
        webView.allowsBackForwardNavigationGestures = isAllow
    }
    
    /** 复用WKWebView需要清除历史记录*/
    func clearWkWebViewHistory() {
        webView.evaluateJavaScript("document.body.innerHTML = '';", completionHandler: nil)
    }
    
}

// MARK: - 交互
extension BKWebViewVC {
    
    /// 处理与JS交互的方法
    private func handleWKScriptMessage(name: String, body: Any, completion: ((String?) -> Void)? = nil) {
        let jsName = BKWebViewJSName(rawValue: name)
        switch jsName {
        case .popToRootWindow:   self.popToRootWindow()
        case .goback:            self.goback()
        case .openNewWindow:     self.openNewWindow(body as! String)
        case .closeWindow:       self.closeWindow(index: body as? Int)
        case .saveLocalStorage:  self.saveLocalStorage(body as! String)
        case .share:             self.share(body as! String)
        case .getToken:          self.getToken(body as! String)
        case .logout:            self.logout()
        case .saveImage:         self.saveImage(body as! String)
        case .openWXMiniprogram: self.openWXMiniprogram(by: body as! String)
        case .getUserDeviceInfo: self.getUserDeviceInfo()
        case .shareAll:          self.shareAll(by: body as! String)
        default: break
        }
        completion?(nil)
    }
    
}

// MARK: - WebView JS交互
extension BKWebViewVC: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.runJavaScriptReceiveMessage(message: message)
        self.runJavaScriptReceiveMessageBlock?(message)
        
        // message.name  方法名
        // message.body  参数值
        PPP("\n方法名name: \(message.name);\n参数值body: \(message.body)")
        self.handleWKScriptMessage(name: message.name, body: message.body)
    }
    
    func popToRootWindow() {
        let visibleNavi = UIApplication.shared.visibleNaviCtrl()
        visibleNavi?.popToRootViewController(animated: true)
    }
    
    func goback() {
        if webView.canGoBack && BKWebViewPool.shared.justOneVisibleWebView {
            webView.goBack()
        } else if webView.canGoBack {
            if webView.backForwardList.backList.count == 2 {
                self.closeWindow(index: -2)
            } else {
                webView.goBack()
            }
        } else {
            self.clearWkWebViewHistory()
            self.callJSMethod(by: .sessionStorageClear)
            self.bk_autoBack()
        }
    }
    
    func openNewWindow(_ url: String) {
        let vc = BKWebViewVC.initWithURLString(url)
        self.navigationController?.pushViewController(vc)
    }
    
    func closeWindow(index: Int?) {
        guard index != nil, let viewCtrls = self.navigationController?.viewControllers else {
            self.clearWkWebViewHistory()
            self.callJSMethod(by: .sessionStorageClear)
            self.bk_autoBack()
            return
        }
        if viewCtrls.count > 1 {
            if let _index = index, let item = webView.backForwardList.item(at: _index) {
                webView.go(to: item)
            } else {
                if webView.canGoBack {
                    webView.goBack()
                } else {
                    self.clearWkWebViewHistory()
                    self.callJSMethod(by: .sessionStorageClear)
                    self.bk_autoBack()
                }
            }
        } else {
            guard let _index = index else {
                if webView.canGoBack {
                    webView.goBack()
                }
                return
            }
            if webView.canGoBack && index == -1 {
                webView.goBack()
            } else {
                if webView.backForwardList.backList.count != abs(_index) && webView.canGoBack {
                    webView.goBack()
                } else {
                    if let item = webView.backForwardList.item(at: _index) {
                        webView.go(to: item)
                    }
                }
            }
        }
    }
    
    func saveLocalStorage(_ obj: String) {
        guard let dic = JSON(parseJSON: obj).dictionaryObject else { return }
        PPP("dic: \(dic.jsonString(prettify: true) ?? "")")
        dic.enumerated().forEach({ (key, value) in
            let jsString = "localStorage.setItem('\(key)', '\(value)')"
            webView.evaluateJavaScript(jsString) { (obj, error) in
                if let obj = obj, let err = error {
                    PPP("\(obj) \(err)")
                }
            }
        })
    }
    
    func share(_ obj: String) {
        guard let dic = JSON(parseJSON: obj).dictionaryObject, let model = DYWebShareModel.deserialize(from: dic) else { return }
        webShareModel = model
        shareStyle = .canNotSave
//        let vc = DYShareBaseVC()
//        vc.delegate = self
//        self.present(vc, animated: true)
    }
    
    func getToken(_ obj: String) {
        
    }
    
    func logout() {
        App.startLogout()
    }
    
    func saveImage(_ base64: String) {
        BKPermission.request(.photoLibrary) { status in
            if status.isAuthorized {
                guard let image = UIImage(base64String: base64) else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                BPM.showResult(.success, msg: .Success.save)
            } else {
                BPM.showAlert(.warning, msg: .canNotVisitPhoto)
            }
        }
    }
    
    func openWXMiniprogram(by obj: String) {
//        WXApiManager.pullWXMiniProgram(by: obj)
    }
    
    func getUserDeviceInfo() {
        let userDic = ["userinfo": XMApp.kUserModel?.toJSON() as Any]
        let deviceDic = ["deviceinfo": UIDevice.bk_deviceInfo]
        let dic = userDic + deviceDic + ["appversion": kAppVersion]
        guard let json = dic.jsonString() else { return }
        PPP(JSON(parseJSON: json))
        let jsString = "setJSUserDeviceInfo('\(json)')"
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    func shareAll(by obj: String) {
        let js = JSON(parseJSON: obj)
        let type = js["type"].intValue
        let _type = type.string.firstK.int!
        let session = _type == 1
        guard let params = js["params"].dictionaryObject, let model = DYWebShareModel.deserialize(from: params) else { return }
        PPP("分享的数据: \(model.toJSONString(prettyPrint: true) ?? "")")
        let shareType: ShareAllType = ShareAllType(rawValue: type) ?? .wechat_h5
        switch shareType {
        case .wechat_h5, .timeline_h5:
            self.handleShareH5(model: model, session: session)
        case .wechat_text, .timeline_text:
            self.handleShareText(model: model, session: session)
        case .wechat_image, .timeline_image:
            if let url = URL(string: model.photo), let image = try? UIImage(url: url) {
                shareImage = image
            }
            if let image = UIImage(base64String: model.base64) {
                shareImage = image
            }
//            WXApiManager.openWXAppShareImage(image: shareImage, session: session)
        }
    }
    
}

// MARK: - 分享
extension BKWebViewVC {
    
    private func handleShareH5(isWwk: Bool = false, model: DYWebShareModel, session: Bool) {
//        if trainEventContentType != .default {
//            self.post_trainEventNotify(eventType: .share)
//        }
//        if !isWwk {
//            WXApiManager.openWXAppShareH5(title: model.title, content: model.content, url: model.url,
//                                          cover: model.cover, base64: model.base64, session: session) { success in
//                let data = ["app": "wechat", "code": success] as [String: Any]
//                let jsString = "\(model.callback)('\(data.jsonString() ?? "")')"
//                self.webView.evaluateJavaScript(jsString, completionHandler: nil)
//            }
//        } else {
//            WWKApiManager.openWWKAppShareH5(title: model.title, content: model.content, url: model.url, cover: model.cover, base64: model.base64)
//        }
    }
    
    private func handleShareText(isWwk: Bool = false, model: DYWebShareModel, session: Bool) {
//        if !isWwk {
//            WXApiManager.openWXAppShareText(text: model.content, session: session) { success in
//                let data = ["app": "wechat", "code": success] as [String: Any]
//                let jsString = "\(model.callback)('\(data.jsonString() ?? "")')"
//                self.webView.evaluateJavaScript(jsString, completionHandler: nil)
//            }
//        } else {
//            WWKApiManager.openWWKAppShareText(text: model.content)
//        }
    }
    
}

// MARK: - WKNavigationDelegate,WKUIDelegate代理
extension BKWebViewVC: WKNavigationDelegate,WKUIDelegate {
    
    // 在发送请求之前,决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let urlStr = navigationAction.request.url?.absoluteString else { return }
        
        if urlStr.hasPrefix("https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb") {
            if urlStr.contains("&redirect_url=") {
                // 拦截URL获取redirect_url
                let arr = urlStr.components(separatedBy: "&redirect_url=")
                // 拿到redirect_url
                let redirect_url_str = arr.lastK
                // 将编码后的url转换回原始的url
                guard var redirect_url = URL(string: redirect_url_str.removingPercentEncoding ?? "") else { return }
                if redirect_url.absoluteString.contains(url_scheme) {
                    if let url = URL(string: (redirect_url.absoluteString as NSString).substring(from: url_scheme.count)) {
                        redirect_url = url
                    }
                }
                PPP("redirect_url: \(redirect_url.absoluteString)")
                // 微信支付是否完成都可以回跳，通过配置scheme给Referer
                url_scheme = String(format: "%@://", redirect_url.host ?? "")
                if !urlStr.contains(url_scheme.urlEncoded) {
                    if let url = URL(string: String(format: "%@%@%@%@", arr.first ?? "", "&redirect_url=", url_scheme.urlEncoded, arr.last ?? "")) {
                        PPP("回调URL: \(url)")
                        PPP("url_scheme: \(url_scheme)")
                        DispatchQueue.main.async {
                            var req = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
                            req.setValue(self.url_scheme, forHTTPHeaderField: "Referer")
                            webView.load(req)
                        }
                    }
                    if let req_url = navigationAction.request.url {
                        PPP("cancel: \(req_url)")
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        
        // MARK: - 调起微信
        if urlStr.hasPrefix("weixin://wap/pay?") {
            guard let url = URL(string: urlStr.removingPercentEncoding ?? "") else { return }
            BKTaskUtil.delay(0.5) {
                BKUtils.bk_openURL(url)
            }
            if let req_url = navigationAction.request.url {
                PPP("cancel: \(req_url)")
            }
            decisionHandler(.cancel)
            // 关闭微信中间页
            self.goback()
//            WXApiManager.default.delegate = self
            return
        }
        
        // MARK: - 调起支付宝
        if urlStr.hasPrefix("alipay://") || urlStr.hasPrefix("alipays://") {
            // 拦截URL,以?号来切割字符串
            let arr = urlStr.components(separatedBy: "?")
            guard let json_part = arr.last?.urlDecoded else { return }
            var dic = JSON(parseJSON: json_part).dictionaryObject
            dic?["fromAppUrlScheme"] = "www.sport-china.cn"
            let new_json_part = dic?.jsonString()
            if let url = URL(string: String(format: "%@?%@", arr.first ?? "", new_json_part?.urlEncoded ?? "")) {
                PPP("回调URL: \(url)")
                DispatchQueue.main.async {
                    BKUtils.bk_openURL(url)
                }
            }
            if let req_url = navigationAction.request.url {
                PPP("cancel: \(req_url)")
            }
            decisionHandler(.cancel)
            return
        }
        
        if let _ = navigationAction.request.url {
            self.showLeftBarButtonItem()
        }
        decisionHandler(.allow)
        
    }
    
    // 在收到响应后,决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let urlStr = navigationResponse.response.url?.absoluteString else { return }
        guard let httpResp = navigationResponse.response as? HTTPURLResponse else {
            decisionHandler(.allow)
            return
        }
        let policy: WKNavigationResponsePolicy = httpResp.statusCode == 200 ? .allow : .cancel
        decisionHandler(policy)
        
    }
    
    // 接收到服务器跳转请求之后再执行
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    // 当webView需要响应身份验证时调用(如需验证服务器证书)
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        if authenticationMethod == NSURLAuthenticationMethodServerTrust {
            guard let secTrust = challenge.protectionSpace.serverTrust else { return }
            let credential = URLCredential(trust: secTrust)
            completionHandler(.useCredential, credential)
        }
        
    }
    
    // 创建一个新的WebView
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        guard let isMainFrame = navigationAction.targetFrame?.isMainFrame else { return nil }
        if !isMainFrame {
            webView.load(navigationAction.request)
        }
        return nil
        
    }
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.setWebviewMemo(webView.url?.host)
    }
    
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if autoChangeTitle {
            navigationItem.title = webView.title
        }
        if !customNaviTitle.isBlank() {
            navigationItem.title = customNaviTitle
        }
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] (result, error) in
            self?.webViewHeight = CGFloat((result as? NSNumber)?.doubleValue ?? 0.0)
            PPP("WKWebView高度: \(self?.webViewHeight ?? 0.0)")
        }
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    // 当WKWebView总体内存占用过大即将白屏的时候
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    // MARK: - 警告框Alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            completionHandler()
        }))
        self.present(alert, animated: true)
        
    }
    
    // MARK: - 确认框Confirm
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            completionHandler(false)
        }))
        self.present(alert, animated: true)
        
    }
    
    // MARK: - 输入框Prompt
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        // 根据prompt进行判断执行相应的方法，defaultText为参数值，completionHandler为给js的回调
        PPP("参数值defaultText: \(defaultText ?? ""); 方法名prompt: \(prompt)")
        self.handleWKScriptMessage(name: prompt, body: defaultText as Any) { (_callback) in
            completionHandler(_callback)
        }
        
    }
    
}

// MARK: - UIScrollViewDelegate代理
extension BKWebViewVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        guard memoLabel != nil else { return }
        if offsetY < 0 {
            if fabsf(Float(offsetY)) > 50 {
                let alpha = (fabsf(Float(offsetY)) - 50) / 100.00
                if alpha >= 1.0 {
                    memoLabel.alpha = 1.0
                } else {
                    memoLabel.alpha = CGFloat(alpha)
                }
            } else {
                memoLabel.alpha = 0.0
            }
        } else {
            memoLabel.alpha = 0.0
        }
    }
    
}

// MARK: - 网络请求
extension BKWebViewVC {
    
//    fileprivate func post_trainEventNotify(eventType: DYTrainViewModel.EventContentType.EventType) {
//        vm.req_trainEventNotify(by: contentId, contentType: trainEventContentType, eventType: eventType) { ok, obj, msg, code in
//
//        }
//    }
    
}
