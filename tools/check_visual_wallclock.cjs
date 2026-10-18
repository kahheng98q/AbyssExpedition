const {chromium}=require('C:/Users/kahhe/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('fs');
(async()=>{
 const evidence=process.argv[2]||(fs.existsSync('docs/validation/visual-vd01/completion-r2/wallclock-summary.json')?'docs/validation/visual-vd01/completion-r2':'docs/validation/visual-vd01/completion-r1'),checks=[],errors=[],network=[];
 const browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
 const page=await browser.newPage({viewport:{width:1440,height:1000}});
 page.on('pageerror',e=>errors.push(e.message));page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url())});
 const check=(ok,name)=>{checks.push({name,pass:!!ok});if(!ok)throw Error(name)};
 try{
  await page.goto('file:///'+process.cwd().replaceAll('\\','/')+'/docs/visual-design/wallclock-gallery.html');
  for(const build of ['release','source','before']){
   await page.selectOption('#build',build);await page.selectOption('#segment','move-right');
   await page.waitForFunction(()=>document.querySelector('#frame').complete&&document.querySelector('#frame').naturalWidth===640);
   check(true,build+' native frames load locally');
   await page.selectOption('#segment','manual-pause');await page.click('#play');
   await page.waitForFunction(()=>document.querySelector('#status').textContent.endsWith('结束'));
   check(await page.evaluate(()=>{const e=window.VD_WALLCLOCK[document.querySelector('#build').value];return new Set(e.records.filter(r=>r.segment==='manual-pause').map(r=>r.tick)).size===1}),build+' real recorded pause has frozen tick');
  }
  await page.selectOption('#build','source');
  check(await page.locator('#segment option[value="source-debug-2x"]').count()===1,'source-only existing debug speed segment');
  await page.selectOption('#build','release');
  check(await page.locator('#segment option[value="source-debug-2x"]').count()===0,'release has no debug speed segment');
  for(const scale of ['1','2','3']){await page.selectOption('#scale',scale);check(await page.locator('#frame').evaluate(n=>n.getBoundingClientRect().width)===640*Number(scale),'integer scale '+scale)}
  await page.screenshot({path:evidence+'/wallclock-desktop.png',fullPage:false});
  await page.setViewportSize({width:390,height:844});
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'mobile board scrolls within its own container');
  await page.screenshot({path:evidence+'/wallclock-mobile.png',fullPage:false});
  check(errors.length===0&&network.length===0,'no browser errors or network requests');
 }finally{fs.writeFileSync(evidence+'/wallclock-browser-checks.json',JSON.stringify({checks,errors,network},null,2));await browser.close()}
 console.log('OFFLINE WALLCLOCK: '+checks.length+' checks passed.');
})().catch(e=>{console.error(e);process.exitCode=1});
