# 目前採用的像素美術基準 v002

使用者針對這張樣稿回覆「差不多」，因此將它作為目前製作基準，後續仍可細修。這不是所有正式素材的最終核定，也不代表遊戲已經換上這版。

## 方向

- 中等像素細緻度，輪廓清楚；保留光影與景深。
- 房屋保留結構、材質差異與能源裝置，減少磚紋、鉚釘和碎線。
- 人物保留騎士、居民與機械義肢辨識，不縮成幾個難辨認的色塊。
- 森林以成組樹叢和前後明暗組織；水面使用成組的水平反光，減少碎點。
- 暖色營火與青綠龍晶、少量洋紅符文維持賽博中古風格。
- 不把固定 16 色、極低解析或高解析插畫作為目標；後續圖片應與本樣稿並排比較。

## 原圖與用途

camp-study.png 原樣保存內建 imagegen 輸出 exec-31a392f6-9bf5-43d4-80a5-8f201725635d.png。以 v001/camp-study.png 為編修參照，減少細節；沒有使用 API 付費後備。本目錄 .gdignore 排除 Godot 匯入。

這是整張風格樣稿，尚未分層或接入遊戲。下一個美術開發單元是營火＋工坊的一段可走動場景，再統一人物與其他設施。提示中的解析度與色數是產圖指引，未作為輸出圖片已符合的技術測量結果。

## Godot 小教學

將樣稿落地時，先做獨立的遠景、森林、地面、建築與角色素材。在 Godot 的實際遊戲視窗比較人物大小和像素尺度；只看放大的素材圖，容易誤判遊玩時的細緻度。原始動畫速度與格數仍由既有 SpriteFrames 管理。

## 完整編修提示詞

Edit this exact scene to visibly REDUCE DETAIL to a polished, medium-resolution 2D game pixel-art style.
Keep its wide side-view composition, building positions and sizes, knight, three settlers, mechanical limbs, workshop, cyan dragon-crystal energy, magenta hologram, warm campfire, layered forest, distant castle/dragon and water reflections.
The source is too detailed and illustration-like. REDRAW the forms with much larger coherent pixel clusters on an approximately 480 x 270 logical canvas, then display at clean 3x nearest-neighbor scale. Every smallest pixel should be a clearly visible square, consistent across buildings, people, foliage and reflections. This is a genuine simplification of drawings, not a blur or mosaic filter.
Reduce visible texture marks by about 70 percent. Houses: broad timber/stone planes with only a handful of structural seams, NO individual tiny bricks, rivets, roof shingles or wood grain. Characters: around 24 to 30 authored pixels high, readable helmet, cape and mechanical limb silhouettes, 2–3 shade clusters per body part, NO tiny face or joint rendering. Trees: broad overlapping foliage clusters with stepped outlines, 3 shades per depth layer, NO tiny leaves or needles. Water: spacious dark bands with a few grouped horizontal reflection strips, NO countless glitter points. Sky: clean stepped cloud shapes, NO fine speckling.
Preserve beautiful warm/cool lighting, harmonious dusky colors, organic silhouettes, atmosphere and depth. Around 48–64 colors with selective local ramps rather than a crude 16-color restriction. The result must be intermediate in complexity: much less intricate than this source, substantially richer than primitive NES flat-block art. Think actual restrained Kingdom-style gameplay pixels with readable small sprites, NOT pixel-painted promotional illustration.
No change of scene, no new structures or characters, no UI, text, borders, labels, smooth shading, anti-aliasing, dithering or glow blur.
