//
//  UIImage+BKExt.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/28.
//  Copyright © 2020 WJF. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 生成渐变色Image
extension UIImage {
    
    enum GradientType: Int {
        case leftToRight = 0 // default
        case topToBottom
    }
    
    /// 获得渐变效果image
    ///
    /// - Parameters:
    ///   - size: 图片size
    ///   - colors: 颜色
    /// - Returns: 渐变图片
    static func bk_gradient(gradientType: GradientType = .leftToRight, size: CGSize, colors: [UIColor], locations: [CGFloat] = [0.0, 1.0]) -> UIImage? {
        // Turn the colors into CGColors
        let cgcolors = colors.map { $0.cgColor }
        
        // Begin the graphics context
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        // If no context was retrieved, then it failed
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // From now on, the context gets ended if any return happens
        defer { UIGraphicsEndImageContext() }
        
        // Create the Coregraphics gradient
        var _locations: [CGFloat] = locations
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgcolors as NSArray as CFArray, locations: &_locations) else { return nil }
        
        var start: CGPoint = .zero
        var end: CGPoint = .zero
        
        switch gradientType {
        case .leftToRight:
            start = CGPoint(x: 0, y: 0)
            end = CGPoint(x: size.width, y: 0)
        case .topToBottom:
            start = CGPoint(x: 0, y: 0)
            end = CGPoint(x: 0, y: size.height)
        }
        // Draw the gradient
        context.drawLinearGradient(gradient, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        
        // Generate the image (the defer takes care of closing the context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 获得从左到右颜色渐变效果
    ///
    /// - Parameters:
    ///   - bounds: 图片frame
    ///   - colors: 左右的颜色
    ///   - locations: Point
    /// - Returns: 渐变图片
    static func bk_gradientImage(with bounds: CGRect, colors: [UIColor], locations: [NSNumber]?) -> UIImage? {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        // This makes it horizontal
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
        
    }
    
}

// MARK: - 生成纯色Image
extension UIImage {
    
    /// 颜色生成图片
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 图片size
    /// - Returns: 返回一个纯色的图片
    static func bk_fill(_ color: UIColor, size: CGSize = CGSize(width: 10.0, height: 10.0)) -> UIImage? {
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        UIGraphicsBeginImageContext(rect.size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        defer { UIGraphicsEndImageContext() }
        
        context.setFillColor(color.cgColor)
        
        context.fill(rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 生成纯色的带边框、圆角的图片
    ///
    /// - Parameters:
    ///   - color: 图片颜色
    ///   - size: 图片size
    ///   - radius: 圆角半径
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    /// - Returns: 一张纯色的带边框、圆角的图片
    static func bk_fill(_ color: UIColor, size: CGSize = CGSize(width: 10.0, height: 10.0), radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        var image = UIImage.bk_fill(color, size: size)
        image = image?.bk_cornerBorder(radius: radius, borderWidth: borderWidth, borderColor: borderColor)
        return image
    }
    
    /// 生成纯色的带圆角的图片
    ///
    /// - Parameters:
    ///   - color: 图片颜色
    ///   - size: 图片size
    ///   - radius: 圆角半径
    /// - Returns: 一张纯色的带圆角的图片
    static func bk_fill(_ color: UIColor, size: CGSize = CGSize(width: 10.0, height: 10.0), radius: CGFloat) -> UIImage? {
        var image = UIImage.bk_fill(color, size: size)
        image = image?.bk_drawRound(radius: radius, size)
        return image
    }
    
    static func bk_originImage(image: UIImage, scaleSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let minSize: CGFloat = min(size.width, size.height)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: minSize/2).addClip()
        image.draw(in: rect)
        guard let _image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return _image
    }
    
}

// MARK: - 图片圆角
extension UIImage {
    
    /// 图片绘制圆角
    ///
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - sizetoFit: 图片size
    /// - Returns: 返回一个带圆角的图片
    func bk_drawRound(radius: CGFloat, _ sizetoFit: CGSize) -> UIImage? {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        guard let currentContext = context else { return self}
        
        defer {
            UIGraphicsEndImageContext();
        }
        
        let size = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: size).cgPath
        currentContext.addPath(path);
        currentContext.clip()
        
        self.draw(in: rect)
        currentContext.drawPath(using: .fillStroke)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 图片绘制圆角边框(设置大边框、圆形不建议使用这个方法)
    ///
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - borderWidth: 边框宽度
    ///   - borderColor: 边框颜色
    /// - Returns: 带边框的圆角图片
    func bk_cornerBorder(radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
                
        let newSize = CGSize(width: self.size.width + 2*borderWidth, height: self.size.height + 2*borderWidth)
        let newRadius = newSize.height / (size.height / radius)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: newSize), cornerRadius: newRadius)
        borderColor.set()
        path.fill()
        
        let imageOrigin = CGPoint(x: borderWidth, y: borderWidth)
        let clipPath = UIBezierPath(roundedRect: CGRect(origin: imageOrigin, size: size), cornerRadius: radius)
        clipPath.addClip()
        
        draw(in: CGRect(origin: imageOrigin, size: CGSize(width: newSize.width-imageOrigin.x, height: newSize.height-imageOrigin.y)))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage
    }
    
    // MARK: - 图片（UIImage）添加任意圆角
    /// 图片（UIImage）添加任意圆角
    /// - Parameter roundingCorners: 圆角数组，如，[.topLeft, .bottomLeft]，左边圆角
    /// - sizeToFit: 装载图片的UI控件size。不传默认图片的size。如果图片和控件的size一样，可以不传。
    func bk_freeRoundingCorners(_ roundingCorners: UIRectCorner,
                                radi: CGFloat = .zero,
                                _ sizeToFit: CGSize = .zero) -> UIImage? {
        
        var rect = CGRect(origin: .zero, size: size)
        
        if sizeToFit != .zero {
            rect = CGRect(origin: .zero, size: sizeToFit)
        }
        
        var radiiSize: CGSize = CGSize(width: 0, height: 0)
        if radi == .zero {
            radiiSize = CGSize(width: rect.height/2, height: rect.height/2)
            if rect.width > rect.height {
                radiiSize = CGSize(width: rect.height/2, height: rect.height/2)
            } else if rect.width < rect.height {
                radiiSize = CGSize(width: rect.width/2, height: rect.width/2)
            }
        } else {
            radiiSize = CGSize(width: radi, height: radi)
        }
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        guard let currentContext = context else { return self}
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        let bezier = UIBezierPath(roundedRect: rect, byRoundingCorners: roundingCorners, cornerRadii: radiiSize)
        
        let path = bezier.cgPath
        
        currentContext.addPath(path)
        
        currentContext.clip()
        
        self.draw(in: rect)
        
        currentContext.drawPath(using: .fillStroke)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage
    }
    
}

extension UIImage {
    
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    
    func rounded(with color: UIColor, width: CGFloat) -> UIImage? {
        let bleed = breadthRect.insetBy(dx: -width, dy: -width)
        UIGraphicsBeginImageContextWithOptions(bleed.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(
            x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : 0,
            y: isPortrait  ? ((size.height-size.width)/2).rounded(.down) : 0),
                                                         size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: bleed.size)).addClip()
        var strokeRect =  breadthRect.insetBy(dx: -width/2, dy: -width/2)
        strokeRect.origin = CGPoint(x: width/2, y: width/2)
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: strokeRect.insetBy(dx: width/2, dy: width/2))
        color.set()
        let line = UIBezierPath(ovalIn: strokeRect)
        line.lineWidth = width
        line.stroke()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

// MARK: - 压缩、裁剪、拼接
extension UIImage {
    
    // MARK: - 图片缩放成指定尺寸(多余部分自动删除)
    func bk_scaled(to newSize: CGSize) -> UIImage {
        let aspectWidth = newSize.width / size.width
        let aspectHeight = newSize.height / size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        var scaledImageRect: CGRect = .zero
        scaledImageRect.size.width = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x = (newSize.width - size.width*aspectRatio) / 2.0
        scaledImageRect.origin.y = (newSize.height - size.height*aspectRatio) / 2.0
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    // MARK: - 图片裁剪成指定比例(多余部分自动删除)
    func bk_crop(ratio: CGFloat) -> UIImage {
        var newSize: CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        } else {
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
        
        var rect: CGRect = .zero
        rect.size.width = size.width
        rect.size.height = size.height
        rect.origin.x = (newSize.width - size.width) / 2.0
        rect.origin.y = (newSize.height - size.height) / 2.0
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    // MARK: - 压缩图片大小
    static func bk_compress(_ image: UIImage, toByte maxLength: Int = 64 * 1024) -> UIImage {
        PPP("原图大小:\(image.kilobytesSize)KB")
        var compression: CGFloat = 1
        guard var data = image.jpegData(compressionQuality: compression),
            data.count > maxLength else { return image }
        
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = image.jpegData(compressionQuality: compression)!
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        var resultImage: UIImage = UIImage(data: data)!
        if data.count < maxLength { return resultImage }
        
        var lastDataLength: Int = 0
        while data.count > maxLength && data.count != lastDataLength {
            lastDataLength = data.count
            let ratio: CGFloat = CGFloat(maxLength) / CGFloat(data.count)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio) / 2.5),
                                      height: Int(resultImage.size.height * sqrt(ratio) / 2.5))
            PPP("sqrt(ratio): \(sqrt(ratio)); size: \(size)")
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            data = image.jpegData(compressionQuality: compression)!
        }
        PPP("压缩后图大小:\(resultImage.kilobytesSize)KB")
        return resultImage
    }
    
    func bk_compressSize(with maxSize: Int) -> Data? {
        // 先判断当前质量是否满足要求，不满足再进行压缩
        guard var finallImageData = jpegData(compressionQuality: 1.0) else { return nil }
        if finallImageData.count/1024 <= maxSize {
            return finallImageData
        }
        // 先调整分辨率
        var defaultSize = CGSize(width: 1024, height: 1024)
        guard let compressImage = self.bk_scaleSize(defaultSize), let compressImageData = compressImage.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        finallImageData = compressImageData
        
        // 保存压缩系数
        var compressionQualityArray = [CGFloat]()
        let avg: CGFloat = 1.0 / 250
        var value = avg
        var i: CGFloat = 250.0
        repeat {
            i -= 1
            value = i * avg
            compressionQualityArray.append(value)
        } while i >= 1
        
        // 调整大小，压缩系数数组compressionQualityArr是从大到小存储
        guard let halfData = halfFuntion(array: compressionQualityArray, image: compressImage, sourceData: finallImageData, maxSize: maxSize) else {
            return nil
        }
        finallImageData = halfData
        // 如果还是未能压缩到指定大小，则进行降分辨率
        while finallImageData.count == 0 {
            // 每次降100分辨率
            if defaultSize.width - 100 <= 0 || defaultSize.height - 100 <= 0 {
                break
            }
            defaultSize = CGSize(width: defaultSize.width - 100, height: defaultSize.height - 100)
            guard let lastValue = compressionQualityArray.last,
                let newImageData = compressImage.jpegData(compressionQuality: lastValue),
                let tempImage = UIImage(data: newImageData),
                let tempCompressImage = tempImage.bk_scaleSize(defaultSize),
                let sourceData = tempCompressImage.jpegData(compressionQuality: 1.0),
                  let halfData = self.halfFuntion(array: compressionQualityArray, image: tempCompressImage, sourceData: sourceData, maxSize: maxSize) else {
                return nil
            }
            finallImageData = halfData
        }
        return finallImageData
    }
    
    // MARK: - 二分法
    private func halfFuntion(array: [CGFloat], image: UIImage, sourceData: Data, maxSize: Int) -> Data? {
        var tempFinallImageData = sourceData
        var finallImageData = Data()
        var start = 0
        var end = array.count - 1
        var index = 0
        
        var difference = Int.max
        while start <= end {
            index = start + (end - start) / 2
            guard let data = image.jpegData(compressionQuality: array[index]) else {
                return nil
            }
            tempFinallImageData = data
            let sizeOrigin = tempFinallImageData.count
            let sizeOriginKB = sizeOrigin / 1024
            if sizeOriginKB > maxSize {
                start = index + 1
            } else if sizeOriginKB < maxSize {
                if maxSize - sizeOriginKB < difference {
                    difference = maxSize - sizeOriginKB
                    finallImageData = tempFinallImageData
                }
                if index <= 0 {
                    break
                }
                end = index - 1
            } else {
                break
            }
        }
        return finallImageData
    }
    
    // MARK: - 裁剪图片
    func bk_crop(rect: CGRect) -> UIImage {
        
        let x = rect.origin.x * kScreenScale
        let y = rect.origin.y * kScreenScale
        let w = rect.size.width * kScreenScale
        let h = rect.size.height * kScreenScale
        
        let pointRect = CGRect(x: x, y: y, width: w, height: h)
        let resImageRef: CGImage? = self.cgImage
        let newImageRef: CGImage? = resImageRef?.cropping(to: pointRect)
        guard let _newImageRef = newImageRef else { return UIImage() }
        let newImage = UIImage(cgImage: _newImageRef, scale: kScreenScale, orientation: self.imageOrientation)
        return newImage
        
    }
    
    // MARK: - 拼接图片
    // 拼2张图
    static func bk_combinTwo(image1: UIImage, image2: UIImage, offsetY: CGFloat = 0, withShareQR: Bool = false) -> UIImage {
        
        let w = max(image1.size.width, image2.size.width)
        let h = image1.size.height + image2.size.height
        let offScreenSize = CGSize(width: w, height: h)
        
        UIGraphicsBeginImageContextWithOptions(offScreenSize, false, 0)
        let rect1 = CGRect(x: 0, y: 0, width: w, height: image1.size.height)
        image1.draw(in: rect1)
        
        let rect2 = CGRect(x: !withShareQR ? 0 : (w-image2.size.width)/2, y: rect1.height+offsetY, width: !withShareQR ? w : image2.size.width, height: image2.size.height)
        image2.draw(in: rect2)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
        
    }
    
    // 拼3张图
    static func bk_combinThree(image1: UIImage, image2: UIImage, offsetY2: CGFloat = 0, image3: UIImage, withShareQR: Bool = false) -> UIImage {
        
        let max1 = max(image1.size.width, image2.size.width)
        let w = max(max1, image3.size.width)
        let h = image1.size.height + image2.size.height + image3.size.height
        let offScreenSize = CGSize(width: w, height: h)
        
        UIGraphicsBeginImageContextWithOptions(offScreenSize, false, 0)
        let rect1 = CGRect(x: 0, y: 0, width: w, height: image1.size.height)
        image1.draw(in: rect1)
        
        let rect2 = CGRect(x: 0, y: rect1.height+offsetY2, width: w, height: image2.size.height)
        image2.draw(in: rect2)
        
        let rect3 = CGRect(x: !withShareQR ? 0 : (w-image3.size.width)/2, y: rect1.height+offsetY2+rect2.height, width: !withShareQR ? w : image3.size.width, height: image3.size.height)
        image3.draw(in: rect3)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
        
    }
    
}

// MARK: - 移除背景色
extension UIImage {
    
    /// 将白色背景变透明的UIImage
    func bk_removeWhiteBg() -> UIImage? {
        let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]
        return bk_removeBackground(colorMasks: colorMasking)
    }
    
    /// 将黑色背景变透明的UIImage
    func bk_removeBlackBg() -> UIImage? {
        let colorMasking: [CGFloat] = [0, 32, 0, 32, 0, 32]
        return bk_removeBackground(colorMasks: colorMasking)
    }
    
    func bk_transparentColor(colorMasking: [CGFloat]) -> UIImage? {
        if let rawImageRef = self.cgImage {
            UIGraphicsBeginImageContext(self.size)
            if let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking) {
                let context: CGContext = UIGraphicsGetCurrentContext()!
                context.translateBy(x: 0.0, y: self.size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                context.draw(maskedImageRef, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
                let result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return result
            }
        }
        return nil
    }
    
    /// 移除UIImage的背景色
    ///
    /// - Parameters:
    ///   - colorMasks: RGB start/end components
    /// - Returns: 新的UIImage
    func bk_removeBackground(colorMasks: [CGFloat]) -> UIImage? {
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        // make sure image has no alpha channel
        let rFormat = UIGraphicsImageRendererFormat()
        rFormat.opaque = true
        let renderer = UIGraphicsImageRenderer(size: self.size, format: rFormat)
        let noAlphaImage = renderer.image { context in
            self.draw(at: .zero)
        }
        
        let noAlphaCGRef = noAlphaImage.cgImage
        guard let maskedImage = noAlphaCGRef?.copy(maskingColorComponents: colorMasks) else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }
        context.saveGState()
        context.translateBy(x: 0, y: imageRect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(maskedImage, in: imageRect)
        context.restoreGState()
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
    
}

// MARK: - 添加透明度
extension UIImage {
    
    func applying(alpha: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        // For iOS10 or later you can use UIGraphicsImageRenderer
        if #available(iOS 10, *) {
            let format = imageRendererFormat
            format.opaque = false
            return UIGraphicsImageRenderer(size: size, format: format).image { context in
                context.cgContext.scaleBy(x: 1, y: -1)
                context.cgContext.translateBy(x: .zero, y: -size.height)
                context.cgContext.setBlendMode(.multiply)
                context.cgContext.setAlpha(alpha)
                context.cgContext.draw(cgImage, in: .init(origin: .zero, size: size))
            }
        } else {
            // For older iOS versions you need to use UIGraphicsBeginImageContextWithOptions
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: .zero, y: -size.height)
            context.setBlendMode(.multiply)
            context.setAlpha(alpha)
            context.draw(cgImage, in: .init(origin: .zero, size: size))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
}

// MARK: - Private
extension UIImage {
    
    // MARK: - 调整图片分辨率/尺寸（等比例缩放）
    private func bk_scaleSize(_ newSize: CGSize) -> UIImage? {
        let heightScale = size.height / newSize.height
        let widthScale = size.width / newSize.width
        
        var finallSize = CGSize(width: size.width, height: size.height)
        if widthScale > 1.0 && widthScale > heightScale {
            finallSize = CGSize(width: size.width / widthScale, height: size.height / widthScale)
        } else if heightScale > 1.0 && widthScale < heightScale {
            finallSize = CGSize(width: size.width / heightScale, height: size.height / heightScale)
        }
        UIGraphicsBeginImageContext(CGSize(width: Int(finallSize.width), height: Int(finallSize.height)))
        self.draw(in: CGRect(x: 0, y: 0, width: finallSize.width, height: finallSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

// MARK: - Public
extension UIImage {
    
    /// 修改图片颜色
    func bk_tintImage(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0.0)
        let context = UIGraphicsGetCurrentContext()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let context = context {
            context.setBlendMode(.sourceAtop)
        }
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    /// 修正图片方向
    var fixOrientationImage: UIImage {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
}

// MARK: - 链接转图片
extension UIImage {
    
    static func bk_urlToImage(_ url: String?) -> UIImage? {
        guard let _url = URL(string: url), let image = try? UIImage(url: _url) else {
            return nil
        }
        return image
    }
    
}
