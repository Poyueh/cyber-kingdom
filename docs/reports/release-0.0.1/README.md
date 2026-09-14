# 0.0.1 發行檢查

統一版本號後從 b882769 建置三平台。完整 tools/check.sh 通過，無 SCRIPT ERROR；Mac PCK 17 assertions、真實 release 啟動與 ad-hoc 簽章驗證通過，CFBundleShortVersionString 為 0.0.1。ZIP CRC 與 SHA-256 通過。Windows 實機與 iPhone Safari 仍待驗收。

直接執行 Pages workflow 內的相同解壓程式驗證：正式網頁包通過；錯誤 checksum、路徑逃逸 ZIP 皆被拒絕。GitHub Actions 固定到官方 commit，使用唯讀附件下載、Pages 發布與必要的 OIDC 權限。

GitHub Pages 原先從 main 根目錄發布，已改為 GitHub Actions；Release published 事件會下載同一版 Web ZIP，核對雜湊再部署。本檢查紀錄完成時附件已準備，遠端發布與線上驗證結果另記 STATUS。
