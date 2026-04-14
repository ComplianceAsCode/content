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
import yaml
import argparse
from pathlib import Path
from typing import Dict, List, Any
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

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

    # Load all family files
    controls = []
    for family_file in sorted(controls_dir.glob('*.yml')):
        family_data = load_yaml(family_file)
        if 'controls' in family_data:
            controls.extend(family_data['controls'])

    return {
        'product': product,
        'metadata': metadata,
        'controls': controls
    }


def merge_control_data(product_controls: Dict[str, Any], oscal_controls: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Merge product control data with OSCAL metadata."""
    merged = []

    for control in product_controls.get('controls', []):
        ctrl_id = control.get('id', '').lower()

        # Get OSCAL metadata
        oscal_data = oscal_controls.get(ctrl_id, {})

        # Extract description from OSCAL parts
        description = ""
        guidance = ""
        if oscal_data.get('parts'):
            for part in oscal_data['parts']:
                if part.get('name') == 'statement':
                    description = part.get('prose', '')
                elif part.get('name') == 'guidance':
                    guidance = part.get('prose', '')

        # Extract related controls from OSCAL
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
            # OSCAL metadata
            'description': description,
            'guidance': guidance,
            'parameters': oscal_data.get('parameters', []),
            'related_controls': related_controls,
            'class': oscal_data.get('class', ''),
            'parent': oscal_data.get('parent', ''),
            # Gap analysis
            'has_rules': len(control.get('rules', [])) > 0,
            'is_automated': control.get('status') == 'automated',
            'is_manual': control.get('status') == 'manual',
            'is_pending': control.get('status') == 'pending',
        }

        merged.append(merged_control)

    return merged


def generate_viewer_data(products: List[str], repo_root: Path) -> Dict[str, Any]:
    """Generate complete data structure for the viewer."""
    data_dir = repo_root / 'utils' / 'nist_sync' / 'data'

    # Load OSCAL catalog
    print("Loading OSCAL catalog...")
    oscal_controls = load_oscal_catalog(data_dir)

    # Load controls for each product
    products_data = {}
    for product in products:
        print(f"Loading controls for {product}...")
        product_controls = load_product_controls(product, repo_root)

        if product_controls:
            merged = merge_control_data(product_controls, oscal_controls)
            products_data[product] = {
                'metadata': product_controls.get('metadata', {}),
                'controls': merged
            }

    # Calculate statistics
    stats = {}
    for product, data in products_data.items():
        controls = data['controls']
        stats[product] = {
            'total': len(controls),
            'automated': sum(1 for c in controls if c['is_automated']),
            'manual': sum(1 for c in controls if c['is_manual']),
            'pending': sum(1 for c in controls if c['is_pending']),
            'with_rules': sum(1 for c in controls if c['has_rules']),
            'without_rules': sum(1 for c in controls if not c['has_rules']),
        }

    return {
        'products': products_data,
        'statistics': stats,
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
        'family.html'
    ]

    # Generate pages for each product in separate subdirectories
    for product in viewer_data['products'].keys():
        product_dir = output_dir / product
        product_dir.mkdir(parents=True, exist_ok=True)

        # Create product-specific data (only this product's data)
        product_data = {
            'products': {product: viewer_data['products'][product]},
            'statistics': {product: viewer_data['statistics'][product]},
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
