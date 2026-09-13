# 2026-09-14 Windows / macOS 預覽版

發行來源 3da141e，遊戲規則仍沿用 de83023，新增離線玩家指南及啟動說明。輸出 builds/desktop-20260914-r2；完整檔案指紋見 manifest.json 與 SHA256SUMS.txt。

第一次從最新 develop 完整匯入時，Godot 無法讀取指南的動畫 WebP；同一錯誤同時使發行匯入與完整檢查失敗。新增 docs/player-guide/.gdignore 後重新匯入、完整檢查與雙平台匯出通過，原動畫仍可在 HTML 使用。沒有略過錯誤訊息或回退舊來源。

- 完整 tools/check.sh：隔離副本沿用最新整合樹並套用相同 .gdignore 修正；無 SCRIPT ERROR、錯誤或失敗。
- Mac 實際匯出的 release 執行檔：原生視窗啟動 90 幀成功，--no-campaign-save 保護既有進度；這次退出無先前音訊清理警告。
- Mac PCK：現有場景回歸與 17 項新功能 assertions 通過，畫面已查看。
- Windows PCK：在 Mac Godot 載入真正的 Windows 套件資源，17 項 assertions 通過。這不是 Windows 作業系統實機遊玩。
- Mac universal（arm64 + x86_64），ad-hoc 簽章驗證通過，尚未 Apple 公證。Windows x64 PE，未簽章。
- ZIP CRC、重複檔名、內附單檔指南與啟動說明均通過。兩 ZIP 分別約 75.6 MiB / 54.2 MiB。

130 個原有個人／引擎檔案保持。測試存檔未提交。以 release/0.1.0-preview.20260914 製作本地預覽交付、回合 develop；尚未上傳外部發行站台，也不是 App Store 正式發行。
