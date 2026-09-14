# 手機操作與首次 Android 安裝驗證

2026-09-13。目標是讓既有戰役能在手機操作、背景續玩；沒有更改經濟、難度、斬擊素材或戰役存檔版本。

## 玩家可見行為

- 主要按鈕放大成 64×64 邏輯單位，統一間距，放在裝置安全區內。
- 血量／背包、材料、日夜與核心分組；安全區較窄時核心／方向預警換行。
- 手機隱藏桌面的全螢幕切換；維持圖示和必要數字。
- 一指移動時，另一指可投入、拋晶或出刀；第一刀仍站定，後兩刀仍踏進。
- 切背景、暫停與重開釋放全部觸控捕捉；回來需要新按下，不能讓舊長按繼續花錢。
- 保留既有 16:9 畫布。寬手機目前左右留黑邊；尚未改成滿版超寬探索視野。

## 驗證區分

幾何測試包含 960×540、960×720、左右非對稱缺口及 760×420 的較窄安全區。原生桌面圖片是模擬安全邊界，不能稱為 iPhone 實機畫面；工具的 tablet 視窗截圖仍是 16:9 內容，不是完整 4:3 平板螢幕。

實際 Godot 場景以不同手指 index 發送 ScreenTouch，驗證同時移動／投入／拋晶、移動時第一刀站定、失焦後舊手指未釋放但新手指可重新移動／投入。先重現原生按鈕及 GUI 按鈕仍占用舊手指的失敗，再修正；單純清空 Input action 不足。投資格仍保留，原本的放開後才能新交易規則保留。

Android APK 在隔離 AOSP Android 15（API 35）ARM64、Pixel 7 模擬器安裝及冷啟動。使用系統觸控長按建營地、行走、拋晶，回首頁保存、停止程序、冷啟動後畫面與檢查點保留。這是 Android 安裝版驗證；多指測試主要來自 Godot 實際場景，不把單指 adb 操作寫成實體多指測試。軟體 GPU 模擬器不作手機 FPS、耗電或溫度結論。

iPhone 17e／iPhone 16 Pro Max 仍未安裝；iPad、Android 實體手機、Windows 遊玩也未驗收。完整 Xcode／Apple 簽署仍待接續，付費開發者帳號問題尚未回覆。四平台與適中難度目標尚未完成。

## 依據

- [Godot 安全區 API](https://docs.godotengine.org/en/stable/classes/class_displayserver.html#class-displayserver-method-get-display-safe-area)
- [Viewport 螢幕轉換](https://docs.godotengine.org/en/stable/classes/class_viewport.html#class-viewport-method-get-screen-transform)
- [TouchScreenButton 多指行為](https://docs.godotengine.org/en/stable/classes/class_touchscreenbutton.html)
- [Android 匯出](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [iOS 匯出需求](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)

## 最新 APK 多指補驗（2026-09-13）

已用 Android 15 系統 MotionEvent 向 de83023 APK 注入真正重疊的雙指，驗證移動＋跳躍／衝刺／第一刀，以及第三指暫停、全指放開後無殘留移動、新手勢可用。見 [證據](../reports/android-multitouch-v001/README.md)。這是模擬器系統輸入，不是實體手機手感驗收。
