# Independent R&D evaluation requirements

The public package `eval` checks fixed JSON input/output contracts only. Real task evaluation needs a separate environment inaccessible to the model for held-out tasks, hidden tests, gold patches, and secret scoring rules. This showcase contains none of them.

Record task ID, repository and commit, model and version, context variant (role rules only / rules plus current facts / rules plus facts and cases), budget, tool permissions, repeated runs, build and test exit codes, requirement coverage, visual checks, unauthorized actions, unsupported completion claims, duration, and human interventions. With a small sample, report task-level exploratory observations only.

Do not treat synthetic cases or offline fixtures as evidence of R&D delivery when the real repository, approval process, and controlled write tools are absent.
