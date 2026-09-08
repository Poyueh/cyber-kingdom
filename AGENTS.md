# Cyber Kingdom 開發規範

## 產品方向

- Godot / GDScript，iPhone 與 iPad 優先，橫向捲軸像素動作 Roguelite。
- 中古劍與魔法、龍、賽博義肢鎧甲；戰鬥與營地經營先分開驗證。
- 使用者一人製作，以低固定成本、可維護與市場驗證為優先。
- 與使用者以繁體中文溝通，每個開發單元附一段對應到實際專案的 Godot 教學。

## 架構

- `domain` 不依賴外層，`application` 只依賴 domain 與自己的 ports。
- 不把 Input、Node、FileAccess 或 UI 操作放進 domain/application。
- Godot 節點放 presentation，存檔等外部操作放 infrastructure，由 bootstrap 組裝。
- 數值以 Resource 提供 Inspector 編輯；不要替尚未存在的需求製造框架。
- 外層可呼叫內層；內層透過 port 表達外部需求。

## TDD 與驗證

- 新遊戲規則與 bug 修正先寫有行為意義的失敗測試，確認失敗原因，再實作、重構。
- 不用只驗證常數或複製實作的測試充數；畫面與手感須另行實際驗證。
- 交付前執行 `bash tools/check.sh`，檢查 Godot SCRIPT ERROR，不能只信程序退出碼。
- 變更儲存格式需保護未知版本和損壞資料，不可靜默覆蓋。

## Gitflow

- `main` 放正式版本；`develop` 整合下一版本。
- 功能從 develop 建 `feature/<name>`；完成驗證再以 `--no-ff` 合併 develop。
- 發行使用 `release/<version>`；正式修補使用 `hotfix/<name>`，都須回合 develop。
- 不強制推送、不重寫既有歷史；不要提交憑證、引擎快取或測試存檔。
- 提交要小且說明目的；更新 docs/STATUS.md，記錄測試和下一步。
