# 第四十四課：用玩家指南認識遊戲場景

這次先練習在 Godot 找到畫面，不必改程式。你尚未回報完成先前練習，因此這份教材不代表已掌握。

1. 在 Godot 左側 FileSystem 找到 `scenes/frontier.tscn`，雙擊開啟。
2. 按 F6 執行目前場景，對照玩家指南「操作」章節，試 A／D 移動、J 出刀與 E 現場互動。
3. 注意「場景」是 Godot 組合角色、地圖與介面的地方；玩家指南的 HTML 是外部說明頁，不是 Godot 場景。

想改玩家看到的說明時，編輯 `docs/player-guide/index.html`，重新執行 `python3 tools/build_player_guide.py` 即可。修改 HTML 不會改變騎士傷害、體力或存檔。

下次回報你是否能找到 frontier.tscn，以及 F6 後是否看見營火，就能決定下一課要從場景樹還是 Inspector 開始。
