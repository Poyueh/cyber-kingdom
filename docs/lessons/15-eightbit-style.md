# 第十五課：像素風的細節尺度

這次營地使用 `data/eightbit_frontier_art.tres`。主要物件先以很小的圖片和固定 16 色製作，再將每個像素放大成四倍；把造型畫簡單，才會有這次的大像素感。

在 Godot FileSystem 選這份資源，Inspector 展開 Props，點選 workshop 查看機械工坊。圖片本身以粗像素構成，並由 WorldView 的 Nearest 貼圖過濾保持邊緣清楚。Nearest 只決定放大方式，不會自動把複雜插畫設計成好看的 8-bit 圖。

騎士這次使用貼圖覆寫：打開 frontier 場景，選 Knight → KnightVisual，在 Texture Overrides 可以看到舊圖路徑與新版圖片的對應。動畫格數、速度與時長仍讀原本設定；未指定的圖片繼續使用原圖。

這版先用營地確認方向；人物後續適合逐格重畫輪廓，介面與敵人也需要統一，不能把一次縮圖當作最終美術完成。
