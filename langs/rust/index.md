# プログラミング言語

## Rust言語

### 基礎

* 名前が出てこないあれ
  * `struct`の中にある名前とデータ型: フィールド(fields) [url](https://doc.rust-lang.org/book/ch05-01-defining-structs.html#defining-and-instantiating-structs)
  * `enum`の中で列挙しているやつ: 列挙子(variants) [url](https://doc.rust-lang.org/book/ch06-01-defining-an-enum.html#defining-an-enum)
* [よく見る記号](./symbol.md)
* [クレート](./crate.md)
* 戻り値
  * [Result, Option](./result_option.md)
  * [anyhow, thiserror](./result_thiserror.md)
* [タプル構造体](./tuple_struct.md)

### デバッグ

* [log](./log.md)
* [tracing_subscriber](./subscriber.md)
  * [tracingサンプル](./tracing.md)
* [tokio-console](./tokio-console.md)
* [vscode デバッグ](./debug.md)

### Cargo

* [cargo workspace](./workspace.md)

### DB

* [redb](./db_redb.md)
* [rusqlite](./db_rusqlite.md)

## 小話

* `enum Event`(それぞれ値を持ってるstructっぽいやつ)で特定のvariantを受け取ったら返してもらう関数を作ろうとしたが引数での指定方法がわからない。AIに作ってもらったら、そうではなくて`Fn(&Event) -> bool`のようなクロージャを引数にとって呼び出し元でクロージャを書けば良いということだった。なるほどね。

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
