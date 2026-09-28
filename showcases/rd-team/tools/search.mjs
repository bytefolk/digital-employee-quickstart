#!/usr/bin/env node
import { readFileSync, realpathSync } from 'node:fs';
import { dirname, join, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const casesRoot = realpathSync(join(root, 'cases'));
const readJson = (path) => JSON.parse(readFileSync(path, 'utf8'));

function options(argv) {
  const values = {};
  for (let i = 0; i < argv.length; i += 2) {
    if (!argv[i]?.startsWith('--') || !argv[i + 1] || argv[i + 1].startsWith('--')) {
      throw new Error('Expected --role/--task-type/--stack/--module/--query/--repository/--commit/--limit followed by a value');
    }
    const key = argv[i].slice(2);
    if (!['role', 'task-type', 'stack', 'module', 'query', 'repository', 'commit', 'limit'].includes(key) || key in values) {
      throw new Error(`Unknown or duplicate option: ${key}`);
    }
    values[key] = argv[i + 1];
  }
  if (!values.role || !values['task-type'] || !values.query) {
    throw new Error('--role, --task-type, and --query are required');
  }
  const limit = values.limit === undefined ? 5 : Number(values.limit);
  if (!Number.isInteger(limit) || limit < 2 || limit > 5) throw new Error('--limit must be between 2 and 5');
  return { ...values, limit };
}

function tokens(value) {
  return new Set(String(value).toLowerCase().match(/[\p{Script=Han}]{2}|[a-z0-9]+/gu) ?? []);
}

function safeCasePath(relative) {
  if (!relative.startsWith('./') || relative.includes('..')) throw new Error(`Invalid case path: ${relative}`);
  const path = realpathSync(join(casesRoot, relative));
  if (!path.startsWith(casesRoot + sep)) throw new Error(`Case path escapes the catalog root: ${relative}`);
  return path;
}

export function search(values) {
  const catalog = readJson(join(casesRoot, 'catalog.json'));
  const queryTerms = tokens(values.query);
  const now = new Date().toISOString().slice(0, 10);
  const results = [];
  for (const entry of catalog.cases) {
    if (!entry.approved) continue;
    const item = readJson(safeCasePath(entry.path));
    if (item.id !== entry.id || !item.source.approved || item.expiresAt < now) continue;
    if (!item.roles.includes(values.role) || item.taskType !== values['task-type']) continue;
    if (values.stack && !item.stack.includes(values.stack)) continue;
    if (values.module && item.module !== values.module) continue;
    const terms = tokens([item.title, item.summary, item.module, ...item.tags].join(' '));
    const matched = [...queryTerms].filter((term) => terms.has(term));
    const score = matched.length / Math.max(1, queryTerms.size);
    if (score === 0) continue;
    const baselineConflict = Boolean(
      (values.repository && item.baseline.repository !== values.repository) ||
      (values.commit && item.baseline.commit !== values.commit)
    );
    results.push({
      id: item.id, version: item.version, sourceType: item.source.type,
      baseline: item.baseline, baselineConflict, score,
      reason: `role=${values.role}; taskType=${item.taskType}; stack=${values.stack ?? 'any'}; textMatches=${matched.join(',') || 'none'}${baselineConflict ? '; case baseline differs from the current repository' : ''}`,
      path: entry.path
    });
  }
  results.sort((a, b) => b.score - a.score || a.id.localeCompare(b.id));
  return { schemaVersion: 'rd-search-result.v1alpha1', query: values.query, count: Math.min(results.length, values.limit), results: results.slice(0, values.limit), note: 'Reference only; current project facts take precedence. Synthetic cases do not establish real delivery performance.' };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try { console.log(JSON.stringify(search(options(process.argv.slice(2))), null, 2)); }
  catch (error) { console.error(error.message); process.exitCode = 1; }
}
