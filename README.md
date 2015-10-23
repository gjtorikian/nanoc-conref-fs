# nanoc-conref-fs

This gem adds a new Filesystem type called `ConrefFS` to nanoc.

The idea is that you have a set of YAML files in a data folder which act as your reusables. You can apply thse reusables throughout your content and layout.

[![Build Status](https://travis-ci.org/gjtorikian/nanoc-conref-fs.svg)](https://travis-ci.org/gjtorikian/nanoc-conref-fs)

**NOTE:** If you use this library with nanoc's ERB filter, and want to use `render`, you'll need to monkey-patch an alias to avoid conflicts:

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

Then, use `renderp` instead of `render`.

## Usage

Nearly all the usage of this gem relies on a *data* folder, sibling to your *content* and *layouts* folders. See [the test fixture](test/fixtures/data) for an example.

You'll also need some relevant keys added to your *nanoc.yaml* file:

* The `data_variables` key applies additional/dynamic values to your data files, based on their path. For example, the following `data_variables` configuration adds a `version` attribute to every data file, whose value is `dotcom`:

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

* Similarly, the `page_variables` also use `scope`s and `value`s to determine variables:

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

If you have a special `data_association` value, additional metadata to items will be applied:

* An attribute called `:parents`, which adds the parent "map topic" to an item.
* An attribute called `:children`, which adds any children of a "map topic."

### Retrieving variables

You can retrieve the stored data at any time (for example, in a layout) by calling `VariableMixin.variables`.

### Retrieving data files

You can fetch anything in the *data* folder by passing in a string, demarcated with `.`s, to `VariableMixin.fetch_data_file`. For example, `VariableMixin.fetch_data_file('reusables.intro')` will fetch the file in *data/reusables/intro.yml*.
