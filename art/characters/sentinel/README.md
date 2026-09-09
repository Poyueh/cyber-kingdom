# 鑄造場守衛 v001

由內建 image_gen 生成，沒有使用第三方圖片；[原始圖](source/sentinel-v001.png) 與[完整提示詞](source/sentinel-v001.prompt.txt) 保留。暗鐵鎧甲、黃銅義肢及琥珀刀刃與騎士的青色能源區分陣營。

原圖為 1536 × 1024 RGBA，具有真正透明度；本機處理保留原圖，最近鄰縮放與二值透明度後，得到 [256 × 192 遊戲圖集](processed/sentinel-v001.png)。每格 128 × 96、腳底錨點 (64, 80)，角色約 48 像素高。圖集包含站姿、跨步、舉刀預警與下劈四個姿勢；走路目前只有兩格，仍是第一輪動畫。

`data/sentinel_animation_frames.tres` 使用 idle、run、windup、attack 四段，與騎士共用 FighterVisual。原本的追擊、血量、傷害及預警規則保留；有效下劈時間與騎士一致。死亡隱藏角色後，命中火花可短暫保留。

處理配方見 `animation-recipes.json`，已授權的本機處理方式可重建：

```sh
python3 tools/prepare_knight_art.py --recipes art/characters/sentinel/animation-recipes.json
```

重建需 Pillow 與 NumPy，一般執行遊戲不需要。已目視檢查透明輪廓和真正場景顯示，手機小尺寸辨識度仍待實機驗證。
