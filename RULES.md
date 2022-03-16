# Traffic rules

## TLDR
We need to:

Allow independent groups in the content project to work at their own pace on parts of the project that don’t influence each other.
Introduce enter and exit criteria for roles with elevated privileges so the hierarchy can self-organize.
Define a framework for organizations to join the project and assume responsibilities.
Make sure that the project stays coherent and individual parts contribute to its value, and the project doesn’t become a disgusting spaghetti soup.


## Decomposition

In order to keep the project scalable, we divide the project into separate areas, and assign groups of users that can be granted commit access with the intention to develop content in respective areas.
Those areas are going to be segmented by

- Products (RHEL, Ubuntu, …) - make it easy to develop content of a product that doesn’t influence the other content or the build system.
- Product-specific profiles (PSPs s.a. Firefox STIG, Ubuntu CIS, …) and respective control files - make it easy for SMEs that only want to assign rules to profiles without going into details.
- Product-independent profiles (PIPs s.a. ANSSI, HIPAA, PCI-DSS, …) and respective control files - ensure that PIP development benefits the whole community instead of cluttering the content with “if product in [...]”.
- Shared resources - rules only loosely coupled to products, templates, CPEs etc. Same principles that apply to PIPs apply for the shared content as well.
- Build system - decisions upon architecture of the build system impact build time, project capabilities, and can also move maintenance costs.
- Test-related code - ensure that tests have the greatest coverage as possible, but that don’t waste time and don’t suffer from false positives.
- Organization administration - ability to grant and remove rights, create and delete repositories etc.


## Implementation

### Products

- Keeping track of the decomposition: Metadata in product.yml files, CODEOWNERS file
- Area of effect: All PSPs that don’t have specific stakeholders, associated content and test scenarios.
- Guidelines: Care needs to be taken when content requires a slightly different approach for different products - don’t copy paste, and also don’t change existing behavior for everybody (link to coding guidelines needed).


### Product Specific Profiles (PSPs)

- Keeping track of the decomposition: Metadata in profile yml files, CODEOWNERS file
- Area of effect: Respective profile files
- Guidelines: N/A


### Product Independent Profiles (PIPs)

- Keeping track of the decomposition: Metadata in control files. Any profile definitions that live as separate profile files are simply a product’s content.
- Area of effect: Just control files
- Guidelines: Let’s try and see whether the control file format helps us with effort sharing.


### Build system

- Keeping track of the decomposition: CODEOWNERS file
- Area of effect: Everything that is directly or indirectly used during the content build process
- Guidelines: We need strong protection against technical debt, and a framework to deal with deprecations or changes of behavior.


### Shared Resources

- Keeping track of the decomposition: CODEOWNERS file
- Area of effect: Content that impacts more products.
- Guidelines: The same as for the build system.


### Tests

- Keeping track of the decomposition: CODEOWNERS file
- Area of effect: Test scenarios, test suite features, unit tests, gating tests
- Guidelines: We need guidelines to preserve test robustness and the rate of tests usefulness.


### Organizational administration

- Keeping track of the decomposition: Maintainer file, readme?
- Area of effect: Github org and project settings
- Guidelines: Enter and exit conditions


## Rights assignment

### Individual PR approve and merge rights

TLDR: 6 non-trivial PRs within 6 months => merge rights for 1 year since the last activity.

Contributors can ask for merge rights on the mailing list or on Gitter.
Although one can technically merge code, the code contribution guidelines still have to be obeyed.

Recommended way to get merge rights: Anybody who submits six non-trivial PRs that get merged in a period no longer than six months are encouraged to ask for rights.
A person can ask to be stripped of merge rights.
If a person doesn’t actively contribute to the project for a period of 12 months, their merge rights are stripped. Active contribution consists of either non-trivial contributions of code, non-trivial reviews, or analyses of problems in issues.  Rights can be also revoked if coding style or conduct are consistently broken.
The project maintainers decide about granting or strip of rights and about exceptions to the procedure e.g. when an applicant has deep prior experience with the project.


### Organizations

Aside from an organization (s.a. a company or an institution) being composed of individuals with individual rights, other developers associated with the organization may get “backup” merge rights or organization administration rights. Those rights can be granted for a period of 12 months and their renewal can be requested. These rights can only be used in cases when regular developers aren’t available and the organization needs to get their things through.
