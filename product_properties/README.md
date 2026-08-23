Product properties
==================

YAML files contained here are processed in lexicographic order, and they allow to define product properties in a efficient way.
Processing of those files can use `jinja2`, and macros or conditionals have access to product properties defined previously and in the `product.yml`.

Properties in a file are expressed in two mappings - obligatory `default` and optional `overrides`.
Properties defined in a mapping nested below `default` can be overriden in a mapping nested below `overrides`.
A property can be set only in one file, so the default-override pattern implemented by Jinja macros can be accomplished, but it has to take place in one file.
Properties specified in the `product.yml` can't be overriden by this mechanism, and attempting to do so will result in an error.

Conventionally, use the filename numerical prefix e.g. `10-` to ensure that some symbols are available before they are used in a definition of other symbols.
