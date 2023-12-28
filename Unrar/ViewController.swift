//
//  ViewController.swift
//  Unrar
//
//  Created by 方恒 on 2023/12/28.
//

import UIKit
import UnrarKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: "#EEF5FF")
        let btn = UIButton.init(type: .custom)
        btn.setTitle("解压rar文件", for: .normal)
        btn.setTitleColor(UIColor(hex: "#176B87"), for: .normal)
        btn.frame = CGRect(x: 20, y: 80, width: 120, height: 44)
        btn.center = view.center
        btn.backgroundColor = UIColor(hex: "#B4D4FF")
        btn.setRoundedCorners(radius: 8)
        btn.addTarget(self, action: #selector(getFiles), for: .touchUpInside)
        view.addSubview(btn)
    }

    @objc func getFiles() {
        print("btn tapped!")
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
                print("\(fileURLs)")
                for fileURL in fileURLs {
                    if (isRARFile(filePath: fileURL.path)) {
                        print("is rar file: \(fileURL.lastPathComponent)")
                        unrar(filePath: fileURL.path, documentDirectory: documentDirectory)
                    } else {
                        print("not rar file: \(fileURL.lastPathComponent)")
                    }
                }
            } catch {
                print("Error while enumerating files \(documentDirectory.path): \(error.localizedDescription)")
            }
        }
    }
    
    func isRARFile(filePath: String) -> Bool {
        if let fileData = FileManager.default.contents(atPath: filePath) {
            let header = fileData.prefix(7)
            if header.count >= 7 {
                let rarSignature: [UInt8] = [0x52, 0x61, 0x72, 0x21, 0x1A, 0x07, 0x00]
                let fileHeader = Array(header)
                if fileHeader == rarSignature {
                    return true
                }
            }
        }
        return false
    }
    
    func unrar(filePath: String, documentDirectory: URL) {
        do {
            // 创建子目录
            let picDir = documentDirectory.appendingPathComponent("pic")
            
            try FileManager.default.createDirectory(at: picDir, withIntermediateDirectories: true)
            
            let archive = try URKArchive(path: filePath)
            
            let destinationPath = picDir.path
            try archive.extractFiles(to: destinationPath, overwrite: true)
            
            // 打印解压后的文件路径
            let contents = try FileManager.default.contentsOfDirectory(atPath: destinationPath)
            for content in contents {
                print("File in pic directory: \(content)")
            }
            
            // list file names
//            let fileNames = try archive.listFilenames()
//            for fileName in fileNames {
//                print("File in RAR: \(fileName)")
//            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: 1.0)
    }
}

extension UIButton {
    func setRoundedCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
