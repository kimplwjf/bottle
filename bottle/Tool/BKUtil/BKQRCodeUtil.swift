//
//  BKQRCodeUtil.swift
//  TestDemoSwift
//
//  Created by 王锦发 on 2020/3/27.
//  Copyright © 2020 WJF. All rights reserved.
//

import UIKit

struct BKQRCodeUtil {
    
    enum QRCodeLogoType: Int {
        case `default` = 0 // 默认无圆角logo
        case radius        // 圆角带白边logo
        case round         // 圆形logo
    }
    
    // MARK: - 生成二维码
    ///
    /// - Parameters:
    ///   - formdata: 需要生成二维码的String数据
    ///   - codeSize: 二维码图片的size
    ///   - logo: 二维码中心logo(为nil时无logo)
    /// - Returns: 二维码
    static func generateQRCode(formdata: String,
                               codeSize: CGFloat,
                               logo: UIImage?,
                               logoType: QRCodeLogoType = .default) -> UIImage {
        
        //创建一个二维码的滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        
        // 恢复滤镜的默认属性
        qrFilter?.setDefaults()
        
        // 将字符串转换成
        let infoData = formdata.data(using: .utf8)
        
        // 通过KVC设置滤镜inputMessage数据
        qrFilter?.setValue(infoData, forKey: "inputMessage")
        
        /**
         * L水平 7%的字码可被修正
         * M水平 15%的字码可被修正
         * Q水平 25%的字码可被修正
         * H水平 30%的字码可被修正
         */
        // 设置生成的二维码的容错率
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        
        // 获得滤镜输出的图像
        let outputImage = qrFilter?.outputImage
        
        // 设置缩放比例
        let scale = codeSize / outputImage!.extent.size.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let transformImage = qrFilter!.outputImage!.transformed(by: transform)
        
        // 获取Image
        let image = UIImage(ciImage: transformImage)

        // 无logo时  返回普通二维码image
        guard var QRCodeLogo = logo else { return image }
        
        // logo尺寸与frame
        let logoWidth = image.size.width/4
        let logoFrame = CGRect(x: (image.size.width - logoWidth)/2, y: (image.size.width - logoWidth)/2, width: logoWidth, height: logoWidth)
        
        // 绘制二维码
        UIGraphicsBeginImageContextWithOptions(image.size, false, kScreenScale)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        switch logoType {
        case .radius:
            QRCodeLogo = QRCodeLogo.bk_cornerBorder(radius: 4, borderWidth: 4, borderColor: .white)!
        case .round:
            QRCodeLogo = QRCodeLogo.bk_freeRoundingCorners(.allCorners)!
        case .default:
            break
        }
        
        // 绘制中间logo
        QRCodeLogo.draw(in: logoFrame)
        
        //返回带有logo的二维码
        let QRCodeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return QRCodeImage!
        
    }
    
}
