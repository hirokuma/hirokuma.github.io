---
layout: default
recentlies: 3
---

# ![image](favicon.ico)

## 調査

* [Bitcoin調査](bitcoin/index.md)
* [Nordic Semiconductor調査](nrf/index.md)
* [Android開発](android/index.md)

## 開発日記

<ul>
  <li>最近の記事
    <ul>
{% assign posts = site.pages | sort: "date" | reverse %}
{% for post in posts limit:page.recentlies %}
      <li>{{ post.date }} <a href="{{ post.url | relative_url }}">{{ post.title }}</a></li>
{% endfor %}
    </ul>
  </li>
</ul>
* アーカイブ
  * [カテゴリー別](tags.md)
  * [2025年](2025/index.md)
  * [2024年](2024/index.md)
  * [それ以前(別サイト)](https://hiro99ma.blogspot.com/)

## その他

* [GitHub](https://github.com/hirokuma)
* [X/Twitter](https://x.com/hiro99ma)
* [お仕事ページ](https://hirokuma.work)
* [About me](aboutme.md)
