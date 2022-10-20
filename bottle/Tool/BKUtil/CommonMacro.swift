//
//  CommonMacro.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

// MARK: - 判断是那种设备
/**
 4  4s  320*480
 */
func iPhone4_4s() -> Bool {
    return kScreenHeight == 480.0
}

/**
 5  5s SE  320*568
 */
func iPhone5_5s_SE() -> Bool {
    return kScreenHeight == 568.0
}

/**
 6  6s  7 8 SE2  375*667
 */
func iPhone6_6s_7_8_SE2() -> Bool {
    return kScreenHeight == 667.0
}

/**
 6p  6sp 7p 8p  414*736
 */
func iPhone6p_6sp_7p_8p() -> Bool {
    return kScreenHeight == 736.0
}

/**
 x xs 11pro  375*812
*/
func iPhoneX_XS_11pro() -> Bool {
    return kScreenHeight == 812.0
}

/**
 xr xsMax 11 11proMax  414*896
*/
func iPhoneXr_xsMax_11_11proMax() -> Bool {
    return kScreenHeight == 896.0
}

/**
 12mini 13mini  360*780
 */
func iPhone12mini_13mini() -> Bool {
    return kScreenHeight == 780.0
}

/**
 12 12pro 13 13pro 14  390*844
 */
func iPhone12_12pro_13_13pro_14() -> Bool {
    return kScreenHeight == 844.0
}

/**
 12proMax 13proMax 14p  428*926
 */
func iPhone12proMax_13proMax_14p() -> Bool {
    return kScreenHeight == 926.0
}

/**
 14pro  393*852
 */
func iPhone14pro() -> Bool {
    return kScreenHeight == 852.0
}

/**
 14proMax  430*932
 */
func iPhone14proMax() -> Bool {
    return kScreenHeight == 932.0
}

// MARK: - 屏幕、导航栏、Tabbar尺寸
let kScreenBounds = UIScreen.main.bounds

/// 屏幕大小
let kScreenSize: CGSize = kScreenBounds.size
/// 屏幕宽度
let kScreenWidth: CGFloat = kScreenSize.width
/// 屏幕高度
let kScreenHeight: CGFloat = kScreenSize.height
/// 屏幕分辨率
let kScreenScale: CGFloat = UIScreen.main.scale
/// 屏幕比例
let kScreenRatio: CGFloat = kScreenWidth / kScreenHeight
/// 屏幕高度大于等于812
let kScreenH_greaterThanX: Bool = kScreenHeight >= 812.0
/// 屏幕高度小于等于667
let kScreenH_lessThan6: Bool = kScreenHeight <= 667.0
/// 屏幕宽度大于375
let kScreenW_greaterThanX: Bool = kScreenWidth > 375.0
/// 屏幕rect
let kScreenRect: CGRect = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)

// MARK: - 适配机型(以 375*812 为基准)
let offset5 = (kScreenHeight*0.006).rounded()
let offset10 = (kScreenHeight*0.012).rounded()
let offset15 = (kScreenHeight*0.018).rounded()
let offset20 = (kScreenHeight*0.025).rounded()
let offset25 = (kScreenHeight*0.031).rounded()
let offset30 = (kScreenHeight*0.037).rounded()
let offset35 = (kScreenHeight*0.0432).rounded()
let offset40 = (kScreenHeight*0.049).rounded()
let offset45 = (kScreenHeight*0.056).rounded()
let offset50 = (kScreenHeight*0.062).rounded()
let offset60 = (kScreenHeight*0.074).rounded()
let offset70 = (kScreenHeight*0.0865).rounded()
let offset80 = (kScreenHeight*0.099).rounded()
let offset90 = (kScreenHeight*0.111).rounded()
let offset100 = (kScreenHeight*0.123).rounded()
let offset120 = (kScreenHeight*0.147).rounded()

/// 安全区域
var safeAreaEdgeInsets: UIEdgeInsets {
    if #available(iOS 11.0, *) {
        return (UIApplication.shared.delegate as? AppDelegate)?.window?.safeAreaInsets ?? .zero
    } else {
        return .zero
    }
}

/// 是否刘海屏
var isFullScreen: Bool {
    if #available(iOS 11.0, *) {
        guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
            return false
        }
        if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
            return true
        }
    }
    return false
}

/// 状态栏默认高度，刘海屏44，普通屏20。
var kStatusBarHeight: CGFloat {
    if iPhoneXr_xsMax_11_11proMax() {
        return 48
    } else if iPhone12_12pro_13_13pro_14() || iPhone12proMax_13proMax_14p() {
        return 47
    } else if iPhone12mini_13mini() {
        return 50
    } else if iPhone14pro() || iPhone14proMax() {
        return 59
    } else {
        return isFullScreen ? 44 : 20
    }
}

/// 获取导航栏高度，刘海屏88，普通屏64。
var kNavigationBarHeight: CGFloat {
    if iPhoneXr_xsMax_11_11proMax() {
        return 88 + 4
    } else if iPhone12_12pro_13_13pro_14() || iPhone12proMax_13proMax_14p() {
        return 88 + 3
    } else if iPhone12mini_13mini() {
        return 88 + 6
    } else if iPhone14pro() || iPhone14proMax() {
        return 88 + 15
    } else {
        return isFullScreen ? 88 : 64
    }
}

/// 获取Tabbar默认高度，刘海屏83，普通屏49。
var kTabBarHeight: CGFloat {
    return isFullScreen ? 83 : 49
}

/// 获取屏幕底部胡子高度，刘海屏34，普通屏没有胡子0。
var kBottomSafeHeight: CGFloat {
    return isFullScreen ? 34 : 0
}

// MARK: - app版本&设备系统版本
let infoDictionary            = Bundle.main.infoDictionary
/** App名称 */
let kAppName: String          = infoDictionary!["CFBundleDisplayName"] as! String
/** App版本号 */
let kAppVersion: String       = infoDictionary!["CFBundleShortVersionString"] as! String
/** Appbuild版本号 */
let kAppBuildVersion: String  = infoDictionary!["CFBundleVersion"] as! String
/** app bundleId */
let kAppBundleId: String      = infoDictionary!["CFBundleIdentifier"] as! String

/** 平台名称（iphonesimulator 、 iphone）*/
let kPlatformName: String     = infoDictionary!["DTPlatformName"] as! String
/** iOS系统版本 */
let kiOSVersion: String       = UIDevice.current.systemVersion
/** 系统名称+版本，e.g. @"iOS 12.1" */
let kOSType: String           = UIDevice.current.systemName + UIDevice.current.systemVersion

// MARK: - 比较版本大小
/// 比较版本大小
///
/// - Parameters:
///   - v1: 版本1 - 新版本
///   - v2: 版本2 - 当前版本
/// - Returns: true: v1>v2  false: v1<=v2
func kCompareVersion(_ v1: String, _ v2: String) -> Bool {
    if v1.isEmpty && v2.isEmpty || v1.isEmpty {
        return false
    }
    if v2.isEmpty {
        return true
    }
    let arr1 = v1.components(separatedBy: ".")
    let arr2 = v2.components(separatedBy: ".")
    // 取count少的
    let minCount = arr1.count > arr2.count ? arr2.count : arr1.count
    var value1: Int = 0
    var value2: Int = 0
    for i in 0..<minCount {
        if !arr1[i].isValidAllNumber() || !arr2[i].isValidAllNumber() {
            return false
        }
        value1 = Int(arr1[i])!
        value2 = Int(arr2[i])!
        
        if value1 > value2 { // v1版本字段大于v2版本字段
            return true
        } else if value1 < value2 { // v1版本字段小于v2版本字段
            return false
        }
    }
    // 字段多的版本高于字段少的版本
    if arr1.count > arr2.count {
        return true
    } else if arr1.count <= arr2.count {
        return false
    }
    return false
}

// MARK: - 颜色相关
func kRGBColor(_ R: CGFloat, _ G: CGFloat, _ B: CGFloat) -> UIColor {
    return kRGBAColor(R: R, G: G, B: B, A: 1.0)
}

func kRGBAColor(R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) -> UIColor {
    return UIColor(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: A)
}

// MARK: - CGRect布局
func kCGRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: w, height: h)
}

/// 计算缩放后的大小
/// - Parameters:
///   - imageSize: 图片原始大小
///   - maxSize: 最大范围
///   - minSize: 最小范围
/// - Returns: 缩放后的大小
func calculateScaleSize(imageSize: CGSize,
                        maxSize: CGSize = CGSize(width: kScreenWidth, height: kScreenHeight),
                        minSize: CGSize = CGSize(width: 50, height: 50)) -> CGSize {
    let maxWidth = maxSize.width
    let maxHeight = maxSize.height
    let minWidth = minSize.width
    let minHeight = minSize.height
    
    let imageWidth = imageSize.width
    let imageHeight = imageSize.height
    
    let imageRatio = imageHeight / imageWidth
    
    if imageRatio >= (maxHeight / minWidth) {
        return CGSize(width: minWidth, height: maxHeight)
    } else if imageRatio <= (minHeight / maxWidth) {
        return CGSize(width: maxWidth, height: minHeight)
    } else {
        let maxRatio = maxHeight / maxWidth
        let minRatio = minHeight / minWidth
        if imageRatio >= minRatio && imageHeight > maxHeight {
            return CGSize(width: imageWidth / imageHeight * maxHeight, height: maxHeight)
        } else if imageRatio < maxRatio && imageWidth > maxWidth {
            return CGSize(width: maxWidth, height: imageHeight / imageWidth * maxWidth)
        } else if imageRatio >= maxRatio && imageWidth < minWidth {
            return CGSize(width: minWidth, height: imageHeight / imageWidth * minWidth)
        } else if imageRatio < maxRatio && imageHeight < minHeight {
            return CGSize(width: imageWidth / imageHeight * minHeight, height: minHeight)
        } else {
            return imageSize
        }
    }
}

// MARK: - 打印日志
func PPP<T>(_ msg: T, file: String = #file, function: String = #function, lineNum: Int = #line) {
    let url: NSURL = NSURL.fileURL(withPath: file) as NSURL
    print("<\(kAppName)>-<\(kAppVersion)>-<DEBUG>\(url.lastPathComponent!):\(lineNum)->\(msg)")
}

// MARK: - 获取所有可使用的字体名
func PPPFamilyNames() {
    let familyNames = UIFont.familyNames
    PPP("可使用的字体名:\n")
    let fontNames = familyNames.map { UIFont.fontNames(forFamilyName: $0) }
    fontNames.forEach { (name) in
        PPP("\(name)\n")
    }
}

// MARK: - 打印属性列表
func PPPIvarList(_ classString: String) {
    PPP("\n\n///////////// \(classString)  IvarList /////////////\n")
    var count : UInt32 = 0
    let list = class_copyIvarList(NSClassFromString(classString), &count)
    for i in 0..<Int(count) {
        let ivar = list![i]
        let name = ivar_getName(ivar)
        let type = ivar_getTypeEncoding(ivar)
        print(String(cString: name!), "<---->", String(cString: type!), "\n")
    }
}

func PPPPropertyList(_ classString: String) {
    PPP("\n\n///////////// \(classString)  PropertyList /////////////\n")
    var count : UInt32 = 0
    let list = class_copyPropertyList(NSClassFromString(classString), &count)
    for i in 0..<Int(count) {
        let property = list![i]
        let name = property_getName(property)
        let type = property_getAttributes(property)
        print(String(cString: name), "<---->", String(cString: type!), "\n")
    }
}

/// 判断一个类是否是自定义类
///
/// - Parameters:
///   - cls: AnyClass
/// - Returns: 自定义类返回true,系统类返回false
func checkCustomClass(for cls: AnyClass) -> Bool {
    let bundle = Bundle(for: cls)
    return bundle == .main
}

// MARK: - 常用
/** 除/取模结果
 *
 * print(1/4) >>> 0
 * print(1%4) >>> 1
 * print(2/4) >>> 0
 * print(2%4) >>> 2
 * print(6/4) >>> 1
 * print(6%4) >>> 2
 *
 */

/** 图片展示contentMode三种常用样式
 *
 * ScaleToFill: 将图片按照整个区域进行拉伸(会破坏图片的比例)
 * ScaleAspectFit: 将图片等比例拉伸，可能不会填充满整个区域
 * ScaleAspectFill: 将图片等比例拉伸，会填充整个区域，但是会有一部分过大而超出整个区域
 *
 */

/** UIViewController的生命周期
 *
 * 1、+(void)initialize: 函数并不会每次创建对象都调用，只有在第一次初始化的时候才会调用，再次创建将不会调用initialize方法。
 * 2、init方法和initCoder方法相似，只是被调用的环境不一样。如果用代码初始化，会调用init方法，从nib文件或者归档(xib、storyboard)进行初始化会调用initCoder。initCoder是NSCoding协议中的方法，NSCoding是负责编码解码，归档处理的协议。
 * 3、loadView: 是开始加载view的起始方法，除非手动调用，否则在ViewController的生命周期中只调用一次。
 * 4、viewDidLoad: 类成员对象和变量的初始化我们都会放在这个方法中，在创建类后无论视图展现还是消失，这个方法也只会在布局时调用一次。
 * 5、viewWillAppear: 在视图将要展现出来的时候调用。
 * 6、viewWillLayoutSubviews: 在将要布局子视图的时候调用。
 * 7、viewDidLayoutSubviews: 在子视图布局完成后调用。
 * 8、viewDidAppear: 视图已经出现。
 * 9、viewWillDisappear: 视图即将消失。
 * 10、viewDidDisappear: 视图已经消失。
 * 11、dealloc: ViewController被释放时调用。
 *
 */

/** 当视图被添加到父控件上时，相关的生命周期
 *
 * 1、initWithFrame
 * 2、willMoveToSuperview
 * 3、didMoveToSuperview
 * 4、willMoveToWindow
 * 5、didMoveToWindow
 * 6、layoutSubviews
 *
 */

/**
 * minimumLineSpacing: 同一个Section内部间Item的和滚动方向平行的间距
 * minimumInteritemSpacing: 同一个Section内部间Item的和滚动方向垂直的间距
 */

/**
 * setNeedsLayout：告知页面需要更新，但是不会立刻开始更新。执行后会立刻调用layoutSubviews。
 * layoutIfNeeded：告知页面布局立刻更新。所以一般都会和setNeedsLayout一起使用。如果希望立刻生成新的frame需要调用此方法，利用这点一般布局动画可以在更新布局后直接使用这个方法让动画生效。
 * layoutSubviews：系统重写布局
 * setNeedsUpdateConstraints：告知需要更新约束，但是不会立刻开始
 * updateConstraintsIfNeeded：告知立刻更新约束
 * updateConstraints：系统更新约束
 */

/**
 * setContentHuggingPriority: 设置抗拉伸优先级,优先级越高(数值越大),越不会被拉伸；优先级越低(数值越小),越容易被拉伸
 * setContentCompressionResistancePriority: 设置抗压缩优先级,优先级越高(数值越大),越不会被压缩；优先级越低(数值越小),越容易被压缩
 */
