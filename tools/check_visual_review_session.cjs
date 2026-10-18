// Browser automation fixtures only: never counted as human review responses.
const {chromium}=require('C:/Users/kahhe/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('fs'),path=require('path');
(async()=>{
 const evidence=process.argv[2]||'docs/validation/visual-vd01/completion-r2',checks=[],errors=[],network=[],downloadFailures=[];
 if(fs.existsSync(path.join(evidence,'review-session-browser-checks.json')))throw Error('Preserve earlier evidence; choose a fresh output directory.');
 const fixtures=path.join(evidence,'browser-test-fixtures');fs.mkdirSync(fixtures,{recursive:true});
 const browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true,downloadsPath:path.resolve(fixtures)});
 const context=await browser.newContext({viewport:{width:390,height:844},deviceScaleFactor:1,acceptDownloads:true});
 await context.addInitScript(()=>{crypto.getRandomValues=values=>{values.fill(0);return values}});
 const page=await context.newPage();page.on('pageerror',e=>errors.push(e.message));page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url())});
 const check=(ok,name)=>{checks.push({name,pass:!!ok});if(!ok)throw Error(name)};
 const answer=async()=>{for(const input of await page.locator('#fields textarea').all())await input.fill('SYNTHETIC AUTOMATION — NOT A HUMAN ANSWER');await page.locator('#answers button').click()};
 const url='file:///'+process.cwd().replaceAll('\\','/')+'/docs/visual-design/review-session.html';
 try{
  await page.goto(url);
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'mobile setup fits offline');
  await page.screenshot({path:evidence+'/review-session-mobile.png'});
  await page.fill('#participant','TEST_AUTOMATION_NOT_HUMAN');await page.click('#begin');
  check(await page.locator('#show').isDisabled(),'undersized display cannot shrink a trial');
  await page.click('#missing');
  await page.setViewportSize({width:1920,height:1080});
  await page.waitForFunction(()=>!document.getElementById('show').disabled);
  check(await page.locator('#show').isEnabled(),'full-size display enables exposure');
  await page.click('#show');await page.waitForSelector('body.exposing');
  check(await page.locator('#frame').evaluate(n=>n.naturalWidth===640&&n.getBoundingClientRect().width===1280),'real native frames at exact 2x');
  check(await page.locator('#answers').isHidden(),'answers hidden during recognition exposure');
  await page.waitForSelector('#answers:not([hidden])');
  check(await page.locator('#fields textarea').count()===6,'six independent recognition answers');await answer();
  await page.click('#show');await page.waitForSelector('body.exposing');await page.keyboard.press('Space');
  await page.waitForSelector('#answers:not([hidden])');check(await page.locator('#fields textarea').count()===1,'UI early response opens one raw answer');await answer();
  await page.click('#show');await page.waitForSelector('#answers:not([hidden])',{timeout:8000});await answer();
  await page.click('#show');await page.waitForSelector('body.exposing');await page.setViewportSize({width:1800,height:1000});
  await page.waitForSelector('#answers:not([hidden])');check((await page.locator('#exposure').textContent()).includes('无效'),'resize invalidates an exposed trial');await answer();
  check(await page.locator('#show').isDisabled(),'3x requires the complete display area');
  await page.setViewportSize({width:1920,height:1080});await page.click('#show');await page.waitForSelector('body.exposing');
  check(await page.locator('#frame').evaluate(n=>n.getBoundingClientRect().width===1920&&n.getBoundingClientRect().height===1080),'exact 3x without clipping or fractional scaling');
  await page.waitForSelector('#answers:not([hidden])');await answer();
  const jsonDownload=page.waitForEvent('download');await page.click('#download');const rawPath=path.join(fixtures,'SYNTHETIC-NOT-HUMAN.json');const jd=await jsonDownload;
  try{await jd.saveAs(rawPath)}catch(error){downloadFailures.push({format:'json',failure:await jd.failure()||error.message})}
  const rawText=await page.locator('#raw-data').inputValue();
  check(await page.locator('#raw-export').isVisible()&&JSON.parse(rawText).records.length===6,'raw JSON remains copyable even if browser cancels download');
  fs.writeFileSync(rawPath,rawText); // Retain the actual DOM export as a clearly synthetic test fixture.
  const raw=JSON.parse(fs.readFileSync(rawPath,'utf8'));
  check(raw.participant==='TEST_AUTOMATION_NOT_HUMAN'&&!('human_results' in raw),'automation is not asserted to be actual human evidence');
  check(raw.records[0].missing===true,'missing trials retained');
  check(raw.records[1].exposure_ms>=1900&&raw.records[1].exposure_ms<=2100&&raw.records[1].timing_valid,'two-second exposure is measured and masked');
  check(raw.records[2].within_five_seconds&&raw.records[2].response_signal_ms<=5000,'UI response signal retains elapsed time');
  check(raw.records[3].response_signal_ms===null&&!raw.records[3].within_five_seconds,'timeout never fabricates a timely UI response');
  check(raw.records[4].invalid===true&&raw.records[4].stop_reason==='window-change','invalid raw record is preserved');
  const csvDownload=page.waitForEvent('download');await page.click('#csv');const csvPath=path.join(fixtures,'SYNTHETIC-NOT-HUMAN-unscored.csv');const cd=await csvDownload;
  try{await cd.saveAs(csvPath)}catch(error){downloadFailures.push({format:'csv',failure:await cd.failure()||error.message})}
  fs.writeFileSync(csvPath,await page.locator('#raw-data').inputValue());
  check(fs.readFileSync(csvPath,'utf8').includes('"correct"')&&fs.readFileSync(csvPath,'utf8').includes('Requires independent human scoring'),'CSV exports raw unscored answers');
  await page.screenshot({path:evidence+'/review-session-desktop.png'});
  await page.goto(url);await page.fill('#participant','TEST_MISSING_ASSET');await page.click('#begin');
  await page.evaluate(()=>{for(const c of Object.values(window.VD_REVIEW_DATA.frames))c.frames[0].file='DOES-NOT-EXIST.png'});
  await page.click('#show');await page.waitForFunction(()=>document.querySelector('#status').textContent.includes('未显示有效画面'));
  check(await page.locator('#answers').isHidden()&&!(await page.locator('body').getAttribute('class')||'').includes('exposing'),'missing assets cannot produce valid exposure');
  check(errors.length===0&&network.length===0,'no uncaught browser errors or remote requests');
 }finally{fs.writeFileSync(path.join(evidence,'review-session-browser-checks.json'),JSON.stringify({synthetic_automation_only:true,checks,errors,network,downloadFailures,export_limit:'Browser download result recorded separately; copyable raw text is the verified fallback.'},null,2));await browser.close()}
 console.log('REVIEW TOOL: '+checks.length+' checks; synthetic fixtures excluded from human evidence.');
})().catch(e=>{console.error(e);process.exitCode=1});
