# 桌面試玩包
2026-09-13。這是目前原型的桌面交付，不是完整 Demo 目標完成或商店正式發行。

## 現有產物
最新有限騎士成長版位於 builds/desktop-growth-20260913（不提交 Git）；首版 desktop-preview-20260912-r2 保留作歷史版本：
- macOS/Cyber Kingdom Demo.app：直接開啟進入營火戰役。
- Cyber-Kingdom-macOS.zip：Mac 傳輸包，Universal 2（Intel／Apple Silicon）。
- Cyber-Kingdom-Windows.zip：解壓後開啟 Cyber Kingdom Demo.exe，旁邊的 .pck 必須保留。
- manifest.json：來源 tree、Godot 版本、入口和 ZIP SHA-256。
- 匯入與兩平台匯出日誌保留在同一資料夾。

Mac 使用 ad-hoc 簽章且未公證；Windows 未正式簽章。這些是開發測試包，跨電腦下載仍可能有系統安全提示；正式販售簽署另行處理。暫用 Bundle ID org.cyberkingdom.demo，不代表已登記 Apple 商店識別碼。

## 可重現建置
需要 macOS、Python 3、Godot 4.7.2 及同版本官方匯出模板。本機已完成模板下載、ZIP CRC 驗證與安裝。程式使用 macOS ditto 保留 .app 權限，不宣稱建置腳本能在 Windows 主機執行。

在倉庫根目錄執行：

```sh
python3 tools/build_desktop.py --ref develop --output builds/my-desktop-preview
```

output 必須是尚未存在的目錄，避免蓋掉既有成果。預設取 HEAD 的已提交資料，也可傳明確 commit 或 staged tree；不會混入工作目錄未提交設定。可用 GODOT_BIN 或 --godot 指定引擎。

建置只在暫存副本將入口改為 frontier.tscn、名稱改為 Cyber Kingdom Demo，並啟用 Apple 晶片匯出要求的 ETC2／ASTC 貼圖匯入。使用者編輯中的 project.godot 不會被改動。若直接從 Godot Export 選單匯出，仍沿用你工作目錄的入口／貼圖設定；要得到本文件的結果請使用上述流程。

兩個 export_presets.cfg 排除研究文件、測試、工具、概念圖、生成原圖與 contact 圖。其餘遊戲資源保留，包含舊場景可用資源，尚未做最終體積最佳化。程式檢查工具退出碼與 Godot ERROR，不能讓錯誤的匯出繼續產生成功清單。

## 已驗證與限制
- 首次匯出發現 Universal／arm64 要求 ETC2／ASTC；新增會失敗的 staging 測試，再補建置副本設定，測試轉綠。
- 兩個 Python 行為測試涵蓋暫存入口／貼圖設定與不改工作目錄，以及 Godot 退出碼為零但輸出 SCRIPT ERROR 時仍停止建置。
- Mac、Windows release 匯出與日誌錯誤掃描成功；ZIP CRC／檔案大小、Windows x86-64 PE 格式與 Mac codesign 完整性另檢查。
- 真正 Mac 執行檔已從預設入口啟動，headless 120 幀零錯誤；原生 GUI 視窗存在。
- 為測試遊戲流程，用相同版本 Godot 執行器載入實際產物 .pck，驗證電容安裝／充能、容量 HUD、營火投入、招募、左側城牆投入、核心失守／重開、暫停、入口與測試檔排除；同時真正渲染並保存畫面。這是打包資源驗證，不能寫成真人在成品程式完成了整局。
- 正式 release template 不提供 --script 參數；最初外部腳本未執行而啟動一般遊戲，沒有把這次沒有結果的嘗試算作測試成功。
- Windows 沒有實機遊玩證據；兩支 iPhone 尚未安裝，Android 尚未產出 APK；完整 Xcode、手機簽署、存續檔與完整難度驗收仍待完成。

研究依據：[Godot Mac 匯出](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html)、[Windows 匯出](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html)、[命令列匯出](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)。實際選項與需求另由本機 4.7.2 引擎核對。
