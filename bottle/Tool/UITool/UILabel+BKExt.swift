//
//  UILabel+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

// MARK: UILabel扩展
extension UILabel {
    
    func bk_alignTop() {
        guard let text = self.text else { return }
        let fontSize: CGSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font as Any])
        // 控件的高度除以一行文字的高度
        let num = Int(frame.size.height/fontSize.height)
        // 计算需要添加换行符个数
        let newLinesToPad = num - numberOfLines
        numberOfLines = 0
        for _ in 0..<newLinesToPad {
            self.text?.append("\n")
        }
    }
    
    func bk_alignBottom() {
        guard let text = self.text else { return }
        let fontSize: CGSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font as Any])
        let num = Int(frame.size.height/fontSize.height)
        let newLinesToPad = num - numberOfLines
        numberOfLines = 0
        for _ in 0..<newLinesToPad {
            self.text = " \n\(self.text ?? "")"
        }
    }
    
    /// 设置lineBreakMode = .byTruncatingTail
    func bk_setTruncatingTail() {
        self.adjustsFontSizeToFitWidth = false
        self.lineBreakMode = .byTruncatingTail
    }
    
    /// 设置字体倾斜
    ///
    /// - Parameters:
    ///   - lean: 倾斜度 负的往右倾斜 正的往左倾斜
    func bk_slant(lean: Float = -10) {
        let matrix = __CGAffineTransformMake(1, 0, CGFloat(tanf(lean * Float(Double.pi)/180)), 1, 0, 0)
        self.transform = matrix
    }
    
    /// 改变行间距
    func bk_setTextWithlineSpacing(text: String, lineSpacing: CGFloat = 10.0) {
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = lineSpacing
        self.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paraph])
    }
    
    /// 添加下划线
    func bk_setUnderline(text: String) {
        self.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.underlineStyle: 1])
    }
    
    /// 获取已知 frame 的 label 的文本行数 & 每一行内容
    /// - Parameters:
    ///   - lineSpace: 行间距
    ///   - textSpace: 字间距，默认为0.0
    ///   - paraSpace: 段间距，默认为0.0
    /// - Returns: label 的文本行数 & 每一行内容
    func bk_linesCountAndLinesContent(lineSpace: CGFloat, textSpace: CGFloat = 0.0, paraSpace: CGFloat = 0.0) -> (Int?, [String]?) {
        return bk_accordWidthLinesCountAndLinesContent(accordWidth: frame.size.width, lineSpace: lineSpace, textSpace: textSpace, paraSpace: paraSpace)
    }
    
    // MARK: 2.2、获取已知 width 的 label 的文本行数 & 每一行内容
    /// 获取已知 width 的 label 的文本行数 & 每一行内容
    /// - Parameters:
    ///   - accordWidth: label 的 width
    ///   - lineSpace: 行间距
    ///   - textSpace: 字间距，默认为0.0
    ///   - paraSpace: 段间距，默认为0.0
    /// - Returns: description
    func bk_accordWidthLinesCountAndLinesContent(accordWidth: CGFloat, lineSpace: CGFloat, textSpace: CGFloat = 0.0, paraSpace: CGFloat = 0.0) -> (Int?, [String]?) {
        guard let t = text, let f = font else { return (0, nil) }
        let align = textAlignment
        let c_fn = f.fontName as CFString
        let fp = f.pointSize
        let c_f = CTFontCreateWithName(c_fn, fp, nil)
        
        let contentDict = UILabel.genTextStyle(text: t as NSString, linebreakmode: NSLineBreakMode.byCharWrapping, align: align, font: f, lineSpace: lineSpace, textSpace: textSpace, paraSpace: paraSpace)
        
        let attr = NSMutableAttributedString(string: t)
        let range = NSRange(location: 0, length: attr.length)
        attr.addAttributes(contentDict, range: range)
        
        attr.addAttribute(NSAttributedString.Key.font, value: c_f, range: range)
        let frameSetter = CTFramesetterCreateWithAttributedString(attr as CFAttributedString)
        
        let path = CGMutablePath()
        /// 2.5 是经验误差值
        path.addRect(CGRect(x: 0, y: 0, width: accordWidth - 2.5, height: CGFloat(MAXFLOAT)))
        let framef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(framef) as NSArray
        var lineArr = [String]()
        for line in lines {
            let lineRange = CTLineGetStringRange(line as! CTLine)
            let lineString = t.subString(start: lineRange.location, length: lineRange.length)
            lineArr.append(lineString as String)
        }
        return (lineArr.count, lineArr)
    }
    
    /// 改变行间距
    /// - Parameter space: 行间距大小
    func bk_changeLineSpace(space: CGFloat) {
        if self.text == nil || self.text == "" {
            return
        }
        let text = self.text
        let attributedString = NSMutableAttributedString(string: text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange.init(location: 0, length: text!.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }
    
    /// 改变字间距
    /// - Parameter space: 字间距大小
    func bk_changeWordSpace(space: CGFloat) {
        if self.text == nil || self.text == "" {
            return
        }
        let text = self.text
        let attributedString = NSMutableAttributedString(string: text!, attributes: [NSAttributedString.Key.kern:space])
        let paragraphStyle = NSMutableParagraphStyle()
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange.init(location: 0, length: text!.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }
    
    /// 改变字间距和行间距
    /// - Parameters:
    ///   - lineSpace: 行间距
    ///   - wordSpace: 字间距
    func bk_changeSpace(lineSpace: CGFloat, wordSpace: CGFloat) {
        if self.text == nil || self.text == "" {
            return
        }
        let text = self.text
        let attributedString = NSMutableAttributedString(string: text!, attributes: [NSAttributedString.Key.kern:wordSpace])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange.init(location: 0, length: text!.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }
    
    /// label添加中划线
    /// - Parameters:
    ///   - lineValue: value 越大,划线越粗
    ///   - underlineColor: 中划线的颜色
    func bk_centerLineText(lineValue: Int = 1, underlineColor: UIColor = .black) {
        guard let content = text else { return }
        let arrText = NSMutableAttributedString(string: content)
        arrText.addAttributes([NSAttributedString.Key.strikethroughStyle: lineValue, NSAttributedString.Key.strikethroughColor: underlineColor], range: NSRange(location: 0, length: arrText.length))
        self.attributedText = arrText
    }
    
    /// 设置文本样式
    /// - Parameters:
    ///   - text: 文字内容
    ///   - linebreakmode: 结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
    ///   - align: 文本对齐方式：（左，中，右，两端对齐，自然）
    ///   - font: 字体大小
    ///   - lineSpace: 字体的行间距
    ///   - textSpace: 设定字符间距，取值为 NSNumber 对象（整数），正值间距加宽，负值间距变窄
    ///   - paraSpace: 段与段之间的间距
    /// - Returns: 返回样式 [NSAttributedString.Key : Any]
    private static func genTextStyle(text: NSString, linebreakmode: NSLineBreakMode, align: NSTextAlignment, font: UIFont, lineSpace: CGFloat, textSpace: CGFloat, paraSpace: CGFloat) -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        // 结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
        /**
         case byWordWrapping = 0       //  以单词为显示单位显示，后面部分省略不显示
         case byCharWrapping = 1       //  以字符为显示单位显示，后面部分省略不显示
         case byClipping = 2           //  剪切与文本宽度相同的内容长度，后半部分被删除
         case byTruncatingHead = 3     //  前面部分文字以……方式省略，显示尾部文字内容
         case byTruncatingTail = 4     //  中间的内容以……方式省略，显示头尾的文字内容
         case byTruncatingMiddle = 5   //  结尾部分的内容以……方式省略，显示头的文字内容
         */
        style.lineBreakMode = linebreakmode
        // 文本对齐方式：（左，中，右，两端对齐，自然）
        style.alignment = align
        // 字体的行间距
        style.lineSpacing = lineSpace
        // 连字属性 在iOS，唯一支持的值分别为0和1
        style.hyphenationFactor = 1.0
        // 首行缩进
        style.firstLineHeadIndent = 0.0
        // 段与段之间的间距
        style.paragraphSpacing = paraSpace
        // 段首行空白空间
        style.paragraphSpacingBefore = 0.0
        // 整体缩进(首行除外)
        style.headIndent = 0.0
        // 文本行末缩进距离
        style.tailIndent = 0.0
        
        /*
         // 一组NSTextTabs。 内容应按位置排序。 默认值是一个由12个左对齐制表符组成的数组，间隔为28pt ？？？？？
         style.tabStops =
         // 一个布尔值，指示系统在截断文本之前是否可以收紧字符间间距 ？？？？？
         style.allowsDefaultTighteningForTruncation = true
         // 文档范围的默认选项卡间隔 ？？？？？
         style.defaultTabInterval = 1
         // 最低行高（设置最低行高后，如果文本小于20行，会通过增加行间距达到20行的高度）
         style.minimumLineHeight = 10
         // 最高行高（设置最高行高后，如果文本大于10行，会通过降低行间距达到10行的高度）
         style.maximumLineHeight = 20
         //从左到右的书写方向
         style.baseWritingDirection = .leftToRight
         // 在受到最小和最大行高约束之前，自然线高度乘以该因子（如果为正） 多少倍行间距
         style.lineHeightMultiple = 15
         */
        
        let dict = [
            NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.kern: textSpace] as [NSAttributedString.Key: Any]
        return dict
    }
    
}

private var UILABELKEY_ISENABLEDCOPY        = "UILabel_isEnabledCopy"
private var UILABELKEY_COPYPRESSDURATION    = "UILabel_copyPressDuration"

// MARK: - 增加 是否允许拷贝文本内容属性，按压时间属性
extension UILabel {
    
    /** 是否允许有复制功能*/
    public var bk_enabledCopy: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &UILABELKEY_ISENABLEDCOPY) else {
                return false
            }
            guard let enabledCopy = value as? Bool else {
                return false
            }
            return enabledCopy
        }
        set {
            objc_setAssociatedObject(self, &UILABELKEY_ISENABLEDCOPY, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.attachLongPressGesture()
        }
    }
    
    /** 设置按压时间，长按指定时间后出现复制按钮*/
    public var bk_copyPressDuration: Float {
        get {
            guard let value = objc_getAssociatedObject(self, &UILABELKEY_COPYPRESSDURATION) else {
                return 0.5
            }
            guard let pressDuration = value as? Float else {
                return 0.5
            }
            return pressDuration
        }
        set {
           objc_setAssociatedObject(self, &UILABELKEY_COPYPRESSDURATION, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    /** 附加长按手势*/
    private func attachLongPressGesture() {
        guard self.bk_enabledCopy else { return }
        self.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showCopyMenu))
        let pressDuration = self.bk_copyPressDuration != 0.5 ? self.bk_copyPressDuration : 0.5
        longPressGesture.minimumPressDuration = TimeInterval(pressDuration)
        self.addGestureRecognizer(longPressGesture)
    }
    
    /** 展示复制按钮*/
    @objc private func showCopyMenu() {
        self.becomeFirstResponder()
        let menu = UIMenuController.shared
        let copy = UIMenuItem(title: "复制", action: #selector(copyText(_:)))
        menu.menuItems = [copy]
        menu.setTargetRect(self.frame, in: self.superview ?? self)
        menu.setMenuVisible(true, animated: true)
    }
    
    /** 复制文本内容*/
    @objc private func copyText(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.text ?? self.attributedText?.string
    }
    
}

// MARK: - UILabel数字变化动画
class BKCountingLabel: UILabel {
    
    // 开始的数字
    public var fromNum = NSNumber(integerLiteral: 0)
    // 结束的数字
    public var toNum = NSNumber(integerLiteral: 100)
    // 字符串格式化
    public var format: String = "%d"
    // 格式化字符串闭包
    public var formatCallback: ((_ value: Double) -> String)?
    
    // 动画的持续时间
    private var duration: TimeInterval = 1.0
    // 动画开始时刻的时间
    private var startTime: CFTimeInterval = 0
    // 定时器
    private var displayLink: CADisplayLink!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bk_startCounting(from fromNum: NSNumber, toNum: NSNumber, duration: Double = 1.0) {
        self.text = fromNum.stringValue
        self.fromNum = fromNum
        self.toNum = toNum
        self.duration = duration
        startDisplayLink()
    }
    
    public func bk_stopCounting() {
        if displayLink != nil {
            displayLink.remove(from: .current, forMode: .common)
            displayLink.invalidate()
            displayLink = nil
        }
    }
    
    private func startDisplayLink() {
        if displayLink != nil {
            displayLink.remove(from: .current, forMode: .common)
            displayLink.invalidate()
            displayLink = nil
        }
        displayLink = CADisplayLink(target: self, selector: .handleDisplayLink)
        // 记录动画开始时刻的时间
        startTime = CACurrentMediaTime()
        displayLink.add(to: .current, forMode: .common)
    }
    
    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        if displayLink.timestamp - startTime >= duration {
            if formatCallback != nil {
                self.text = self.formatCallback!(toNum.doubleValue)
            } else {
                self.text = String(format: self.format, toNum.doubleValue)
            }
            // 结束定时器
            bk_stopCounting()
        } else {
            // 计算现在时刻的数字
            let currentNum = (toNum.doubleValue - fromNum.doubleValue) * (displayLink.timestamp - startTime) / duration + fromNum.doubleValue
            if formatCallback != nil {
                self.text = self.formatCallback!(currentNum)
            } else {
                self.text = String(format: self.format, currentNum)
            }
        }
    }
    
}

private extension Selector {
    static let handleDisplayLink = #selector(BKCountingLabel.handleDisplayLink(_:))
}

// MARK: - UILabel数字倒计时动画
class BKCountdownLabel: UILabel {
    
    /// 开始倒计时时间
    var seconds: Int = 3
    /// 倒计时时间回调
    var onCountdownCallback: ((_ seconds: Int) -> Void)?
    // 倒计时计时器
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func start() {
        self.startTimer()
    }
    
    public func destoryTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startTimer() {
        self.destoryTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdownAction), userInfo: nil, repeats: true)
    }
    
    @objc private func countdownAction() {
        self.onCountdownCallback?(seconds)
        if seconds > 0 {
            text = String(format: "%d", seconds)
            let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            // 字体变化大小
            animation.values = [3.0, 2.0, 0.7, 1.0]
            animation.duration = 0.5
            self.layer.add(animation, forKey: "scaleTime")
            seconds -= 1
        } else {
            self.destoryTimer()
            self.removeFromSuperview()
        }
    }
    
}
