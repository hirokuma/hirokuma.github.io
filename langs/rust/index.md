# プログラミング言語

## Rust言語

### 基礎

* [よく見る記号](./symbol.md)
* [クレート](./crate.md)
* [Result, Option](./result_option.md)
* [タプル構造体](./tuple_struct.md)

### デバッグ

* [log](./log.md)
* [tracing_subscriber](./subscriber.md)
* [tokio-console](./tokio-console.md)
* [vscode デバッグ](./debug.md)

### Cargo

* [cargo workspace](./workspace.md)

----

<!-- begin -->
{% assign selected_tag = "rust" %}
{% assign tag_pages = site.pages | where: "tags", selected_tag | where: "daily", false | sort: "date" | reverse %}
<ul>
{% for post in tag_pages %}
  <li>
  {{ post.date }}: <a href="{{ post.url | relative_url }}" class="post-title">{{ post.title }}</a>
  {% if post.tags %}
    {% for tag in post.tags %}
      <a href="{{ 'tags/' | append: tag | relative_url }}" class="post-tag"><small><span>#{{ tag }}</span></small></a>
    {% endfor %}
  {% endif %} <!-- post.tags -->
  </li>
{% endfor %}
</ul>
<!-- end -->
