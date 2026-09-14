# 第二課：看懂騎士待機動畫

這次只學一件事：找到角色的四個畫格，觀察播放速度。

1. 在 Godot FileSystem 開啟 `scenes/knight_visual.tscn`。
2. 選擇 KnightVisual，點 Inspector 的 Sprite Frames 資源。
3. 在 SpriteFrames 面板選 `idle`，可以看到四個畫格；按面板播放按鈕預覽。
4. 比較四格的披風和肩膀，理解動畫是連續播放不同圖片。需要時可把 FPS 從 4 改成 6 看差異，練習後改回 4 並保存。
5. 按 F5 回到完整訓練場，放開移動鍵觀察待機；按 Esc 暫停，畫格也應停止。

`AnimatedSprite2D` 是顯示動畫的節點，`SpriteFrames` 是保存圖片順序與播放速度的資源。這是 Godot 官方支援的角色動畫方式：[官方 2D 動畫教學](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html)。

本專案另由呈現腳本以遊戲時間推動畫格，使 Esc 與切出視窗的暫停保持一致；因此沒有開啟節點自動播放。Godot 編輯器的面板預覽仍可用來看素材。

每格圖片透過 AtlasTexture 引用圖集的一部分。目前新版已把原圖校正為每格 128 × 96 的遊戲用圖，原始生成 PNG 另行保留：[官方 AtlasTexture 說明](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html)。

完成後可以用自己的話說說：如果想讓待機更快，是改傷害、角色移動速度，還是 SpriteFrames 的 FPS？任何步驟不清楚，直接告訴我卡在哪裡；提供這份教學不代表我會把你記錄為已學會。
