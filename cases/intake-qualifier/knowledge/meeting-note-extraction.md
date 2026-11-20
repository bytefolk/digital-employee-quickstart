# Communication-note extraction contract

Approval status: approved public fixture for case-library tests.
Source: ByteFolk Digital Employee case-library maintainers - generic framework material; no vendor, tenant, customer or credential data.
Last reviewed: 2026-11-18.

Extraction runs **only** on `transcript.text` (communication records). The
contract is deliberately conservative: anything the transcript does not
literally support is omitted, never guessed.

## Commitments

A commitment exists only when the transcript records a party agreeing to do
something.

- `statement`: what was agreed, in plain words.
- `owner`: only if the transcript names who. Omit otherwise — never guess from
  speaker roles.
- `dueBy`: only if the transcript states a date/time. "Next week" without a
  calendar anchor stays un-parsed: omit `dueBy`, keep the phrase inside
  `statement`.
- `excerpt`: the supporting transcript fragment.

## Objections

An objection is explicit reluctance: price, timing, capability, authority,
competitor, other.

- `statement`: the objection as raised.
- `kind`: classify into the enum; `other` when nothing fits.
- `excerpt`: the supporting transcript fragment.

Do not treat clarifying questions as objections.

## Next actions

A next action is a future step the transcript assigns or clearly implies at the
communication's end.

- `statement`: the step.
- `owner` / `dueBy`: same rule as commitments — only if stated.
- Follow-up suggestions the *employee* would add on its own do not belong
  here; those go in the proposal draft or clarifying questions.

## Absence

No transcript in the input → `meetingExtraction: null`. This is absence, not
degradation: no `degraded[]` entry, no write-back effect.
