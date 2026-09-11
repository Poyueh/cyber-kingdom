# 賽博龐克中古世界 v001

使用內建 imagegen 於 2026-09-11 生成原創場景素材，已接入 scenes/frontier.tscn。未使用付費 API 後備、外部素材或遊戲截圖。生成內容仍需人工檢查與後續美術統一。

## 美術規格與來源

古老哥德城、巨龍與魔法仍是世界骨架；露出的黑鋼支架、義肢工作臂、龍晶反應爐、粗電纜、洋紅符文投影構成機械文明。青綠表現能源，洋紅表現符文訊號，琥珀表現熱源。保留底部暗霧讓角色與圖示清楚。

sources/ 保留原始輸出並以 .gdignore 排除匯入。skyline-study.png 是首版探索，skyline.png 是以首版為參照加強霓虹與工業構造的版本。buildings.png 為九格建築；props.png 為六格物件；ground.png 為橫向地面條。

工具來源：Codex 內建 imagegen。原始檔案對應：

| 保留來源 | 原始輸出檔 |
| --- | --- |
| skyline-study.png | exec-0bf548f1-24dd-43ed-a11f-0560fb8c7e38.png |
| skyline.png | exec-103d65c6-2f81-4fc4-b4e4-c5133ee1bb67.png |
| buildings.png | exec-1d1a3f5f-9cce-4b60-9416-00ac7a697415.png |
| props.png | exec-6a593cde-ca5b-460d-8a3d-b7792a5e1575.png |
| ground.png | exec-653ea509-a51f-4f3a-b00a-da2a657546e0.png |

## 可重建流程

執行 tools/prepare_cyberpunk_art.py（Pillow、NumPy），依保留原圖手動框選九個建築、六個物件，清理 alpha、保留半透明洋紅投影，再以最近鄰縮放。已獲使用者授權使用本機工具編修圖片。ground 為 768×111，skyline 為 960×430；15 張 sprite 各有相同尺寸的 emission mask，共 32 張遊戲 PNG。尺寸、切格與 alpha 門檻集中在處理腳本。腳底以底部中心定位，不改碰撞位置。

新主題由 data/cyber_frontier_art.tres 裝配；原人物、植物、礦物繼續沿用既有素材。資源的 Emission Masks 控制柔和脈動；Show Power Grid 控制已建設施之間的裝飾線路，沒有新增供電遊戲規則。

實際畫面見 docs/previews/cyberpunk-*.png 與 cyberpunk-pulse-v001.gif。建成營地的畫面使用展示用已建設施配置，夜景直接設定夜間；不是正常流程通關證據或手機效能測試。

## 完整生成提示詞

### cyber_bg_prompt

Use case: stylized-concept. Production game background, original cyberpunk medieval dark fantasy pixel art. Very wide landscape panorama approximately 2.25:1. A world ruled by ancient dragons and magic, humans surviving in improvised dragon-crystal-powered mechanical fortresses. Strong recognizable cyberpunk visual identity: gothic stone spires fused with dense vertical industrial megastructures, stacked salvage-metal dwellings built into ruined castle walls, exposed huge cables, cyan power conduits, restrained hot-magenta neon rune glyphs, antenna arrays, steam exhaust and luminous crystal reactors. A large distant dragon silhouette circling the wired citadel. Night teal-blue sky, violet haze and amber windows, volumetric pixel fog, rainy atmosphere. Dense city occupies the middle and far distance, ruin arches at edges, a few twisted trees only; NOT a forest-dominated landscape. Important game-layer constraints: no characters, no UI, no legible words or logos, no modern cars or guns. No foreground floor, no foreground platforms or huge foreground objects: bottom quarter is quiet dark mist so separately drawn characters and buildings read clearly. Crisp deliberate low-resolution pixels, coherent 2D side-scrolling game view, distant layers lower contrast than foreground game assets. Sophisticated lighting, limited palette, clear silhouette separation. This is a background plate, not a gameplay screenshot.

### cyber_buildings_prompt

Use case: stylized-concept. Original game asset sprite sheet for Cyber Kingdom, crisp professional pixel art, genuine transparent background, exactly NINE separated individual building sprites in a regular 3-column x 3-row grid. No grid lines, no labels, no text. Generous empty transparent margins between cells, every building fully visible and grounded on its own baseline. Side elevation, very slight visible right side, no isometric ground diamonds, no ground shadows or scenery. World: humans survive in medieval dragon-ruled lands using salvaged cybernetic machinery powered by cyan dragon crystals. All sprites must look CYBERPUNK MEDIEVAL: gothic stone forms, riveted black steel exoskeletons, thick exposed power cables, visible hydraulic machinery, prominent cyan light strips and crystal cores, occasional magenta holographic rune emblems, warm amber work lights; NOT plain wooden huts or steampunk brass. Coherent dark steel/teal/violet palette, thick readable pixel clusters suitable for each building resized to about 130-180 game pixels wide. Row 1 left-to-right: (1) small first-tier refuge gatehouse with armored stone arch, exposed crystal power cell and patched metal roof; (2) upgraded two-storey refuge with cyan conduits, mechanical buttresses and a magenta rune banner; (3) imposing third-tier gothic cyber-citadel with tall spire, reactor heart and crystal-powered mechanical crown. Row 2 left-to-right: (4) open-front prosthetic tools workshop with hanging articulated mechanical limbs, cyan powered workbench and hammer rune symbol; (5) knight armory with swords, powered armor racks, shield-shaped neon emblem, NO firearms; (6) prosthesis forge with luminous dragon crystal generator, furnace amber glow, mechanical arms and cable coils. Row 3 left-to-right: (7) narrow protective beacon tower with floating cyan crystal held in a metal ring and energy emitters; (8) narrow fortified wall barricade with upright steel plates, stone footing, cyan energy slit and small rune shield; (9) frontier outpost with compact metal awning, crystal battery, antenna mast and supply crates. Consistent hand-crafted pixel art, no smooth illustration, all nine distinct functional silhouettes, transparent cutouts only.

### cyber_props_prompt

Use case: stylized-concept. Original pixel-art game props sprite sheet, exactly six isolated objects in 3 columns and 2 rows with generous separation, fully transparent background, no labels/text/grid, side view with very slight right face, consistent dark steel + cyan dragon-crystal light + restrained magenta/amber accents. Cyberpunk medieval humans surviving among dragons, salvaged advanced machinery clamped onto ancient stone forms. Readable crisp chunky pixel clusters for objects about 50-110 pixels wide in game. TOP ROW left to right: (1) starter campfire: warm orange real fire burning inside a circular improvised steel brazier on old stones, beside a clearly visible cyan crystal battery and connected thick cables, no hut or settled buildings; (2) undeveloped construction site marker: low stack of steel beams and stone blocks with small luminous magenta wireframe gothic-arch hologram projected from a portable cyan battery, no letters; (3) crop farming bed: low medieval raised earth planter with vivid green edible crops, robotic irrigation arms, exposed cyan pipes, small crystal pump, crops remain obvious. BOTTOM ROW left to right: (4) roadside utility relay: tall narrow ancient stone post braced with black metal, hanging cables and bright cyan crystal lamp, medieval neon streetlight; (5) sealed treasure chest made from wood reinforced with thick black armored plates and clear cyan glowing lock, NO weapons; (6) OPEN version of the same treasure chest, hinged lid raised and interior lined with dim cyan light, EMPTY so the crystals can be spawned separately in the game. Actual alpha transparency, no platform or floor outside individual objects, no background or external shadows, no modern city skyline.

### cyber_ground_prompt

Use case: stylized-concept. A single horizontal terrain-platform TILE for a 2D side-scrolling cyberpunk medieval pixel-art game. Transparent empty background above and below, one very wide low strip with approximately 6:1 width to height silhouette, centered and spanning nearly the full image width. Straight continuous level walkable TOP EDGE at exactly the same height all the way across, left and right cut edges designed to repeat seamlessly. Top surface: worn dark slate stone pavement with small steel grates, thin cyan-lit power channel and occasional restrained amber safety marks, no grass carpet. Cross-section beneath top: ancient ruined masonry and dark rock packed with thick salvaged industrial pipes, riveted black metal beams, sparse cyan cables and a few tiny magenta crystal nodes embedded below the walking surface. Bottom fades into almost-black layered stone. Crisp chunky hand-crafted pixel art, limited charcoal/bluegray/teal palette, bright accents sparse. No characters, no buildings, no signs, no words, no floating objects, no raised obstacles above top edge. This is an isolated platform texture strip, not a landscape scene.

### cyber_bg_revision_prompt

Use case: style-transfer. Edit the reference background for our game. Preserve its wide composition, distant flying dragon, major gothic spires, empty dark mist at bottom for gameplay layers, and crisp pixel-art rendering. Push the built environment MUCH MORE unmistakably CYBERPUNK. Replace about half of the mid-distance stone dwelling facades with densely stacked weathered dark-metal habitation modules, service balconies, exposed industrial ventilation units, air ducts, antenna clusters, huge overhead electrical cable bundles and armored cyan power conduits. Add several clearly visible vertical rectangular magenta/cyan NEON rune sign panels and holographic pictogram screens attached to the gothic towers; geometric icon glyphs only, NO readable words. Large central spire has advanced industrial reactor cladding and angular metal machinery visibly bolted around its ancient stone shell. Show low-tech human improvisation beneath a high-tech skyline, damp polluted violet haze and scattered amber work lights. Keep medieval pointed arches and dragon world recognizable, but the metal infrastructure and neon panels must be prominent at game-screen size. Strong cyberpunk teal/magenta contrast with dark silhouettes. No cars, firearms, modern roads, people, UI or foreground obstacles. Bottom quarter stays low-detail dark fog. Maintain original aspect ratio.
