const {chromium}=require('C:/Users/kahhe/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('fs');
const latest=fs.existsSync('docs/validation/visual-vd01/completion-r2/candidate-files.json');
const current=fs.existsSync('docs/validation/visual-vd01/completion-r1/candidate-files.json');
const evidence=process.argv[3]||(latest?'docs/validation/visual-vd01/completion-r2':current?'docs/validation/visual-vd01/completion-r1':'docs/validation/visual-vd01'),captureFolder=process.argv[2]||(latest?'completion-r2/cache-release':current?'completion-r1/release-r2':'after/release-r3');
(async()=>{
 const browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
 const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[],network=[],checks=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url())});
 const check=(value,name)=>{checks.push({name,pass:!!value});if(!value)throw Error(name)};
 try{
  await page.goto('file:///'+process.cwd().replaceAll('\\','/')+'/docs/game-development-dashboard.html');
  await page.evaluate(()=>document.querySelectorAll('img').forEach(i=>i.loading='eager'));
  await page.waitForFunction(()=>[...document.images].every(i=>i.complete&&i.naturalWidth>0));check(true,'all actual local dashboard images load');
  check(await page.locator('.hero img').evaluate((i,folder)=>i.naturalWidth===640&&i.src.includes(folder),captureFolder),'current corrected candidate in hero preview');
  await page.screenshot({path:evidence+'/dashboard-desktop.png',fullPage:false});
  await page.setViewportSize({width:390,height:844});
  await page.screenshot({path:evidence+'/dashboard-mobile.png',fullPage:false});
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'mobile outer layout stays within viewport');
  check(errors.length===0&&network.length===0,'no browser errors or network requests');
 }finally{fs.writeFileSync(evidence+'/dashboard-browser-checks.json',JSON.stringify({checks,errors,network},null,2));await browser.close()}
 console.log('OFFLINE DASHBOARD: '+checks.length+' checks passed.');
})().catch(e=>{console.error(e);process.exitCode=1});
