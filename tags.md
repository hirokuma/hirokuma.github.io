### Tags

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

