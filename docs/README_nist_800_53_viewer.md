# NIST 800-53 Control Viewer & Gap Analysis

Interactive web-based viewer for NIST 800-53 control files with comprehensive gap analysis and backlog management features.

## Features

### Dashboard View
- **Overall Coverage Statistics**: Total controls, automated, manual, and pending counts with percentages
- **Gap Analysis**: Visual representation of controls without rules
- **Product Comparison**: Side-by-side comparison of rhel8, rhel9, and rhel10 coverage
- **Family Coverage Chart**: Bar chart showing automation coverage by control family
- **Baseline Level Breakdown**: Distribution across LOW, MODERATE, and HIGH baselines
- **Top Gaps List**: Quick view of controls that need rule implementation

### Controls View
- **Advanced Filtering**:
  - Filter by control family (AC, AU, CM, IA, SC, SI, etc.)
  - Filter by baseline level (Low, Moderate, High)
  - Filter by status (Automated, Manual, Pending)
  - Filter by gap status (With Rules, Without Rules)
  - Full-text search across control IDs, titles, and descriptions

- **Control Details**:
  - OSCAL metadata (description, guidance, parameters)
  - Implementation status
  - Rule listings
  - Related controls with clickable links
  - Baseline level applicability

- **Backlog Management**:
  - Add TODO items per control
  - Mark items as complete
  - Delete completed items
  - Persistent storage in browser localStorage

## Building the Viewer

### Using CMake (Recommended)

```bash
# Build everything including the NIST viewer
cd build
cmake .. -G Ninja
ninja nist-viewer

# The viewer will be generated at:
# build/nist-controls-viewer/nist-controls-viewer.html
```

### Manual Generation

```bash
cd utils/nist_sync

# Generate the viewer for specific products
python3 generate_nist_viewer.py \
  --products rhel8 rhel9 rhel10 \
  --output-dir ../../build/nist-controls-viewer \
  --repo-root ../..

# Open the viewer
open ../../build/nist-controls-viewer/nist-controls-viewer.html
```

## Published Version

The viewer is automatically published to GitHub Pages via the `gh-pages` workflow:

**URL**: https://complianceascode.github.io/content-pages/nist-viewer/nist-controls-viewer.html

The published version updates automatically when changes are pushed to the master branch.

## Data Structure

The viewer has all control data embedded directly in the HTML file (as `EMBEDDED_DATA` JavaScript constant). This allows the viewer to work when opened directly as a local file without CORS issues.

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

### Modifying the Template
Edit `utils/nist_sync/nist_viewer_template.html` to customize:
- Styling (CSS in `<style>` section)
- Layout (HTML structure)
- Behavior (JavaScript functions)

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
- The data should be embedded in the HTML file - regenerate the viewer with `ninja nist-viewer`
- If you modified the template, ensure the `/* DATA_PLACEHOLDER */` comment exists in the script section
- Check browser console for specific error messages
- The HTML file should be around 7MB - if it's much smaller, the data wasn't embedded properly

### Controls not showing
- Check filter settings - try resetting all filters
- Verify the data file contains controls for the selected product

### TODOs not persisting
- localStorage must be enabled in your browser
- Check browser privacy settings
- TODOs are per-browser and per-domain

### Dashboard not rendering
- Check browser console for JavaScript errors
- Ensure the JSON data loaded successfully
- Try refreshing the page

## Development

To develop new features:

1. Edit `nist_viewer_template.html`
2. Test locally by opening the generated HTML file
3. Regenerate after changes: `ninja nist-viewer`
4. Commit both the template and updated CMake files

## License

Same license as the ComplianceAsCode/content project (BSD-3-Clause).
