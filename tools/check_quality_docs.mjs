import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
const root = process.cwd();
const files = ['docs/game-development-dashboard.html', 'docs/IMPLEMENTATION_OVERVIEW.md', 'README.md', 'docs/validation/quality-20261018.md', 'specs/001-abyss-expedition-mvp/quality-pass-20261018.md'];
const failures = [];
let checked = 0;
for (const file of files) {
  const content = fs.readFileSync(file, 'utf8');
  const urls = file.endsWith('.html') ? [...content.matchAll(/(?:href|src)="([^"]+)"/g)].map(m=>m[1]) : [...content.matchAll(/\]\(([^)]+)\)/g)].map(m=>m[1]);
  for (const url of urls) {
    if (/^(https?:|mailto:|#)/.test(url)) continue;
    const target = path.resolve(path.dirname(file), url.split('#')[0]);
    checked++;
    if (!fs.existsSync(target)) failures.push(`${file}: missing ${url}`);
  }
  if (file.endsWith('.html')) {
    const ids = [...content.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]);
    if (new Set(ids).size !== ids.length) failures.push('duplicate dashboard ids');
    for (const match of content.matchAll(/href="#([^"]+)"/g)) if (!ids.includes(match[1])) failures.push(`missing anchor ${match[1]}`);
    for (const match of content.matchAll(/<img\b[^>]*>/g)) if (!/alt="[^"]+"/.test(match[0])) failures.push('image missing alt');
    for (const match of content.matchAll(/<script>([\s\S]*?)<\/script>/g)) new vm.Script(match[1]);
    if (/<(?:script|img|link)[^>]+(?:src|href)="https?:/.test(content)) failures.push('remote runtime/asset dependency');
  }
}
const before=fs.readFileSync('docs/validation/quality-20261018/before-engine.log','utf8').split(/\r?\n/).filter(x=>x.startsWith('QUALITY STATE'));
const after=fs.readFileSync('docs/validation/quality-20261018/after.log','utf8').split(/\r?\n/).filter(x=>x.startsWith('QUALITY STATE'));
if (before.length !== 3 || JSON.stringify(before) !== JSON.stringify(after)) failures.push('before/after controlled state mismatch');
const report = {localLinksChecked:checked, dashboardInlineScriptParses:true, controlledStatesIdentical:failures.every(x=>!x.includes('state')), failures};
fs.writeFileSync('docs/validation/quality-20261018/document-check.json', JSON.stringify(report,null,2));
console.log(JSON.stringify(report,null,2));
process.exitCode=failures.length ? 1 : 0;
