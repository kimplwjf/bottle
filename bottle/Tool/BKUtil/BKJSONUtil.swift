//
//  BKJSONUtil.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/27.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit
import HandyJSON

/** HandyJSON封装 */
class BKJSONUtil: NSObject {
    
    /**
     * JSONString转对象
     */
    static func jsonStringToModel(_ jsonStr: String, _ modelType: HandyJSON.Type) -> BaseModel {
        if jsonStr == "" || jsonStr.count == 0 {
            #if DEBUG || RUNNING
            PPP("\(#function): 字符串为空")
            #endif
            return BaseModel()
        }
        return modelType.deserialize(from: jsonStr) as! BaseModel
        
    }
    
    /**
     * JSON数组转对象数组
     */
    static func jsonArrayToModel(_ jsonArrayStr: String, _ modelType: HandyJSON.Type) -> [BaseModel] {
        if jsonArrayStr == "" || jsonArrayStr.count == 0 {
            #if DEBUG || RUNNING
            PPP("\(#function): 字符串为空")
            #endif
            return []
        }
        var modelArray : [BaseModel] = []
        let data = jsonArrayStr.data(using: .utf8)
        let peoplesArray = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [AnyObject]
        for people in peoplesArray! {
            modelArray.append(dictionaryToModel(people as! [String: Any], modelType))
        }
        return modelArray
        
    }
    
    /**
     * 字典转对象
     */
    static func dictionaryToModel(_ dictionary: [String: Any], _ modelType: HandyJSON.Type) -> BaseModel {
        if dictionary.count == 0 {
            #if DEBUG || RUNNING
            PPP("\(#function): 字典为空")
            #endif
            return BaseModel()
        }
        return modelType.deserialize(from: dictionary) as! BaseModel
    }
    
    /**
     * 字典转JSON数据
     */
    static func dictionaryToJSONData(_ dictionary: [String: Any]) -> Data? {
        if !(JSONSerialization.isValidJSONObject(dictionary)) {
            PPP("\(#function): 不能转换")
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        return data
    }
    
    /**
     * 数组转JSONString
     */
    static func arrayToJSONString(_ array: [Any]) -> String? {
        if !(JSONSerialization.isValidJSONObject(array)) {
            PPP("\(#function): 不能转换")
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: array, options: [])
        let jsonStr = String(data: data!, encoding: .utf8)
        return jsonStr
    }
    
    /**
     * 数组转JSON数据
     */
    static func arrayToJSONData(_ array: [Any]) -> Data? {
        if !(JSONSerialization.isValidJSONObject(array)) {
            PPP("\(#function): 不能转换")
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: array, options: [])
        PPP("JSON数据的大小: \(data?.count ?? 0)字节")
        return data
    }
    
    /**
     * 对象数组转JSON数据
     */
    static func modelArrayToJSONData(_ models: [HandyJSON]) -> Data {
        var arr: [[String: Any]] = [[String: Any]]()
        models.forEach { model in
            guard let dic = model.toJSON() else { return }
            arr.append(dic)
        }
        if let data = self.arrayToJSONData(arr) {
            return data
        } else {
            return Data()
        }
    }
    
}
