# NIST 800-53 Control Viewer & Gap Analysis

Interactive multi-page web-based viewer for NIST 800-53 control files with comprehensive gap analysis and backlog management features.

## Architecture

The viewer is a multi-page web application with the following pages:

- **index.html** - Dashboard with overview statistics and charts
- **controls.html** - Controls list with advanced filtering
- **control-detail.html** - Individual control details with OSCAL metadata and TODO management
- **gaps.html** - Gap analysis showing controls without rules
- **statistics.html** - Detailed statistics and metrics
- **family.html** - Control family breakdown and family-specific views

All pages share:
- Common navigation header for seamless page transitions
- Shared CSS styling for consistent look and feel
- Embedded JSON data for offline access (no external API calls)
- Product selector that persists across pages via localStorage

## Features

### Dashboard (index.html)
- **Overall Coverage Statistics**: Total controls, automated, manual, and pending counts with percentages
- **Gap Analysis Summary**: Total controls without rules
- **Product Comparison Table**: Side-by-side comparison of rhel8, rhel9, and rhel10 coverage
- **Family Coverage Chart**: Bar chart showing automation coverage by control family
- **Top Gaps List**: Quick view of controls that need rule implementation (links to detailed gap analysis)

### Controls Browser (controls.html)
- **Advanced Filtering**:
  - Filter by control family (AC, AU, CM, IA, SC, SI, etc.)
  - Filter by baseline level (Low, Moderate, High)
  - Filter by status (Automated, Manual, Pending)
  - Filter by gap status (With Rules, Without Rules)
  - Full-text search across control IDs, titles, and descriptions
  - Select All / Deselect All checkboxes for each filter category

- **Controls List**:
  - Clickable control cards showing ID, title, status, and metadata
  - Visual gap indicators (red dots for controls without rules)
  - Rule count and baseline level badges

### Control Details (control-detail.html)
- **OSCAL Metadata**: Full description, supplemental guidance, and parameters (ODPs)
- **Implementation Status**: Automated, manual, or pending
- **Rule Listings**: All rules mapped to this control
- **Related Controls**: Clickable links to related controls
- **Baseline Level Applicability**: Which baselines (low, moderate, high) include this control

- **Backlog Management**:
  - Add TODO items per control
  - Mark items as complete
  - Delete completed items
  - Persistent storage in browser localStorage (per-control)

### Gap Analysis (gaps.html)
- **Gap Summary**: Total gaps broken down by baseline level (high, moderate, low)
- **Priority Sections**: Gaps organized by baseline priority
- **Family Breakdown**: Which control families have the most gaps
- **Quick Navigation**: Click any gap to view control details

### Statistics (statistics.html)
- **Product Overview**: Comprehensive metrics for current product
- **Baseline Breakdown**: Coverage statistics for each baseline level (low, moderate, high)
- **Cross-Product Comparison**: Table comparing all products side-by-side
- **Family Statistics**: Detailed metrics for each control family

### Control Families (family.html)
- **Family Grid View**: All control families with coverage stats
- **Family Detail View**: Click any family to see all controls in that family
- **Family-Specific Stats**: Automated, manual, pending, and gap counts per family
- **Quick Control Access**: Jump to any control within a family

## Building the Viewer

### Using CMake (Recommended)

```bash
# Build everything including the NIST viewer
cd build
cmake .. -G Ninja
ninja nist-viewer

# The viewer will be generated at:
# build/nist-controls-viewer/
#   ├── index.html                   (Redirects to rhel9/)
#   ├── nist-controls-data.json      (Reference data file)
#   ├── rhel8/
#   │   ├── index.html               (RHEL8 Dashboard)
#   │   ├── controls.html            (Controls browser)
#   │   ├── control-detail.html      (Control details)
#   │   ├── gaps.html                (Gap analysis)
#   │   ├── statistics.html          (Statistics)
#   │   └── family.html              (Families)
#   ├── rhel9/
#   │   ├── index.html               (RHEL9 Dashboard)
#   │   └── ... (same structure)
#   └── rhel10/
#       ├── index.html               (RHEL10 Dashboard)
#       └── ... (same structure)
```

### Manual Generation

```bash
cd utils/nist_sync

# Generate the viewer for specific products
python3 generate_nist_viewer.py \
  --products rhel8 rhel9 rhel10 \
  --output-dir ../../build/nist-controls-viewer \
  --repo-root ../..

# Open the viewer (redirects to rhel9 by default)
open ../../build/nist-controls-viewer/index.html

# Or open a specific product directly:
open ../../build/nist-controls-viewer/rhel9/index.html
```

## Published Version

The viewer is automatically published to GitHub Pages via the `gh-pages` workflow:

**URL**: https://complianceascode.github.io/content-pages/nist-viewer/

The published version updates automatically when changes are pushed to the master branch. Navigate to the dashboard (index.html) to start browsing.

## Data Structure

The viewer generates product-specific pages in separate subdirectories (rhel8/, rhel9/, rhel10/). Each product's pages embed only that product's data (as `EMBEDDED_DATA` JavaScript constant), significantly reducing file sizes and improving performance.

Product-specific data structure:
- Each product subdirectory contains a complete set of viewer pages
- Each page embeds only that product's control data (~2.5MB vs ~7.5MB for all products)
- Pages communicate via URL parameters (e.g., `control-detail.html?id=ac-2`)
- TODOs are stored in localStorage per-control
- Product switching is done via links in the header (not localStorage)

A separate `nist-controls-data.json` file is also generated for reference and debugging purposes.

The data structure contains:

```json
{
  "products": {
    "rhel9": {
      "metadata": { /* Product metadata */ },
      "controls": [
        {
          "id": "ac-1",
          "title": "Access Control Policy and Procedures",
          "levels": ["low", "moderate", "high"],
          "rules": ["rule_id_1", "rule_id_2"],
          "status": "automated",
          "description": "OSCAL description...",
          "guidance": "OSCAL guidance...",
          "parameters": [ /* ODPs */ ],
          "related_controls": ["ac-2", "pm-9"],
          "has_rules": true,
          "is_automated": true
        }
      ]
    }
  },
  "statistics": {
    "rhel9": {
      "total": 1196,
      "automated": 850,
      "manual": 50,
      "pending": 296,
      "with_rules": 900,
      "without_rules": 296
    }
  },
  "families": [ /* 21 control families */ ]
}
```

## Gap Analysis Features

### Gap Identification
Controls are marked as "gaps" when:
- `status: pending` - No implementation exists
- `has_rules: false` - No rules are mapped to the control

### Gap Visualization
- **Dashboard**: Red indicator showing total gaps with percentage
- **Controls List**: Red dot indicator on gap controls
- **Filter**: Dedicated "Without Rules" filter to show only gaps
- **Gap List**: Top 20 gaps displayed on dashboard

### Addressing Gaps
1. Navigate to a gap control in the Controls view
2. Add TODO items describing what needs to be implemented
3. Create the necessary rules in the repository
4. Regenerate the viewer to see updated statistics

## TODO/Backlog Management

### Adding TODOs
1. Select a control
2. Scroll to the "TODO / Backlog Items" section
3. Type your TODO item
4. Click "Add"

### Managing TODOs
- **Check**: Mark as complete
- **Uncheck**: Mark as incomplete
- **Delete**: Remove the item

TODOs are stored in browser localStorage, so they persist across sessions but are local to your browser.

## Customization

### Modifying the Templates
Edit files in `utils/nist_sync/templates/` to customize:
- **_shared_styles.html** - Common CSS used across all pages
- **_shared_header.html** - Navigation header and product selector
- **index.html** - Dashboard page
- **controls.html** - Controls browser page
- **control-detail.html** - Individual control detail page
- **gaps.html** - Gap analysis page
- **statistics.html** - Statistics page
- **family.html** - Control families page

Each template can have its own page-specific styles and JavaScript in addition to the shared components.

### Adding New Statistics
Modify `generate_nist_viewer.py`:
1. Update `generate_viewer_data()` to calculate new statistics
2. Update the template to display them

### Regenerate
After making changes:
```bash
ninja nist-viewer
```

## Workflow Integration

The viewer is automatically built and published by `.github/workflows/gh-pages.yaml`:

```yaml
- name: Generate NIST 800-53 Control Viewer
  run: ninja nist-viewer
  working-directory: ./build
```

The generated files are copied to the GitHub Pages site by `utils/generate_html_pages.sh`.

## Browser Compatibility

The viewer uses modern JavaScript features and requires:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

No external dependencies - all functionality is self-contained in a single HTML file.

## Troubleshooting

### "Error loading data"
- The data should be embedded in each HTML file - regenerate the viewer with `ninja nist-viewer`
- If you modified a template, ensure the `/* DATA_PLACEHOLDER */` comment exists in the script section
- Check browser console for specific error messages
- Each HTML file should be several MB in size - if much smaller, the data wasn't embedded properly

### Controls not showing
- Check filter settings on controls.html - try resetting all filters
- Verify the data is embedded (open browser console and check for `EMBEDDED_DATA`)
- Try switching products using the product selector

### TODOs not persisting
- localStorage must be enabled in your browser
- Check browser privacy settings
- TODOs are per-browser, per-domain, and per-control
- Clearing browser data will erase TODOs

### Dashboard not rendering / Page not loading
- Check browser console for JavaScript errors
- Ensure the EMBEDDED_DATA constant is defined
- Try refreshing the page
- Verify you're using a modern browser (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)

### Navigation not working
- Ensure all 6 HTML files are in the same directory
- Check that file paths are relative (not absolute)
- If hosting on a web server, verify all files are accessible

### Product selection not persisting
- Check that localStorage is enabled
- The product selection is stored in localStorage key `selected-product`
- Clearing browser data will reset to default (rhel9)

## Development

To develop new features:

1. Edit templates in `utils/nist_sync/templates/`:
   - For styling changes: edit `_shared_styles.html`
   - For navigation changes: edit `_shared_header.html`
   - For page-specific changes: edit the corresponding page template
2. Test locally by opening the generated HTML files in a browser
3. Regenerate after changes: `ninja nist-viewer` (from build directory)
4. Commit template changes

### Adding a New Page

1. Create a new template file in `utils/nist_sync/templates/` (e.g., `new-page.html`)
2. Include placeholders for shared components:
   ```html
   <!-- SHARED_STYLES_PLACEHOLDER -->
   <!-- SHARED_HEADER_PLACEHOLDER -->
   /* DATA_PLACEHOLDER */
   ```
3. Add the page to the `pages` list in `generate_nist_viewer.py`
4. Add navigation link to `_shared_header.html`
5. Regenerate and test

## License

Same license as the ComplianceAsCode/content project (BSD-3-Clause).
