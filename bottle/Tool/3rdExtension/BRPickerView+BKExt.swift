//
//  BRPickerView+BKExt.swift
//  dysaidao
//
//  Created by 王锦发 on 2020/5/11.
//  Copyright © 2020 王锦发. All rights reserved.
//

import Foundation

typealias AddressTuple = (province: BRProvinceModel, city: BRCityModel, area: BRAreaModel)
typealias BRStringResultCallBack = (_ index: Int, _ value: String) -> Void
typealias BRAddressResultCallBack = (AddressTuple) -> Void
typealias BRDateResultCallBack = (_ date: Date, _ value: String) -> Void

class BKBRPickerView: NSObject {
    
    deinit {
        PPP("BKBRPickerView>>>>>>已被释放")
    }
    
    static let shared = BKBRPickerView()
    
    private override init() { }
    
    enum PickerStyle {
        case `default`
        case train
        
        var style: (radius: Int, titleBarColor: UIColor, doneBtnTitle: String, btnTitleFont: CGFloat, selectRowTextColor: UIColor) {
            switch self {
            case .default: return (10, .lightWhiteDark27, "确定", 18, .dark)
            case .train: return (0, .lightGray229Dark33, "完成", 16, .lightBlack51DarkLight230)
            }
        }
    }
    
    private var _pickerStyle: PickerStyle = .default
    
    /// 选择器样式
    lazy var pickerStyle: BRPickerStyle = {
        let style = BRPickerStyle()
        style.topCornerRadius = _pickerStyle.style.radius
        style.pickerTextFont = .systemFont(ofSize: 18)
        style.pickerColor = .lightWhiteDark27
        style.pickerTextColor = XMColor.gray153
        style.selectRowTextColor = _pickerStyle.style.selectRowTextColor
        style.selectRowTextFont = .systemFont(ofSize: 22)
        style.separatorColor = .dark.withAlphaComponent(0.05)
        style.selectRowColor = .dark.withAlphaComponent(0.05)
        style.titleBarColor = _pickerStyle.style.titleBarColor
        style.cancelBtnTitle = "取消"
        style.cancelTextFont = .systemFont(ofSize: _pickerStyle.style.btnTitleFont)
        style.cancelTextColor = _pickerStyle == .default ? .lightBlackDarkWhite : .light
        style.doneBtnTitle = _pickerStyle.style.doneBtnTitle
        style.doneTextFont = .systemFont(ofSize: _pickerStyle.style.btnTitleFont)
        style.doneTextColor = _pickerStyle == .default ? .dark : .light
        return style
    }()
    
    // MARK: - 字符串选择器
    @discardableResult
    static func bk_showStrPicker(_ pickerMode: BRStringPickerMode = .componentSingle,
                                 pickerStyle: PickerStyle = .default,
                                 dataSourceArr: [Any] = ["男", "女"],
                                 title: String? = nil,
                                 selectIndex: Int = 0,
                                 isAutoSelect: Bool = true,
                                 handler: @escaping BRStringResultCallBack) -> BRStringPickerView {
        let picker = BRStringPickerView(pickerMode: pickerMode)
        picker.dataSourceArr = dataSourceArr
        picker.title = title
        picker.isAutoSelect = isAutoSelect
        picker.selectIndex = selectIndex
        picker.resultModelBlock = { resultModel in
            guard let _index = resultModel?.index, let _value = resultModel?.value else {
                handler(0, "")
                return
            }
            PPP("字符串选择器 >>> \(_index); \(_value)")
            handler(_index, _value)
        }
        BKBRPickerView.shared._pickerStyle = pickerStyle
        picker.pickerStyle = BKBRPickerView.shared.pickerStyle
        picker.show()
        return picker
    }
    
    // MARK: - 地址选择器
    @discardableResult
    static func bk_showAddressPicker(_ pickerMode: BRAddressPickerMode = .area,
                                     pickerStyle: PickerStyle = .default,
                                     title: String = "请选择地址",
                                     selectIndexs: [Int] = [18, 0, 3],
                                     isAutoSelect: Bool = true,
                                     handler: @escaping BRAddressResultCallBack) -> BRAddressPickerView {
        let picker = BRAddressPickerView(pickerMode: pickerMode)
        picker.title = title
        picker.isAutoSelect = isAutoSelect
        picker.selectIndexs = selectIndexs.map { NSNumber(value: $0) }
        picker.resultBlock = { (province, city, area) in
            guard let p = province, let c = city, let a = area else {
                handler((BRProvinceModel(), BRCityModel(), BRAreaModel()))
                return
            }
            PPP("地址选择器 >>> 索引:【\(p.index) \(c.index) \(a.index)】;地址:【\(p.name ?? "") \(c.name ?? "") \(a.name ?? "")】")
            handler((p, c, a))
        }
        BKBRPickerView.shared._pickerStyle = pickerStyle
        picker.pickerStyle = BKBRPickerView.shared.pickerStyle
        picker.show()
        return picker
    }
    
    // MARK: - 时间选择器
    @discardableResult
    static func bk_showDatePicker(_ pickerMode: BRDatePickerMode = .date,
                                  pickerStyle: PickerStyle = .default,
                                  title: String = "请选择生日",
                                  selectDate: Date? = nil,
                                  minDate: Date? = nil,
                                  maxDate: Date? = nil,
                                  isAutoSelect: Bool = true,
                                  handler: @escaping BRDateResultCallBack) -> BRDatePickerView {
        let picker = BRDatePickerView(pickerMode: pickerMode)
        picker.isAutoSelect = isAutoSelect
        picker.selectDate = selectDate
        picker.minDate = minDate
        picker.maxDate = maxDate
        picker.title = title
        picker.resultBlock = { (date, value) in
            guard let _date = date, let dateStr = value else {
                handler(Date(), "")
                return
            }
            PPP("时间选择器 >>> \(_date); \(dateStr)")
            handler(_date, dateStr)
        }
        BKBRPickerView.shared._pickerStyle = pickerStyle
        picker.pickerStyle = BKBRPickerView.shared.pickerStyle
        picker.show()
        return picker
    }
    
}

extension BRStringPickerView {
    var _pickerView: UIPickerView? {
        for sub in self.subviews {
            if let _sub = sub as? UIPickerView {
                return _sub
            }
        }
        return nil
    }
}

extension BRAddressPickerView {
    var _pickerView: UIPickerView? {
        for sub in self.subviews {
            if let _sub = sub as? UIPickerView {
                return _sub
            }
        }
        return nil
    }
}

extension BRDatePickerView {
    var _pickerView: UIPickerView? {
        for sub in self.subviews {
            if let _sub = sub as? UIPickerView {
                return _sub
            }
        }
        return nil
    }
}
