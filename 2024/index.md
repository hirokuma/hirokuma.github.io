---
layout: default
thisyear: "2024"
---

# 年間リスト

## {{ page.thisyear }}年

<ul>
{% assign posts = site.pages | sort: "date" | reverse %}
{% for post in posts %}
  {% assign year = post.date | date: "%Y" %}
  {% if year == page.thisyear %}
    <li>{{ post.date }} <a href="{{ post.url | relative_url }}">{{ post.title }}</a></li>
        {% for tag in post.tags %}
          <a href="{{ 'tag/' | append: tag | url_encode | relative_url }}" class="post-tag"><small><span>#{{ tag }}</span></small></a>
        {% endfor %}
  {% endif %}
{% endfor %}
</ul>
