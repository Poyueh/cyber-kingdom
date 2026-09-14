# 第五十五課：讓提示大小成為可調設定

這次鬼魂的提示大小獨立成 `guidance_icon_size`，預設 42。Godot 的 `@export_range` 會讓它出現在 Inspector，往後調整不需要搜尋整段繪圖程式。

小練習：開啟 `scenes/frontier.tscn` 並執行，左側場景樹切到 Remote，展開 HUD，選擇使用 `campaign_guide_view.gd` 的鬼魂節點。Inspector 搜尋 Guidance Icon Size，試著從 42 改成 48，再看提示。Remote 的調整只影響這次執行，停止後會還原。

提示是程式建立的節點，因此要在執行中的 Remote 找，而不是未執行的 Local 場景。先觀察差異即可；尚未收到練習回報，不記為已掌握。
