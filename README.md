# nanoc-conref-fs

This gem adds a new Filesystem type called `ConrefFS` to nanoc.

The idea is that you have a set of YAML files in a data folder which act as your reusables. You can apply thse reusables throughout your content and layout.

To do that, first, create a key called `variables`, and populate it with any set of variable names you like:

``` yaml
variables:
  latest_version: "2.0"
```

In this case, a new variable called `latest_version` is available to use, and it's defined a `"2.0"`. You can use this variable throughout your YAML file with the `%{...}` notation. For example:

``` yaml
defaults:
  -
    scope:
      path: ""
      type: "source"
      values:
        version: "%{latest_version}"
```

This sets a frontmatter of `version` on all the files in the `source` collection. It uses whatever value is defined in `latest_version` to set that up.
