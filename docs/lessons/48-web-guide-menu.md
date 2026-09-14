# 第四十八課：Godot 選單與網頁視窗

這次先暫停遊戲，再從 OptionsMenu 的書本按鈕開啟指南。Godot 只在 Web 平台建立此按鈕，由 presentation/web_player_guide.gd 呼叫網頁閱讀器；iframe 和關閉視窗放在 web/guide-reader.js，視覺尺寸在 guide-reader.css。遊戲規則不需要知道瀏覽器的存在。

[Godot 官方 JavaScriptBridge 說明](https://docs.godotengine.org/en/stable/tutorials/platform/web/javascript_bridge.html)介紹這個網頁橋接方式。Windows／Mac 沒有新增按鈕，也不呼叫橋接。

小練習：在 Godot 開啟 presentation/campaign_options.gd，找到 OS.has_feature("web") 區塊；它表示只有匯出網頁版才執行。這次只看懂平台條件，不需要改動。未收到練習回報，不記為已掌握。
