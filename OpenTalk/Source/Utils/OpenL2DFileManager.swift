//
//  OpenL2DFileManager.swift
//  OpenTalk
//

import Foundation
import SSZipArchive
import OpenLive2D

@objc class OpenL2DFileManager: NSObject {
    
    @objc enum L2DModelType: Int, CaseIterable {
        case suzu
        case mia
        case sayo
        case bafu
        case yagari
        
        var fileName: String {
            switch self {
            case .suzu   : return "SUZU"
            case .mia    : return "MIA"
            case .sayo   : return "SAYO"
            case .bafu   : return "芭弗"
            case .yagari : return "栗子猫头鹰少年"
            }
        }
        
        var modelDirPath: URL? {
            return OpenL2DFileManager.destinationURL?.appendingPathComponent(fileName)
        }
        
        var modelJsonPath: String? {
            let modelJsonName = fileName + ".model3.json"
            return modelDirPath?.appendingPathComponent(modelJsonName).path
        }
        
        /// 放大比例
        var zoomScale: Float {
            switch self {
            case .mia:  return 2.1
            case .suzu: return 2.1
            case .sayo: return 2.0
            case .bafu: return 3.0
            case .yagari: return 2.1
            }
        }
        
        /// 中心偏移值
        var offset: (Float, Float) {
            switch self {
            case .mia:  return (0.0, -0.8)
            case .suzu: return (0.0, -0.7)
            case .sayo: return (0.0, -0.7)
            case .bafu: return (0.0, -1.3)
            case .yagari: return (0.0, -1.3)
            }
        }
        
        func toConfigurationModel() -> OpenL2DConfigurationModel {
            let model = OpenL2DConfigurationModel()
            model.zoomSclae = zoomScale
            model.offsetX = offset.0
            model.offsetY = offset.1
            model.modelDirPath = modelDirPath?.path ?? ""
            model.fileName = fileName
            model.backgroundImagePath = (modelDirPath?.path ?? "") + "/backgroundImage.png"
            return model
        }
    }
    
    // 沙盒路径
    private static var destinationURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Live2D")
    }

    @objc static func clean() {
        guard let path = destinationURL?.path else { return }
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    @objc class func unzipL2DFilesIfNeeded() {
        // 调试时可以开启清理
        // clean()
        
        L2DModelType.allCases.forEach { type in
            unzipFile(type)
        }
    }
        
    private class func unzipFile(_ type: L2DModelType) {
        // 压缩包路径 - 资源放在 Resources/Live2D/ 下
        guard let sourceURL = Bundle.main.url(forResource: type.fileName, withExtension: "zip") else {
            print("live 2d - 找不到对应的压缩包文件 -- \(type.fileName)")
            return
        }
        
        guard let destinationPath = destinationURL else { return }
                    
        // 检查model文件夹是否存在
        let modelDir = destinationPath.appendingPathComponent(type.fileName)
        if FileManager.default.fileExists(atPath: modelDir.path) {
            return
        }
        
        do {
            try FileManager.default.createDirectory(at: destinationPath, withIntermediateDirectories: true, attributes: nil)
            if SSZipArchive.unzipFile(atPath: sourceURL.path, toDestination: destinationPath.path) {
                print("解压live 2d - \(type.fileName).zip 成功")
            } else {
                print("解压live 2d - \(type.fileName).zip 失败")
            }
        } catch {
            print("创建目录失败: \(error.localizedDescription)")
        }
    }
}
