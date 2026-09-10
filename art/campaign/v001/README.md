# 營火戰役像素素材 v001

透過內建 imagegen 產生原創營火、石礦、藥草、建設標記，已接到 `presentation/campaign_view.gd`。沒有使用外部付費 API 或下載他作遊戲素材。

- 遊戲用圖：`campfire.png`、`stone.png`、`herbs.png`、`plot.png`。
- [完整提示詞](sources/prompt.txt)；[保留原圖](sources/props.png)。
- 原圖具有 RGBA 透明通道，使用既有授權的本機 Pillow 工具裁切與最近鄰縮放；配方 `tools/prepare_campaign_art.py`。
- sources/.gdignore 排除原始大圖的遊戲匯入。遊戲使用已整理 PNG，不依賴 Python 或產圖服務。

這是已接入的原型素材，整體像素密度、動畫與手機可讀性仍可隨後續試玩調整。
