# R&D handoff contracts

The `*.schema.json` files are synchronous JSON Schemas. Each position's output Schema is copied at the same version as its handoff contract. `taskId` joins work on one requirement; `sourceRefs` names current material, while `caseRefs` names cases actually retrieved. Preserve unresolved issues in `assumptions`, `risks`, and `handoffQuestions`.

A `passed` check requires execution evidence. Use `not_run` if the command was not run, and list only existing files in `artifacts`. Review and QA are separate positions with separate task outputs; neither is replaced by developer self-assessment.

`api-contract.v1` is optional for a slice that reuses an existing API. Project facts must confirm actual paths and authorization rules before creating one.
