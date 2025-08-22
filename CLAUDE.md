# Security Content Writing Guidelines

## Writing Style for Rule Metadata
Apply these guidelines to descriptions, rationale statements, and OCIL statements:

### Voice and Tone
- Use active voice ("Configure the system" not "The system should be configured")
- Write in present tense for current states and imperative mood for actions
- Be clear, concise, and direct
- Assume readers have basic system administration knowledge but may be unfamiliar with specific security concepts
- Do not use contractions ("cannot" not "can't")
- Use professional, authoritative tone without being overly technical

### Formatting and Syntax
- Use markdown code blocks (``` or `) for:
  - Terminal commands and input
  - Terminal output and logs
  - Configuration file contents
  - File paths and configuration values
  - Package names and service names
- Do not use **bold** or *italics* text
- Do not use heading sections in rule prose
- Follow the existing guidelines in docs/manual/developer/04_style_guide.md where applicable
- Lines in rule prose should be wrapped at 80 characters

### Content Structure
- Start descriptions with the security objective or requirement
- Follow with implementation details
- Include relevant context about why the control matters
- End rationale statements with potential security risks if not implemented

### Technical Accuracy
- Verify all commands, file paths, and configuration examples
- Use exact parameter names and values from official documentation
- Include version-specific information when relevant
- Reference authoritative sources (NIST, CIS, DISA STIG) when applicable

## Examples

### Good Description
```
Ensure the `auditd` service starts automatically at boot time. Configure the system to enable audit logging by setting the service to start during system initialization.
```

### Poor Description
```
You should make sure auditd is enabled so it'll start when the system boots up.
```

### Good Command Example
```
Run the following command to enable the service:
`systemctl enable auditd`
```

### Good Configuration Example
```
Add the following line to `/etc/audit/auditd.conf`:
`log_format = RAW`
```
