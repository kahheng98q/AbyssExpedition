const {chromium}=require('C:/Users/kahhe/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('fs'),path=require('path');
const evidence=process.argv[2]||(fs.existsSync('docs/validation/visual-vd01/completion-r2/candidate-files.json')?'docs/validation/visual-vd01/completion-r2':fs.existsSync('docs/validation/visual-vd01/completion-r1/candidate-files.json')?'docs/validation/visual-vd01/completion-r1':'docs/validation/visual-vd01');
(async()=>{
 const browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
 const page=await browser.newPage({viewport:{width:1440,height:1000}});const errors=[],network=[],checks=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url())});
 const check=(ok,name)=>{checks.push({name,pass:!!ok});if(!ok)throw Error(name)};
 try{
  const base='file:///'+process.cwd().replaceAll('\\','/')+'/docs/visual-design/';
  await page.goto(base+'runtime-gallery.html');await page.waitForFunction(()=>document.querySelector('#after').complete&&document.querySelector('#after').naturalWidth===640);
  for(const scene of ['combat-c100','combat-c0','rescue-succeeded','rescue-failed','rescue-declined','level-up'])for(const size of ['1280','1920','1371']){
   await page.selectOption('#scene',scene);await page.selectOption('#size',size);
   await page.waitForFunction(()=>['before','after'].every(id=>{const i=document.getElementById(id);return i.complete&&i.naturalWidth===640}));check(true,scene+'/'+size+' local pair');
  }
  await page.click('#gray');check(await page.locator('#pair').evaluate(n=>n.classList.contains('gray')),'gray comparison');
  for(const condition of ['normal','dense','max-corruption','motion']){
   await page.selectOption('#condition',condition);await page.click('#play');await page.waitForFunction(()=>document.querySelector('#frame-status').textContent.startsWith('两秒结束'));
   check(await page.locator('#frame').evaluate(n=>n.naturalWidth===640&&n.style.visibility==='hidden'),condition+' real60 frames / neutral mask');
  }
  for(const scale of ['1','2','3']){await page.selectOption('#scale',scale);const width=await page.locator('#frame').evaluate(n=>n.getBoundingClientRect().width);check(width===640*Number(scale),'integer image width '+scale)}
  await page.screenshot({path:evidence+'/offline-gallery-desktop.png',fullPage:true});
  await page.setViewportSize({width:390,height:844});await page.screenshot({path:evidence+'/offline-gallery-mobile.png',fullPage:true});
  check(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth),'mobile page has no outer overflow; native boards scroll locally');
  await page.goto(base+'preview.html');await page.evaluate(()=>[...document.images].forEach(i=>i.loading='eager'));await page.waitForFunction(()=>[...document.images].every(i=>i.complete&&i.naturalWidth>0));check(true,'concept + REAL preview all images local');
  check(errors.length===0,'no browser errors');check(network.length===0,'zero network requests');
 }finally{
  fs.writeFileSync(evidence+'/offline-browser-checks.json',JSON.stringify({url_kind:'file://',checks,errors,network},null,2));await browser.close();
 }
 console.log('OFFLINE BROWSER: '+checks.length+' checks passed; zero network.');
})().catch(e=>{console.error(e);process.exitCode=1});
