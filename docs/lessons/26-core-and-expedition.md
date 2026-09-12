# 第二十六課：調整核心生命
在 Godot FileSystem 選 data/campaign.tres，於 Inspector 展開 Core and Expedition。Core Max Hp 預設 180；暫時改成 240，儲存後打開 scenes/frontier.tscn 按 F6。

畫面中央營火圖示旁會顯示 240，這就是全局需要保護的核心。Core Recharge 控制每次填滿充能格回復多少，Rift Seal Seconds 控制工匠需要工作的時間，與騎士生命分開。

這些 Resource 數值在開始一局時傳入規則層。正在執行的舊局不會自動更新，要重開場景；已匯出的桌面程式則需重新打包。試完可改回 180。

本課尚未收到操作回報，不記為已掌握。
