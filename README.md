# Cyber Kingdom

Godot 製作中的橫向捲軸像素動作遊戲。人類靠龍晶驅動機械義肢，在巨龍與魔法統治的世界建立最後的避難所；每次出征權衡強化自己或保護居民。目標平台是 iPhone / iPad；先在 Mac 驗證戰鬥與營地經營，再決定完整內容量。

目前版本是**戰鬥訓練場**，已有騎士待機、跑步、八格斬擊、四格衝刺及可連續通過的平台路線、鐵甲守衛與古城鑄造場背景，尚未包含完整 Roguelite、營地經營或完整動作美術。

## 開啟遊玩

1. 開啟電腦中的 Godot，按「匯入 / Import」。
2. 選擇 `/Users/jenpoyueh/GitHub/cyber-kingdom/project.godot`。
3. 進入編輯器後按 **F5**（部分 Mac 鍵盤需 Fn + F5）。

目前驗證版本：**Godot 4.7.2 Standard / GDScript**。使用 Compatibility renderer，不需 C# / .NET。

| 操作 | 鍵盤 |
| --- | --- |
| 左右移動 | A / D |
| 跳躍 | Space |
| 揮劍 | J |
| 衝刺 | L |
| 重開訓練 | R |
| 暫停 | Esc |
| 重試存檔 | P |

畫面也有觸控按鈕，桌面可用滑鼠試按。真正的多點觸控、安全區、效能仍須 iPhone / iPad 實機驗證。

擊敗守衛會得到廢料並保存。存檔在 Godot 的 `user://progress_v1.json`；切出視窗會暫停，回來後按 Esc 或 PAUSE 繼續。

[觀看新版劈砍與鑄造場近景預覽](docs/previews/mobility-cleave-v003.gif)。預覽放大攝影機以便看清角色；F5 遊玩的預設鏡頭保持原比例。

## 從這裡開始學

- [第一課：打開專案、看懂場景、改一個數值](docs/lessons/01-first-godot.md)
- [第二課：看懂騎士待機動畫](docs/lessons/02-knight-animation.md)
- [第三課：調整跑步動畫速度](docs/lessons/03-running-and-sword-timing.md)
- [第四課：比較命中停頓的手感](docs/lessons/04-hit-feedback.md)
- [第五課：調整能實際跳上的平台](docs/lessons/05-jump-and-platforms.md)
- [遊戲核心方向與能源抉擇](docs/design/vision.md)
- [程式分層與修改位置](docs/ARCHITECTURE.md)
- [Gitflow 開發流程](docs/GITFLOW.md)
- [半年計畫與目前進度](docs/STATUS.md)

## 驗證

在專案根目錄執行 `bash tools/check.sh`。包含依賴方向檢查、Godot 匯入、行為測試、實際場景輸入整合、平台全程走跳與主場景啟動。檢查紀錄保存在不納入 Git 的 `test-results/`。

macOS 預設使用 `/Applications/Godot.app/Contents/MacOS/Godot`。其他位置可指定 `GODOT_BIN`。腳本需要 Bash、Python 3 與 Godot，不依賴付費套件。Windows 可在 Git Bash 中指定 Godot 執行檔與可用的 Python 3。

## 發佈狀態

目前尚未產生 iOS 安裝包、完成簽署或上架；這台電腦還需要完整 Xcode 及後續匯出設定。Apple 開發者帳號、實機測試與行銷是另外的工作與成本，不包含在這個訓練場完成範圍。
