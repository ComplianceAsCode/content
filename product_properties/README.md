Product properties
==================

YAML files contained here are processed in lexicographic order, and they allow to define product properties in a efficient way.
Processing of those files can use `jinja2`, and macros or conditionals have access to product properties defined previously and in the `product.yml`.
Properties read from these yaml files can be overriden by properties from files processed later, while the properties specified in the `product.yml` override all previous definitions.

Conventionally, use the filename prefix `10-` to define defaults, and use subsequent prefixes to override those defaults based on products.
