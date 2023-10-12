# content/build-scripts

This flowchart represents the high-level interaction of components under the `build-scripts`, `cmake` and `build` folders.

Note that colors are used to highlight components which interact with other folders under the `content` repository.

> ***NOTE***: Since the colors have only visual effects when presented in individual flowcharts, they are very useful when analyzing multiple flowcharts together.

<div class="mermaid" style="width=100%;">
flowchart TD
    subgraph build
    110[build-scripts] --> |populates| 111[build]
        111[build] --> |generates| 112(data stream files)
    110[build-scripts] --> |triggers| 114[cmake]
        114[cmake] --> |populates| 111[build]
        114[cmake] --> |can trigger| 115[tests]
    end
    style 115 fill: #00FA9A,stroke:#333,stroke-width:4px
    style 112 fill: #A9A9A9,stroke:#333
</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
