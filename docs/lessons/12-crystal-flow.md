# 第十二課：不改程式，調整龍晶的吸收手感

1. 在 Godot 左側 FileSystem 點 `data/campaign.tres`。
2. Inspector 展開 **Crystal Motion**。
3. 將 **Magnet Radius** 從 112 改成 160，按 F5 → REFUGE／避難所。
4. 按 Q 丟出一顆，稍微走開，等約 2 秒後再靠近：更遠就能開始吸收。
5. 試完可還原 112。數字越大，探索時越容易撿到龍晶。

其他三個欄位：**Magnet Speed** 是飛向騎士的速度；**Throw Grace** 是剛丟出後不吸回的秒數；**Crystal Radius** 控制場景龍晶大小，不影響頭頂的投入格。預設分別是 300、2、9。

這就是 Resource 的用途：把需要常調的設計數值放進 Inspector。背包是否滿、是否付款的規則在 `domain/crystal_pouch.gd`；場景動畫在 `presentation/ambient_motion.gd`。調美術尺寸不會改掉背包容量。

想換流浪者待機圖：開 `scenes/frontier.tscn`，選 WorldView，在 **Wanderer Idle** 換圖。現在的格式是橫排六格，每格 64×64，腳底位於第 61 列；保持格式即可沿用播放邏輯。

你可以先試一次「吸收範圍 112／160」的差異，再告訴我哪個舒服。教學紀錄仍以實際回饋為準，這一課不表示你已熟悉 Resource。
