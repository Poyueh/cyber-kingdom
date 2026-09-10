# 居民開拓美術 v002

這套素材使用內建 image_gen 生成，已切格、保留透明輪廓、整理成遊戲像素尺寸，並接入 Godot。沒有使用 API／CLI 付費後備模式。

## 原圖與提示詞

完整五組生成提示詞：[sources/prompts.json](sources/prompts.json)。原圖：

- [背景](sources/background.png)：龍晶森林、古城遠景、月光與地面。
- [資源圖集](sources/props.png)：樹、礦、野果、回收箱、拓荒站、農作、樹樁與鹿。
- [工匠四種動作](sources/engineer.png)：行走、作業、搬運、待機。
- [其他居民](sources/citizens.png)：流浪者、居民、農夫、獵人與守備兵。
- [建築](sources/buildings.png)：三級聚落、工坊、武器坊、義肢爐、護民塔與防線。

原圖保持生成內容；`sources/.gdignore` 讓 Godot 不把大張原稿當作遊戲資源。

## 遊戲使用檔案

- `woodland.png`、`ground.png`：960×430 背景與768×111地面；地面上緣對齊碰撞高度430。
- `tree.png`、`tree-plain.png`、`crystal.png`、`berries.png`、`cache.png`、`stump.png`、`deer.png`：有限資源與清理狀態。普通樹的晶體色區調成樹皮色，含龍晶的樹保留青色提示，詳細產出也顯示於工作標記。
- `outpost.png`、`crops.png`：拓荒站與農作。
- `hall-1.png`、`hall-2.png`、`hall-3.png`、`workshop.png`、`armory.png`、`forge.png`、`beacon.png`、`wall.png`：聚落設施。
- `engineer-atlas.png`：384×256，6欄4列，每格64×64；走路／作業／搬運／待機。
- `citizens-atlas.png`：320×256，5欄4列，每格64×64；各職業四格行走。

這些檔案由 [frontier_art.tres](../../../data/frontier_art.tres) 統一引用。素材是新的整合版本，仍需持續人工檢查像素輪廓、手部／器具、動作與手機可讀性，不能把生成圖集視作最終動畫品質保證。

## 可重建配方與檢查

使用 [prepare_resident_art.py](../../../tools/prepare_resident_art.py)；依賴 Pillow 與 NumPy，執行位置可任意。配方只讀本資料夾保存的原圖，使用生成的 alpha、裁切、主體連通區清理及最近鄰縮圖。居民以腳底作錨點，工匠各格採同一比例；來源的其他居民最後一列較矮，先按實際列界切出，再校正角色高度。

[recipe.json](recipe.json) 保存資源裁切範圍和工匠腳底錨點。圖集邊界曾混入鄰格碎片，已在主體清理時移除。沒有以透明格網當作真正透明，也沒有把生成原稿留在專案外作執行依賴。

Godot 實際渲染已檢查聚落、森林、工作、搬運與拓荒站完成；預覽見 docs/previews/resident-*-v002。作業動畫正常播放，長途搬運等待的展示採同一模擬規則加速；這是開發驗證，不代表手機實機通過。
