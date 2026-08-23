# content/tests

This flowchart represents the high-level interaction of components under the `tests` folder.

Note that colors are used to highlight components which interact with other folders under the `content` repository.

> ***NOTE***: Since the colors have only visual effects when presented in individual flowcharts, they are very useful when analyzing multiple flowcharts together.

<div class="mermaid" style="width=100%;">
graph LR
    subgraph tests
    120[tests] --> |contains| 121[data]
        121[data] --> 122[profile_stability]
            122[profile_stability] --> |contains| 123[products]
                123[products] --> |contains| 124[profiles]
    120[tests] --> |contains| 125[kickstarts]
        125[kickstarts] --> |contains| 126(kickstart_files)
    120[tests] --> |contains| 127[shared]
        127[shared] --> |contains| 128[audit]
            128[audit] --> |contains| 129(audit_files)
        127[shared] --> |contains| 130(bash scripts)
        127[shared] --> |contains| 131(conf files)
    120[tests] --> |contains| 132[ssg_test_suite]
        132[ssg_test_suite] --> |contains| 133(python scripts)
    120[tests] --> |contains| 134[unit]
        134[unit] --> |contains| 135[bash]
            135[bash] --> |contains| 136[execute_tests.sh]
                136[execute_tests.sh] --> |process| 137[script_name.jinja]
            135[bash] --> |contains| 137[script_name.jinja]
        134[unit] --> |contains| 138[build-scripts]
            138[build-scripts] --> |contains| 139[test_relabel_ids.py]
        134[unit] --> |contains| 140[kubernetes]
            140[kubernetes] --> |contains| 141[Makefile]
        134[unit] --> |contains| 142[ssg_test_suite]
            142[ssg_test_suite] --> |contains| 143[data]
                143[data] --> |contains| 144[rules.json]
            142[ssg_test_suite] --> |contains| 145[test_analyze_results.py]
            142[ssg_test_suite] --> |contains| 146[test_matches_platform.py]
            142[ssg_test_suite] --> |can test| 147([rules])
            142[ssg_test_suite] --> |can test| 148[profiles]
        134[unit] --> |contains| 149[ssg-module]
            149[ssg-module] --> |contains| 150[test_module_name.py]
            149[ssg-module] --> |contains| 151[data]
                151[data] --> |contains| 152(data used for tests)
            149[ssg-module] --> |contains| 153[test_playbook_builder_data]
                153[test_playbook_builder_data] --> |contains| 154[applicability]
                153[test_playbook_builder_data] --> |contains| 155[fixes]
                153[test_playbook_builder_data] --> |contains| 156[guide]
                153[test_playbook_builder_data] --> |contains| 157[profiles]
                153[test_playbook_builder_data] --> |contains| 158[rules]
                153[test_playbook_builder_data] --> |contains| 159[build_config.yml]
                153[test_playbook_builder_data] --> |contains| 160[product.yml]
                153[test_playbook_builder_data] --> |contains| 161[selinux_state.yml]
        134[unit] --> |contains| 162[utils]
            162[utils] --> |contains| 163[test_generate_contributors.py]
    120[tests] --> |contains| 164(misc files)
        164(misc files) --> |includes| 165[README.md]
        164(misc files) --> |includes| 166[test_suite.py]
        164(misc files) --> |includes| 167(python scripts)
        164(misc files) --> |includes| 168(bash scripts)
        164(misc files) --> |includes| 169(yaml files)
    120[tests] --> |may use| 170[Dockerfiles]
    end
    style 120 fill: #00FA9A,stroke:#333,stroke-width:4px
    style 123 fill: #F0E68C,stroke:#333,stroke-width:4px
    style 124 fill: #F4A460,stroke:#333,stroke-width:4px
    style 126 fill: #A9A9A9,stroke:#333
    style 130 fill: #A9A9A9,stroke:#333
    style 131 fill: #A9A9A9,stroke:#333
    style 133 fill: #A9A9A9,stroke:#333
    style 134 fill: #A9A9A9,stroke:#333
    style 147 fill: #FFD700,stroke:#333,stroke-width:4px
    style 148 fill: #F4A460,stroke:#333,stroke-width:4px
    style 152 fill: #A9A9A9,stroke:#333
    style 154 fill: #00BFFF,stroke:#333,stroke-width:4px
    style 157 fill: #F4A460,stroke:#333,stroke-width:4px
    style 158 fill: #FFD700,stroke:#333,stroke-width:4px
    style 167 fill: #A9A9A9,stroke:#333
    style 168 fill: #A9A9A9,stroke:#333
    style 169 fill: #A9A9A9,stroke:#333
    style 170 fill: #CD5C5C,stroke:#333,stroke-width:4px
</div>

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
