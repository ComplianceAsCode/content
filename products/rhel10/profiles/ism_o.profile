documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - wcushen
        - eliseelk
        - sashperso
        - anjuskantha

reference: https://www.cyber.gov.au/ism

title: 'Australian Cyber Security Centre (ACSC) ISM Official'

description: |-
  This profile contains configuration checks for Red Hat Enterprise Linux 10
  that align to the Australian Cyber Security Centre (ACSC) Information Security Manual (ISM).

  The ISM uses a risk-based approach to cyber security. This profile provides a guide to aligning
  Red Hat Enterprise Linux security controls with the ISM, which can be used to select controls
  specific to an organisation's security posture and risk profile.

  A copy of the ISM can be found at the ACSC website:

  https://www.cyber.gov.au/ism

extends: e8

selections:
    - ism_o:all
