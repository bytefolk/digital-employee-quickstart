# Decision notes

Suggested approach: Changing a filter resets pagination. Filtering and pagination share request parameters, and only the current request may update results.

Counterexample: Keeping the old page after a filter change can create a false empty state.
