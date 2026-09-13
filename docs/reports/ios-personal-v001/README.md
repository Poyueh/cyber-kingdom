# 首次 Personal Team iOS 匯出與編譯

2026-09-13。使用者已在 Xcode 登入並確認 Personal Team；從 Xcode 的團隊設定取得真實識別碼，未讀取帳號權杖或密碼。後續偵測到一個有效 Apple Development 簽署身分。

## 實際產物

- `builds/ios-personal-20260913/CyberKingdomDemo.xcodeproj`：真實 Xcode 專案，已在 Xcode 開啟。
- `builds/ios-personal-20260913/DerivedData/Build/Products/Debug-iphoneos/CyberKingdomDemo.app`：已成功編譯的 iPhone ARM64 App，尚未簽署，不能直接安裝。
- Bundle ID：com.jenpoyueh.cyberkingdom.demo；來源與其他平台相同為 de83023 / 3b561b1f2cd401f3082760c150e8161ae5c7d840。

工具 tools/build_ios.py 首次使用真實 Xcode／團隊完成端到端匯出。PCK 為 17,510,304 bytes；App 內 PCK 與匯出檔逐位元組一致。Info.plist 確認 iphoneos、iPhone＋iPad、最低 iOS 15；file 確認 Mach-O ARM64。完整雜湊見 manifest.json。

## 環境修復與結果

SDK 路徑存在不能證明所有建置工具已可用。第一次泛用 iOS 裝置建置回報平台未安裝；透過 Apple 官方 xcodebuild -downloadPlatform iOS -architectureVariant arm64 完成 iOS 26.5 runtime 下載。

下載程序回報完成後，runtime 管理器標示映像 Ready，但 runtime 實際路徑不存在、simctl list runtimes 為空，ibtool 因此無法編譯 Launch Screen。使用 Apple simctl runtime scan-and-mount 重新掃描掛載後，runtime 顯示 isAvailable=true；再次執行相同 unsigned 建置成功。沒有刪除其他 runtime、裝置或改用空白啟動畫面掩蓋問題。

另外實際嘗試 -allowProvisioningUpdates 自動簽署，Apple 回報此團隊尚無裝置可建立 provisioning profile。當下 devicectl 裝置清單為空，因此停在簽署前置。有效憑證不等於已有裝置描述檔。詳見 signing-result.log。

成功的編譯設定為 CODE_SIGNING_ALLOWED=NO，只驗證程式可建置；codesign 也確認 App 未簽署。沒有可安裝 IPA、沒有 iPhone 啟動／遊玩證據，不能當成四平台目標完成。

## 檢查與限制

完整 tools/check.sh 再次在隔離遊戲來源通過，無 SCRIPT ERROR。保留原有 130 個個人及引擎匯入檔案，沒有改遊戲規則或已交付的 Mac／Windows／Android 包。帳號識別只填入本地匯出專案，不提交憑證、描述檔或私鑰。

已記錄尚待發行前整理的模板警告：boot_splash/fullsize 找不到屬性、dummy.h 的 pragma once、相機／麥克風／相簿使用說明為空，以及沒有 AppIntents 依賴而跳過 metadata。這次編譯成功不代表通過 App Store 檢查；沒有為消除警告虛構權限用途。

下一步：接上實際 iPhone 並信任電腦，依手機要求啟用 Developer Mode，再讓 Xcode 登記裝置、產生描述檔及簽署安裝，最後驗證操作／背景恢復／音訊／完整流程。

[Apple 元件安裝說明](https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components)；[Apple 裝置執行與自動簽署](https://help.apple.com/xcode/mac/current/en.lproj/dev5a825a1ca.html)。runtime 掃描掛載介面已依本機 simctl runtime help 核對。
