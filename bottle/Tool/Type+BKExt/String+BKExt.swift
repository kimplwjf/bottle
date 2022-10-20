//
//  String+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

protocol RandomNumType {
    associatedtype Element
    func random() -> Element
}

extension String {
    struct Success {
        static let save = "保存成功"
        static let upload = "上传成功"
        static let export = "导出成功"
        static let modify = "修改成功"
        static let delete = "删除成功"
        static let quit = "退出成功"
        static let join = "加入成功"
        static let bind = "绑定成功"
        static let unbind = "解绑成功"
        static let apply = "报名成功"
        static let transfer = "转让成功"
        static let dissolve = "解散成功"
        static let clock = "打卡成功"
        static let share = "分享成功"
        static let release = "发布成功"
        static let signIn = "签到成功"
        static let send = "发送成功"
        static let copy = "复制成功"
    }
    /// 输入有误,请重新输入
    static let inputError = "输入有误,请重新输入"
    /// 填写不完整
    static let incompleteInfo = "填写不完整"
    /// 没有找到相关内容
    static let emptyContent = "没有找到相关内容"
    /// 无法访问相机
    static let canNotVisitCamera = "无法访问相机"
    /// 无法访问相册,保存失败
    static let canNotVisitPhoto = "无法访问相册,保存失败"
    /// 手机号码格式错误
    static let mobileFormatError = "手机号码格式错误"
    /// 身份证号校验错误
    static let idCardVerifyError = "身份证号校验错误"
    /// 验证码填写错误
    static let verifyCodeError = "验证码填写错误"
    /// 请更新至最新版本App使用
    static let pleaseUpdateApp = "请升级最新版本App使用"
}

// MARK: - 提取年月日
extension String {
    
    var year: String {
        return self.subStringPrefix(to: 4)
    }
    
    var month: String {
        return self.subString(start: 5, length: 2)
    }
    
    var day: String {
        return self.subString(start: 8, length: 2)
    }
    
    var mmdd: String {
        return self.subString(start: 5, length: 5)
    }
    
    var formatTime: String {
        var newTime = self
        if self.contains("月"), let monthIndex = self.firstIndex(of: "月") {
            let index1 = self.index(monthIndex, offsetBy: -2)
            let index2 = self.index(monthIndex, offsetBy: -1)
            let str1 = String(self[index1])
            let str2 = String(self[index2])
            if str1 == "0" {
                let month = str1 + str2 + "月"
                let newMonth = month.subStringSuffix(from: 1)
                newTime = newTime.replacingOccurrences(of: month, with: newMonth)
            }
        }
        if self.contains("日"), let dayIndex = self.firstIndex(of: "日") {
            let index1 = self.index(dayIndex, offsetBy: -2)
            let index2 = self.index(dayIndex, offsetBy: -1)
            let str1 = String(self[index1])
            let str2 = String(self[index2])
            if str1 == "0" {
                let day = str1 + str2 + "日"
                let newDay = day.subStringSuffix(from: 1)
                newTime = newTime.replacingOccurrences(of: day, with: newDay)
            }
        }
        return newTime
    }
    
}

// MARK: - String扩展
extension String {
    
    var length: Int {
        return self.utf16.count
    }
    
    // let emoji = “😆😆😆😆😆😆”
    // emoji.length // return 12
    
    /**
     //字符串范围截取
     let num = "123.45"
     let deRange = num.range(of: ".")
     
     //截取小数点前字符(不包含小数点)  123
     let wholeNumber = num.prefix(upTo: deRange!.lowerBound)
     //截取小数点后字符(不包含小数点) 45
     let backNumber = num.suffix(from: deRange!.upperBound)
     //截取小数点前字符(包含小数点) 123.
     let wholeNumbers = num.prefix(upTo: deRange!.upperBound)
     //截取小数点后字符(包含小数点) .45
     let backNumbers = num.suffix(from: deRange!.lowerBound)
     */
    
    var urlEncode: String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    /// 去掉所有空格
    var removeAllSpace: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    var lastK: String {
        return self.subString(start: self.count - 1, length: 1)
    }
    
    var firstK: String {
        return self.subString(start: 0, length: 1)
    }
    
    /// 空字符串变为 nil
    var nilIfEmpty: String? {
        self.isBlank() ? nil : self
    }
    
    /// 字符竖排
    var toVertical: String {
        var new: String = ""
        for chat in self {
            new.append(chat)
            new.append("\n")
        }
        return new
    }
    
    /// 截取range字符(不包含range)之前的所有字符
    func prefixUpTo(range: String) -> String {
        if let _range = self.range(of: range) {
            let newString = self.prefix(upTo: _range.lowerBound)
            return String(newString)
        } else {
            return self
        }
    }
    
    /// 截取range字符(包含range)之后的所有字符
    func suffixFrom(range: String) -> String {
        if let _range = self.range(of: range) {
            let newString = self.suffix(from: _range.lowerBound)
            return String(newString)
        } else {
            return self
        }
    }
    
    /// 判断字符串是否是空白
    /// 空格、换行符都会判断为空白
    /// ""  -> true
    /// " "  -> true
    /// "\n"  -> true
    /// "\n "  -> true
    ///
    /// - Returns: true or false
    func isBlank() -> Bool {
        var tmpStr = self
        //去掉空格&换行
        tmpStr = tmpStr.trimmingCharacters(in: .whitespacesAndNewlines)
        return tmpStr.isEmpty
    }
    
    /** 截取字符串 */
    func indexOf(char: Character) -> Int {
        return firstIndex(of: char)!.utf16Offset(in: self)
    }
    
    /** 从0开始计算,截取包含start且长度为length的所有字符,获得新字符串 */
    func subString(start: Int, length: Int = -1) -> String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy: start)
        let en = self.index(st, offsetBy: len)
        return String(self[st..<en])
    }
    
    /** 从0开始计算,截取包含from之后的所有字符,获得新字符串 */
    func subStringSuffix(from: Int) -> String {
        if from < self.count + 1 {
            return String(suffix(from: index(startIndex, offsetBy: from)))
        } else {
            return self
        }
    }
    
    /** 从前面截取,从0开始计算,包含through,获得新字符串 */
    func subStringPrefix(through: Int) -> String {
        if through < self.count + 1 {
            return String(prefix(through: index(startIndex, offsetBy: through)))
        } else {
            return self
        }
    }
    
    /** 从前面截取,从0开始计算,不包含to,获得新字符串 */
    func subStringPrefix(to: Int) -> String {
        if to < self.count + 1 {
            return String(prefix(upTo: index(startIndex, offsetBy: to)))
        } else {
            return self
        }
    }
    
    /// 从某个位置开始截取
    /// - Parameters:
    ///   - index: 起始位置
    subscript(from index: Int) -> String {
        guard index >= 0 && index < count else { return self }
        let startIndex = self.index(startIndex, offsetBy: index)
        let subString = self[startIndex..<endIndex]
        return String(subString)
    }
    
    /// 从零开始截取到某个位置
    /// - Parameters:
    ///   - index: 达到某个位置
    subscript(to index: Int) -> String {
        guard index >= 0 && index < count else { return self }
        let endIndex = self.index(startIndex, offsetBy: index)
        let subString = self[startIndex..<endIndex]
        return String(subString)
    }
    
    /// 某个范围内截取
    /// - Parameters:
    ///   - range: 范围
    subscript<R>(range range: R) -> String where R: RangeExpression, R.Bound == Int {
        let range = range.relative(to: Int.min..<Int.max)
        guard range.lowerBound >= 0,
                let lowerIndex = self.index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
                let upperIndex = self.index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex) else { return self }
        return String(self[lowerIndex..<upperIndex])
    }
    
    /** 汉字转拼音 */
    func transformToPinYin() -> String {
        let mutableString = NSMutableString(string: self)
        //把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        //去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        
        let string = String(mutableString)
        //去掉空格
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    /** Range转换为NSRange */
    func toNSRange(from range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16),
            let to = range.upperBound.samePosition(in: utf16) else { return NSMakeRange(0, self.count) }
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from), length: utf16.distance(from: from, to: to))
    }
    
    /** NSRange转换为Range */
    func toRange(from nsRange: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) else { return nil }
        return from..<to
    }
    
    /** 获得string内容高度 */
    func stringHeightWith(fontSize: CGFloat, width: CGFloat, lineSpace: CGFloat) -> CGFloat {
        
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle.copy()]
        let text = self as NSString
        let rect = text.boundingRect(with: size, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: attributes, context: nil)
        
        return rect.size.height
    }
    
    func heightWithFont(font: CGFloat = 15, fixedWidth: CGFloat) -> CGFloat {
        guard self.count > 0 && fixedWidth > 0 else {
            return 0
        }
        let size = CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))
        let text = self as NSString
        let rect = text.boundingRect(with: size, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)], context: nil)
        
        return rect.size.height
    }
    
    func widthWithFont(font: CGFloat = 15, fixedHeight: CGFloat) -> CGFloat {
        guard self.count > 0 else {
            return 0
        }
        
        let size = CGSize(width: CGFloat(MAXFLOAT), height: fixedHeight)
        let text = self as NSString
        let rect = text.boundingRect(with: size, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)], context: nil)
        
        return rect.size.width
    }
    
    func urlScheme(scheme: String) -> URL? {
        if let url = URL(string: self) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = scheme
            return components?.url
        }
        return nil
    }
    
}

// MARK: - md5
extension String {
    /// 32位 小写
    var md5ForLower32Bit: String {
        return md5()
    }
    /// 32位 大写
    var md5ForUpper32Bit: String {
        return md5().uppercased()
    }
}

// MARK: - String+RegularExpression
extension String {
    
    /// 通过正则表达式匹配替换
    func replacingStringOfRegularExpression(pattern: String, template: String) -> String {
        var content = self
        do {
            let range = NSRange(location: 0, length: content.count)
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            content = expression.stringByReplacingMatches(in: content, options: .reportCompletion, range: range, withTemplate: template)
        } catch {
            PPP("regular expression error")
        }
        return content
    }
    
    /// 通过正则表达式匹配返回结果
    func matches(pattern: String) -> [NSTextCheckingResult] {
        do {
            let range = NSRange(location: 0, length: count)
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matchResults = expression.matches(in: self, options: .reportCompletion, range: range)
            return matchResults
        } catch {
            PPP("regular expression error")
        }
        return []
    }
    
    /// 通过正则表达式返回第一个匹配结果
    func firstMatch(pattern: String) -> NSTextCheckingResult? {
        do {
            let range = NSRange(location: 0, length: count)
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let match = expression.firstMatch(in: self, options: .reportCompletion, range: range)
            return match
            
        } catch {
            PPP("regular expression error")
        }
        return nil
    }
    
}

// MARK: - NSAttributedString扩展
extension NSAttributedString {
    
    /// 根据最大宽计算高度（便捷调用)
    func heightForLabel(width: CGFloat) -> CGFloat {
        let textSize = textSizeForLabel(width: width, height: CGFloat(Float.greatestFiniteMagnitude))
        return textSize.height
    }
    
    /// 根据最大高计算宽度（便捷调用)
    func widthForLabel(height: CGFloat) -> CGFloat {
        let textSize = textSizeForLabel(width: CGFloat(Float.greatestFiniteMagnitude), height: height)
        return textSize.width
    }
    
    /// 计算宽度和高度（核心)
    func textSizeForLabel(width: CGFloat, height: CGFloat) -> CGSize {
        let defaultOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let maxSize = CGSize(width: width, height: height)
        let rect = self.boundingRect(with: maxSize, options: defaultOptions, context: nil)
        let textWidth: CGFloat = CGFloat(Int(rect.width) + 1)
        let textHeight: CGFloat = CGFloat(Int(rect.height) + 1)
        return CGSize(width: textWidth, height: textHeight)
    }
    
}

// MARK: - 正则封装成=~运算符判断
struct RegexHelper {
    
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(_ input: String) -> Bool {
        let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
    
}

precedencegroup MatchPrecedence {
    associativity: none
    higherThan: DefaultPrecedence
}

infix operator =~: MatchPrecedence

func =~(lhs: String, rhs: String) -> Bool {
    do {
        return try RegexHelper(rhs).match(lhs)
    } catch _ {
        return false
    }
}

extension String {
    
    /// 验证手机号正则
    func isValidPhone() -> Bool {
        let phone = self.trimmingCharacters(in: .whitespaces)
        let regex = "^1(3\\d|4[5-9]|5[0-35-9]|6[567]|7[0-8]|8\\d|9[0-35-9])\\d{8}$"
        return phone =~ regex
    }
    
    /// 验证身份证正则
    func isValidIDCard() -> Bool {
        // 判断是否为空
        if self.count <= 0 {
            return false
        }
        // 判断是否是18位,末尾是否是X
        let identityCard = self.trimmingCharacters(in: .whitespaces)
        let regex = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = predicate.evaluate(with: identityCard)
        if !result {
            return false
        }
        // 判断生日是否合法
        let dateStr: String = self.subString(start: 6, length: 8)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if formatter.date(from: dateStr) == nil {
            return false
        }
        // 判断校验位
        if self.count == 18 {
            // 将前17位加权因子保存在数组里
            let idCardWi: [String] = ["7", "9", "10", "5", "8", "4", "2", "1", "6", "3", "7", "9", "10", "5", "8", "4", "2"]
            // 这是除以11后，可能产生的11位余数、验证码，也保存成数组
            let idCardY: [String] = ["1", "0", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
            // 用来保存前17位各自乖以加权因子后的总和
            var idCardWiSum: Int = 0
            for i in 0..<17 {
                idCardWiSum += Int(self.subString(start: i, length: 1))!*Int(idCardWi[i])!
            }
            // 计算出校验码所在数组的位置
            let idCardMod: Int = idCardWiSum % 11
            // 得到最后一位身份证号码
            let idCardLast: String = self.lastK
            // 如果等于2，则说明校验码是10，身份证号码最后一位应该是X
            if idCardMod == 2 {
                if idCardLast == "X" || idCardLast == "x" {
                    return true
                } else {
                    return false
                }
            } else {
                // 用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
                if Int(idCardLast) == Int(idCardY[idCardMod]) {
                    return true
                } else {
                    return false
                }
            }
        }
        return false
    }
    
    /// 验证邮箱正则
    func isValidEmail() -> Bool {
        let email = self.trimmingCharacters(in: .whitespaces)
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return email =~ regex
    }
    
    /// 验证用户名昵称正则
    func isValidUserName(from: Int = 2, to: Int = 11) -> Bool {
        let userName = self.trimmingCharacters(in: .whitespaces)
        let regex = "^[\u{4e00}-\u{9fa5}_a-zA-Z0-9]{\(from),\(to)}$"
        return userName =~ regex
    }
    
    /// 验证银行卡号正则
    func isValidBankCard() -> Bool {
        for char in self {
            if char == "_" {
                return false
            }
        }
        
        var result = ""
        let pattern = "[0-9]{15,18}"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let res = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count))
        
        for checkingRes in res {
            result = result + (self as NSString).substring(with: checkingRes.range)
        }
        return result == self
    }
    
    /// 验证密码正则
    func isValidPassword() -> Bool {
        let pattern = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,18}$" //"^[@A-Za-z0-9!#\\$%\\^&*\\.~_]{6,20}$"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)
        if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) {
            return true
        }
        return false
    }
    
    /// 是否是合法账号(只含有数字、字母、下划线、@、. 位数1到30位)
    func isValidAccount() -> Bool {
        let regex = "^[a-zA-Z0-9_.@]{1,30}$"
        return self =~ regex
    }
    
    /// 是否是合法密码(只含有数字、字母)
    func isValidPassword(from: Int, to: Int) -> Bool {
        let regex = "^[0-9A-Za-z]{\(from),\(to)}$"
        return self =~ regex
    }
    
    /// 是否是有效中文姓名
    func isValidChineseName() -> Bool {
        let regex = "^[\u{4e00}-\u{9fa5}]+(·[\u{4e00}-\u{9fa5}]+)*$"
        return self =~ regex
    }
    
    /// 是否是有效英文姓名
    func isValidEnglishName() -> Bool {
        let regex = "^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"
        return self =~ regex
    }
    
    /// 验证是否是纯数字
    func isValidAllNumber() -> Bool {
        let regex = "^[0-9]+$"
        return self =~ regex
    }
    
    /// 验证是否只有数字和小数点
    func isValidNumberAndDot() -> Bool {
        let regex = "^[0-9.]+$"
        return self =~ regex
    }
    
    /// 验证指定位数纯数字
    func isValidNumberEqual(to count: Int) -> Bool {
        let regex = "^[0-9]{\(count)}$"
        return self =~ regex
    }
    
    /// 验证是否小于等于指定位数的纯数字
    func isValidNumbersLessThanOrEqual(to count: Int) -> Bool {
        let regex = "^[0-9]{0,\(count)}$"
        return self =~ regex
    }
    
    /// 验证全部是空格
    func isValidAllEmpty() -> Bool {
        let regex = "^\\s*$"
        return self =~ regex
    }
    
    /// 验证小数点后位数
    func isValidDecimalPointCount(_ count: Int) -> Bool {
        let regex = "^(([1-9]{1}\\d*)|([0]{1}))(\\.(\\d){0,\(count)})?$"
        return self =~ regex
    }
    
    /// 验证是否是有效提现金额
    func isValidWithdraw() -> Bool {
        let regex = "^\\d+(\\.\\d{1,2})?$"
        return self =~ regex
    }
    
    /// 加星号隐藏显示(默认隐藏电话中间4位)
    func bk_addAsterisk(loc: Int = 3, len: Int = 4) -> String {
        var asterisk: String = ""
        for _ in 0..<len {
            asterisk.append("*")
        }
        return (self as NSString).replacingCharacters(in: NSMakeRange(loc, len), with: asterisk)
    }
    
}
