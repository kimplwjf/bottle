//
//  DBCollectModel.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/19.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit
import WCDBSwift

final class DBCollectModel: BaseModel,TableCodable {
    
    /**
     * 已存入 DBCollectModel 数据库表的字段, 时间:2022.10.19
     *
     * id:      自增id
     * userId:  用户id
     * collect: 收藏语录
     */
    var id: Int = 0
    var userId: Int = 0
    var collect: String = ""
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = DBCollectModel
        static let objectRelationalMapping = TableBinding(DBCollectModel.CodingKeys.self)
        
        case id
        case userId
        case collect
        
        static var columnConstraintBindings: [DBCollectModel.CodingKeys: ColumnConstraintBinding]? {
            return [
                .id: .init(isPrimary: true, isAutoIncrement: true),
                .userId: .init(defaultTo: 0),
                .collect: .init(defaultTo: "")
            ]
        }
        
        static var indexBindings: [IndexBinding.Subfix: IndexBinding]? {
            return ["_index": .init(isUnique: false, indexesBy: userId)]
        }
    }
    
    /// 用于定义是否使用自增的方式插入
    var isAutoIncrement: Bool = true
    /// 用于获取自增插入后的主键值
    var lastInsertedRowID: Int64 = 0
    
}

