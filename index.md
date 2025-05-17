# top

<form id="ddg-search" action="https://duckduckgo.com/" method="get" target="_blank" onsubmit="addSiteToQuery()">
  <input type="text" id="search-box" name="q" placeholder="サイト内検索">
  <input type="submit" value="検索">
</form>

<script>
  function addSiteToQuery() {
    const input = document.getElementById('search-box');
    const site = 'example.com';  // ← あなたのドメインに置き換えてください
    input.value = `site:${site} ${input.value}`;
  }
</script>

## 調査

* [Bitcoin調査](bitcoin/index.md)
* [Nordic Semiconductor調査](nrf/index.md)
* [Android開発](android/index.md)

## 開発日記


* [2025年(更新中)](devwork2025.md)
* 最新の 3記事
  * 05/17 [ble: gattlib (5)](2025/05/20250517-ble.md)
  * 05/16 [wsl: snapfuseが残るがあきらめた](2025/05/20250516-wsl.md)
  * 05/15 [math: 集合と群 (2)](2025/05/20250515-math.md)
* 過去
  * [2024年](devwork2024.md)
  * [それ以前(別サイト)](https://hiro99ma.blogspot.com/)
