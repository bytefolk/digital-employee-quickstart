#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { search } from './search.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const json = (path) => JSON.parse(readFileSync(join(root, path), 'utf8'));
const org = json('organization.v1alpha1.json');
const roles = org.roles.map((role) => role.id);
assert.equal(roles.length, 7);
assert.equal(new Set(roles).size, 7);
for (const role of org.roles) {
  const prefix = role.id === 'tech-lead' ? 'positions/tech-lead' : `positions/tech-lead/${role.id}`;
  const manifest = json(`${prefix}/employee.json`);
  assert.equal(manifest.name, role.id);
  assert.equal(manifest.policy.mode, 'approval_required');
  assert.deepEqual(manifest.policy.filesystem.read, ['./**']);
  assert.deepEqual(manifest.policy.filesystem.write, ['./**']);
  assert.equal(manifest.policy.network, 'host_policy');
  assert.deepEqual(role.toolAllow, ['Read', 'Grep', 'Glob', 'Write', 'Edit', 'Bash', 'WebSearch', 'WebFetch', 'Browser']);
  assert.deepEqual(role.toolDeny, []);
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
console.log(JSON.stringify({status: 'passed', roles: roles.length, cases: json('cases/catalog.json').cases.length, checks: ['assets','fixtures','workflow','case-provenance','search','baseline-conflict']}));
