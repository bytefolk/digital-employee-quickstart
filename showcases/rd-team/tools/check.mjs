#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { search } from './search.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const json = (path) => JSON.parse(readFileSync(join(root, path), 'utf8'));
const org = json('organization.v1alpha1.json');
// Pin a conservative default rather than accepting every declaration from the
// organization being checked. Changes here also require independent ownership.
const owners = readFileSync(join(root, '../../.github/CODEOWNERS'), 'utf8');
for (const path of ['/showcases/rd-team/', '/.github/workflows/showcases-rd-team-v0.6.yml', '/.github/CODEOWNERS']) {
  assert(owners.split('\n').includes(`${path} @PeterGuy326`), `Missing independent owner for ${path}`);
}
for (const readme of ['README.md', 'README.zh-CN.md']) {
  const content = readFileSync(join(root, readme), 'utf8');
  assert(content.includes('fail-closed') && content.includes('host_policy') && content.includes('deny'), `${readme}: missing network fallback boundary`);
}
const roles = org.roles.map((role) => role.id);
assert.equal(roles.length, 7);
assert.equal(new Set(roles).size, 7);
for (const role of org.roles) {
  const prefix = role.id === 'tech-lead' ? 'positions/tech-lead' : `positions/tech-lead/${role.id}`;
  const manifest = json(`${prefix}/employee.json`);
  assert.equal(manifest.name, role.id);
  assert.equal(manifest.policy.mode, 'approval_required');
  assert.deepEqual(manifest.policy.filesystem.read, ['./**']);
  assert.deepEqual(manifest.policy.filesystem.write, ['./work/**']);
  // Deny by default: an unsupported host_policy must never imply allow.
  // A future opt-in needs independently reviewed host enforcement evidence.
  assert.equal(manifest.policy.network, 'deny');
  assert.deepEqual(role.toolAllow, ['Read', 'Grep', 'Glob', 'Write', 'Edit', 'WebSearch', 'WebFetch', 'Browser']);
  assert.deepEqual(role.toolDeny, ['Bash']);
  assert(role.toolDeny.every(tool => !role.toolAllow.includes(tool)));
  for (const instructions of ['SKILL.md', 'playbooks/task.md']) {
    const content = readFileSync(join(root, prefix, instructions), 'utf8');
    for (const boundary of ['work/', 'employee.json', 'evals', 'schemas', 'Bash', 'rm', 'git push', 'curl', 'host_policy', 'fail-closed']) {
      assert(content.includes(boundary), `${role.id}/${instructions}: missing ${boundary} boundary`);
    }
  }
  assert.equal(role.mode, 'approval_required');
  for (const asset of manifest.assets) assert(existsSync(join(root, prefix, asset)));
  const output = json(`${prefix}/schemas/output.schema.json`);
  const fixture = json(`${prefix}/evals/cases.json`).cases[0].expectedOutput;
  assert.equal(fixture.schemaVersion, output.properties.schemaVersion.const);
  for (const key of output.required) assert(key in fixture, `${role.id}: missing ${key}`);
  assert(existsSync(join(root, 'contracts', `${fixture.schemaVersion}.schema.json`)));
}
const workflow = json('workflow.json');
const seen = new Set();
for (const step of workflow.steps) {
  assert(roles.includes(step.role));
  for (const dependency of step.after) assert(seen.has(dependency), `Unresolved workflow dependency ${dependency}`);
  seen.add(step.id);
}
assert.notEqual(workflow.steps.find((step) => step.id === 'review').role, workflow.steps.find((step) => step.id === 'qa').role);
for (const entry of json('cases/catalog.json').cases) {
  const item = json(`cases/${entry.id}/case.json`);
  assert.equal(item.id, entry.id);
  assert.equal(item.source.type, 'synthetic');
  assert.equal(json(`cases/${entry.id}/result.json`).verified, false);
}
const hit = search({role: 'frontend-engineer', 'task-type': 'frontend-feature', stack: 'react', query: 'member list pagination', repository: 'example/member-console', commit: 'demo-baseline-v1', limit: 5});
assert(hit.results.some((item) => item.id === 'member-list-filter-001' && item.score === 1 && !item.baselineConflict));
assert(hit.results.every((item) => item.reason.includes('role=frontend-engineer')));
const conflict = search({role: 'frontend-engineer', 'task-type': 'frontend-feature', query: 'member list', repository: 'other/repository', commit: 'other', limit: 5});
assert(conflict.results.every((item) => item.baselineConflict));
const wrongStack = search({role: 'frontend-engineer', 'task-type': 'frontend-feature', stack: 'python', query: 'member list', limit: 5});
assert.equal(wrongStack.count, 0);
const noHit = search({role: 'frontend-engineer', 'task-type': 'frontend-feature', query: 'unrelated astronomy observatory', limit: 5});
assert.equal(noHit.count, 0);
console.log(JSON.stringify({status: 'passed', roles: roles.length, cases: json('cases/catalog.json').cases.length, checks: ['assets','fixtures','workflow','case-provenance','search','baseline-conflict','output-only-writes','shell-deny','network-fail-closed','independent-ownership']}));
