# content/*/rules

This flowchart represents the high-level interaction of components under the `rules` folders.

Note that colors are used to highlight components which interact with other folders under the `content` repository.

> ***NOTE***: Since the colors have only visual effects when presented in individual flowcharts, they are very useful when analyzing multiple flowcharts together.

<div class="mermaid" style="width=100%;">
flowchart TD
    subgraph rules
    1([rules]) --> |identified by| 2[rule name]
        2[rule name] --> |described at| 3[rule.yml]
            3[rule.yml] --> |may define platform| 4[applicability]
            3[rule.yml] --> |may use| 5(jinja2 macros)
        2[rule name] --> |instructed using| 6[oval]
            6[oval] --> |uses format| 7([OVAL + XCCDF])
                7([OVAL + XCCDF]) --> |written at| 8[shared.xml]
                    8[shared.xml] --> |may use| 5(jinja2 macros)
        2[rule name] --> |may have| 9(remediation)
            9(remediation) --> |may use| 10[bash]
                10[bash] --> |written at| 11[shared.sh]
                    11[shared.sh] --> |may use| 5(jinja2 macros)
            9(remediation) --> |may use| 12[ansible]
                12[ansible] --> |written at| 13[shared.yml]
                    13[shared.yml] --> |may use| 5(jinja2 macros)
        2[rule name] --> |may have| 14[tests]
            14[tests] --> |uses| 15(bash scripts)
                15(bash scripts) --> |to test| 16(failure)
                    16(failure) --> |written at| 17[name.fail.sh]
                        17[name.fail.sh] --> |may use| 5(jinja2 macros)
                15(bash scripts) --> |to test| 18(success)
                    18(success) --> |written at| 19[name.pass.sh]
                        19[name.pass.sh] --> |may use| 5(jinja2 macros)
            14[tests] --> |may have exceptions like| 20[ocp4]
    1([rules]) --> |may share| 21(variables)
        21(variables) --> |written at| 22[var_name.var]
    1([rules]) --> |may share| 23(properties)
        23(properties) --> |written at| 24[group.yml]
            24[group.yml] --> |may define platform| 4[applicability]
    1([rules]) --> |may use| 25[templates]
        25[templates] --> |may use| 5(jinja2 macros)
    end
    style 1 fill: #FFD700,stroke:#333,stroke-width:4px
    style 4 fill: #00BFFF,stroke:#333,stroke-width:4px
    style 5 fill: #FFA07A,stroke:#333,stroke-width:4px
    style 7 fill: #D3D3D3,stroke:#333
    style 14 fill: #32CD32,stroke:#333,stroke-width:4px
    style 15 fill: #A9A9A9,stroke:#333
    style 16 fill: #A9A9A9,stroke:#333
    style 18 fill: #A9A9A9,stroke:#333
    style 21 fill: #FFA500,stroke:#333,stroke-width:4px
    style 23 fill: #A9A9A9,stroke:#333
    style 25 fill: #9370DB,stroke:#333,stroke-width:4px
</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
