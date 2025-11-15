---
title: "年間リスト"
thisyear: "2025"
---

# 年間リスト

## {{ page.thisyear }}年

<ul>
{% assign posts = site.pages | sort: "date" | reverse %}
{% for post in posts %}
  {% assign year = post.date | date: "%Y" %}
  {% if year == page.thisyear %}
    <li>
      {{ post.date }}{% if post.draft } (下書き){% endif %} <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
        {% for tag in post.tags %}
          <a href="{{ 'tag/' | append: tag | url_encode | relative_url }}" class="post-tag"><small><span>#{{ tag }}</span></small></a>
        {% endfor %}
    </li>
  {% endif %}
{% endfor %}
</ul>
