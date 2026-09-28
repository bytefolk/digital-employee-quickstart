# Case admission

The three catalog entries are synthetic teaching examples (`source.type=synthetic`). They test retrieval and demonstrate a working method. They do not count toward the target of real high-quality cases and must not serve as model-effect evaluation answers.

Before a real case enters retrieval, a maintainer records source and reuse authorization, anonymization review, license, pinned repository commit, requirement, decisions, final patch or artifact, independent review, measured test results, owner, and review date. Keep `approved=false` until all gates pass; retrieval skips unapproved entries.

Held-out tasks, hidden tests, gold patches, and secret scoring rules belong in a separate environment inaccessible to the model, not in this directory, employee assets, or a normal workspace.
