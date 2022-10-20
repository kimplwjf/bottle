//
//  UITextView+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

extension UITextView {
    
    /// 改变行间距
    /// - Parameter space: 行间距大小
    func bk_changeLineSpace(space: CGFloat, color: UIColor) {
        if self.text == nil || self.text == "" {
            return
        }
        let text = self.text
        let attributedString = NSMutableAttributedString(string: text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text!.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text!.count))
        self.attributedText = attributedString
        self.sizeToFit()
    }
    
}

// MARK: - 扩展 UITextView，添加 placeholder 和 字数限制功能。
/*
 1、使用 SnapKit 进行布局。
 2、使用 objc/runtime 动态添加了 bk_placeholderLabel 等属性
 */

fileprivate var bk_placeholderLabelKey = "bk_placeholderLabelKey"
fileprivate var bk_placeholderKey = "bk_placeholderKey"
fileprivate var bk_attributedTextKey = "bk_attributedTextKey"
fileprivate var bk_wordCountLabelKey = "bk_wordCountLabelKey"
fileprivate var bk_maxWordCountKey = "bk_maxWordCountKey"

public extension UITextView {
    
    /// 移除监听
    func bk_removeAllObservers() {
        NOC.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
        NOC.default.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object: nil)
        if bk_placeholderLabel != nil {
            removeObserver(self, forKeyPath: "text")
        }
    }
    
    /// bk_placeholder Label
    var bk_placeholderLabel: UILabel? {
        set { objc_setAssociatedObject(self, &bk_placeholderLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get {
            let obj = objc_getAssociatedObject(self, &bk_placeholderLabelKey)
            guard let placeholderLabel = obj as? UILabel else {
                let label = UILabel()
                label.textAlignment = self.textAlignment
                label.numberOfLines = 0
                label.font = self.font
                label.textColor = UIColor.lightGray
                label.isUserInteractionEnabled = false
                label.translatesAutoresizingMaskIntoConstraints = false
                addSubview(label)
                // 添加约束。要约束宽，否则可能导致label不换行
                addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 2))
                addConstraint(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 2))
                addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
                addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1.0, constant: 0))
                // 设置bk_placeholderLabel，自动调用set方法
                self.bk_placeholderLabel = label
                
                addObserver(self, forKeyPath: "text", options: .new, context: nil)
                NOC.default.addObserver(self, selector: #selector(bk_textDidChange), name: UITextView.textDidChangeNotification, object: nil)
                NOC.default.addObserver(self, selector: #selector(bk_textDidChange), name: UITextView.textDidBeginEditingNotification, object: nil)
//                bk_textDidChange()
                
                return label
            }
            return placeholderLabel
        }
    }
    
    /// bk_placeholder
    var bk_placeholder: String? {
        set {
            objc_setAssociatedObject(self, bk_placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let placeholder = newValue else { return }
            self.bk_placeholderLabel?.text = placeholder
        }
        get { return objc_getAssociatedObject(self, bk_placeholderKey) as? String }
    }
    
    /// bk_placeholderAttributedText
    var bk_placeholderAttributedText: NSAttributedString? {
        set {
            objc_setAssociatedObject(self, &bk_attributedTextKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let attr = newValue else { return }
            self.bk_placeholderLabel?.attributedText = attr
        }
        get { return objc_getAssociatedObject(self, &bk_attributedTextKey) as? NSAttributedString }
    }
    
    /// 字数的Label
    var bk_wordCountLabel: UILabel? {
        set {
            // 调用 setter 的时候会执行此处代码，将自定义的label通过runtime保存起来
            objc_setAssociatedObject(self, &bk_wordCountLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let obj = objc_getAssociatedObject(self, &bk_wordCountLabelKey) as? UILabel
            guard let wordCountLabel = obj else {
                let label = UILabel()
                label.textAlignment = .right
                label.font = self.font
                label.textColor = UIColor.lightGray
                label.isUserInteractionEnabled = false
                
                // 添加到视图中
                if let grandfatherView = self.superview {
                    // 这里添加到 self.superview。如果添加到self，发现自动布局效果不理想。
                    grandfatherView.addSubview(label)
                    
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    grandfatherView.addConstraint(NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -7)) 
                    grandfatherView.addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -7))
                } else {
                    print("请先将你的UITextView添加到视图中")
                }
                
                // 调用setter
                self.bk_wordCountLabel = label
                
                NOC.default.addObserver(self, selector: #selector(bk_maxWordCountAction), name: UITextView.textDidChangeNotification, object: nil)
                
                return label
            }
            return wordCountLabel
        }
    }
    
    /// 限制的字数
    var bk_maxWordCount: Int? {
        set {
            let num = NSNumber(integerLiteral: newValue!)
            objc_setAssociatedObject(self, &bk_maxWordCountKey, num, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard let count = newValue else { return }
            guard let label = self.bk_wordCountLabel else { return }
            label.text = "\(self.text.count)/\(count)"
        }
        get {
            let num = objc_getAssociatedObject(self, &bk_maxWordCountKey) as? NSNumber
            return num?.intValue
        }
    }
    
    @objc private func bk_maxWordCountAction() {
        guard let maxCount = self.bk_maxWordCount else { return }
        if self.text.count > maxCount {
            /// 输入的文字超过最大值
            self.text = (self.text as NSString).substring(to: maxCount)
            print("已经超过限制的字数了!")
        }
    }
    
    /// text 长度发生了变化
    @objc private func bk_textDidChange() {
        if let placeholderLabel = self.bk_placeholderLabel {
            placeholderLabel.isHidden = (self.text.count > 0)
        }
        
        if let wordCountLabel = self.bk_wordCountLabel {
            guard let count = self.bk_maxWordCount else { return }
            wordCountLabel.text = "\(self.text.count)/\(count)"
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is UITextView {
            let lbl = object as! UITextView
            if lbl === self && keyPath == "text" {
                if lbl.text == " " {
                    self.text = ""
                }
                bk_textDidChange()
            }
        }
    }
    
}

extension UITextView {
    
    /// 设置字体倾斜
    ///
    /// - Parameters:
    ///   - lean: 倾斜度 负的往右倾斜 正的往左倾斜
    func bk_slant(lean: Float = -10) {
        let matrix = __CGAffineTransformMake(1, 0, CGFloat(tanf(lean * Float(Double.pi)/180)), 1, 0, 0)
        self.transform = matrix
    }
    
}

protocol BKAttributedTextViewDelegate: NSObjectProtocol {
    func tapTextView(_ isOpen: Bool)
    func textViewHeightDidChanged(_ height: CGFloat)
}

extension BKAttributedTextViewDelegate {
    func tapTextView(_ isOpen: Bool) { }
    func textViewHeightDidChanged(_ height: CGFloat) { }
}

// MARK: - BKAttributedTextView
class BKAttributedTextView: UITextView {
    
    var kDelegate: BKAttributedTextViewDelegate?
    var allText: String = "" {
        didSet {
            if !allText.isEmpty {
                self.reloadTextView()
            } else {
                self.kDelegate?.textViewHeightDidChanged(0.0)
            }
        }
    }
    var isOpen: Bool = false
    var lessLine: Int = 2 // rows for close status
    var openText: String = "展开"
    var closeText: String = "收起"
    var linkColor: UIColor = .white
    var kAttributs: [NSAttributedString.Key: Any] = [:]
    var kParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
    
    private var kFont: UIFont = .systemFont(ofSize: 16)
    private var kAllLine: Int = 0
    private var kLineHeight: CGFloat = 0.0
    private var kCloseHeight: CGFloat = 0.0
    private var kOpenHeight: CGFloat = 0.0
    private let kClickUrlString: String = "com.textView.isOpen"
    
    // need set frame.size.width, the height will be calculated according to this width
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.textContainer.lineFragmentPadding = 0 // clear side margin
        textContainerInset = .zero // clear inset
        isEditable = false // disable edit, otherwise click will pop up the keyboard
        isScrollEnabled = false // disable scroll
        delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Selector
extension BKAttributedTextView {
    
    @objc private func tapAction() {
        let str = attributedText.string
        if str.contains(openText) || str.contains(closeText) {
            isOpen = !isOpen
            self.kDelegate?.tapTextView(isOpen)
            self.reloadText()
        }
    }
    
}

// MARK: - Public
extension BKAttributedTextView {
    
    class func calculateHeight(text: String, closeText: String = "收起", font: UIFont, lineSpacing: CGFloat, width: CGFloat, lessLine: Int, callback: (_ closeHeight: CGFloat, _ openHeight: CGFloat) -> Void) {
        let lineHeight = lineSpacing + font.lineHeight
        // get height according font and width
        let rect = NSString(string: text + closeText).boundingRect(with: CGSize(width: width-8, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let height = rect.height
        // get line number according height and lineHeight
        let allLine = Int(floor(height/font.lineHeight))
        let openHeight = CGFloat(allLine) * lineHeight
        var closeHeight = openHeight
        if lessLine < allLine {
            closeHeight = CGFloat(lessLine) * lineHeight
        }
        callback(closeHeight, openHeight)
    }
    
}

// MARK: - Private
extension BKAttributedTextView {
    
    private func reloadTextView() {
        self.calculatePropertys()
        self.reloadText()
    }
    
    private func reloadText() {
        if kAllLine > lessLine && !isOpen {
            self.closeTextAction()
        } else {
            self.openTextAction(isOpen: isOpen)
        }
    }
    
    private func openTextAction(isOpen: Bool) {
        let result = isOpen ? allText + closeText : allText
        let attributedString = NSMutableAttributedString(string: result, attributes: kAttributs)
        attributedString.addAttribute(.paragraphStyle, value: kParagraph, range: NSRange(location: 0, length: allText.count))
        
        if result.contains(closeText) {
            let linkRange = NSRange(location: result.count - closeText.count, length: closeText.count)
            attributedString.addAttribute(.link, value: kClickUrlString, range: linkRange)
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: linkColor,
                .underlineColor: linkColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            linkTextAttributes = linkAttributes
        }
        
        attributedText = attributedString
        self.kDelegate?.textViewHeightDidChanged(kOpenHeight)
    }
    
    private func closeTextAction() {
        let preLessLineText = preLessLineString()
        // cut the same text as openText, then + openText
        let startIndex = preLessLineText.index(preLessLineText.endIndex, offsetBy: -(openText.count+2))
        let endIndex = preLessLineText.endIndex
        let range = startIndex ..< endIndex
        let needShowText = preLessLineText.replacingCharacters(in: range, with: openText)
        
        let attributedString = NSMutableAttributedString(string: needShowText, attributes: kAttributs)
        attributedString.addAttribute(.paragraphStyle, value: kParagraph, range: NSRange(location: 0, length: needShowText.count))
        
        let linkRange = NSRange(location: needShowText.count - openText.count, length: openText.count)
        attributedString.addAttribute(.link, value: kClickUrlString, range: linkRange)
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: linkColor,
            .underlineColor: linkColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        linkTextAttributes = linkAttributes
        attributedText = attributedString
        self.kDelegate?.textViewHeightDidChanged(kCloseHeight)
    }
    
    private func calculatePropertys() {
        kFont = kAttributs[.font] as? UIFont ?? .systemFont(ofSize: 16)
        font = kFont
        kLineHeight = kParagraph.lineSpacing + kFont.lineHeight
        text = allText
        // get height according font and width
        let height = sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        // get line number according height and lineHeight
        kAllLine = Int(floor(height/kFont.lineHeight))
        kOpenHeight = CGFloat(kAllLine) * kLineHeight
        if kAllLine > lessLine {
            kCloseHeight = CGFloat(lessLine) * kLineHeight
        } else {
            kCloseHeight = kOpenHeight
        }
    }
    
    private func preLessLineString() -> String {
        let attributedString = NSMutableAttributedString(string: allText, attributes: kAttributs)
        let ctFrameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        // here add 8 spacing to width for calculate
        let containerFrame = CGRect(x: 0, y: 0, width: frame.size.width-8, height: CGFloat.greatestFiniteMagnitude)
        let path = CGPath(rect: containerFrame, transform: nil)
        let ctFrame = CTFramesetterCreateFrame(ctFrameSetter, CFRange(location: 0, length: 0), path, nil)
        let lines: NSArray = CTFrameGetLines(ctFrame)
        // length of the first less lines
        var preLessLineLength = 0.0
        for i in 0..<lessLine {
            let lineRange = CTLineGetStringRange(lines[i] as! CTLine)
            preLessLineLength += Double(lineRange.length)
        }
        // get the first less lines of string
        let index = allText.index(allText.startIndex, offsetBy: Int(preLessLineLength))
        let lineString = allText[...index]
        return String(lineString)
    }
    
}

extension BKAttributedTextView: UITextViewDelegate {
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == kClickUrlString {
            isOpen = !isOpen
            self.kDelegate?.tapTextView(isOpen)
            self.reloadText()
            return false
        }
        return true
    }
    
}
