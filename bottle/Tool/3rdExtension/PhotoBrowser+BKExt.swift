//
//  PhotoBrowser+BKExt.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/1/18.
//  Copyright © 2022 王锦发. All rights reserved.
//

import Foundation
import Photos
import UIKit
import ZLPhotoBrowser
import SKPhotoBrowser

typealias ImagePhotoTuple = (image: UIImage, phAsset: PHAsset)
typealias ImagePickerCallback = ([ImagePhotoTuple]) -> Void

struct PhotoBrowser {
    
    /// 选择单张图片
    static func pickerSingleImage(callback: @escaping ImagePickerCallback) {
        self.pickerImage(maxCount: 1, callback: callback)
    }
    
    /// 图片选择器
    ///
    /// - Parameters:
    ///   - maxCount: 最大选择张数
    static func pickerImage(maxCount: Int = 9, callback: @escaping ImagePickerCallback) {
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = maxCount
        config.cellCornerRadio = 5.0
        config.sortAscending = false
        config.allowSelectGif = false
        config.allowSelectVideo = false
        let sheet = ZLPhotoPreviewSheet()
        sheet.selectImageBlock = { images, phAssets, isOriginal in
            var photoTuples = [ImagePhotoTuple]()
            zip(images, phAssets).forEach {
                photoTuples.append(($0.0, $0.1))
            }
            DispatchQueue.main.async {
                callback(photoTuples)
            }
        }
        if let visibleVC = UIApplication.shared.visibleCtrl() {
            sheet.showPhotoLibrary(sender: visibleVC)
        }
    }
    
    /// 缩放图片
    /// - Parameters:
    ///   - delegate: 代理
    ///   - imgs: 图片
    ///   - index: 索引
    ///   - isShowDelete: 是否展示删除按钮
    static func zoomImage(delegate: SKPhotoBrowserDelegate? = nil, imgs: [UIImage], index: Int, isShowDelete: Bool = false) {
        let photos: [SKPhoto] = imgs.map { SKPhoto.photoWithImage($0) }
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayDeleteButton = isShowDelete
        SKPhotoBrowserOptions.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        let photoBrower = SKPhotoBrowser(photos: photos, initialPageIndex: index)
        photoBrower.delegate = delegate
        UIApplication.shared.visibleCtrl()?.present(photoBrower, animated: true)
    }
    
    /// 缩放图片
    /// - Parameters:
    ///   - delegate: 代理
    ///   - urls: 图片地址
    ///   - index: 索引
    ///   - isShowDelete: 是否展示删除按钮
    static func zoomImage(delegate: SKPhotoBrowserDelegate? = nil, urls: [String], index: Int, isShowDelete: Bool = false) {
        let photos: [SKPhoto] = urls.map { SKPhoto.photoWithImageURL($0) }
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayDeleteButton = isShowDelete
        SKPhotoBrowserOptions.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        let photoBrower = SKPhotoBrowser(photos: photos, initialPageIndex: index)
        photoBrower.delegate = delegate
        UIApplication.shared.visibleCtrl()?.present(photoBrower, animated: true)
    }
    
}
