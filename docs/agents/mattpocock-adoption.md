# Matt Pocock 技能的專案用法

## 來源與閱讀範圍

使用者要求學習 `/Users/jenpoyueh/mattpocock` 並運用於本專案。實際來源是其 `skills/` 倉庫，閱讀版本為 `3cca18b368ae95cdbdebbff572ccafa662551015`，來源工作目錄乾淨。

已閱讀 engineering 18 個及 productivity 7 個 SKILL.md；深入閱讀 TDD、模組設計、術語與教學的相關參考文件。另盤點 misc 4 個及 in-progress 8 個的名稱／用途，尚未全文研讀或採用，見末尾清單。

這是將知識整理成專案規範，沒有安裝全域技能、執行套件安裝器、修改原始技能包或聲稱改變模型本身。未來工作先依本文件，細節需要時才閱讀原始 SKILL.md；來源路徑不可用時，仍可依以下已保存的規範開發。

## 每個開發單元

1. 讀 CONTEXT.md、目前進度及相關 ADR，確認玩家會看到的結果。先查現有程式與測試，再決定修改位置。
2. 寫下一個小而完整的驗收情境，以及透過哪個公開介面觀察結果。跨日功能才建立本地規格與相依工作項目；單純調圖或改文案不用完整工單流程。
3. 遊戲規則採一段一段的 TDD：一個合理失敗的行為測試 → 最少實作讓它通過 → 下一段。綠燈後整理程式並重跑相關測試。
4. 接到 Godot 實際場景驗證。美術需目視檢查、動畫需播放檢查、手機操作需實機；無錯誤啟動不能代替手感或顯示正確。
5. 分別檢查「符合需求」與「符合架構規範」，避免好看的程式實作了錯誤玩法。用功能分支起點作比較；已有明確使用者需求時直接作為驗收來源。
6. 執行專案檢查，記錄結果與限制，按 Gitflow 提交和整合。最後教使用者一個與本次改動對應的 Godot 操作。

## 測試與模組設計

- 優先測公開行為和結果：同一刀只能扣一次血、擊敗後廢料只增加一次、重開仍讀得到進度。預期值來自規則與獨立算例。
- 測試同一行為時，避免綁定內部函式呼叫次數或私人欄位；重構後行為不變，測試通常也應不變。
- 目前可用的測試位置是 Combatant、TrainingSession、ProgressStore 以及 Godot 實際場景。新功能優先沿用；新增介面時先說明它要隔離什麼、怎樣驗收。
- 大部分測試使用真實內層模組；檔案、時間、亂數等外部來源才注入可控制替身。正式存檔仍以獨立測試檔驗證真正讀寫。
- 使用小而清楚的介面包住有價值的複雜規則；呼叫者不必知道內部操作順序。抽象是否值得，要看它是否集中變更與隱藏複雜度。
- 建立 port 要有實際差異來源；本專案 JSON 與記憶體進度儲存已是例子。避免只為符合分層圖增加轉呼叫類別。
- 合併模組後只移除已被等價行為覆蓋的重複測試；先確保重要回歸情境保留。

## 除錯、規格與原型

- 除錯先建立能抓到原始症狀的重現方法，縮小情境，逐一驗證可反駁的假設。效能問題先量測，修好後回到原始情境驗證並清除臨時紀錄。
- 規格描述玩家的問題、可見結果、驗收情境、依賴與本次範圍。長期規格避免抄整段程式和容易失效的細節。
- 每個工作項目交付一條能獨立示範的完整路徑，例如「揮劍時顯示相應動畫且命中仍只計一次」，而非先做全部資料層再做全部畫面。
- 原型先說明要回答的問題。玩法用 Godot 獨立場景，純視覺方向可以是圖片；原型結論記入規格，正式實作仍遵守測試與分層。

## 與原包的適配差異

| 原包做法 | 本專案採用方式與原因 |
| --- | --- |
| TDD 每個測試介面先請使用者確認 | 已授權範圍與既有介面由代理說明後持續實作；只就未決的玩法或重大取捨詢問，避免要求新手批准每個技術細節。 |
| TDD 將重構留到 review | 保留本專案的紅 → 綠 → 重構習慣；重構以綠燈為前提，和新增行為分開驗證。 |
| grilling 完整訪談、分輪確認 | 一般開發先自行查事實，採已知偏好；只問會影響結果且尚未決定的問題。完整訪談由使用者需要時再啟動。 |
| HTML／網頁路由原型 | Godot 玩法在 Godot 驗證；有比較價值時才另做 HTML 說明工具。 |
| teach 建立完整 HTML 教學工作區 | 延用 docs/lessons，先提供短練習；只有互動能改善理解時才新增 HTML。 |
| 平行代理審查、研究與介面方案比較 | 本文件採雙面向審查與來源查證的原則，不因此自動啟用多代理。實際委派依當次授權、工具規則與適用技能處理。 |
| 外部工單、套件安裝、Claude hooks | 本次保留現有本地文件與 Gitflow；沒有建立外部工單或安裝 Node／TypeScript 工具鏈。 |

原始技能的流程不因閱讀就全部啟用。若使用者未來明確要求執行某項原始技能，先讀該版本並辨識前置條件；使用者的既有指示和本專案適配優先。

## 教學與持續記錄

每次只教一個能在專案完成的小操作。下一次可請使用者回想或重做，確認是否理解。曾經提供教學文件不等於使用者已學會；只有使用者示範、回答或陳述程度後，才更新學習紀錄。術語定義放 CONTEXT.md；實作位置放 ARCHITECTURE.md；進度放 STATUS.md；有長期取捨且值得保留原因的決策才寫 ADR。

## 本次採用的來源

原始路徑根目錄：`/Users/jenpoyueh/mattpocock/skills/skills`。以下連結是本機來源，搬到其他電腦時需重新定位。

| 類別 | 技能 | 閱讀範圍 |
| --- | --- | --- |
| engineering | [ask-matt](/Users/jenpoyueh/mattpocock/skills/skills/engineering/ask-matt/SKILL.md) | SKILL.md 全文 |
| engineering | [code-review](/Users/jenpoyueh/mattpocock/skills/skills/engineering/code-review/SKILL.md) | SKILL.md 全文 |
| engineering | [codebase-design](/Users/jenpoyueh/mattpocock/skills/skills/engineering/codebase-design/SKILL.md) | SKILL.md 全文 |
| engineering | [diagnosing-bugs](/Users/jenpoyueh/mattpocock/skills/skills/engineering/diagnosing-bugs/SKILL.md) | SKILL.md 全文 |
| engineering | [domain-modeling](/Users/jenpoyueh/mattpocock/skills/skills/engineering/domain-modeling/SKILL.md) | SKILL.md 全文 |
| engineering | [grill-with-docs](/Users/jenpoyueh/mattpocock/skills/skills/engineering/grill-with-docs/SKILL.md) | SKILL.md 全文 |
| engineering | [implement](/Users/jenpoyueh/mattpocock/skills/skills/engineering/implement/SKILL.md) | SKILL.md 全文 |
| engineering | [improve-codebase-architecture](/Users/jenpoyueh/mattpocock/skills/skills/engineering/improve-codebase-architecture/SKILL.md) | SKILL.md 全文 |
| engineering | [prototype](/Users/jenpoyueh/mattpocock/skills/skills/engineering/prototype/SKILL.md) | SKILL.md 全文 |
| engineering | [research](/Users/jenpoyueh/mattpocock/skills/skills/engineering/research/SKILL.md) | SKILL.md 全文 |
| engineering | [resolving-merge-conflicts](/Users/jenpoyueh/mattpocock/skills/skills/engineering/resolving-merge-conflicts/SKILL.md) | SKILL.md 全文 |
| engineering | [setup-matt-pocock-skills](/Users/jenpoyueh/mattpocock/skills/skills/engineering/setup-matt-pocock-skills/SKILL.md) | SKILL.md 全文 |
| engineering | [tdd](/Users/jenpoyueh/mattpocock/skills/skills/engineering/tdd/SKILL.md) | SKILL.md 全文 |
| engineering | [to-spec](/Users/jenpoyueh/mattpocock/skills/skills/engineering/to-spec/SKILL.md) | SKILL.md 全文 |
| engineering | [to-tickets](/Users/jenpoyueh/mattpocock/skills/skills/engineering/to-tickets/SKILL.md) | SKILL.md 全文 |
| engineering | [triage](/Users/jenpoyueh/mattpocock/skills/skills/engineering/triage/SKILL.md) | SKILL.md 全文 |
| engineering | [wayfinder](/Users/jenpoyueh/mattpocock/skills/skills/engineering/wayfinder/SKILL.md) | SKILL.md 全文 |
| engineering | [wizard](/Users/jenpoyueh/mattpocock/skills/skills/engineering/wizard/SKILL.md) | SKILL.md 全文 |
| in-progress | [claude-handoff](/Users/jenpoyueh/mattpocock/skills/skills/in-progress/claude-handoff/SKILL.md) | 名稱與用途盤點；未採用 |
| in-progress | [implement-spec](/Users/jenpoyueh/mattpocock/skills/skills/in-progress/implement-spec/SKILL.md) | 名稱與用途盤點；未採用 |
| in-progress | [loop-me](/Users/jenpoyueh/mattpocock/skills/skills/in-progress/loop-me/SKILL.md) | 名稱與用途盤點；未採用 |
| in-progress | [retro](/Users/jenpoyueh/mattpocock/skills/skills/in-progress/retro/SKILL.md) | 名稱與用途盤點；未採用 |
| in-progress | [setup-ts-deep-modules](/Users/jenpoyueh/mattpocock/skills/skills/in-progress/setup-ts-deep-modules/SKILL.md) | 名稱與用途盤點；未採用 |
| in-progress | [writing-beats](/Users/jenpoyueh/mattpocock/skills/skills/in-progress/writing-beats/SKILL.md) | 名稱與用途盤點；未採用 |
| in-progress | [writing-fragments](/Users/jenpoyueh/mattpocock/skills/skills/in-progress/writing-fragments/SKILL.md) | 名稱與用途盤點；未採用 |
| in-progress | [writing-shape](/Users/jenpoyueh/mattpocock/skills/skills/in-progress/writing-shape/SKILL.md) | 名稱與用途盤點；未採用 |
| misc | [git-guardrails-claude-code](/Users/jenpoyueh/mattpocock/skills/skills/misc/git-guardrails-claude-code/SKILL.md) | 名稱與用途盤點；未採用 |
| misc | [migrate-to-shoehorn](/Users/jenpoyueh/mattpocock/skills/skills/misc/migrate-to-shoehorn/SKILL.md) | 名稱與用途盤點；未採用 |
| misc | [scaffold-exercises](/Users/jenpoyueh/mattpocock/skills/skills/misc/scaffold-exercises/SKILL.md) | 名稱與用途盤點；未採用 |
| misc | [setup-pre-commit](/Users/jenpoyueh/mattpocock/skills/skills/misc/setup-pre-commit/SKILL.md) | 名稱與用途盤點；未採用 |
| productivity | [grill-me](/Users/jenpoyueh/mattpocock/skills/skills/productivity/grill-me/SKILL.md) | SKILL.md 全文 |
| productivity | [grilling](/Users/jenpoyueh/mattpocock/skills/skills/productivity/grilling/SKILL.md) | SKILL.md 全文 |
| productivity | [handoff](/Users/jenpoyueh/mattpocock/skills/skills/productivity/handoff/SKILL.md) | SKILL.md 全文 |
| productivity | [teach](/Users/jenpoyueh/mattpocock/skills/skills/productivity/teach/SKILL.md) | SKILL.md 全文 |
| productivity | [to-questionnaire](/Users/jenpoyueh/mattpocock/skills/skills/productivity/to-questionnaire/SKILL.md) | SKILL.md 全文 |
| productivity | [wait-what](/Users/jenpoyueh/mattpocock/skills/skills/productivity/wait-what/SKILL.md) | SKILL.md 全文 |
| productivity | [writing-for-agents](/Users/jenpoyueh/mattpocock/skills/skills/productivity/writing-for-agents/SKILL.md) | SKILL.md 全文 |
