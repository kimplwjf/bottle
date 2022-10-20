//
//  BKCodeView.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/1/27.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

protocol BKCodeProtocol {
    // 输入框
    var textField: UITextField { get }
    // 位数
    var codeNum: Int { get set }
    // 未输入的下划线颜色
    var lineColor: UIColor { get set }
    // 输入的下划线颜色
    var lineInputColor: UIColor { get set }
    // 输入错误下划线颜色
    var errorlineColor: UIColor { get set }
    // 光标颜色
    var cursorColor: UIColor { get set }
    // 文本字体大小
    var fontNum: UIFont { get set }
    // 文本颜色
    var textColor: UIColor { get set }
    
    mutating func changeCodeAttributes(lineColor: UIColor, lineInputColor: UIColor, errorlineColor: UIColor, cursorColor: UIColor, fontNum: UIFont, textColor: UIColor)
    
    mutating func changeCodeNum(num: Int)
}

struct BKCodeAttributes: BKCodeProtocol {
    var textField: UITextField = UITextField()
    var codeNum: Int = 4
    var lineColor: UIColor = .gray
    var lineInputColor: UIColor = .blue
    var errorlineColor: UIColor = .red
    var cursorColor: UIColor = .lightBlackDarkWhite
    var fontNum: UIFont = .systemFont(ofSize: 18)
    var textColor: UIColor = .lightBlackDarkWhite
}

extension BKCodeAttributes {
    
    mutating func changeCodeAttributes(lineColor: UIColor = .gray,
                                       lineInputColor: UIColor = .blue,
                                       errorlineColor: UIColor = .red,
                                       cursorColor: UIColor = .lightBlackDarkWhite,
                                       fontNum: UIFont = .systemFont(ofSize: 18),
                                       textColor: UIColor = .lightBlackDarkWhite) {
        self.lineColor = lineColor
        self.lineInputColor = lineInputColor
        self.errorlineColor = errorlineColor
        self.cursorColor = cursorColor
        self.fontNum = fontNum
        self.textColor = textColor
    }
    
    mutating func changeCodeNum(num: Int) {
        self.codeNum = num
    }
    
}

struct BKCodeLength {
    var W: CGFloat = 40.0 // 横线宽度
    var H: CGFloat = 2.0 // 横线高度
}

protocol BKCodeViewDelegate: NSObjectProtocol {
    func textField(_ textField: UITextField, text: String) -> Bool
}

class BKCodeView: UIView {
    
    typealias CodeCallback = (String) -> Void
    private var callbackText: CodeCallback?
    func bk_addCodeText(by callback: @escaping CodeCallback) {
        self.callbackText = callback
    }
    
    weak var delegate: BKCodeViewDelegate?
    
    lazy var style: BKCodeAttributes = BKCodeAttributes()
    
    lazy var textField = UITextField()
    
    lazy var lineArr: [UIView] = []
    
    lazy var labelArr: [UILabel] = []
    
    lazy var layerArr: [CALayer] = []
    
    lazy var _w: CGFloat = CGFloat()
    lazy var _h: CGFloat = CGFloat()
    
    private var errorOrClean: String = ""
    private let length: BKCodeLength
    
    init(frame: CGRect = .zero, length: BKCodeLength = BKCodeLength()) {
        self.length = length
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.createTextField()
        self.createInputLabel()
        self.createLineView()
        
    }
    
}

// MARK: - Create UI
extension BKCodeView {
    
    fileprivate func createTextField() {
        _w = self.frame.size.width
        _h = self.frame.size.height
        textField = style.textField
        textField.delegate = self
        textField.becomeFirstResponder()
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
        self.addSubview(textField)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEditingEvents)
    }
    
    fileprivate func createLineView() {
        for num in 0..<style.codeNum {
            let x1 = CGFloat(num)*length.W
            let x2 = style.codeNum != 1 ? CGFloat(num)*(_w - CGFloat(style.codeNum) * length.W)/(CGFloat(style.codeNum - 1)) : 0
            let lineView = UIView(frame: CGRect(x: x1+x2, y: _h - length.H, width: length.W, height: length.H))
            lineView.backgroundColor = style.lineColor
            self.addSubview(lineView)
            lineArr.append(lineView)
        }
    }
    
    fileprivate func createInputLabel() {
        for num in 0..<style.codeNum {
            let x1 = CGFloat(num)*length.W
            let x2 = style.codeNum != 1 ? CGFloat(num)*(_w - CGFloat(style.codeNum) * length.W)/(CGFloat(style.codeNum - 1)) : 0
            let label = UILabel(frame: CGRect(x: x1+x2, y: 0, width: length.W, height: _h - length.H))
            label.textColor = style.textColor
            label.font = style.fontNum
            label.textAlignment = .center
            let path = UIBezierPath(rect: CGRect(x: (label.frame.width-2)/2, y: 5, width: 2, height: label.frame.height-10))
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.fillColor = style.cursorColor.cgColor
            self.addSubview(label)
            if num == 0 {
                lineLayer.isHidden = false
            } else {
                lineLayer.isHidden = true
            }
            label.layer.addSublayer(lineLayer)
            lineLayer.add(alphaChange(), forKey: "alpha")
            labelArr.append(label)
            layerArr.append(lineLayer)
        }
    }
    
}

// MARK: - UITextFieldDelegate代理
extension BKCodeView: UITextFieldDelegate {
    
    @objc fileprivate func textFieldDidChange(_ tf: UITextField) {
        labelArr.forEach { $0.text = nil }
        let count = textField.text?.count ?? 0
        for i in 0..<count {
            if i < labelArr.count {
                labelArr[i].isHidden = false
                labelArr[i].text = textField.text?.subString(start: i, length: 1)
            }
        }
        if errorOrClean == "error" {
            lineArr.forEach { (line) in
                line.backgroundColor = style.errorlineColor
                loadShakeAnimationForView(view: line)
            }
            
            UIView.animate(withDuration: 1.0) {
                self.lineArr.forEach { (line) in
                    line.backgroundColor = self.style.lineColor
                }
                for i in 0..<count {
                    if i < self.lineArr.count {
                        self.lineArr[i].backgroundColor = self.style.lineInputColor
                    }
                }
            }
            errorOrClean = ""
        } else {
            lineArr.forEach { (line) in
                line.backgroundColor = style.lineColor
            }
            for i in 0..<count {
                if i < lineArr.count {
                    lineArr[i].backgroundColor = style.lineInputColor
                }
            }
        }
        
        layerArr.forEach { (layer) in
            layer.isHidden = true
        }
        if count < style.codeNum {
            layerArr[count].isHidden = false
        }
        if count <= style.codeNum {
            self.callbackText?(textField.text ?? "")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let curText = textField.text ?? ""
        let newText = curText.replacingCharacters(in: curText.toRange(from: range)!, with: string)
        PPP("textField当前输入的值: \(newText)")
        
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        } else if string.isEmpty {
            return true
        } else if newText.count > style.codeNum {
            return false
        } else if (textField.text?.count)! >= style.codeNum {
            return false
        } else {
            guard let bool = self.delegate?.textField(textField, text: newText) else { return false }
            return bool
        }
    }
    
    func cleanText(errStr: String = "error") {
        errorOrClean = errStr
        BKTaskUtil.delay(0.5) {
            self.textField.text = ""
            self.textFieldDidChange(self.textField)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        textField.becomeFirstResponder()
    }
    
}

// MARK: - Animation
extension BKCodeView {
    
    public func alphaChange() -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = "opacity"
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 1.0
        animation.repeatCount = MAXFLOAT
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    public func loadShakeAnimationForView(view: UIView) {
        let layer = view.layer
        let point = layer.position
        let x = CGPoint(x: point.x + 2, y: point.y)
        let y = CGPoint(x: point.x - 2, y: point.y)
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fromValue = x
        animation.toValue = y
        animation.autoreverses = true
        animation.duration = 0.1
        animation.repeatCount = 1
        layer.add(animation, forKey: nil)
    }
    
}
