---
layout: default
recentlies: 5
---

# ![image](favicon.ico)

## 技術調査

* [Bitcoin調査](bitcoin/index.md)
* [Nordic Semiconductor調査](nrf/index.md)
* [Android開発](android/index.md)
* [プログラミング言語](langs/index.md)
* [Linux](linux/index.md)

<ul>
  <li>最近の調査
    <ul>
{% assign posts = site.pages | where: "daily", false | where: "draft", false | sort: "date" | reverse %}
{% for post in posts limit:page.recentlies %}
      <li>
        {{ post.date }} <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
          {% for tag in post.tags %}
            <small><span>#{{ tag }}</span></small>
          {% endfor %}
      </li>
{% endfor %}
    </ul>
  </li>
</ul>

## 開発日記

<ul>
  <li>最近の日記
    <ul>
{% assign posts = site.pages | where: "daily", true | where: "draft", false | sort: "date" | reverse %}
{% for post in posts limit:page.recentlies %}
      <li>
        {{ post.date }} <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
          {% for tag in post.tags %}
            <small><span>#{{ tag }}</span></small>
          {% endfor %}
      </li>
{% endfor %}
    </ul>
  </li>
</ul>

## カテゴリー別

<ul>
  {% assign tags = site.tags | sort: "sortorder" %}
  {% for tag in tags %}
    {% if tag.sub %}
      <li style="padding-left: 20px;"><a href="{{ tag.url | relative_url }}">{{ tag.name }}</a></li>
    {% elsif tag.nourl %}
      <li>{{ tag.name }}</li>
    {% else %}
      <li><a href="{{ tag.url | relative_url }}">{{ tag.name }}</a></li>
    {% endif %}
  {% endfor %}
</ul>

## 年別

* [2025年](2025/index.md)
* [2024年](2024/index.md)
* [それ以前(別サイト)](https://hiro99ma.blogspot.com/)

## その他

* [GitHub](https://github.com/hirokuma)
* [X/Twitter](https://x.com/hiro99ma)
* [お仕事ページ](https://hirokuma.work)
* [About me](aboutme.md)
