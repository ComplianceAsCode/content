# Stabilization Phase

## Definition
A period of time before release, when the project is extensively tested and the only accepted contributions are fixes to issues discovered during stabilization testing.
New content, features, tests, or improvements are not accepted.
Fixes for known issues that haven't been discovered during the stabilization process are also not accepted.

To not interfere with project liveliness, the stabilization happens in a separate branch with *stabilization* prefix, e.g. stabilization-v0.1.70.
Master/main branch contributions are not affected.

During this period, project is tested, contributors are informed about upcoming release, everything is prepared for release (release notes, contributors list, milestones), and issue fixes are verified.

## Duration
Current duration is set to **2 weeks**.
This duration is approximate.
Complications such as newly discovered major issues during this period might slightly prolong it.

The duration is tied to release cadence.
The more time between release, the more time for stabilization is needed.
Thus, the current 2 weeks stabilization is for release every 2 months.
However, stabilization period does not affect release cadence.
Next release date will be the same as there would not be any prolongation.

## Exit Criteria
Criteria that must be met for stabilization conclusion (in stabilization branch):
- No major issues (build fails, remediation breaks system, built artifacts are invalid) in project,
- All newly discovered issues are reported and fixed or planned for future release based on maintainers' discretion,
- Issue fixes are either verified or re-opened and planned for future release,
- Preparations for release (release notes, contributors list, milestones) are finished.

With that, the stabilization phase can be concluded.
If it happens before the planned release date, the decision is upon release assignee to either release earlier or wait until the date.
