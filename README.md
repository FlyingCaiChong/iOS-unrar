# iOS rar 文件解压

> 背景, 手机“文件”应用程序里的`rar`文件, 用原生程序打不开, 需要下载第三方 app 打开, 但是又不想下载, 担心会有隐私泄漏问题. 然后想着自己写一个 demo 来实现一下.

## 需求

开发一个 demo, 用来解压手机“文件”应用程序里的`rar`文件.

## 实现思路

要实现这个需求, 需要完成两个步骤

1. 能够访问到手机“文件”应用程序中的`rar`文件.
2. 解压`rar`文件

### 访问 rar 文件

在项目的 info.plist 文件中添加`UIFileSharingEnabled`和`CFBundleDocumentTypes`键. `key`-`value`的内容如下:

```xml
<key>UIFileSharingEnabled</key>
	<true/>
<key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeName</key>
			<string>Archive</string>
			<key>LSHandlerRank</key>
			<string>Default</string>
			<key>LSItemContentTypes</key>
			<array>
				<string>com.rar-archive</string>
			</array>
		</dict>
	</array>
```

然后运行项目之后, 打开手机“文件”应用程序, 选择`rar`文件, 移动到“我的 iPhone”-"[项目名]"文件夹下.

编写代码, 获取项目文件夹里的文件

```swift
// 获取文件
func getFiles() {
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

// 判断是否是rar文件
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
```

### 解压`rar`文件

解压`rar`文件使用的是第三方库[UnrarKit](https://github.com/abbeycode/UnrarKit).

#### 安装 UnrarKit

```sh
pod "UnrarKit"
```

#### 使用

```swift
func unrar(filePath: String, documentDirectory: URL) {
    do {
        // 创建子目录
        let picDir = documentDirectory.appendingPathComponent("pic")
        try FileManager.default.createDirectory(at: picDir, withIntermediateDirectories: true)

        // 初始化
        let archive = try URKArchive(path: filePath)

        // 解压文件到目标目录
        let destinationPath = picDir.path
        try archive.extractFiles(to: destinationPath, overwrite: true)

        // 打印解压后的文件路径
        let contents = try FileManager.default.contentsOfDirectory(atPath: destinationPath)
        for content in contents {
            print("File in pic directory: \(content)")
        }

        // 列出文件名
        let fileNames = try archive.listFilenames()
        for fileName in fileNames {
            print("File in RAR: \(fileName)")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
```

---

##### 如果遇到执行`pop install`时报错`LoadError - dlopen(/Library/Ruby/Gems/2.6.0/gems/ffi-1.15.5/lib/ffi_c.bundle, 0x0009)...`.

该问题是由于在`Mac M1`芯片上使用`CocoaPods`时出现了兼容性问题。这个问题通常是由于`Ruby gem ffi`的架构不兼容所致。为了解决这个问题，你可以按照以下步骤操作：

1. 打开终端并导航到你的项目目录。
2. 运行以下命令来使用`arch`指令以`x86_64`架构运行`pod install`：

```bash
arch -x86_64 pod install
```

这个命令会强制使用`x86_64`架构来运行`pod install`，从而解决了在 M1 芯片上的兼容性问题。
