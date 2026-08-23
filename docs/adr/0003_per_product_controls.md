---
content-version: 0.1.79
title: ADR-0003 - Per Product Controls
status: proposed
---

## Context
As of late October 2025  there was over 50 control files in the `controls` folder.
Many of these control files are product specific.
The goal of this ADR is to help keep product specific information separate from the global standard like ANSSI.


## Decision
We will allow the creation of `controls` directory under each product.
All product specific control files will be moved to the product specific control file.
The product specific control files in `products/example/controls` can override the controls in `controls`.

## Consequences
This will create more places to look for control files, but it will help keep product specific information with the product.
