# Gitflow

`main` 保存正式發行版本；日常可遊玩的整合成果放在 `develop`。每個開發單元從 develop 建立 feature 分支，先測試再實作，完成後以 merge commit 保留工作單元。

```text
main ────────────────────── 正式發行
  └─ develop ────────────── 下一版本整合
       └─ feature/<name> ── 開發與驗證 ── merge --no-ff → develop
```

## 每日開發

1. 檢查工作目錄，不覆蓋未提交修改。
2. 從 develop 建立 `feature/<name>`。
3. 為新規則寫測試，確認合理失敗，再完成實作。
4. 執行 `bash tools/check.sh`，需要時試玩；更新進度與教學。
5. 提交功能和文件，以 `--no-ff` 合併回 develop。

例如下一個營地測試可用 `feature/camp-economy-prototype`。`test:`、`feat:`、`fix:`、`docs:` 描述提交目的。

## 發行與修補

- 準備可發行版：由 develop 開 `release/<version>`，只處理發行與驗證問題。
- 驗證完成後回合 main 和 develop，於 main 建正式版本 tag。
- 已發行版的緊急修補：從 main 開 `hotfix/<name>`，修好也回合 main 與 develop。
- 尚未簽署、未通過裝置驗證的訓練場不當作正式上架版本。

本地 Git 提交與 GitHub 備份是不同步驟。提交完成不代表已推送；不使用 force push，不重寫歷史，不提交憑證。這一輪只進行本地提交與整合，遠端發佈另行處理。
