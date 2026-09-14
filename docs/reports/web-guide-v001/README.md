# H5 選單指南驗收

来源 536d676。先增加匯出閱讀器打包測試，確認缺少 install_guide_reader 而失敗，再補上實作，3 個 Python Web 測試轉綠。完整 tools/check.sh 通過，無 SCRIPT ERROR；桌面場景新增驗證：原生暫停選單不出現 PlayerGuide。首次受 sandbox 引擎設定寫入限制而中止，取得引擎設定存取權後同一檢查完成。

實際 Web release 匯出、ZIP CRC 通過。Codex 內建瀏覽器從營火暫停選單點書本圖示，真正開啟同站 guide.html iframe；單一實例、延後載入，沒有跳離遊戲。指南中的建國示意付款 12→11，遊戲背包保持 12，Esc（焦點在 iframe 內）關閉後仍顯示播放圖示與暫停面板。再次開啟、關閉按鈕、焦點返回 canvas 通過。

1280×720、844×390、390×844 目視通過，手機尺寸關閉按鈕固定且無頁面橫向溢出；指南能獨立捲動與使用既有章節連結。console error 為空。尺寸模擬不等於 iPhone Safari 真機觸控驗收。Windows／macOS 成品未重建、未替換；只有 Web preset 增加頁面載入與 Web-only 選單分支。

使用者確認同步更新現有 Pages，預計發行 v0.0.2（H5 更新），原有 v0.0.1 三平台附件保持。線上驗收結果另記 STATUS。
