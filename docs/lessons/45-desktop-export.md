# 第四十五課：Godot 的桌面匯出

在 Godot 上方「專案 → 匯出」可以看見 `macOS Demo` 與 `Windows Demo`。它們是相同遊戲的兩組打包設定，不需要維護兩份玩法程式。

這次先只查看：macOS 的架構是 universal，Windows 是 x86_64。Universal 代表同一個 Mac App 包含 Apple Silicon 與 Intel 執行檔。

正式交付由 `tools/build_desktop.py` 使用指定 Git 版本的隔離副本匯出，入口改為營火戰役，避免把尚未驗證的 Inspector 個人調整混進交付。Windows 的 .exe 與 .pck 必須一起提供；Mac 的 .app 本身就是包含程式與資源的資料夾。

指南資料夾中的 `.gdignore` 告訴 Godot 略過網頁專用素材；HTML 仍能正常讀取它們。本課只提供練習，尚未取得掌握程度的回報。
