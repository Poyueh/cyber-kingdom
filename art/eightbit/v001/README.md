# 8-bit 風格營地原型 v001

2026-09-11，使用者指出上一版過度精細，要求更接近 8-bit 像素遊戲。這版改成大色塊、簡化輪廓、少量霓虹與固定 16 色素材；用可玩營地先驗證美術方向。這是 8-bit 風格目標，沒有模擬特定主機的硬體限制。

## 來源與處理

以 Codex 內建 imagegen 生成全新背景、十六格物件圖集與地面；原始輸出保存在 sources/，由 .gdignore 排除匯入。沒有使用付費 API 後備。

- skyline.png：exec-b9f46fd7-d5a0-4581-949d-9b480ff850e5.png
- sprites.png：exec-45c14a52-8076-40a8-8614-36ff77396e0e.png
- ground.png：exec-dec1225a-b31a-4dac-a584-d0e6486c68d0.png

使用先前已授權的本機 Pillow／NumPy 處理，執行 tools/prepare_eightbit_art.py 可重建。圖集去透明邊界後縮成小圖，套固定色盤，以最近鄰整數四倍放大；建築大多只有約 20–53 個邏輯像素寬。背景 240×108 放成 960×432，地面 192×28 放大並裁到原有地面尺寸。沒有柔焦或抖色；來源自帶的細微漸層經色盤統一。

色盤：#080c1c #142040 #263858 #465878 #7888a0 #c2d4d8 #12606c #20b0bc #60e0d0 #b83888 #e870a0 #d88038 #f8d878 #488858 #785848 #c09870。

礦物、草藥、野果、鹿與人物沿用本專案既有原創圖片，降低解析度並套同一色盤。騎士與居民是過渡處理，尚非逐格重畫的最終 8-bit 角色。騎士保留所有 atlas 尺寸、動畫格數、裁切區、速度和各格時長；在呈現層替換貼圖，不覆寫使用者編輯的 SpriteFrames 資源。

接入 data/eightbit_frontier_art.tres 與 scenes/frontier.tscn。HUD 圖示、數字與夜襲敵人仍沿用原版；不宣稱整款美術已完成。完整提示詞如下。

## 背景

Create a TRUE old 8-bit console pixel-art BACKGROUND for an original side-view cyber-medieval game. This is deliberately very low resolution: design on a 256 by 112 logical pixel grid, then show enlarged square pixels with exact hard edges. Wide 16:7 landscape. Use only 12 flat colors: near-black navy, dark blue, muted purple, blue-gray, dark teal, teal, cyan, pale cyan, magenta, dusty pink, amber, pale yellow. Large simple clusters, broad EMPTY areas, silhouettes, minimal ornament. NO dithering, gradients, glow blur, anti-aliasing, realistic shading, tiny details or painterly textures. Think sparse readable 1980s cartridge background, not modern detailed pixel illustration. Scene: a distant medieval castle with just five chunky towers, two hanging magenta rune signs each one simple symbol, a few thick cyan power cables, a large simple dark dragon silhouette in the sky. Castle occupies upper two thirds; lower third is solid dark navy mist made of only two stepped color bands. A small angular moon at upper left. Buildings are mostly dark silhouettes, no grids of tiny windows, no individual bricks, no fine machinery, no foreground ground or people. Modest cyan and magenta accents convey crystal-powered cyberpunk, stone spires convey medieval magic. Artwork fills frame; no text, border, HUD, logo or characters. Make it striking through composition and silhouette, NOT detail.

## 物件圖集

Create one transparent PNG SPRITE SHEET for an ORIGINAL 8-BIT cyber-medieval side-scrolling game. Exactly 4 columns by 4 rows, sixteen equally spaced cells, transparent gutters. Design each sprite on a maximum 48x48 logical pixel grid, enlarged with uniform huge square pixels. Simple angular readable silhouettes, black/navy outlines, only 3 to 5 flat colors per object from navy, bluegray, teal, cyan, magenta, amber. NO anti-aliasing, realistic shading, texture noise, gradients, glow haze, isometric view, floor shadows, labels or tiny details. This must look like a primitive but attractive 1980s console cartridge tile set, NOT detailed modern pixel illustration. Each building has only ONE large cyan energy stripe or magenta symbol; simple blacksteel framework and a medieval roof. Pure side elevation, bottom centered, whole object inside its cell, lots of transparent space.
Row 1 left to right: 1 small refuge gate with one cyan battery, 2 upgraded stone hall with two simple towers, 3 castle keep with three battlements and one magenta banner, 4 mechanical prosthetic workshop with large cyan robot arm silhouette.
Row 2: 5 armory with one big sword symbol, 6 forge with amber furnace mouth and cyan crystal, 7 crystal beacon on slender blacksteel pedestal, 8 short reinforced defensive wall with cyan vertical strip.
Row 3: 9 small frontier outpost with antenna, 10 campfire in a mechanical brazier with cyan battery beside it, 11 simple magenta wireframe construction projection above small pad, 12 two green crop sprouts in a dark mechanical planter.
Row 4: 13 cyan roadside energy lamp, 14 small CLOSED armored treasure chest with cyan latch, 15 same treasure chest OPEN with lid upright, 16 sparse angular pine tree with one cyan crystal on trunk.
Hard pixel steps clearly visible, large solid shapes, no more than two shades for any material. Actual transparent alpha background, no checkerboard baked into picture.

## 地面

A single horizontal ground tile strip for a TRUE primitive 8-bit side-scroller, 3:1 image. Design on a 96x32 logical pixel grid enlarged with perfectly hard square pixels. Only SIX flat colors: near-black navy, dark blue, muted bluegray, teal, cyan and dull amber. Top surface exactly flat horizontal, thin cyan energy rail, then just two rows of LARGE rectangular dark stone slabs with dark mortar lines. One simple thick right-angle pipe every third slab. Very sparse, clean, readable, NO rubble, chips, texture, dithering, speckles, gradient, small details, shadows or perspective. Each slab is a large solid rectangle with one straight lighter upper edge. Medieval stone plus crystal-powered cyber machinery, but simplicity takes priority. Whole image is filled by ground cross section, no sky, no object above the top surface, no transparency, no text, no border. Left and right edge must match for horizontal repetition. Looks like a minimal Nintendo-era tile strip, NOT modern pixel illustration.
