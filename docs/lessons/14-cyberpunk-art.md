# 第十四課：在 Inspector 更換場景美術

這次把營地改成「古城石材＋外露機械＋龍晶能源」：黑鋼工坊、義肢工作臂、霓虹符文與能源管線都已接入戰役。

1. 在 Godot FileSystem 選 `data/cyber_frontier_art.tres`。
2. Inspector 的 **Woodland** 是遠景，**Ground** 是地面；展開 **Props** 可以找到 `campfire`、`workshop`、`hall-1` 等物件。把圖片拖入對應欄位即可換圖，不必改遊戲規則。
3. **Show Power Grid** 決定是否顯示已建設施之間的能源流光。先關閉、F5 → REFUGE，再開啟比較差異；這只是畫面效果，不影響建造成本。
4. **Emission Masks** 是與原圖同尺寸的透明發光遮罩，只保留青綠和洋紅光源。更換物件圖時也要更換相同名稱的遮罩，否則亮光可能對不準。

`scenes/frontier.tscn` 的 **WorldView → Art** 指向這份資源。Resource 可以想成一張「素材清單」：畫面向它取圖片，建造與龍晶規則留在內層，因此換美術不必改玩法。

原圖、完整產圖提示詞和切圖方法保存在 `art/cyberpunk/v001/README.md`。圖片以底部中心對齊地面，換圖時保留腳底位置；不要為了圖片大小移動碰撞地板。
