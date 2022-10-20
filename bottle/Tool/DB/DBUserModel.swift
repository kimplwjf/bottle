//
//  DBUserModel.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/9/20.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import WCDBSwift

enum UserState: Int {
    case normal = 0
    case deleted = -1
}

// MARK: - 用户登录model
final class DBUserModel: BaseModel,TableCodable,Codable {
    
    /**
     * 已存入 DBUserModel 数据库表的字段, 时间:2022.10.17
     *
     * email:         账号
     * pwd:           密码
     * nickname:      用户名
     * userId:        用户id
     * sex:           性别 1=男 2=女
     * province:      省份
     * city:          城市
     * area:          区域
     * state:         是否注销 0=正常 -1=已注销
     */
    var email: String = ""
    var pwd: String = ""
    var nickname: String = ""
    var userId: Int = 0
    var sex: Int = 1
    var province: String = ""
    var city: String = ""
    var area: String = ""
    var state: Int = 0
    
    /**** 分隔线 - 以下字段不写入数据库表 ****/
    var sexType: SexType {
        return SexType(rawValue: sex) ?? .man
    }
    
    var _state: UserState {
        get { return UserState(rawValue: state) ?? .normal }
        set { state = newValue.rawValue }
    }
    /**** 分隔线 - 以上字段不写入数据库表 ****/
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = DBUserModel
        static let objectRelationalMapping = TableBinding(DBUserModel.CodingKeys.self)
        
        case email
        case pwd
        case nickname
        case userId
        case sex
        case province
        case city
        case area
        case state
        
        static var columnConstraintBindings: [DBUserModel.CodingKeys: ColumnConstraintBinding]? {
            return [
                .email: .init(defaultTo: ""),
                .pwd: .init(defaultTo: ""),
                .nickname: .init(defaultTo: ""),
                .userId: .init(isPrimary: true, defaultTo: 0),
                .sex: .init(defaultTo: 1),
                .province: .init(defaultTo: ""),
                .city: .init(defaultTo: ""),
                .area: .init(defaultTo: ""),
                .state: .init(defaultTo: 0)
            ]
        }
        
        static var indexBindings: [IndexBinding.Subfix: IndexBinding]? {
            return ["_uniqueIndex": .init(isUnique: true, indexesBy: userId)]
        }
    }
    
    /// 用于定义是否使用自增的方式插入
    var isAutoIncrement: Bool = true
    /// 用于获取自增插入后的主键值
    var lastInsertedRowID: Int64 = 0
    
}
