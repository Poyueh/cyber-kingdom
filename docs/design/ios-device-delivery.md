# iPhone／iPad 安裝交付

2026-09-13 最新結果：使用者已登入 Personal Team，真實團隊識別碼與有效 Apple Development 憑證均已確認。Godot 已成功匯出 Xcode 專案，iPhone ARM64 App 已完成未簽署編譯。iOS 26.5 runtime 下載及掛載問題已修復。實際自動簽署被 Apple 擋在「團隊尚無測試裝置、無法建立描述檔」；目前沒有連接 iPhone。產物尚不可安裝，詳見 [本次報告](../reports/ios-personal-v001/README.md)。

## 已準備的流程

export_presets.cfg 新增 iOS Demo，目標 iPhone 與 iPad、ARM64、最低 iOS 15，保留目前相容渲染路徑。Team ID 與 Bundle ID 刻意留白，須由實際帳號與應用識別填入。程式不拿測試字串當真實團隊，也不修改全機 xcode-select。

工具 tools/build_ios.py 的 --check 是唯讀檢查：Godot 版本對應的模板、完整 Xcode、可用 iPhoneOS SDK、Team ID／Bundle ID 格式。ready_for_export 只代表可嘗試匯出，不表示帳號驗證、憑證可用、Bundle ID 已登記或能安裝；installable 仍為 false。

正式執行時從指定 Git tree 建乾淨副本，沿用桌面工具設定營火入口、圖示及行動貼圖；只在副本的 iOS 區段填 Team／Bundle。輸出必須是全新目錄。引擎回傳零但記錄含 ERROR 仍失敗，缺少 Xcode 專案或非空 PCK 亦不算成功。生成的 manifest 明確標記只是 Xcode 專案。

--xcode 可以指定 Xcode.app，工具只對子程序傳 DEVELOPER_DIR，不改其他開發工作的全機選擇。此版設定 export_project_only=true，產生專案後仍需 Xcode 簽署、編譯與真機安裝，不會自動上傳商店、接受授權條款或購買開發者方案。

## Xcode 設定完成後

1. 在 Xcode 使用實際 Apple Account，確認可用 Team ID；選定本 App 的 Bundle ID。帳號密碼與私鑰不要貼進對話或提交 Git。
2. 執行環境檢查，再由工具匯出。若只有 Command Line Tools，工具會在建立輸出目錄前停止。
3. 在 Xcode 開啟 CyberKingdomDemo.xcodeproj，於 Signing & Capabilities 選真實 Team，接上其中一支 iPhone，依裝置提示完成信任／Developer Mode，再以 Run 安裝。
4. 記錄每支手機的 OS／版本及實際開局、付款、移動與攻擊多指操作、背景恢復、音效／靜音、安全區、完整勝敗重試。安裝成功與正常玩完整局分開記錄。
5. 確认兩機操作與效能後，再準備正式 App Store 簽署與送審；目前工具產物不是商店交付。

本機裝置測試可使用免費 Apple Account，正式 App Store 發佈另需 Apple Developer Program。具體帳號可用功能以 Apple 當時規則與 Xcode 為準。

## 驗證範圍

8 個 Python 測試涵蓋拒絕把 CLT 當 Xcode、子程序環境隔離、識別碼格式／注入、只更新 iOS 副本區段、保護既有輸出、缺 PCK 不報成功、缺前置條件不開始匯出，以及有自訂環境時 ERROR 掃描仍有效。測試用 Team ID 僅是格式測試資料，沒有用它向 Godot 或 Apple 真正匯出／簽署。

早期前置檢查因環境／識別碼不足退出 2。後續已使用真實帳號完成端到端匯出及未簽署 ARM64 編譯；自動簽署因無裝置描述檔退出 65。匯出工具可用已有實際證據，但簽署與實體手機驗證尚待完成。

## 一手來源

- [Godot iOS 匯出](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)：Xcode、Team／Bundle 及裝置流程。
- [iOS 匯出選項](https://docs.godotengine.org/en/stable/classes/class_editorexportplatformios.html)：project-only 與設定的意義。
- [Godot 4.7.2 iOS exporter](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/ios/export/export_plugin.cpp)：device family 2 為 iPhone 與 iPad。
- [同版 iOS header](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/ios/export/export_plugin.h)：最低版本預設 15.0。
- [同版 Apple exporter](https://github.com/godotengine/godot/blob/4.7.2-stable/editor/export/editor_export_platform_apple_embedded.cpp)：project-only 產生專案後停止，並不建立 IPA。
- [Xcode 官方頁](https://apps.apple.com/tw/app/xcode/id497799835)：免費帳號本機測試與付費發佈的區別。
