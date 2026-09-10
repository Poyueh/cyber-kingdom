# 騎士移動 v002

使用內建 imagegen，以既有騎士造型為參考，生成八格跑步和四種跳躍姿勢。沒有使用付費外部 API。原圖有真實 RGBA 透明背景。

- [生成提示詞](sources/prompt.txt)
- [保留原圖](sources/motion.png)
- 遊戲圖集：run.png、jump.png。
- 可重建的切格／對齊配方：tools/prepare_knight_motion.py，使用已獲授權的本機 Pillow 處理。
- data/knight_motion_frames.tres 只含 run 與 jump；不覆寫使用者編輯的原劈砍／衝刺資源。

四種跳躍姿勢由垂直速度選擇，實際位移仍由角色物理計算。跑步與披風為新畫格，細部像素一致性及轉場仍可後續試玩修整。
