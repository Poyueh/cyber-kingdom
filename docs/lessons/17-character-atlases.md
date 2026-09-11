# 第十七課：換角色外觀，保留動畫時間
這次把角色貼圖換成龍晶義肢造型，攻擊何時造成傷害、衝刺移動多遠仍由原規則管理。

在 Godot 開啟 scenes/frontier.tscn，選 Knight 下的 KnightVisual，找到 Inspector 的 Texture Overrides。這個字典左側是原貼圖路徑，右側是這次的新貼圖；相同的畫格區域與播放時間會套用到新圖上。

實際練習：展開其中的 knight-idle.png 查看圖集。每格是 128×96，腳底對齊同一條線；改美術時若移動腳底，遊戲中的人就可能突然上下跳。先觀察貼圖即可，暫時不需要更動動畫速度。

居民圖集則在 data/refuge_art.tres 的 Engineer Atlas 和 Citizens Atlas。前者按動作分列，後者按職業分欄，所以角色取得工程錘後，既有職業規則自然會切換成工匠外觀。

按 F5 → REFUGE 試玩。本課提供操作練習，尚不表示你已掌握 SpriteFrames 或字典。
