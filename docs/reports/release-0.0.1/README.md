# 0.0.1 發行檢查

統一版本號後從 b882769 建置三平台。完整 tools/check.sh 通過，無 SCRIPT ERROR；Mac PCK 17 assertions、真實 release 啟動與 ad-hoc 簽章驗證通過，CFBundleShortVersionString 為 0.0.1。ZIP CRC 與 SHA-256 通過。Windows 實機與 iPhone Safari 仍待驗收。

直接執行 Pages workflow 內的相同解壓程式驗證：正式網頁包通過；錯誤 checksum、路徑逃逸 ZIP 皆被拒絕。GitHub Actions 固定到官方 commit，使用唯讀附件下載、Pages 發布與必要的 OIDC 權限。

GitHub Pages 原先從 main 根目錄發布，已改為 GitHub Actions；Release published 事件會下載同一版 Web ZIP，核對雜湊再部署。本檢查紀錄完成時附件已準備，遠端發布與線上驗證結果另記 STATUS。

## 公開驗收

Release：https://github.com/Poyueh/cyber-kingdom/releases/tag/v0.0.1 。四個附件與本機雜湊相同，見 published-release.json。

Pages：https://poyueh.github.io/cyber-kingdom/ 。main 的 run 34802636219 成功部署；五個公開核心檔案皆 HTTP 200、SHA-256 與本機 Web 成品一致，WASM MIME 為 application/wasm，見 pages-verified.json。Codex 內建瀏覽器實際載入營火場景、暫停音量面板與恢復遊戲成功，console error 為空；線上建設長按未完成驗收，玩法回歸沿用先前 Chrome 實測。

第一次標籤部署被 main-only 環境規則擋下；hotfix 保留該規則，Release 工作改從 main 派發部署。本次現有 v0.0.1 手動派發成功，未重新製作附件或移動既有標籤。未來 Release 自動派發分支需在下一次真實發行時驗收。Actions 有 Node 20 動作由平台改以 Node 24 執行的棄用警告，未影響成功部署；後續維護固定動作版本時處理。
