# nanoc-conref-fs

This gem adds a new Filesystem type to Nanoc called `ConrefFS`. This filesystem permits you to use reusable content and Liquid variables in your content to generate multiple outputs from a single source. It makes heavy use of item representations (or `rep`s for short).

The idea is that you have a set of YAML files in a data folder which act as your reusables. You can apply these reusables throughout your content.

[![Build Status](https://travis-ci.org/gjtorikian/nanoc-conref-fs.svg)](https://travis-ci.org/gjtorikian/nanoc-conref-fs)

To get started, set the data source in your *nanoc.yaml* file:

``` yml
data_sources:
  -
    type: conref-fs
```

You'll probably also want to provide a list of `rep`s which define all the item reps available to your site. For example:

``` yml
data_sources:
  -
    type: conref-fs
    reps:
      - :default
      - :X
```

At this point, you'll want to make a couple of changes to your *Rules* file:

* In the `preprocess` block, add a line that looks like this: `ConrefFS.apply_attributes(@config, item, :default)`. This will transform Liquid variables in frontmatter, and add the `:parents` and `:children` attributes to your items (see below).

* Add `filter :'conref-fs-filter'` to any of your `compile` Rules to have them render through the conref processor, converting Liquid variables into the actual YAML text.

**NOTE:** If you use this library with Nanoc's ERB filter, and want to use `render`, you'll need to monkey-patch an alias to avoid conflicts with Liquid:

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

## Usage

Nearly all the usage of this gem relies on a *data* folder, sibling to your *content* and *layouts* folders. See [the test fixture](test/fixtures/data) for an example. You can change this with the `data_dir` config option:

``` yml
data_sources:
  -
    type: conref-fs
    data_dir: 'somewhere_else'
    reps:
      - :default
      - :X
```

Then, you can [construct a data folder filled with YAML files](https://github.com/gjtorikian/nanoc-conref-fs/tree/master/test/fixtures/data). These act as the source of your reusable content.

Finally, you'll need some relevant keys added to your *nanoc.yaml* file.

### Data folder variables

The `data_variables` key applies additional/dynamic values to your data files, based on their path. For example, the following `data_variables` configuration adds a `version` attribute to every data file, whose value is `dotcom`:

 ``` yaml
 data_variables:
   -
     scope:
       path: ""
     values:
       version: "dotcom"
 ```

 You could add to this key to indicate that any data file called *changed* instead has a version of `something_different`:

 ``` yaml
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

### Associating files with data

If you have a special `data_association` value in your `scope`, additional metadata to items will be applied:

* An attribute called `:parents`, which adds the parent "map topic" to an item.
* An attribute called `:children`, which adds any children of a "map topic."

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
