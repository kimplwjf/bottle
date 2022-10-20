//
//  Date+BKExt.swift
//  diyisaidao
//
//  Created by 王锦发 on 2020/4/21.
//  Copyright © 2020 王锦发. All rights reserved.
//

import Foundation
import SwifterSwift

// MARK: - Date扩展
extension Date {
    
    enum StatType: Int {
        case week = 0
        case month
        case year
        case total
        
        var title: String {
            switch self {
            case .week: return "周"
            case .month: return "月"
            case .year: return "年"
            case .total: return "总"
            }
        }
    }
    
    enum DateTimeType {
        case hour_24
        case `default`
    }
    
    enum TimestampType {
        case second
        case millisecond
    }
    
    /// Date转化为日期字符串
    ///
    /// - Parameters:
    ///   - date: Date
    ///   - dateFormat: 格式化样式默认"yyyy-MM-dd HH:mm:ss.SSS"
    func stringBy(formatter: String = "yyyy-MM-dd HH:mm:ss.SSS") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = formatter
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    /// 获取当前是星期几
    func getWeekday(formatter: String = "周") -> String {
        let weekDays = ["日","一","二","三","四","五","六"] // [1,2,3,4,5,6,7]
        let wd = weekDays.map { formatter + $0 }
        return wd[self.weekday - 1]
    }
    
    /// 时间戳转换为Date
    static func transTimestampToDate(_ timeStamp: Int, type: TimestampType = .millisecond) -> Date {
        var _time = timeStamp
        switch type {
        case .millisecond: _time = _time/1000
        case .second: break
        }
        let date = Date(timeIntervalSince1970: TimeInterval(_time))
        return date
    }
    
    /// 获取本周第一天(默认周日为1)
    static func startWeekDay(date: Date) -> Date {
        let weekDay: Int = date.weekday
        let diffDay: Int = weekDay == 1 ? -6 : 2 - weekDay
        if diffDay == 0 {
            return date
        }
        return date.adding(.day, value: diffDay)
    }
    
    /// 获取月份的最大天数
    static func getMonthMaximum(_ year: Int, _ month: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12: return 31
        case 4, 6, 9, 11: return 30
        default: return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) ? 29 : 28
        }
    }
    
    /// 日期字符串转化为Date
    ///
    /// - Parameters:
    ///   - str: 日期字符串
    ///   - dateFormat: 格式化样式，默认为"yyyy-MM-dd HH:mm:ss"
    /// - Returns: Date
    static func dateBy(str: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "zh_CN")
        let date = dateFormatter.date(from: str)
        if date != nil {
            return date
        } else {
            dateFormatter.dateFormat = dateFormat.prefixUpTo(range: " ")
            let twelveHoursDate = dateFormatter.date(from: str.prefixUpTo(range: " "))
            return twelveHoursDate
        }
    }
    
    /// 计算两个日期的月数差
    static func dateDiffMonth(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let startStr = startDate.stringBy(formatter: "yyyy-MM-dd")
        let endStr = endDate.stringBy(formatter: "yyyy-MM-dd")
        let start = self.dateBy(str: startStr, dateFormat: "yyyy-MM-dd")
        let end = self.dateBy(str: endStr, dateFormat: "yyyy-MM-dd")
        let diff: DateComponents = calendar.dateComponents([.month], from: start!, to: end!)
        return abs(diff.month ?? 0)
    }
    
    /// 计算两个日期的天数差
    static func dateDiffDay(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let startStr = startDate.stringBy(formatter: "yyyy-MM-dd")
        let endStr = endDate.stringBy(formatter: "yyyy-MM-dd")
        let start = self.dateBy(str: startStr, dateFormat: "yyyy-MM-dd")
        let end = self.dateBy(str: endStr, dateFormat: "yyyy-MM-dd")
        let diff: DateComponents = calendar.dateComponents([.day], from: start!, to: end!)
        return abs(diff.day ?? 0)
    }
    
    /// 秒数转化为时间字符串 格式HH:mm:ss
    static func secondsToTimeString(seconds: Int, type: DateTimeType = .default) -> String {
        guard seconds > 0 else {
            return "--"
        }
        let h: Int
        // 小时计算
        switch type {
        case .hour_24: h = (seconds)%(24*3600)/3600
        case .default: h = seconds / 3600
        }
        // 分钟计算
        let m = (seconds)%3600/60
        // 秒计算
        let s = (seconds)%60
        let timeString = String(format: "%02lu:%02lu:%02lu", h, m, s)
        return timeString
    }
    
    /// 时分秒字符串转化为秒数
    static func timeStringToSeconds(_ timeStr: String) -> Int {
        if timeStr.count == 6 {
            let h = timeStr.subString(start: 0, length: 2).int!
            let m = timeStr.subString(start: 2, length: 2).int!
            let s = timeStr.subString(start: 4, length: 2).int!
            let hour: Int = h * 3600
            let min: Int = m * 60
            return hour + min + s
        } else if timeStr.count == 8 {
            let h = timeStr.subString(start: 0, length: 2).int!
            let m = timeStr.subString(start: 3, length: 2).int!
            let s = timeStr.subString(start: 6, length: 2).int!
            let hour: Int = h * 3600
            let min: Int = m * 60
            return hour + min + s
        } else {
            return 0
        }
    }
    
    /// 秒数转化为时间字符串 格式HH:mm:ss(分开获取时分秒)
    static func secondsToTimeStringPart(seconds: Int) -> (hours: String, mins: String, seconds: String) {
        // 小时计算
        let h = (seconds)%(24*3600)/3600
        // 分钟计算
        let m = (seconds)%3600/60
        // 秒计算
        let s = (seconds)%60
        return (String(format: "%02lu", h), String(format: "%02lu", m), String(format: "%02lu", s))
    }
    
    static func secondsToDateTimeString(seconds: Int) -> String {
        // 天数计算
        let d = (seconds)/(24*3600)
        // 小时计算
        let h = (seconds)%(24*3600)/3600
        // 分钟计算
        let m = (seconds)%3600/60
        // 秒计算
        let s = (seconds)%60
        let timeString = String(format: "%02lu天%02lu小时%02lu分%02lu秒", d, h, m, s)
        return timeString
    }
    
    /// 秒数转化为分秒格式
    static func transToHourMinSec(time: Int) -> String {
        var minutes = 0
        var seconds = 0
        var minutesText = ""
        var secondsText = ""
        minutes = time % 3600 / 60
        minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        seconds = time % 3600 % 60
        secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        return "\(minutesText):\(secondsText)"
    }
    
    /// 消息毫秒级时间戳格式化
    static func msgTimeFormat(_ timeStamp: Int) -> String {
        let timeInterval: TimeInterval = TimeInterval(Double(timeStamp)/1000)
        let date = Date(timeIntervalSince1970: timeInterval)
        var time = date.stringBy(formatter: "yyyy年MM月dd日 HH:mm")
        let monday = self.startWeekDay(date: Date())
        if date.isInToday {
            time = "今天" + date.stringBy(formatter: "HH:mm")
        } else if date.isInYesterday {
            time = "昨天" + date.stringBy(formatter: "HH:mm")
        } else if date.isLaterThanOrEqual(to: monday) {
            time = date.getWeekday(formatter: "星期") + " " + date.stringBy(formatter: "HH:mm")
        } else if date.isInCurrentYear {
            time = date.stringBy(formatter: "MM月dd日 HH:mm")
        }
        return time.formatTime
    }
    
    /// 时间戳展示格式化
    static func timestampFormat(_ timeStamp: Int) -> String {
        let timeInterval: TimeInterval = TimeInterval(Double(timeStamp)/1000)
        let date = Date(timeIntervalSince1970: timeInterval)
        var time = date.stringBy(formatter: "yyyy年MM月dd日 HH:mm")
        if date.isInToday {
            time = "今天" + date.stringBy(formatter: "HH:mm")
        } else if date.isInCurrentYear {
            time = date.stringBy(formatter: "MM月dd日 HH:mm")
        } else if !date.isInCurrentYear {
            time = date.stringBy(formatter: "yyyy年MM月dd日")
        }
        return time.formatTime
    }
    
}

/// 根据时间生成随机字符串
var dateRandomString: String {
    let str: String = Date().nanoStampString + UUID().uuidString + "\(TimeInterval.random(in: 0.01...10000))"
    return str.md5ForUpper32Bit
}

extension Date {
    
    /// 获取当前时间月份的最大天数
    var maxDayOfMonth: Int {
        return Date.getMonthMaximum(self.year, self.month)
    }
    
    /// 秒级时间戳
    var timeStamp: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return timeStamp
    }
    
    /// 毫秒级时间戳
    var milliStamp: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return Int(millisecond)
    }
    
    /// 纳秒级时间戳
    var nanoStamp: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let nanosecond = CLongLong(round(timeInterval*1000000000))
        return Int(nanosecond)
    }
    
    var timeStampString: String {
        return String(timeStamp)
    }
    
    var milliStampString: String {
        return String(milliStamp)
    }
    
    var nanoStampString: String {
        return String(nanoStamp)
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
}

extension Date {
    
    func equals(_ date: Date) -> Bool {
        return self.compare(date) == .orderedSame
    }
    
    func isLater(than date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
    }
    
    func isLaterThanOrEqual(to date: Date) -> Bool {
        return self.compare(date) == .orderedDescending || self.compare(date) == .orderedSame
    }
    
    func isEarlier(than date: Date) -> Bool {
        return self.compare(date) == .orderedAscending
    }
    
    func isEarlierThanOrEqual(to date: Date) -> Bool {
        return self.compare(date) == .orderedAscending || self.compare(date) == .orderedSame
    }
    
    func isSameYear(date: Date) -> Bool {
        return self.year == date.year
    }
    
    func isSameDay(date: Date) -> Bool {
        return Date.isSameDay(date: self, as: date)
    }
    
    static func isSameDay(date: Date, as compareDate: Date) -> Bool {
        let calendar = Calendar.autoupdatingCurrent
        var components = calendar.dateComponents([.era, .year, .month, .day], from: date)
        let dateOne = calendar.date(from: components)
        
        components = calendar.dateComponents([.era, .year, .month, .day], from: compareDate)
        let dateTwo = calendar.date(from: components)
        
        return (dateOne?.equals(dateTwo!))!
    }
    
}

// MARK: - Formatter
extension Formatter {
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
}
