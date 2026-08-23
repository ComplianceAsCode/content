# content/controls

This flowchart represents the high-level interaction of components under the `controls` folder.

Note that colors are used to highlight components which interact with other folders under the `content` repository.

> ***NOTE***: Since the colors have only visual effects when presented in individual flowcharts, they are very useful when analyzing multiple flowcharts together.

<div class="mermaid" style="width=100%;">
flowchart TD
    subgraph controls
    90[controls] --> |written at| 91[control_name.yml]
        91[control_name.yml] --> |may include| 92([rules])
        91[control_name.yml] --> |may override| 93[variables]
    end
    style 90 fill: #BDB76B,stroke:#333,stroke-width:4px
    style 92 fill: #FFD700,stroke:#333,stroke-width:4px
    style 93 fill: #FFA500,stroke:#333,stroke-width:4px
</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
