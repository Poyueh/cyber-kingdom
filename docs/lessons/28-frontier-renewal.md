# 第二十八課：調整營地等候名額
在 Godot FileSystem 選 data/campaign.tres，展開 Inspector 的 Frontier Renewal。Camp Waiting Limit 預設 2，代表同一探索營地最多兩位流浪者等候招募。

暫時改成 1，儲存後開 scenes/frontier.tscn 按 F6。營地已有人等待時，日出不再補人；招募帶走後，下一次真正熬過夜晚才會補一位。只把遊戲暫停或走開再回來不會刷新。

Tree Timber 是每棵樹的木材，Population Limit 則限制整張地圖的人物數。先保持這兩項不變，只觀察等待名額。試完可以把 Camp Waiting Limit 改回 2；已匯出程式需重新打包。本課尚無操作回饋，不記為已掌握。
