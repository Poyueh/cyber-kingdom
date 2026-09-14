# 第四十九課：起始場景、旅程與龍晶數值

Godot 的 F5 會執行專案設定中的 Main Scene。現在是 `scenes/start_menu.tscn`，按「新遊戲」才切换到戰役；F6 則只執行你正在編輯的場景。

想調整採集收益：在 FileSystem 點 `data/campaign.tres`，Inspector 的 Crystal harvest 可調整樹木、礦脈、寶箱與植物產出的龍晶；Crystal Prices 控制付款格數。以新遊戲測試數值，舊紀錄會保留自己的規則，避免讀檔時突然改變平衡。

起始頁的畫面在 presentation/start_menu.gd，流程在 bootstrap/start_menu_root.gd；讀寫檔案交給 infrastructure/campaign_catalog.gd 與既有 store。這樣改版面不用碰存檔保護，改價格不用碰按鈕。

可以練習把 Tree Crystals 從 4 改成 5，開新局、招募工匠並標記樹木，等交貨後確認五顆龍晶落在收貨點。這只是練習建議，目前尚無使用者完成或理解程度回報。
