# content/products

This flowchart represents the high-level interaction of components under the `products` folder.

Note that colors are used to highlight components which interact with other folders under the `content` repository.

> ***NOTE***: Since the colors have only visual effects when presented in individual flowcharts, they are very useful when analyzing multiple flowcharts together.

<div class="mermaid" style="width=100%;">
flowchart TD
    subgraph products
    60[products] --> |identified by| 61[product_name]
        61[product_name] --> |defined at| 62[product.yml]
        61[product_name] --> |contains| 63[overlays]
        61[product_name] --> |contains| 64[profiles]
            64[profiles] --> |written at| 65[profile_name.profile]
                65[profile_name.profile] --> |refers to| 66([rules])
                65[profile_name.profile] --> |may override| 67[variables]
                65[profile_name.profile] --> |may use| 68[controls]
        61[product_name] --> |contains| 69[transforms]
        61[product_name] --> |may have| 70[kickstart]
        61[product_name] --> |may have| 71[checks]
            71[checks] --> |instructed using| 72([OVAL + XCCDF])
                72([OVAL + XCCDF]) --> |written at| 73[check_name.xml]
    end
    style 60 fill: #F0E68C,stroke:#333,stroke-width:4px
    style 64 fill: #F4A460,stroke:#333,stroke-width:4px
    style 66 fill: #FFD700,stroke:#333,stroke-width:4px
    style 67 fill: #FFA500,stroke:#333,stroke-width:4px
    style 72 fill: #D3D3D3,stroke:#333
    style 73 fill: #1E90FF,stroke:#333,stroke-width:4px
</div>
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
