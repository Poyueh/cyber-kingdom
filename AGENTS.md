# Cyber Kingdom 開發規範

## 產品方向

- Godot / GDScript，iPhone 與 iPad 優先，橫向捲軸像素動作 Roguelite。
- 人類靠龍晶驅動機械義肢，在魔法與巨龍統治的世界建立最後的避難所。玩家每次出征都要權衡強化自己或保護居民；完整準則見 `docs/design/vision.md`。
- 騎士負責探索、標記工作、投入建設與戰鬥；砍樹、開採、採果、採藥和施工由居民執行；寶箱由騎士直接開啟。工匠搬運入庫，清理後可建拓荒站擴展收貨範圍。
- 目前主場景從營火起家，騎士背包有限；現場每次投入一顆龍晶，未滿格的進度保留。夜襲逐日變強，日夜規格見 `docs/design/campfire-campaign.md`。
- 避難所採現場投入、居民自主取器具與工作；居民只在實際受擊且未被防護擋住時退回流浪者，細則見 `docs/design/walkable-refuge.md`。
- 戰鬥與避難所經營先分開驗證；必要路線可用基本走跳通過，不強迫消耗戰略能源。
- 使用者一人製作，以低固定成本、可維護與市場驗證為優先。
- 主玩法介面使用圖示與必要數字；不要恢復常駐文字面板、文字按鈕或人物／建築文字牌。成本與材料圖示必須讀實際互動規則。
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

## 專案知識入口

- 開始功能設計、實作、除錯或審查時，先讀 `CONTEXT.md`、`docs/agents/mattpocock-adoption.md` 與相關 ADR；同一工作單元已讀且未變更時不必重讀。
- 本地 Matt Pocock 技能包作為按需參考；適配與來源版本以 adoption 文件為準。保留現有 Godot、Clean Architecture、TDD、Gitflow 及使用者授權。
- 遊戲術語集中在 `CONTEXT.md`，進度集中在 `docs/STATUS.md`。
- 教學前讀 `docs/lessons/learning-records/`，以使用者實際回饋更新掌握程度。
