# content/shared

This flowchart represents the high-level interaction of components under the `shared` folder.

Note that colors are used to highlight components which interact with other folders under the `content` repository.

> ***NOTE***: Since the colors have only visual effects when presented in individual flowcharts, they are very useful when analyzing multiple flowcharts together.

<div class="mermaid" style="width=100%;">
flowchart TD
    subgraph shared
    30[shared] --> |defines| 31(jinja2 macros)
        31(jinja2 macros) --> |written at| 32[macros-name.jinja]
    30[shared] --> |contains| 33[applicability]
        33[applicability] --> |written at| 34[category_name.yml]
            34[category_name.yml] --> |refers to| 37[check_name.xml]
    30[shared] --> |contains| 35[checks]
        35[checks] --> |instructed using| 36([OVAL + XCCDF])
            36([OVAL + XCCDF]) --> |written at| 37[check_name.xml]
    30[shared] --> |contains| 38[templates]
        38[templates] --> |identified by| 39[template_name]
            39[template_name] --> |supports| 40(languages)
                40(languages) --> |informed at| 41[template.yml]
                40(languages) --> |written at| 42[language.template]
                    42[language.template] --> |may use| 31(jinja2 macros)
            39[template_name] --> |may have| 43(processing scripts)
                43(processing scripts) --> |written at| 44[template.py]
            39[template_name] --> |may have| 45[tests]
    30[shared] --> |contains| 46[transforms]
        46[transforms] --> |instructed using| 47([XSLT])
            47([XSLT]) --> |written at| 48[name.xslt]
        46[transforms] --> |contains| 49(scripts)
            49(scripts) --> |uses| 50(python or bash)
    30[shared] --> |contains| 51[references]
        51[references] --> |contains| 52(Available CCEs)
        51[references] --> |contains| 53(Misc References)
    30[shared] --> |contains| 54[images]
    end
    style 30 fill: #FFFF00,stroke:#333,stroke-width:4px
    style 31 fill: #FFA07A,stroke:#333,stroke-width:4px
    style 33 fill: #00BFFF,stroke:#333,stroke-width:4px
    style 36 fill: #D3D3D3,stroke:#333
    style 38 fill: #9370DB,stroke:#333,stroke-width:4px
    style 37 fill: #1E90FF,stroke:#333,stroke-width:4px
    style 47 fill: #D3D3D3,stroke:#333
    style 40 fill: #A9A9A9,stroke:#333
    style 43 fill: #A9A9A9,stroke:#333
    style 45 fill: #32CD32,stroke:#333,stroke-width:4px
    style 50 fill: #A9A9A9,stroke:#333
    style 52 fill: #A9A9A9,stroke:#333
    style 53 fill: #A9A9A9,stroke:#333
</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
