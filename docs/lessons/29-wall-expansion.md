# 第二十九課：建牆的清地範圍
在 Godot FileSystem 選 data/campaign.tres，Inspector 展開 Defense Posts，找到 Wall Clearance。80 代表新城牆左右各 80 世界單位內的樹要先由工匠砍完；它不影響騎士攻擊距離。

先保持 80，開 scenes/frontier.tscn 按 F6，探索新防線。缺少的聚落、拓荒站、前一段牆與待砍樹會以圖示表示。若把數字改成 100，離牆稍遠的樹也可能變成施工前置條件；只改這一項並重開本輪比較，試完改回 80。

純規則在 domain/frontier_defenses.gd，畫面讀規則結果；數字從 Resource 注入，所以調整時不用改城牆繪製程式。本課沒有使用者操作回饋，尚不記為已掌握。
