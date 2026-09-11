# 中等細緻度避難所素材 v001
以已大致認可的 art/concepts/kingdom-quality-v002/camp-study.png 為基準。這是第一段可玩場景的美術接入，並非全遊戲最終品質。

## 來源與重製
sources/background.png、forest.png、props.png、ground.png 由內建 imagegen 依上述樣稿生成；完整提示、來源路徑保存在 sources/generation.json。沒有下載 Kingdom 的遊戲素材。原圖留存，商店提交前仍須完成全專案素材來源盤點。

使用 tools/prepare_refuge_art.py（Pillow、NumPy）重製：營地、工坊、營火與路燈從透明四格圖分離；背景、森林與石岸水面各自成層。以目標尺寸的一半整理像素，再最近鄰放大；每圖最多 96 色，並非強制 16 色。來源透明度轉為乾淨的透明邊緣。

其餘設施從 art/cyberpunk/v001 過渡，施工標記由 art/campaign/v001/plot.png 取用；採集物、居民來自 frontier/v002、campaign/v001、ambient/v001。騎士來自原 processed 與 motion-v002 貼圖，保留整張尺寸、原切格和時序，尚未逐格重畫。腳本記載每個對應來源。

## Godot 裝配
data/refuge_art.tres 指派所有貼圖，scenes/frontier.tscn 使用此主題。data/frontier_art.gd 新增 forest_layer、forest_scroll、show_river；預設不影響舊主題。
presentation/refuge_scenery.gd 只負責繪製森林與水面。倒影僅包含營火、燈和已建成的主要設施；不是全世界的鏡像。光線不代表新增供電規則。
遠景龍影與城堡是背景，尚無龍戰或城市探索。
