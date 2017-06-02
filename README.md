[![Build Status](https://travis-ci.org/gjtorikian/nanoc-conref-fs.svg)](https://travis-ci.org/gjtorikian/nanoc-conref-fs)
# nanoc-conref-fs

This gem adds a new Filesystem type to Nanoc called `ConrefFS`. This filesystem permits you to use reusable content and Liquid variables in your content to generate multiple outputs from a single source. It makes heavy use of item representations (or `rep`s for short).

The idea is that you have a set of YAML files in a data folder which act as your reusables. You can apply these reusables throughout your content.

## Setup

To get started, set the data source in your *nanoc.yaml* file:

``` yaml
data_sources:
  -
    type: conref-fs
```

You'll probably also want to provide a list of `rep`s which define all the item reps available to your site. For example:

``` yaml
data_sources:
  -
    type: conref-fs
    reps:
      - :default
      - :X
```

At this point, you'll want to make a couple of changes to your *Rules* file:

* In the `preprocess` block, add a line that looks like this: `ConrefFS.apply_attributes(@config, item, :default)`. This will transform Liquid variables in frontmatter, and add the `:parents` and `:children` attributes to your items [(see below)](#associating-files-with-data).

```yaml
preprocess do
  @items.each do |item|
    ConrefFS.apply_attributes(@config, item, :default)
  end
end

```

* Add `filter :'conref-fs-filter'` to any of your `compile` Rules to have them render through the conref processor, converting Liquid variables into the actual YAML text.

```yaml
compile '/**/*.html' do
  filter :'conref-fs-filter'
  filter :erb # If using erb you will need the monkey patch mentioned below.
  layout '/default.*'
end
```

#### Using Erb and Liquid
If you use this library with Nanoc's ERB filter, and want to use `render`, you'll need to monkey-patch an alias to avoid conflicts with Liquid:

``` ruby
require 'nanoc-conref-fs'
include Nanoc::Helpers::Rendering
Nanoc::Helpers::Rendering.module_eval do
  if respond_to? :render
    alias_method :renderp, :render
    remove_method :render
  end
end
```

Then, you can use `renderp` just as you would with `render`.

## Defining Variables For Templates

The variables exposed to your templates follow certain conventions. By default Nanoc Conref FS sources all its variables from a *./data/* folder, sibling to your *content* and *layouts* folders. See [the test fixture](test/fixtures/data) for an example. You can change the default folder with the `data_dir` config option:

``` yaml
data_sources:
  -
    type: conref-fs
    data_dir: 'somewhere_else'
    reps:
      - :default
      - :X
```

The *./data/* folder should contain [yaml files](https://github.com/gjtorikian/nanoc-conref-fs/tree/master/test/fixtures/data) that organize your variables. These yaml files are the source of your reusable content. Nanoc Conref FS will use your file structure to organize the variables meaning your file names and layout will affect the variable names in the templates.

### Using Variables in Templates

Now that you have variables defined in data files how do you use them? There are a couple ways variables are bound. The first and simpliest verison is often used for reusable content.

As an example moving fowards lets say we have the following directory structure

```
data/
  |-> reusables/
  |   |-> names.yml
  |-> Categories
  |   |-> simple.yml 

```

For the first example lets use this sample content:

*data/reusables/names.yml*

```yaml
first: 'Cory'
last: 'Gwin'

```

Nanoc Conref FS exposes these simple variables to you using liquid. The variables will be bound to the `site.data` namespace. The variables will be name spaced to `site.data.foldername.filename.variable`.

```html
<p>{{ site.data.reusables.names.first }}</p>
<p>{{ site.data.reusables.names.last }}</p>
```

You can also bind a more complex data_association to the page conditionally. This is often used for building navigation structures.

Lets use this content:

*data/categories/simple.yml*

```yaml
- Creating a new organization account:
  - About organizations
  - Creating a new organization from scratch
- Create A Repo:
  - Oh wow
  - I am a child.
```

In the above structure `- Creating a new organization account:` will be a specific page in our navigation structure, with 2 children. We want to create a template that knows about the current pages sub-pages.

The first step in getting this to work is to setup your page variables with a data association. We have not talked about page variable yet, but this is a method of binding more complex variables to specific pages.

First we need to configure the page variables in *nanoc.yml*

```yaml
page_variables:
  -
    scope:
      path: 'test-data'
    values:
      page_version: 'test association'
      data_association: 'categories.simple'
```
 
Lets parse the above setting. `page_variable` is just a convention to start the page variable settings. `scope -> path` is the file path to apply these values to. `values` are variables to apply to the page. In the above example `page_version` will be exposed as a simple liquid tag, string. The `data_association` setting has special properties that we will now discuss.
 
The data_association will use a combination of the `title` in the front matter and the yaml configs to determine a `children` and `parent` map to expose to your template via the `item`. Lets check it out.

```html
---
title: Create A Repo <- used as the parent of the data_association
intro: {{ site.data.reusables.names.first_name }} #<- will output Cory
---
<p><%= @item[:data_association] %> <- this is a string represenation of the data_association "categories.simple"</p>
<p>
  <%= @item[:children] %> <- ["Oh wow", "I am a child."] These are the children of the `Create Repo` category in categories/simple.yml
</p>


```

### Data folder variables

The `data_variables` key applies additional/dynamic values to your data files, based on their path, before the variables are applied to the page. For example, the following `data_variables` configuration adds a `version` attribute to every data file, whose value is `dotcom`:

 ``` yaml
 data_variables:
   -
     scope:
       path: ""
     values:
       version: "dotcom"
 ```

 You could add to this key to indicate that any data file called *changed* instead has a version of `something_different`:

```yaml
 data_variables:
   -
     scope:
       path: ""
     values:
       version: "dotcom"
   -
     scope:
       path: "changed"
     values:
       version: "2.0"
```

In addition to `path`, you can provide an array of `reps` to define which `reps` should receive which version:

``` yaml
data_variables:
  -
    scope:
      path: "feature"
    values:
      version: "dotcom"
  -
    scope:
      path: "feature"
      reps:
        - :X
    values:
      version: "something_else"
```

In this example, any data folder with a path containing "feature" will have `page.version` equal to `dotcom`. However, if you're constructing for the `:X` item representation, `page.version` becomes `something_else`.

### Page variables

Similarly, the `page_variables` also use `scope`s, `rep`s, and `value`s to determine variables:

``` yaml
page_variables:
  -
    scope:
      path: ""
    values:
      version: "dotcom"
  -
    scope:
      path: "different"
    values:
      version: "2.0"
```

In this case, every file path will get a `version` of `dotcom`, but any file matching `different` will get a version of 2.0.

See the tests for further usage of these conditionals. In both cases, `path` is converted into a Ruby regular expression before being matched against a filename.


### Retrieving variables

You can retrieve the stored data at any time (for example, in a layout) by calling `Variables.variables`.

### Retrieving data files

You can fetch anything in the *data* folder by passing in a string, demarcated with `.`s, to `Variables.fetch_data_file`. For example, `Variables.fetch_data_file('reusables.intro')` will fetch the file in *data/reusables/intro.yml*.

### Ignoring content

You can use the `create_ignore_rules` method to construct ignore rules for your content. For example, say you have a category file that looks like this:

``` yaml
Something:
  - Blah1
  {% if page.version == 'dotcom' %}
  - Blah2
  {% endif %}
```

By default, Nanoc will try to compile and layout a page for `Blah2` for every item rep, even though it probably shouldn't.

You can use `create_ignore_rules`, passing in an item rep and a category file to generate ignore rules. For example:

``` ruby
ConrefFS.create_ignore_rules(:X, 'categories.category').each do |f|
  ignore f, rep: :X
end
```
