//
//  BaseModel.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import HandyJSON

/// HandyJSON的基类
class BaseModel: HandyJSON {
    
    required init() { }
    
    func mapping(mapper: HelpingMapper) { // 自定义解析规则,日期数字颜色,如果要指定解析格式,子类实现重写此方法即可
        //        mapper <<<
        //            date <-- CustomDateFormatTransform(formatString: "yyyy-MM-dd")
        //
        //        mapper <<<
        //            decimal <-- NSDecimalNumberTransform()
        //
        //        mapper <<<
        //            url <-- URLTransform(shouldEncodeURLString: false)
        //
        //        mapper <<<
        //            data <-- DataTransform()
        //
        //        mapper <<<
        //            color <-- HexColorTransform()
    }
    
}
