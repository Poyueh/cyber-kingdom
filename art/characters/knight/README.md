# 機械騎士動作 v001

訓練場已接入四格待機、六格跑步與四格揮劍。跳躍與衝刺暫用中立姿勢，守衛和場景仍是臨時美術。這是可玩版本的第一輪素材，還需要動作打磨與手機辨識度驗證。

## 來源與處理

素材由內建 image_gen 生成，沒有下載第三方角色圖。跑步與揮劍以本專案原始待機圖作為角色參考。

| 動作 | 原始圖 | 完整提示詞 | 遊戲使用圖 |
| --- | --- | --- | --- |
| 待機 | [idle-v001.png](idle-v001.png) | [提示詞](idle-v001.prompt.txt) | processed/idle-v001.png |
| 跑步 | [source/run-v001.png](source/run-v001.png) | [提示詞](source/run-v001.prompt.txt) | processed/run-v001.png |
| 揮劍 | [source/attack-v001.png](source/attack-v001.png) | [提示詞](source/attack-v001.prompt.txt) | processed/attack-v001.png |

跑步與揮劍原圖含有畫進圖片的棋盤背景，並非真正透明。使用者已明確同意本機 Python 去背與切格校正；所有生成原圖保留不覆寫。處理工具只移除與外緣連通的淺灰背景，再以最近鄰縮放、二值透明度與逐格腳底錨點組成遊戲用圖。這是針對目前素材的配方，新角色需重新檢查，不能假設同一去背門檻適用所有圖片。

## 遊戲用規格

- 每格 128 × 96，腳底錨點 (64, 80)，角色身高約 48 像素。
- 待機圖 256 × 192；跑步圖 384 × 192；揮劍圖 256 × 192。
- 新資源為 `data/knight_animation_frames.tres`；待機 4 FPS，跑步 12 FPS。
- 待機目前按新圖集的 0、1、2、3 順序播放；原始待機資源仍保留供參考，未覆寫其編輯內容。
- `scenes/knight_visual.tscn` 採 1:1 縮放、Nearest filter 與 (0, -32) 位置，維持共同腳底。
- 揮劍四格對應起手、有效揮擊兩格、收招；遊戲依戰鬥進度選格，SpriteFrames 的 attack FPS 只供編輯器預覽。
- 預設整刀 0.22 秒：前 25% 起手，中間 50% 可命中，最後 25% 收招。刀光與傷害使用相同時間窗口。

## 重建

已提交處理結果，一般開啟 Godot 不需要安裝圖片工具。只有重新處理素材時，需要 Python 3、Pillow 與 NumPy，並在專案根目錄執行：

```sh
python3 tools/prepare_knight_art.py
```

裁切範圍、比例與腳底位置記錄於 `animation-recipes.json`。工具不需要網路，也不呼叫付費服務。

原圖、處理後畫格及 Godot 真正渲染結果已目視檢查；[近景動作預覽](../../../docs/previews/knight-run-attack-v001.gif) 展示實際跑步與擊敗守衛。展示用攝影機放大兩倍，專案預設鏡頭未改動。
