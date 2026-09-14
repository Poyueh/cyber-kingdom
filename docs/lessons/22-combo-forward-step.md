# 第二十二課：調整連斬踏步距離

在 Godot 左下 FileSystem 開啟 data/knight_combo.tres，在右側 Inspector 展開 Forward Step。

- Return Step Distance：第二刀前進距離，預設 22。
- Finisher Step Distance：第三刀前進距離，預設 32。

第一刀固定原地。數字是遊戲世界像素，會隨鏡頭縮放看起來放大。先把第二刀改成 15，儲存後開 scenes/frontier.tscn，按 F6 試玩；不按方向鍵，連按三次 J／劍圖示，觀察第二刀變短。結束後可改回 22。

數值在開始／重開戰役時讀取；修改後請重新執行場景。F5 目前會先進訓練場，F6 執行正在編輯的場景。

程式將「走路」與「出刀踏進」分開，因此調整踏步不會改跑速、傷害或攻擊時間；貼牆仍由 Godot 碰撞阻擋。這次先熟悉這兩個欄位即可。
