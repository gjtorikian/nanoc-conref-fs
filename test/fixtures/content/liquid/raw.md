---
title: Raw
---

For example, to list a project's name, you might write something like `The project is called {% raw %}{{ site.github.project_title }}{% endraw %}` or to list an organization's open source repositories, you might use the following:

{% raw %}

``` liquid
{% for repository in site.github.public_repositories %}
  * [{{ repository.name }}]({{ repository.html_url }})
{% endfor %}
```

{% endraw %}
