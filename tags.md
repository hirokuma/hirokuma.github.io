### tags

<ul>
{% for tag in site.tags %}
  <li><a href="{{ tag.url | relative_url }}">{{ tag.name }}</a></li>
{% endfor %}
</ul>

