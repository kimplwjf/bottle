//
//  WCDBManager.swift
//  dysaidao
//
//  Created by 王锦发 on 2021/9/20.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import WCDBSwift

typealias DB = WCDBManager

struct DBDataNamePath {
    static let dbName = "wcdb"
    static let dbPath = BKFilePathUtil.setupFilePath(directory: .documents, name: "/DB/\(dbName).db").path
}

enum DBTableName: String {
    case collect = "DBCollectModel" // 收集语录表
    case user = "DBUserModel" // 用户信息表
}

class WCDBManager: NSObject {
    
    static let shared = WCDBManager()
    
    var db: Database?
    
    static var dbName: String {
        return DBDataNamePath.dbName
    }
    
    private override init() {
        super.init()
        db = self.createDB()
        self.createTables()
    }
    
}

extension WCDBManager {
    
    /// 初始化数据库
    static func startSetup() {
        _ = WCDBManager.shared
    }
    
}

// MARK: - Private
extension WCDBManager {
    
    /// 创建数据库
    private func createDB() -> Database {
        PPP("数据库【\(DBDataNamePath.dbName)】路径 = \(DBDataNamePath.dbPath)")
        let db = Database(withPath: DBDataNamePath.dbPath)
        return db
    }
    
    /// 数据库与表的初始化
    private func createTables() {
        do {
            // 创建主数据库main的相关表
            try db?.run(transaction: {
                self.createTable(table: .collect, modelType: DBCollectModel.self)
                self.createTable(table: .user, modelType: DBUserModel.self)
            })
        } catch let error {
            PPP("初始化数据库及ORM对应关系建立失败\(error.localizedDescription)")
        }
    }
    
}

// MARK: - Public
extension WCDBManager {
    
    /// 创建表
    public func createTable<T: TableDecodable>(table: DBTableName, modelType: T.Type) {
        do {
            try db?.create(table: table.rawValue, of: modelType)
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
    /// 获取表行数
    public func count(table: DBTableName, on result: ColumnResultConvertible, where condition: Condition? = nil) -> Int {
        do {
            guard let count = try db?.getValue(on: result, fromTable: table.rawValue, where: condition).int64Value else { return 0 }
            return Int(count)
        } catch let error {
            PPP(error.localizedDescription)
        }
        return 0
    }
    
    /// 获取表名
    public func getTable<Root: TableCodable>(table: DBTableName, type: Root.Type) -> String {
        do {
            let name = try db?.getTable(named: table.rawValue, of: type)?.name
            return name ?? ""
        } catch let error {
            PPP(error.localizedDescription)
        }
        return ""
    }
    
    /// 获取表中不重复的列值
    public func getDistinctColumn(table: DBTableName, on result: ColumnResultConvertible, where condition: Condition? = nil) -> FundamentalColumn? {
        do {
            guard let values = try db?.getDistinctColumn(on: result, fromTable: table.rawValue, where: condition) else { return nil }
            return values
        } catch let error {
            PPP(error.localizedDescription)
        }
        return nil
    }
    
    // MARK: - 增
    /// 插入
    public func insert<T: TableEncodable>(object: T..., intoTable table: DBTableName) {
        do {
            try db?.insert(objects: object, intoTable: table.rawValue)
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
    /// 插入
    public func inserts<T: TableEncodable>(objects: [T], intoTable table: DBTableName) {
        do {
            try db?.insert(objects: objects, intoTable: table.rawValue)
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
    /// 插入或更新
    public func insertOrUpdate<T: TableEncodable>(table: DBTableName, on propertys: [PropertyConvertible]? = nil, with object: T..., where condition: Condition? = nil) {
        do {
            try db?.insertOrReplace(objects: object, on: propertys, intoTable: table.rawValue)
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
    /// 插入或更新
    public func insertOrUpdates<T: TableEncodable>(table: DBTableName, on propertys: [PropertyConvertible]? = nil, with objects: [T], where condition: Condition? = nil) {
        do {
            try db?.insertOrReplace(objects: objects, on: propertys, intoTable: table.rawValue)
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
    // MARK: - 删
    /// 删除
    public func delete(table: DBTableName, where condition: Condition? = nil) {
        do {
            try db?.delete(fromTable: table.rawValue, where: condition)
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
    // MARK: - 查
    /// 查找
    public func query<T: TableDecodable>(table: DBTableName, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil) -> T? {
        do {
            let object: T? = try db?.getObject(fromTable: table.rawValue, where: condition, orderBy: orderList)
            return object
        } catch let error {
            PPP(error.localizedDescription)
        }
        return nil
    }
    
    /// 查找
    public func querys<T: TableDecodable>(table: DBTableName, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil) -> [T] {
        do {
            guard let _db = db else { return [] }
            let objects: [T] = try _db.getObjects(fromTable: table.rawValue, where: condition, orderBy: orderList, limit: limit)
            return objects
        } catch let error {
            PPP(error.localizedDescription)
        }
        return []
    }
    
    // MARK: - 改
    /// 修改
    public func update<T: TableEncodable>(table: DBTableName, on propertys: [PropertyConvertible], with object: T, where condition: Condition? = nil) {
        do {
            try db?.update(table: table.rawValue, on: propertys, with: object, where: condition)
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
    // MARK: - 删库❌慎用
    /// 删除数据库表
    func drop(table: DBTableName) {
        do {
            try db?.drop(table: table.rawValue)
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
    /// 删除所有与该数据库相关的文件
    func removeDBFile() {
        do {
            try db?.close(onClosed: {
                try db?.removeFiles()
            })
        } catch let error {
            PPP(error.localizedDescription)
        }
    }
    
}
