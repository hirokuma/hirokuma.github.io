# プログラミング言語

## C/C++言語

{% assign selected_tag = "clang" %}
<div class="blogs">
  {% assign tag_pages = site.pages | where: "tags", selected_tag | where: "daily": false | sort: "date" | reverse %}
  {% for post in tag_pages %}
    <article class="blog-post">
      <div class="post-header">
        {{ post.date }}: <a href="{{ post.url | relative_url }}" class="post-title">{{ post.title }}</a>
        {% if post.tags %}
          {% for tag in post.tags %}
            <a href="{{ 'tag/' | append: tag | url_encode | relative_url }}" class="post-tag"><span>#</span>{{ tag }}</a>
            &nbsp;&nbsp;
          {% endfor %}
        {% endif %} <!-- post.tags -->
      </div>
    </article>
  {% endfor %}
</div>

## Rust

{% assign selected_tag = "rust" %}
<div class="blogs">
  {% assign tag_pages = site.pages | where: "tags", selected_tag | where: "daily": false | sort: "date" | reverse %}
  {% for post in tag_pages %}
    <article class="blog-post">
      <div class="post-header">
        {{ post.date }}: <a href="{{ post.url | relative_url }}" class="post-title">{{ post.title }}</a>
        {% if post.tags %}
          {% for tag in post.tags %}
            <a href="{{ 'tag/' | append: tag | url_encode | relative_url }}" class="post-tag"><span>#</span>{{ tag }}</a>
            &nbsp;&nbsp;
          {% endfor %}
        {% endif %} <!-- post.tags -->
      </div>
    </article>
  {% endfor %}
</div>
