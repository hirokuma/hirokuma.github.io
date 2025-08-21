# プログラミング言語

## C/C++言語

<!-- begin -->
{% assign selected_tag = "clang" %}
{% assign tag_pages = site.pages | where: "tags", selected_tag | where: "daily", false | sort: "date" | reverse %}
{% for post in tag_pages %}
<p class="post-header">
  {{ post.date }}: <a href="{{ post.url | relative_url }}" class="post-title">{{ post.title }}</a>
  {% if post.tags %}
    {% for tag in post.tags %}
      <a href="{{ 'tag/' | append: tag | url_encode | relative_url }}" class="post-tag"><small><span>#{{ tag }}</span></small></a>
    {% endfor %}
  {% endif %} <!-- post.tags -->
</p>
{% endfor %}
<!-- end -->

## Rust

<!-- begin -->
{% assign selected_tag = "rust" %}
{% assign tag_pages = site.pages | where: "tags", selected_tag | where: "daily", false | sort: "date" | reverse %}
{% for post in tag_pages %}
<p class="post-header">
  {{ post.date }}: <a href="{{ post.url | relative_url }}" class="post-title">{{ post.title }}</a>
  {% if post.tags %}
    {% for tag in post.tags %}
      <a href="{{ 'tag/' | append: tag | url_encode | relative_url }}" class="post-tag"><small><span>#{{ tag }}</span></small></a>
    {% endfor %}
  {% endif %} <!-- post.tags -->
</p>
{% endfor %}
<!-- end -->
