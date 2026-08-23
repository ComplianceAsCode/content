Introduction
============

ComplianceAsCode content is a complex project composed by many correlated components
which harmonize together during the build to form consumables for the scanners.

Understanding all these relationships by reading the code can be a challenge.
So, regardless of whether you are an experienced engineer interested in understanding
how it works in an overview or if you are looking for a high-level technical view of the
project, these graphs and flowcharts can definitely be useful for you.

CMake Graphs
------------

If you want to see nice graph showing dependencies between CMake targets, there is also a
CMake feature worth to be checked.

For example, the following commands will generate a `png` image showing the dependencies
for the rhel8 build target::

   cd content/build
   cmake --graphviz=ssg.dot ..
   dot -Tpng -o rhel8.png ssg.dot.rhel8
   xdg-open rhel8.png

.. seealso::
   PR which made this great feature to nicely work in this project:
   `<https://github.com/ComplianceAsCode/content/pull/7767>`_

High-level Flowcharts
---------------------

As a complement for better understanding of how the ComplianceAsCode project interacts
with the many components spread among the root folders, you can take advantage of these
flowcharts.

They were written to be interpreted by the `mermaid JavaScript library <https://mermaid-js.github.io/>`_,
so they can be easily ported, updated or modified locally or even `online <https://mermaid-js.github.io/mermaid-live-editor/>`_.

.. tip::
   You can play with these individual flowcharts combining them in a bigger unified
   flowchart where you can create more complex relationships from different perspectives.

.. note::
   These flowcharts are not automatically updated. While the overall project structure is
   not expected to undergo major changes frequently, it is possible that the flowcharts
   do not reflect the most up-to-date structure.

   It is intended to automate the maintenance of these flowcharts at some level. However,
   to achieve this, we first need to assess the means to simplify the structure, and
   these flowcharts are the beginning of those assessments.
