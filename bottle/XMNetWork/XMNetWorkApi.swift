//
//  XMNetWorkConstant.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

enum XMNetKey: String {
    case code
    case msg
    case data
}

let XMNetCodeKey   = XMNetKey.code.rawValue
let XMNetMsgKey    = XMNetKey.msg.rawValue
let XMNetDataKey   = XMNetKey.data.rawValue
let XMNetWorkError = "当前网络不可用,请检查你的网络或刷新重试"
let XMNetBusy      = "加载失败,请稍后重试"

/******** 接口 ********/
struct XMApiPort {
    
    // MARK: - BaseApi
    struct BaseApi {
        /// 发送短信验证码
        static let smsCode = "/sms/code/lite"
        /// 获取七牛上传token
        static let qiniuToken = "/config/qiniu/upload/token"
        /// 获取在线参数
        static let onlineConfigAll = "/api/common/online/config/all-map"
        /// 检查App
        static let checkApp = "/app/check"
        /// 上传日志通知
        static let logUpload = "/log/app/upload/notify"
        /// 批量上传日志通知
        static let batchLogUpload = "/log/app/upload/notify/batch"
    }
    
    // MARK: - 埋点
    struct EventTrack {
        /// 上传用户跑步行为事件
        static let uploadEvent = "/api/common/upload/event"
    }
    
    // MARK: - 登录注册
    struct LoginRegister {
        /// 手机验证码登录
        static let login = "/user/login/mobile/code/lite"
    }
    
    // MARK: - 跑步
    struct Run {
        /// 分页获取跑步记录列表
        static let runPage_size = "/run/page/lite"
        /// 获取跑步记录详情
        static let runDetail = "/run/detail"
        /// 更新跑步记录轨迹图
        static let runUpdateTrackImage = "/run/update/track/image"
        /// APP上传跑步记录通知
        static let runAppUpload = "/api/user/run/upload/app"
    }
    
    // MARK: - 我的
    struct Mine {
        /// [我的]获取用户摘要信息
        static let userSummary = "/api/user/summary"
    }
    
}
