# 第十八課：調整居民散步速度
開啟 Godot 的 data/campaign.tres，在 Inspector 展開 Resident Stroll。Stroll Speed 預設是 24，表示居民散步每秒移動的遊戲距離；可以先試 18 或 30，記住原值後再改回。

按 F5 → REFUGE，先遠離流浪者觀察他來回散步，再走近。靠近 72 距離內他會停下方便招攬；無職居民在營地附近散步，有器具就先去拿。工匠、農夫、獵人與守備兵仍依原任務行動。

散步規則放在 domain/resident_roaming.gd，任務優先順序由 application/campaign_session.gd 決定；圖片只依實際移動距離播放步伐。這樣換圖不會改變居民的工作規則。

騎士則把「步伐」和「揮劍進度」分開計時，因此邊走邊砍、收招時不必重播跑步第一格。這次先理解這個概念，不需要編輯動畫程式。
