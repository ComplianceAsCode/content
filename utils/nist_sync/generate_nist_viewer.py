#!/usr/bin/env python3
"""
Generate NIST 800-53 Control Viewer HTML page with gap analysis and backlog management.

This script:
1. Loads NIST 800-53 control files for each product
2. Loads OSCAL catalog data for NIST 800-53 Rev 5
3. Merges control data with OSCAL metadata
4. Generates interactive HTML viewer with gap analysis
"""

import json
import re
import yaml
import argparse
from pathlib import Path
from typing import Dict, List, Any, Tuple
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    import ssg.components
    _HAS_SSG_COMPONENTS = True
except ImportError:
    _HAS_SSG_COMPONENTS = False

try:
    from ruamel.yaml import YAML
    yaml_loader = YAML()
    yaml_loader.preserve_quotes = True
    yaml_loader.default_flow_style = False
except ImportError:
    yaml_loader = None


def load_yaml(filepath: Path) -> Dict[str, Any]:
    """Load YAML file."""
    with open(filepath, 'r') as f:
        if yaml_loader:
            return yaml_loader.load(f)
        else:
            return yaml.safe_load(f)


def load_oscal_catalog(data_dir: Path) -> Dict[str, Any]:
    """Load NIST OSCAL catalog."""
    catalog_file = data_dir / 'nist_800_53_rev5_catalog.json'

    if not catalog_file.exists():
        print(f"Warning: OSCAL catalog not found at {catalog_file}")
        print("Run: cd utils/nist_sync && python3 download_oscal.py")
        return {}

    with open(catalog_file, 'r') as f:
        catalog = json.load(f)

    # Build control ID -> control data mapping
    controls_map = {}

    def extract_controls(controls_list, parent_id=None):
        """Recursively extract controls from OSCAL catalog."""
        for control in controls_list:
            ctrl_id = control.get('id', '').lower()

            controls_map[ctrl_id] = {
                'id': ctrl_id,
                'title': control.get('title', ''),
                'class': control.get('class', ''),
                'parts': control.get('parts', []),
                'properties': control.get('props', []),
                'parameters': control.get('params', []),
                'parent': parent_id
            }

            # Process sub-controls
            if 'controls' in control:
                extract_controls(control['controls'], parent_id=ctrl_id)

    # Extract controls from catalog
    if 'catalog' in catalog:
        for group in catalog['catalog'].get('groups', []):
            if 'controls' in group:
                extract_controls(group['controls'])

    return controls_map


def _flatten_controls(controls_list, parent_id=None):
    """Recursively flatten nested controls, adding parent_id and enhancements info."""
    result = []
    for ctrl in controls_list:
        ctrl_copy = dict(ctrl)
        if parent_id:
            ctrl_copy['parent_id'] = parent_id
        nested = ctrl_copy.pop('controls', None)
        if nested:
            ctrl_copy['enhancements'] = [str(c.get('id', '')) for c in nested]
            result.append(ctrl_copy)
            result.extend(_flatten_controls(nested, parent_id=str(ctrl.get('id', ''))))
        else:
            result.append(ctrl_copy)
    return result


def load_product_controls(product: str, repo_root: Path) -> Dict[str, Any]:
    """Load control files for a product."""
    controls_dir = repo_root / 'products' / product / 'controls' / 'nist_800_53'
    metadata_file = repo_root / 'products' / product / 'controls' / 'nist_800_53.yml'

    if not controls_dir.exists():
        print(f"Warning: Control directory not found for {product}: {controls_dir}")
        return {}

    # Load metadata
    metadata = {}
    if metadata_file.exists():
        metadata = load_yaml(metadata_file)

    # Load all family files, flattening nested enhancements
    controls = []
    for family_file in sorted(controls_dir.glob('*.yml')):
        family_data = load_yaml(family_file)
        if 'controls' in family_data:
            controls.extend(_flatten_controls(family_data['controls']))

    return {
        'product': product,
        'metadata': metadata,
        'controls': controls
    }


def _build_params_map(oscal_data: Dict[str, Any]) -> Dict[str, str]:
    """Build {param_id: label} from OSCAL params list."""
    params = {}
    for param in oscal_data.get('parameters', []):
        pid = param.get('id', '')
        label = param.get('label', pid)
        if pid:
            params[pid] = label
    return params


def _process_prose(prose: str, params_map: Dict[str, str]) -> str:
    """Process OSCAL prose: resolve param refs and convert cross-control links.

    - {{ insert: param, param_id }} -> <span class="odp" title="param_id">[label]</span>
    - [text](#anchor) markdown links -> internal viewer links
    """
    if not prose:
        return ''

    def replace_param(m: re.Match) -> str:
        param_id = m.group(1).strip()
        label = params_map.get(param_id, param_id)
        return f'<span class="odp" title="{param_id}">[{label}]</span>'

    prose = re.sub(r'\{\{\s*insert:\s*param,\s*([^}]+?)\s*\}\}', replace_param, prose)

    def replace_link(m: re.Match) -> str:
        text = m.group(1)
        anchor = m.group(2)
        # Anchor examples: #ac-2.4  #ac-2_smt.a  #cm-6_gp  -> extract ctrl ID
        ctrl_id = re.split(r'[_#]', anchor.lstrip('#'))[0]
        return f'<a href="control-detail.html?id={ctrl_id}" class="ctrl-ref">{text}</a>'

    prose = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', replace_link, prose)
    return prose


def _extract_statement(parts: List[Dict], params_map: Dict[str, str]) -> Dict[str, Any]:
    """Extract control statement as structured {prose, items:[{prose, items:[...]}]}."""
    for part in parts:
        if part.get('name') != 'statement':
            continue
        top_prose = _process_prose(part.get('prose', ''), params_map)

        def extract_items(container):
            result = []
            for sub in container.get('parts', []):
                if sub.get('name') == 'item':
                    result.append({
                        'prose': _process_prose(sub.get('prose', ''), params_map),
                        'items': extract_items(sub),
                    })
            return result

        return {'prose': top_prose, 'items': extract_items(part)}
    return {}


def _extract_guidance(parts: List[Dict], params_map: Dict[str, str]) -> List[str]:
    """Extract guidance prose as a list of paragraphs."""
    for part in parts:
        if part.get('name') == 'guidance':
            prose = _process_prose(part.get('prose', ''), params_map)
            return [p.strip() for p in prose.split('\n\n') if p.strip()]
    return []


def _build_params_display(oscal_data: Dict[str, Any]) -> List[Dict[str, str]]:
    """Return list of {id, label} for display in the Parameters section."""
    result = []
    for param in oscal_data.get('parameters', []):
        pid = param.get('id', '')
        label = param.get('label', '')
        if pid:
            result.append({'id': pid, 'label': label})
    return result


def merge_control_data(product_controls: Dict[str, Any], oscal_controls: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Merge product control data with OSCAL metadata."""
    merged = []

    for control in product_controls.get('controls', []):
        ctrl_id = control.get('id', '').lower()
        oscal_data = oscal_controls.get(ctrl_id, {})

        params_map = _build_params_map(oscal_data)
        oscal_parts = oscal_data.get('parts', [])

        # Extract related controls from OSCAL properties
        related_controls = []
        for prop in oscal_data.get('properties', []):
            if prop.get('name') == 'related':
                related_controls.append(prop.get('value', ''))

        merged_control = {
            'id': ctrl_id,
            'title': control.get('title', oscal_data.get('title', '')),
            'levels': control.get('levels', []),
            'rules': control.get('rules', []),
            'status': control.get('status', 'pending'),
            'notes': control.get('notes', ''),
            # OSCAL metadata — structured for rich rendering
            'statement': _extract_statement(oscal_parts, params_map),
            'guidance': _extract_guidance(oscal_parts, params_map),
            'parameters': _build_params_display(oscal_data),
            'related_controls': related_controls,
            'class': oscal_data.get('class', ''),
            'parent': oscal_data.get('parent', ''),
            # Gap analysis flags
            'has_rules': len(control.get('rules', [])) > 0,
            'is_automated': control.get('status') == 'automated',
            'is_manual': control.get('status') == 'manual',
            'is_pending': control.get('status') == 'pending',
            'is_inherently_met': control.get('status') == 'inherently met',
            'is_does_not_meet': control.get('status') == 'does not meet',
            'is_not_applicable': control.get('status') == 'not applicable',
        }

        if control.get('parent_id'):
            merged_control['parent_id'] = control['parent_id']
        if control.get('enhancements'):
            merged_control['enhancements'] = control['enhancements']

        merged.append(merged_control)

    return merged


GITHUB_BASE = "https://github.com/ComplianceAsCode/content/tree/master"


def _build_rule_url_map(repo_root: Path) -> Dict[str, str]:
    """Walk the repo and build {rule_id: github_url} by finding rule.yml files."""
    rule_map: Dict[str, str] = {}
    for search_root in [repo_root / 'linux_os', repo_root / 'applications']:
        if not search_root.exists():
            continue
        for rule_yml in search_root.rglob('rule.yml'):
            rule_dir = rule_yml.parent
            rule_id = rule_dir.name
            rel = rule_dir.relative_to(repo_root)
            rule_map[rule_id] = f"{GITHUB_BASE}/{rel}/rule.yml"
    return rule_map


def _load_components_data(repo_root: Path) -> Tuple[Any, Dict[str, List[str]]]:
    """Load component definitions and return (components_dict, rule_to_components_mapping).

    Returns (None, {}) if ssg.components is unavailable or the directory is missing.
    """
    if not _HAS_SSG_COMPONENTS:
        print("Warning: ssg.components not available; component data will be omitted from viewer.")
        return None, {}
    components_dir = repo_root / 'components'
    if not components_dir.exists():
        print(f"Warning: Components directory not found: {components_dir}")
        return None, {}
    print("Loading components...")
    components = ssg.components.load(str(components_dir))
    rule_to_components = ssg.components.rule_component_mapping(components)
    return components, rule_to_components


def _enrich_controls_with_components(
    merged: List[Dict[str, Any]],
    rule_to_components: Dict[str, List[str]],
) -> None:
    """Add 'components' and 'component_count' fields to each merged control (in-place)."""
    for control in merged:
        comp_map: Dict[str, List[str]] = {}
        for rule_id in control.get('rules', []):
            if '=' in str(rule_id):
                continue
            for comp in rule_to_components.get(rule_id, []):
                comp_map.setdefault(comp, []).append(rule_id)
        control['components'] = comp_map
        control['component_count'] = len(comp_map)


def _build_component_stats(
    products_data: Dict[str, Any],
    components_dict,
) -> Dict[str, Any]:
    """Build per-product component summary statistics."""
    component_stats: Dict[str, Any] = {}
    for product, data in products_data.items():
        comp_summary: Dict[str, Any] = {}
        for control in data['controls']:
            ctrl_id = control['id']
            for comp_name, rules in control.get('components', {}).items():
                if comp_name not in comp_summary:
                    packages = []
                    if components_dict and comp_name in components_dict:
                        packages = list(components_dict[comp_name].packages)
                    comp_summary[comp_name] = {
                        'name': comp_name,
                        'control_count': 0,
                        'rule_count': 0,
                        'controls': [],
                        'packages': packages,
                    }
                comp_summary[comp_name]['control_count'] += 1
                comp_summary[comp_name]['rule_count'] += len(rules)
                comp_summary[comp_name]['controls'].append(ctrl_id)
        component_stats[product] = comp_summary
    return component_stats


def generate_viewer_data(products: List[str], repo_root: Path) -> Dict[str, Any]:
    """Generate complete data structure for the viewer."""
    data_dir = repo_root / 'utils' / 'nist_sync' / 'data'

    # Load OSCAL catalog
    print("Loading OSCAL catalog...")
    oscal_controls = load_oscal_catalog(data_dir)

    # Load component definitions (centralized, shared across products)
    components_dict, rule_to_components = _load_components_data(repo_root)

    # Build rule → GitHub URL map
    print("Indexing rule paths...")
    rule_url_map = _build_rule_url_map(repo_root)

    # Load controls for each product
    products_data = {}
    for product in products:
        print(f"Loading controls for {product}...")
        product_controls = load_product_controls(product, repo_root)

        if product_controls:
            merged = merge_control_data(product_controls, oscal_controls)
            # Enrich each control with component information
            _enrich_controls_with_components(merged, rule_to_components)
            # Attach GitHub URL to each rule entry
            for control in merged:
                control['rule_urls'] = {
                    r: rule_url_map[r]
                    for r in control.get('rules', [])
                    if '=' not in str(r) and r in rule_url_map
                }
            products_data[product] = {
                'metadata': product_controls.get('metadata', {}),
                'controls': merged
            }

    # Calculate statistics
    stats = {}
    for product, data in products_data.items():
        controls = data['controls']
        base = [c for c in controls if not c.get('parent_id')]
        enhancements = [c for c in controls if c.get('parent_id')]
        stats[product] = {
            'total': len(controls),
            'base_controls': len(base),
            'enhancement_controls': len(enhancements),
            'automated': sum(1 for c in controls if c['is_automated']),
            'manual': sum(1 for c in controls if c['is_manual']),
            'pending': sum(1 for c in controls if c['is_pending']),
            'inherently_met': sum(1 for c in controls if c['is_inherently_met']),
            'does_not_meet': sum(1 for c in controls if c['is_does_not_meet']),
            'not_applicable': sum(1 for c in controls if c['is_not_applicable']),
            'with_rules': sum(1 for c in controls if c['has_rules']),
            'without_rules': sum(1 for c in controls if not c['has_rules']),
            'base_automated': sum(1 for c in base if c['is_automated']),
            'base_pending': sum(1 for c in base if c['is_pending']),
            'enh_automated': sum(1 for c in enhancements if c['is_automated']),
            'enh_pending': sum(1 for c in enhancements if c['is_pending']),
        }

    # Build component statistics per product
    component_stats = _build_component_stats(products_data, components_dict)

    return {
        'products': products_data,
        'statistics': stats,
        'component_stats': component_stats,
        'families': [
            {'id': 'ac', 'name': 'Access Control'},
            {'id': 'at', 'name': 'Awareness and Training'},
            {'id': 'au', 'name': 'Audit and Accountability'},
            {'id': 'ca', 'name': 'Assessment, Authorization, and Monitoring'},
            {'id': 'cm', 'name': 'Configuration Management'},
            {'id': 'cp', 'name': 'Contingency Planning'},
            {'id': 'ia', 'name': 'Identification and Authentication'},
            {'id': 'ir', 'name': 'Incident Response'},
            {'id': 'ma', 'name': 'Maintenance'},
            {'id': 'mp', 'name': 'Media Protection'},
            {'id': 'pe', 'name': 'Physical and Environmental Protection'},
            {'id': 'pl', 'name': 'Planning'},
            {'id': 'pm', 'name': 'Program Management'},
            {'id': 'ps', 'name': 'Personnel Security'},
            {'id': 'pt', 'name': 'PII Processing and Transparency'},
            {'id': 'ra', 'name': 'Risk Assessment'},
            {'id': 'sa', 'name': 'System and Services Acquisition'},
            {'id': 'sc', 'name': 'System and Communications Protection'},
            {'id': 'si', 'name': 'System and Information Integrity'},
            {'id': 'sr', 'name': 'Supply Chain Risk Management'},
            {'id': 'other', 'name': 'Other (Unmapped CIS Items)'},
        ]
    }


def generate_html_viewer(output_dir: Path, templates_dir: Path, viewer_data: Dict[str, Any]):
    """Generate multi-page HTML viewer from templates with embedded data."""

    # Read shared components
    shared_styles = (templates_dir / '_shared_styles.html').read_text()
    shared_header_template = (templates_dir / '_shared_header.html').read_text()

    # List of page templates to generate
    pages = [
        'index.html',
        'controls.html',
        'control-detail.html',
        'gaps.html',
        'statistics.html',
        'family.html',
        'components.html',
    ]

    # Generate pages for each product in separate subdirectories
    for product in viewer_data['products'].keys():
        product_dir = output_dir / product
        product_dir.mkdir(parents=True, exist_ok=True)

        # Create product-specific data (only this product's data)
        product_data = {
            'products': {product: viewer_data['products'][product]},
            'statistics': {product: viewer_data['statistics'][product]},
            'component_stats': {product: viewer_data['component_stats'].get(product, {})},
            'families': viewer_data['families']
        }

        # Embed the JSON data for this product
        json_data = json.dumps(product_data, indent=2)
        embedded_data_script = f'const EMBEDDED_DATA = {json_data};\nconst CURRENT_PRODUCT = "{product}";'

        # Create product selector links for header
        all_products = list(viewer_data['products'].keys())
        product_links = []
        for prod in all_products:
            if prod == product:
                product_links.append(f'<strong>{prod.upper()}</strong>')
            else:
                product_links.append(f'<a href="../{prod}/index.html" style="color: #0366d6; text-decoration: none;">{prod.upper()}</a>')

        product_selector_html = ' | '.join(product_links)

        # Update shared header with product selector
        shared_header = shared_header_template.replace(
            '<!-- PRODUCT_SELECTOR_PLACEHOLDER -->',
            f'<div style="margin-left: auto; font-size: 14px;">Product: {product_selector_html}</div>'
        )

        # Generate each page for this product
        for page in pages:
            template_file = templates_dir / page

            if not template_file.exists():
                print(f"Warning: Template not found: {template_file}")
                continue

            # Read template
            html_content = template_file.read_text()

            # Replace placeholders
            html_content = html_content.replace('<!-- SHARED_STYLES_PLACEHOLDER -->', f'<style>{shared_styles}</style>')
            html_content = html_content.replace('<!-- SHARED_HEADER_PLACEHOLDER -->', shared_header)
            html_content = html_content.replace('/* DATA_PLACEHOLDER */', embedded_data_script)

            # Write output file
            output_file = product_dir / page
            output_file.write_text(html_content)
            print(f"Generated: {output_file}")

    # Create an index.html that redirects to rhel9 by default
    default_product = 'rhel9' if 'rhel9' in viewer_data['products'] else list(viewer_data['products'].keys())[0]
    redirect_html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0; url=./{default_product}/index.html">
    <title>NIST 800-53 Control Viewer</title>
</head>
<body>
    <p>Redirecting to <a href="./{default_product}/index.html">{default_product.upper()} viewer</a>...</p>
</body>
</html>'''

    (output_dir / 'index.html').write_text(redirect_html)
    print(f"Generated redirect: {output_dir / 'index.html'}")

    print(f"\nMulti-page viewer generated in: {output_dir}")
    print("Product-specific viewers:")
    for product in viewer_data['products'].keys():
        print(f"  - {product.upper()}: {output_dir / product / 'index.html'}")
    print(f"\nOpen {output_dir / 'index.html'} in a web browser (redirects to {default_product.upper()}).")


def main():
    parser = argparse.ArgumentParser(description='Generate NIST 800-53 Control Viewer')
    parser.add_argument('--products', nargs='+', default=['rhel8', 'rhel9', 'rhel10'],
                        help='Products to include (default: rhel8 rhel9 rhel10)')
    parser.add_argument('--output-dir', type=Path, required=True,
                        help='Output directory for generated files')
    parser.add_argument('--repo-root', type=Path, default=Path.cwd(),
                        help='Repository root directory')

    args = parser.parse_args()

    # Ensure output directory exists
    args.output_dir.mkdir(parents=True, exist_ok=True)

    # Generate viewer data
    print("Generating viewer data...")
    viewer_data = generate_viewer_data(args.products, args.repo_root)

    # Write data file (for reference/debugging)
    data_file = args.output_dir / 'nist-controls-data.json'
    with open(data_file, 'w') as f:
        json.dump(viewer_data, f, indent=2)
    print(f"Generated data file: {data_file}")

    # Generate multi-page HTML viewer
    templates_dir = Path(__file__).parent / 'templates'

    if templates_dir.exists():
        generate_html_viewer(args.output_dir, templates_dir, viewer_data)
    else:
        print(f"Warning: Templates directory not found: {templates_dir}")
        print("HTML viewer not generated. Ensure templates directory exists.")

    print("\nViewer generation complete!")


if __name__ == '__main__':
    main()
