# 第十九課：調整連斬容錯

在 Godot 左側 FileSystem 找到 `data/knight_combo.tres`，點一下。右側 Inspector 的 **Input Buffer Seconds** 是「提前按下一刀可以保留多久」，目前為 **0.30 秒**。

先開啟 `scenes/frontier.tscn` 再按 F6，或按 F5 從訓練入口進入戰役，連按 J／劍圖示。試著把 Input Buffer Seconds 改成 0.15，再玩一次；你會需要更接近前一刀收勢時按鍵。比較後可改回 0.30。

**Followup Grace Seconds** 是已收完前一刀後，還能算作下一段的時間。它與提前按鍵緩衝不同。這次先只調一個參數，才容易知道手感差別來自哪裡。

目前按一下出一刀，連按接「斜斬 → 回挑 → 重劈」，按住不會自動連打；第三刀必須收招。連斬規則在 domain，這個 Resource 只提供數值，由 bootstrap 轉交，因此你不用改程式就能調整容錯。

本課已提供，尚未收到你的操作回饋，不代表已學會 Inspector 或 Resource。
