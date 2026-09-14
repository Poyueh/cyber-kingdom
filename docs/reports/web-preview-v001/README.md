# 瀏覽器預覽版驗證

來源 8b48a98，Godot 4.7.2 單執行緒 Web release；交付 builds/web-20260914-r3/Cyber-Kingdom-Web.zip，約 28 MiB，未壓縮引擎與資源約 57 MB，另附指南。ZIP CRC 與 SHA-256 通過。只開本機 HTTP 預覽，未上傳公網。

完整 tools/check.sh 通過，包含兩個新增 Python 匯出保護測試。Chrome 以獨立暫存瀏覽器環境測試，無 SCRIPT ERROR、JavaScript 錯誤或 WebGL 錯誤。

桌面 1280×720：長按 E 建營地（12 → 10 晶）、滑鼠手動存檔、D 移動與 Q 丟晶（9 晶）、滑鼠還原（10 晶、原位置）、重新載入保留進度且暫停、Space 跳躍、J 出刀截圖與 L 衝刺通過。直接讀取 IndexedDB 中的測試快照確認結果，沒有注入遊戲資源或修改模型。

行動版採 Chrome 模擬 Android、844×390 與真實瀏覽器 touch 事件：長按互動建立營地至 10 晶、移動至 x=150.33、點暫停寫入 IndexedDB。不是實體 iPhone Safari 驗收；尚無 Safari 音質、實機幀率或長時間遊玩結論。

首次桌面測試發現滑鼠無法點到畫面中的存讀檔按鈕。隔離診斷顯示桌面視窗置中造成 viewport 與滑鼠座標偏移；bootstrap 對 web 略過 window.size / position 後，實際滑鼠與完整存讀檔回歸通過。第二個問題是 web 不帶原生 mobile 特徵，加入 web 觸控能力判斷後，手機操作按鈕和實際觸控通過。診斷 autoload 只存在 /tmp 副本，未進入交付。

來源匯出沿用已提交設定，沒有整合既有 Inspector 個人調整。網頁 user:// 存檔與桌面分開。瀏覽器尺寸不再執行原生視窗置中；手動控制模式仍優先。

可重現：在靜態 HTTP 伺服器開啟交付的 web/index.html，以新瀏覽器資料執行上述操作。桌面存檔鈕位於 (546,488)，手動還原鈕 (685,488)；行動版投入 (574,355)、右移 (166,355)、暫停 (734,31)，座標只適用上述尺寸。使用 Playwright / Chrome CDP 發出按鍵、滑鼠與觸控，不直接呼叫遊戲邏輯。
