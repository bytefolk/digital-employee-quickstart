# Decision notes

Suggested approach: Distinguish initial loading, a true empty list, API errors, and insufficient permission; give an actionable retry path.

Counterexample: Rendering a failed request as an empty list hides a fault.
