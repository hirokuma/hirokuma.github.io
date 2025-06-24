---
layout: default
thisyear: "2025"
---

## 開発日記 {{ page.thisyear }}年

<ul>
{% assign posts = site.pages | sort: "date" | reverse %}
{% for post in site.posts %}
  {% assign year = post.date | date: "%Y" %}
  {% if year == page.thisyear %}
    <li>{{ post.date }} <a href="{{ post.url | relative_url }}">{{ post.title }}</a></li>
  {% endif %}
{% endfor %}
</ul>
