# 測試安裝包

2026-09-13。原型可在 Mac、Windows 打包，Android 已有模擬器安裝證據；不是完整 Demo 驗收或商店正式發行。

## 現有產物

- builds/desktop-touch-20260913/Cyber-Kingdom-macOS.zip：約 73.3 MiB，解壓後開啟 .app。
- builds/desktop-touch-20260913/Cyber-Kingdom-Windows.zip：約 51.9 MiB，解壓後開啟 .exe，旁邊 .pck 必須保留。
- builds/android-touch-20260913-v2/Cyber-Kingdom-Android-debug.apk：約 43.0 MiB，ARM64 Android 測試版。
- 各資料夾的 manifest.json 保存來源 tree、雜湊與建置用途；安裝包不提交 Git。

三份產物來自 c5e5df2a3c5a5959891a6899338c66adb965b689，入口皆為營火戰役 frontier.tscn。後續文件、預覽及驗證報告不改變遊戲內容。原 desktop-save／expansion 與失敗的 android-touch-20260913 留作歷史；Android 請用 v2。

Mac 為 ad-hoc 簽章、未公證；Windows 未簽署；Android 使用本機 debug certificate。Bundle/package ID 暫為 org.cyberkingdom.demo，未代表 Apple 商店正式登記。iOS 尚無可安裝包。

## 可重現桌面建置

需要 macOS、Python 3、Godot 4.7.2 與相同版本官方匯出模板：

```sh
python3 tools/build_desktop.py --ref develop --output builds/my-desktop-preview
```

output 必須是新目錄。預設取 HEAD 已提交資料，亦可指定 commit／tree；不混入工作目錄未提交設定。Mac ZIP 使用 ditto 保留權限，未宣稱此腳本可直接在 Windows 主機執行。

工具只在暫存副本設定 frontier 入口、Cyber Kingdom Demo 名稱、原創龍晶騎士 app-icon.svg，及 ETC2／ASTC 貼圖匯入。原 project.godot 不變。直接使用 Godot Export 選單則沿用工作目錄設定；要重現此文件請用工具。

## Android 本機測試建置

已在此 Mac 安裝官方 command-line tools、platform-tools、Android 35／36 platform、build-tools 35.0.1／36.0.0。Godot 4.7.2 模板實際 target SDK 為 36、minimum 24。使用現有 OpenJDK 21；Godot 設定的 Android SDK 與 Java SDK 路徑須指向本機安裝處。

在 Godot Editor Settings → Export → Android 設定路徑。本機 Android SDK 為 /Users/jenpoyueh/Library/Android/sdk，JDK 為 /opt/homebrew/Cellar/openjdk/21.0.3/libexec/openjdk.jdk/Contents/Home；其他電腦請使用自己的路徑。

本機 debug key 放在 ~/.android/cyber-kingdom-debug.keystore，未提交 Git。這是測試專用、標準公開 debug 密碼，不是正式發行憑證。另一台電腦可建立自己的 debug key：

```sh
keytool -genkeypair -keystore ~/.android/cyber-kingdom-debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
python3 tools/build_android.py --ref develop --output builds/my-android-preview
```

keytool 需要 ~/.android 已存在；若已有同名檔案請保留，勿重建覆蓋。可用 --debug-key 指定另一個測試 key。不同簽章不能直接更新已有同 package 安裝，解除安裝會刪進度，所以同一測試期保留這支 key。

預設非 Gradle 匯出，沒有加入 NDK／CMake 等此流程不需要的工具。APK 只含 ARM64 ABI，未要求網際網路權限；支援範圍還需實體裝置驗證。正式商店後續改用 release key、AAB 與版本碼流程，不能把此 APK 當正式上架。

## 驗證與限制

乾淨副本完整 tools/check.sh 通過 1094 項 Godot 斷言及 2 個 Python 建置測試。建置比對 735 個遊戲／測試／設定檔案與產物來源一致，原個人 25 檔不動。

桌面 ZIP CRC／SHA-256、Mac 簽章完整性、Windows x86-64 格式通過；真正 Mac release 入口 120 幀無錯誤。引擎載入實際 PCK 驗證建設、居民、成長、外擴、核心終局與完整續玩，原生渲染通過。PCK 檢查必須從專案外執行，例如 --path /tmp；使用原生圖形模式，不能用 headless 截圖。這不是真人完成整局的證明。

Android v2 無匯出 ERROR，v2/v3 APK 簽章與 16 KiB native alignment 檢查通過。已在隔離 AOSP Android 15 ARM64 模擬器安裝、冷啟動，觸控長按建營地、移動、拋晶、回首頁存檔、停止程序和重開續玩通過。冷重開出現一次軟體 GLES shader cache 重編譯警告，仍成功渲染，無 SCRIPT ERROR 或崩潰。沒有從模擬器推論實體手機 FPS／耗電。

Android 4.7.2 模板的可啟動 alias 是 com.godot.game.GodotAppLauncher；內部 GodotApp activity 不對外開放。測試啟動請讀 APK manifest／套件解析結果，不要為了測試修改 activity 權限。

三平台排除 docs、tests、tools、概念圖、原始生成圖及 contact 圖，仍保留舊場景可用資源；尚未最終縮減體積。錯誤掃描不只看退出碼；初次缺少 project icon 即使有 APK 仍算失敗，修正後重建 v2。

iPhone 17e／iPhone 16 Pro Max 尚未安裝。完整 Xcode 與 Apple 簽署未完成；iPad、Android 真機、Windows 實機、真人難度與動作美感仍未驗收。[驗證報告](reports/mobile-controls-v001/manifest.json)、[手機規格](design/mobile-controls.md)。

參考：[Godot Android 匯出](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)、[官方 Android 工具](https://developer.android.com/studio#command-line-tools-only)、[Godot iOS 匯出](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)。選項另以本機 4.7.2 實際輸出核對。
