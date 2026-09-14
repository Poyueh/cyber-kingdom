# 第四十三課：Godot 與 Xcode 各負責什麼

Godot 把場景、圖片、音樂及程式打包成 PCK，再產生 Xcode 專案；Xcode 把它編譯成 iPhone App，並用 Apple 團隊與裝置描述檔完成簽署。

這次已在 Xcode 開啟 CyberKingdomDemo 專案。你可以選左側專案，再選 CyberKingdomDemo target 的 Signing & Capabilities，查看 Team 是否為自己的 Personal Team，以及 Automatically manage signing 是否開啟。

看到 BUILD SUCCEEDED 不一定可以裝手機：本次成功編譯先關閉簽署，用來確認程式與資源；真正安裝仍需要連接受信任的 iPhone，讓 Xcode 產生描述檔。

遊戲內容仍在 Godot 修改。builds 裡的 Xcode 專案是匯出產物，下次匯出可能重新產生，因此玩法與素材不要只改在這裡。

使用者已回報成功登入並看到 Personal Team；本課的 target／簽署觀察尚未回報，不記為已掌握。
