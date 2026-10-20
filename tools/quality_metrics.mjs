import fs from 'node:fs';
for (const phase of ['baseline','current','cached']) {
 const rows=fs.readFileSync(`docs/validation/quality-20261018/benchmark-${phase}/m4-101.csv`,'utf8').trim().split(/\r?\n/);
 const cols=rows.shift().split(','); const data=rows.map(r=>r.split(',').map(Number));
 const out={phase};
 for(const name of ['frame_ms','process_ms','physics_ms','draw_calls','nodes']) { const i=cols.indexOf(name); const a=data.map(r=>r[i]).sort((a,b)=>a-b); out[name]={p50:a[Math.floor(a.length*.5)],p95:a[Math.floor(a.length*.95)]}; }
 console.log(JSON.stringify(out));
}
