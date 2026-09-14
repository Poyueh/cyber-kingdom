# 第五十二課：在 Inspector 調整巨龍

Godot 的 Resource 是可在 Inspector 編輯的資料。這次把巨龍數值放在 `data/campaign_tuning.gd`，玩法程式讀取資料後再計算，不必為了調生命改戰鬥流程。

在 Godot 的 FileSystem 點選 `data/campaign.tres`，找到 **Final dragon**。`Dragon Baseline Day` 是強度下限日；`Dragon Health` 是基本生命，`Dragon Daily Health` 是晚一天增加的生命。

例如保持第 6 天基準，將每日生命增加從 240 改成 120：第 7 天召喚會從 2040 變成 1920 生命；第 1～6 天仍是 1800。先在自己的 feature 分支調整，再按 F6 開新旅程。已存旅程保留建立時的規則，因此不會被新設定偷偷改掉。

這次先練習找到欄位、理解計算，不必立刻改值。尚未收到實際操作回報，不記為已掌握。
