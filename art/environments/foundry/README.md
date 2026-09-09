# 古城鑄造場 v001

由內建 image_gen 生成，未使用第三方參考圖。[原始全景](source/foundry-v001.png) 為 2172 × 724；[完整提示詞](source/foundry-v001.prompt.txt) 保留。石拱、符文導管、熔爐與遠方龍影延續原有世界方向；龍影僅是背景裝飾。

以最近鄰縮成 [900 × 300 遊戲背景](processed/foundry-v001.png)，在場景中兩倍顯示。背景是一張全景圖，目前尚未拆分成視差圖層或可無縫拼接圖塊。前景石磚與平台仍由 Godot 原生繪圖呈現，位置與現有碰撞吻合；生成圖不提供碰撞。

重建方式（需要 Pillow）：

```sh
python3 tools/prepare_foundry_backdrop.py
```

原圖不覆寫；已用 Godot 真正渲染檢查前景輪廓、敵人辨識與平台位置。下一輪再依試玩需求製作分層背景與地形圖塊。
