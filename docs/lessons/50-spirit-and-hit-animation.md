# 第五十課：把動畫和遊戲判定分開

這次的龍晶殘影只讀取「下一個建議目標」，不會替騎士走路或花錢；受擊動畫只讀生命與護盾損失，不會額外扣血。這樣改動畫幅度不會不小心改變遊戲難度。

在 Godot 開啟 `scenes/frontier.tscn`，選 Knight 下的 KnightVisual：Inspector 的 Hurt Seconds 控制回穩時間，Hurt Distance 控制騎士受擊的視覺偏移。可以先把 Hurt Distance 從 7 改為 5，比較較輕的反應；這不會改碰撞框或真正的擊退距離。

殘影的距離和高度在 `presentation/campaign_guide_view.gd` 的 Spirit Distance／Spirit Height；目前由 HUD 建立，可在執行後的 Remote 節點樹查看。HUD 的 First Day Guidance 與 Expedition Guidance 可分別關閉建國／遠征建議。

尚未收到實作或理解回報，不把本課記為已掌握。
