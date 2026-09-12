# 第二十四課：調整居民收工時間
本次只認識一個 Resource 欄位，不需要改程式。

1. 在 Godot 的 FileSystem 點選 data/campaign.tres。
2. 在 Inspector 展開 Resident Night Safety，找到 Return Margin。預設為 15，表示把走回營地所需時間之外，再預留 15 秒。
3. 若想觀察居民更早回來，可以暫時改成 30，儲存，開啟 scenes/frontier.tscn 並按 F6。招募工匠、指派遠處資源，觀察傍晚回營；比較完可改回 15。

這不是「日落前固定 15 秒所有人同時回來」：遠處的人需要更多路程時間，所以會先動身。天亮後會繼續原工作。旁邊 Hunter Damage 與 Hunter Interval 控制獵人的夜間防守；數字透過 Resource 送進遊戲規則，動畫本身不決定傷害。

F5 目前仍由訓練場進入，F6 才是執行目前打開的戰役場景。修改後停止再重開，新的數值才会套用。使用者尚未回報完成此練習，不能記為已掌握。
