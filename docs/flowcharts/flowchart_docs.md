# content/docs

This flowchart represents the high-level interaction of components under the `docs` folder.

Note that colors are used to highlight components which interact with other folders under the `content` repository.

> ***NOTE***: Since the colors have only visual effects when presented in individual flowcharts, they are very useful when analyzing multiple flowcharts together.

<div class="mermaid" style="width=100%;">
flowchart TD
    subgraph docs
    180[docs] --> |about| 181[jinja_macros]
    180[docs] --> |contains| 182[manual]
        182[manual] --> |for| 183[developer]
            183[developer] --> |rendered at| 184(complianceascode.readthedocs.io)
        182[manual] --> |contains| 185[images]
        182[manual] --> |contains| 186[user_guide.adoc]
    180[docs] --> |about| 187[modules]
    180[docs] --> |about| 188[templates]
    180[docs] --> |contains| 189[readme_images]
    end
    style 181 fill: #FFA07A,stroke:#333,stroke-width:4px
    style 188 fill: #9370DB,stroke:#333,stroke-width:4px
    style 184 fill: #A9A9A9,stroke:#333
</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
