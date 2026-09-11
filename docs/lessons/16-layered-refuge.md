# 第十六課：同一個可玩場景，分層更換美術
這次只改呈現層與美術 Resource；龍晶花費、招攬與居民工作仍由原本規則處理。

1. 在 Godot 開啟 scenes/frontier.tscn，選 WorldView。
2. 展開 Inspector 的 Art，會看到 data/refuge_art.tres。Woodland 是遠景，Forest Layer 是較近森林，Props 是建築與資源貼圖。
3. Forest Scroll 預設 0.25。數值越大，走動時這層移動越快；先記住原值，再試 0.15 和 0.4。按 F6 可單獨執行目前場景；F5 從訓練場進 REFUGE。
4. Show River 控制水面裝飾。暫停後，倒影和流光共用的模擬時間停止。

為什麼放 Resource：你換工坊圖片時，不需要修改居民如何取工程錘。這就是本專案 Clean Architecture 的實際用途。

原圖、透明切圖與重製方法在 art/refuge/v001/README.md。角色仍沿用既有動畫，這次沒有把它當成新動畫完成；也尚未驗證 iPhone／iPad。這篇提供練習，尚不表示你已掌握這些操作。
