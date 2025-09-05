# content/*/benchmarks

This flowchart represents the high-level interaction of components under the `apple_os`, `applications` and `linux_os` folders.

Note that colors are used to highlight components which interact with other folders under the `content` repository.

> ***NOTE***: Since the colors have only visual effects when presented in individual flowcharts, they are very useful when analyzing multiple flowcharts together.

<div class="mermaid" style="width=100%;">
flowchart TD
    subgraph benchmarks
    100[apple_os] --> |contains| 101([rules])
    100[apple_os] --> |defines| 102(benchmark)
        102(benchmark) --> |written at| 103[benchmark.yml]
    104[applications] --> |contains| 101(rules)
    104[applications] --> |defines| 102(benchmark)
    105[linux_os] --> |contains| 101(rules)
    105[linux_os] --> |defines| 102(benchmark)
    end
    style 101 fill: #FFD700,stroke:#333,stroke-width:4px
    style 102 fill: #A9A9A9,stroke:#333
</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
