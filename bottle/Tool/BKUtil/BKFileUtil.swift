//
//  BKFileUtil.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/6/10.
//  Copyright © 2022 王锦发. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 常用沙盒封装使用
enum AppDirectories {
    // 该目录主要存放用户产生的文件,该目录会被iTunes和iCloud同步。
    case documents
    // 用来存放默认设置或其他状态信息,该目录除Caches子目录以外会被iTunes和iCloud同步。
    case library
    // 主要存放缓存文件,比如音乐缓存,图片缓存等,用户使用过程中的缓存都可以保存在这个目录中,可用于保存可再生文件,应用程序也需要负责删除这些文件,该目录不会被iTunes和iCloud同步。
    case libraryCaches
    // Library/Preferences 存放应用偏好设置文件,该目录会被iTunes和iCloud同步。
    // 临时文件目录,在程序重新运行的时候,和开机的时候,会清空temp文件夹
    case temp
    case customPath(path: FilePathProtocol)
}

protocol FilePathProtocol {
    func filePathUrl() -> URL
    func stringPath() -> String
}

extension String: FilePathProtocol {
    func filePathUrl() -> URL {
        return URL(fileURLWithPath: self)
    }
    
    func stringPath() -> String {
        return self
    }
}

// MARK: - BKFilePathUtil
//// - Returns: URL
struct BKFilePathUtil {
    
    static func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func libraryDirectoryURL() -> URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
    }
    
    static func tempDirectoryURL() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    static func librayCachesURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    /// 获取文件路径URL
    static func getFilePath(directory: AppDirectories, folderName: String, fileName: String = "") -> URL {
        return self.setupFilePath(directory: directory, name: folderName).appendingPathComponent(fileName)
    }
    
    /// 获取文件路径URL
    static func setupFilePath(directory: AppDirectories, name: String) -> URL {
        return getURL(for: directory).appendingPathComponent(name)
    }
    
    private static func getURL(for directory: AppDirectories) -> URL {
        switch directory {
        case .documents:
            return documentsDirectoryURL()
        case .library:
            return libraryDirectoryURL()
        case .libraryCaches:
            return librayCachesURL()
        case .temp:
            return tempDirectoryURL()
        case .customPath(let path):
            return path.filePathUrl()
        }
    }
    
}

// MARK: - BKFileUtil
struct BKFileUtil {
    
    /// 创建文件路径(实际创建文件夹)
    static func createFilePath(directory: AppDirectories, folderName: String, fileName: String = "") -> URL {
        var path = BKFilePathUtil.setupFilePath(directory: directory, name: folderName)
        BKFileUtil.createFolder(basePath: directory, folderName: folderName)
        path = path.appendingPathComponent(fileName)
        return path
    }
    
    /// 创建文件夹
    @discardableResult
    static func createFolder(basePath: AppDirectories, folderName: String, createIntermediates: Bool = true, attributes: [FileAttributeKey: Any]? = nil) -> Bool {
        let filePath = BKFilePathUtil.setupFilePath(directory: basePath, name: folderName)
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: createIntermediates, attributes: attributes)
            PPP("创建文件夹路径成功！>>> \(filePath)")
            return true
        } catch {
            PPP("创建文件夹路径失败!")
            return false
        }
    }
    
    /// 写入数据
    @discardableResult
    static func writeFile(content: Data, filePath: FilePathProtocol, options: Data.WritingOptions = []) -> Bool {
        do {
            try content.write(to: filePath.filePathUrl(), options: options)
            PPP("文件写入数据成功!>>>路径: \(filePath.filePathUrl())")
            return true
        } catch {
            PPP("文件写入数据失败!")
            return false
        }
    }
    
    /// 读取数据
    static func readFile(filePath: FilePathProtocol) -> Data? {
        let fileContents = FileManager.default.contents(atPath: filePath.filePathUrl().path)
        return fileContents?.isEmpty == true ? nil : fileContents
    }
    
    /// 删除文件
    @discardableResult
    static func removeFile(filePath: FilePathProtocol) -> Bool {
        do {
            try FileManager.default.removeItem(at: filePath.filePathUrl())
            PPP("文件删除成功!>>>路径: \(filePath.filePathUrl())")
            return true
        } catch {
            PPP("文件删除失败!")
            return false
        }
    }
    
    /// 重命名文件
    @discardableResult
    static func renameFile(path: AppDirectories, oldName: String, newName: String) -> Bool {
        let oldPath = BKFilePathUtil.setupFilePath(directory: path, name: oldName)
        let newPath = BKFilePathUtil.setupFilePath(directory: path, name: newName)
        do {
            try FileManager.default.moveItem(at: oldPath, to: newPath)
            PPP("文件重命名成功!>>>路径: \(newPath)")
            return true
        } catch {
            PPP("文件重命名失败!")
            return false
        }
    }
    
    /// 移动文件
    @discardableResult
    static func moveFile(fileName: String, fromDirectory: String, toDirectory: String) -> Bool {
        let fromPath = BKFilePathUtil.setupFilePath(directory: .customPath(path: fromDirectory), name: fileName)
        let toPath = BKFilePathUtil.setupFilePath(directory: .customPath(path: toDirectory), name: fileName)
        do {
            try FileManager.default.moveItem(at: fromPath, to: toPath)
            PPP("文件移动成功!>>>路径: \(toPath)")
            return true
        } catch {
            PPP("文件移动失败!")
            return false
        }
    }
    
    /// 复制文件
    static func copyFile(fileName: String, fromDirectory: String, toDirectory: String) throws {
        let fromPath = BKFilePathUtil.setupFilePath(directory: .customPath(path: fromDirectory), name: fileName)
        let toPath = BKFilePathUtil.setupFilePath(directory: .customPath(path: toDirectory), name: fileName)
        return try FileManager.default.copyItem(at: fromPath, to: toPath)
    }
    
    /// 文件是否可写
    static func isWritable(filePath: FilePathProtocol) -> Bool {
        return FileManager.default.isWritableFile(atPath: filePath.stringPath()) ? true : false
    }
    
    /// 文件是否可读
    static func isReadable(filePath: FilePathProtocol) -> Bool {
        return FileManager.default.isReadableFile(atPath: filePath.stringPath()) ? true : false
    }
    
    /// 文件是否存在
    static func exists(filePath: FilePathProtocol) -> Bool {
        return FileManager.default.fileExists(atPath: filePath.stringPath()) ? true : false
    }
    
    /// 获取路径下的文件列表
    static func getFilePathList(folderPath: FilePathProtocol) -> [String] {
        let fileList = try? FileManager.default.contentsOfDirectory(atPath: folderPath.stringPath())
        PPP("文件列表成员如下:\n\(fileList ?? [])")
        return fileList ?? []
    }
    
    /// 查找路径及其子路径下所有指定类型文件
    static func findAllFile(type: String, folderPath: String, maxCount: Int = .max) -> [String] {
        let fileManager = FileManager.default
        let dirEnum = fileManager.enumerator(atPath: folderPath)
        var fileArr = [String]()
        while let file = dirEnum?.nextObject() as? String {
            if type == file.pathExtension {
                fileArr.append("\(folderPath)/\(file)")
            }
            if fileArr.count == maxCount {
                break
            }
        }
        PPP("\(#function)查找文件如下:\n\(fileArr)")
        return fileArr
    }
    
    /// 查找文件夹路径及其子路径下所有指定类型文件所在文件夹路径
    static func findAllFolder(type: String, folderPath: String, maxCount: Int = .max) -> [String] {
        let fileManager = FileManager.default
        let dirEnum = fileManager.enumerator(atPath: folderPath)
        var fileArr = [String]()
        while let file = dirEnum?.nextObject() as? String {
            if type == file.pathExtension {
                let path = ("\(folderPath)/\(file)" as NSString).deletingLastPathComponent
                fileArr.append(path)
            }
            if fileArr.count == maxCount {
                break
            }
        }
        PPP("\(#function)查找文件如下:\n\(fileArr)")
        return fileArr
    }
    
    /// 查找路径下所有空文件夹,只会查找一级目录
    static func findAllEmptyFolder(path: String) -> [String] {
        let fileManager = FileManager.default
        var fileArr = [String]()
        if let fileNameListArr = try? fileManager.contentsOfDirectory(atPath: path) {
            for filePath in fileNameListArr {
                let completePath = "\(path)/\(filePath)"
                var isDirectory = ObjCBool(false)
                if fileManager.fileExists(atPath: completePath, isDirectory: &isDirectory), isDirectory.boolValue,
                   let pathArr = try? fileManager.contentsOfDirectory(atPath: completePath), pathArr.isEmpty {
                    fileArr.append(completePath)
                }
            }
        }
        return fileArr
    }
    
}

// MARK: - 保存图片到本地
extension BKFileUtil {
    
    @discardableResult
    static func saveImageToFile(directory: AppDirectories = .documents,
                                image: UIImage,
                                folderName: String,
                                fileName: String) -> Bool {
        let path = BKFileUtil.createFilePath(directory: directory, folderName: folderName, fileName: fileName)
        guard let data = image.pngData() else { return false }
        return BKFileUtil.writeFile(content: data, filePath: path.path)
    }
    
}
