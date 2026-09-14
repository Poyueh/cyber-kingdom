# Kingdom 品質目標：賽博中古營地風格樣稿

2026-09-11。使用者指出 16 色粗像素版太簡陋，明確要求以 Kingdom 系列的品質為目標。此前把「像素風」等同極低解析和硬性少色是錯誤解讀；今後以細緻像素輪廓、場景層次、統一美術密度和動畫完成度判斷。

camp-study.png 是內建 imagegen 生成的方向樣稿，尚未切圖、製作動畫、分層或接入 Godot。不能稱作遊戲實際畫面，也不能宣稱已達成 Kingdom 的完整製作品質。圖片仍需像素清理、人物辨識與實際鏡頭尺度驗證。

## 參考與原創內容

已透過瀏覽器實際查看官方網站與 Steam 商店圖，觀察像素密度、暖燈與冷色環境、前後景明暗、水面反射和角色比例。生成時僅將最後一張官方截圖作為風格／細節尺度參考。騎士、義肢工坊、龍晶裝置和營地為新生成內容；未將官方圖作為遊戲資產。

- [Kingdom Two Crowns 官方圖庫](https://kingdomthegame.com/kingdom-two-crowns/)
- [官方 Steam 服裝 DLC 商店頁](https://store.steampowered.com/app/3062350/Kingdom_Two_Crowns_Regents_Royal_Wardrobe/)
- 參照圖： https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3062350/ss_eac894935f3077512c61df4293c949199f4cfdeb.1920x1080.jpg?t=1728551444
- 生成方式：Codex 內建 imagegen，非付費 API 後備。
- 生成原圖：exec-0ac21b49-8749-481f-a3a4-aa4749accded.png；本目錄 camp-study.png 為原樣複製，沒有降色或縮圖。

## 下一個可驗收單元

先用這張樣稿讓使用者評估細緻度與氛圍，再從其中製作一個可走動的營火＋工坊片段。人物約 24–32 邏輯像素高、建築約 65–90 像素高只是生成時的構圖指引，不是已量測或必須套用的硬規格。水面、樹層、燈光必須分層製作；角色須逐格整理，不能把整張樣稿當成遊戲背景便宣稱完成。

## Godot 小教學

一張風格樣稿展示的是最終視覺目標。接入 Godot 時，需要把遠景、樹林、地面、建築和人物分成獨立圖層：遠景低對比，人物與互動物件輪廓清楚，各層再設定不同移動速度形成景深。Nearest 貼圖過濾保持像素邊緣；品質仍取決於造型、光影與動畫，不能靠降解析度代替設計。

## 完整提示詞

Use case: stylized-concept. Create ONE original game art-direction mockup for Cyber Kingdom, a side-scrolling medieval cyberpunk settlement RPG. Landscape 16:9, a single coherent playable scene, no panels.
Input image: the attached official Kingdom Two Crowns gameplay screenshot is a STYLE AND PIXEL-DENSITY reference only. Study its precise small pixel clusters, human-scale buildings, restrained surface detail, layered atmospheric distance, warm lamps against cool weather and reflective water. Aim for that level of polished pixel craftsmanship and calm environmental storytelling. Invent all characters, buildings and composition; do not recreate its particular house, monarch, mount, banner, UI or scenery.
Show a small LAST HUMAN REFUGE on a level mossy stone embankment at blue-hour dusk. Foreground focal point is an original walking knight with steel mechanical legs, a modest crimson cape and a single cyan dragon-crystal power core; a sword hangs by their side. Three distinct small human settlers with visible mechanical prostheses live around a warm compact brazier. A stone-and-timber refuge hall has functional black-steel braces and exposed power cables. Beside it a small open prosthetics workshop contains a visible articulated repair arm and glowing cyan battery; a modest magenta projected rune is the one holographic element. Have a few cyan ground conduits link camp structures. Warm amber interiors communicate shelter, cyan and muted magenta identify crystal machinery. This is recognizably medieval cyberpunk rather than a conventional wooden village.
Composition: eye-level orthographic SIDE VIEW, straight walkable horizontal line around 68 percent image height. The settlement spans the middle half, with generous readable space to either side. Small coherent characters about 24–32 logical pixels high on a roughly 480x270 authored canvas; buildings about 65–90 logical pixels high, not towering over the entire screen. Foreground grasses and reeds in deliberate clusters. Quiet shallow water occupies bottom quarter, with broken horizontal pixel reflections of the lamps and crystal light. Dense layered teal forest in middle distance, muted violet mountain silhouettes and a small ruined gothic spire very far away. A restrained dragon silhouette high above the distant spire; it must not dominate the composition.
Style: meticulous hand-placed MODERN PIXEL ART of Kingdom Two Crowns-level visual sophistication. Crisp consistent square pixel grid, thoughtfully shaped clusters, stepped diagonal edges, clear faces and silhouettes at sprite scale, selective highlights, approximately 32–48 harmonious colors with 3–5 shades per material. Rich atmosphere and natural organic shapes, readable low-detail far background, moderate carefully placed detail on buildings. Show at an integer enlarged pixel scale. NOT primitive NES graphics, NOT giant crude blocks, NOT smooth digital painting, NOT vector art, NOT high-resolution texture reduced with a pixel filter, NO noisy dithering, tiny random brick/window grids, bloom haze, photorealistic lighting, oversized city wallpaper or excessive neon signs. No text, no logos, no HUD, no labels, no title. The output is an art-direction mockup, not a claimed engine screenshot.
