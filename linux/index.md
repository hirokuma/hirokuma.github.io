# Linux

<!-- begin -->
{% assign selected_tag = "linux" %}
{% assign tag_pages = site.pages | where: "tags", selected_tag | where: "daily", false | sort: "date" | reverse %}
<p class="post-header">
<ul>
  {% for post in tag_pages %}
    <li>
    {{ post.date }}: <a href="{{ post.url | relative_url }}" class="post-title">{{ post.title }}</a>
    {% if post.tags %}
      {% for tag in post.tags %}
        <a href="{{ 'tag/' | append: tag | url_encode | relative_url }}" class="post-tag"><small><span>#{{ tag }}</span></small></a>
      {% endfor %}
    {% endif %} <!-- post.tags -->
    </li>
  {% endfor %}
</ul>
</p>
<!-- end -->
