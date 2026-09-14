# 三語介面與語言偏好

目前提供繁體中文（zh_TW）、簡體中文（zh_CN）、英文（en）。起始頁與暫停選單皆可切換，包含紀錄列表、錯誤訊息與 H5 圖文指南。遊玩 HUD 維持圖示優先。

## 預設語言

手動選擇優先；自動模式依 Steam 遊戲語言、裝置／瀏覽器語系、英文後備依序決定。辨識 Hant/Hans、TW/HK/MO 與 Steam 的 tchinese/schinese/english。購買地區不代表語言，不使用 IP 或國家推斷。

目前已接裝置語言。未安裝 Steam SDK、未配置 App ID；未來 Steam bootstrap 初始化成功後，呼叫 ISteamApps.GetCurrentGameLanguage()，將結果交給 GameLanguage.set_steam_language()。這是已預留的接點，不能宣稱已通過 Steam 實機測試。

Steam 官方文件：https://partner.steamgames.com/doc/api/ISteamApps#GetCurrentGameLanguage

## 邊界與保存

- application/language_choice.gd 是純語言選擇規則，無 UI 或檔案依賴。
- infrastructure/language_preferences.gd 儲存在 user://language.cfg，與旅程分開。先寫暫存再替換；未知版本或損壞檔案不覆寫。保存失敗仍套用本次語言，選單 tooltip 提示可重試。
- bootstrap/localization.gd 組裝服務，建立 Translation，透過 TranslationServer 與 changed 訊號更新畫面；暫停仍可操作。
- localization/game_text.gd 每列依序為原文鍵、繁中、簡中、英文。格式占位符必須保留。已上線鍵若改名，須一起更新使用者。
- presentation/localized_font.gd 使用共同 FontVariation，依地區選 Noto TC/SC，另一字型補缺字。兩個官方字型均隨附 OFL 授權；延遲載入避免全新匯入時 Autoload 先於字型匯入。
- H5 指南從 docs/player-guide/translations.json 翻譯文字；tools/build_player_guide.py 將字典、腳本與圖片嵌入獨立 HTML。請用建置工具預覽，不直接開啟來源模板 index.html。URL lang 同步遊戲選擇。

## 驗證與範圍

tests/test_language_scene.gd 驗證選擇優先序、即時更新、記憶偏好、簡中字型、紀錄列表、暫停選單、未知檔案保護。tools/test_localization.py 檢查字串及占位符、指南覆蓋率與獨立包。

H5 已實際驗證三語、重新整理保存、選單與指南；844×390 是瀏覽器版面檢查，不等同 iPhone 實機測試。舊截圖中的嵌入字樣不重繪，文字說明已翻譯。商店頁、宣傳文案與 Steam SDK 接線另行安排；英文與簡中文字句仍應收集母語玩家回饋。
