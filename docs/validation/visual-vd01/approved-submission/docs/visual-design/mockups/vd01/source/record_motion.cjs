// Local offline canvas recordings of authored mockups. No Godot process or web server.
const {chromium}=require('C:/Users/kahhe/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('fs'),path=require('path'),{pathToFileURL}=require('url');
// Minimal WebM mux: one VP8 track, millisecond timecodes, exact declared duration.
const hex=s=>Buffer.from(s,'hex');
function vint(n){for(let w=1;w<=8;w++){if(n<Math.pow(2,7*w)-1){const b=Buffer.alloc(w);let v=BigInt(n)|(1n<<BigInt(7*w));for(let i=w-1;i>=0;i--){b[i]=Number(v&255n);v>>=8n}return b}}throw Error('size')}
const el=(id,b)=>Buffer.concat([hex(id),vint(b.length),b]);
function uint(id,n){let a=[];do{a.unshift(n&255);n=Math.floor(n/256)}while(n);return el(id,Buffer.from(a))}
const str=(id,s)=>el(id,Buffer.from(s));
function webm(chunks,seconds){let dur=Buffer.alloc(8);dur.writeDoubleBE(seconds*1000);const head=el('1a45dfa3',Buffer.concat([uint('4286',1),uint('42f7',1),uint('42f2',4),uint('42f3',8),str('4282','webm'),uint('4287',4),uint('4285',2)]));const info=el('1549a966',Buffer.concat([uint('2ad7b1',1000000),str('4d80','VD-01 concept'),str('5741','VD-01 concept'),el('4489',dur)]));const track=el('1654ae6b',el('ae',Buffer.concat([uint('d7',1),uint('73c5',1),uint('83',1),str('86','V_VP8'),uint('23e383',33333333),el('e0',Buffer.concat([uint('b0',640),uint('ba',360)]))])));const blocks=chunks.map(c=>{const h=Buffer.alloc(4);h[0]=0x81;h.writeInt16BE(Math.round(c.timestamp/1000),1);h[3]=c.key?0x80:0;return el('a3',Buffer.concat([h,Buffer.from(c.data,'base64')]))});return Buffer.concat([head,el('18538067',Buffer.concat([info,track,el('1f43b675',Buffer.concat([uint('e7',0),...blocks]))]))])}
(async()=>{
 const root=path.resolve(__dirname,'..'),browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true,args:['--disable-background-timer-throttling','--disable-renderer-backgrounding']});
 const page=await browser.newPage({viewport:{width:900,height:600}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto(pathToFileURL(path.join(root,'motion-player.html')).href);await page.waitForFunction(()=>window.VDReady===true);
 const reports=[];
 for(const [mode,file,duration] of [['actors','actors-motion.webm',8],['effects','effects-motion.webm',4],['normal','combat-motion.webm',2],['dense','combat-dense.webm',2],['max-corruption','combat-max.webm',2],['normal-grayscale','combat-normal-grayscale.webm',2],['dense-grayscale','combat-dense-grayscale.webm',2],['max-corruption-grayscale','combat-max-grayscale.webm',2],['normal-unlit','combat-normal-unlit.webm',2],['dense-unlit','combat-dense-unlit.webm',2],['max-corruption-unlit','combat-max-unlit.webm',2],['directions','combat-directions.webm',2],['events','event-sampling.webm',3]]){
   const chunks=await page.evaluate(async([m,d])=>await window.encodeFrames(m,d),[mode,duration]);fs.writeFileSync(path.join(root,file),webm(chunks,duration));
   const meta=await page.evaluate(async f=>{const v=document.createElement('video');v.src=f;await new Promise((res,rej)=>{v.onloadedmetadata=res;v.onerror=rej});return {width:v.videoWidth,height:v.videoHeight,duration:v.duration===Infinity?'stream duration; sequential playback verified separately':v.duration}},file);
   reports.push({mode,file,requested_seconds:duration,encoded_frames:chunks.length,bytes:fs.statSync(path.join(root,file)).size,...meta});
 }
 await browser.close();if(errors.length)throw Error(errors.join('\n'));
 fs.writeFileSync(path.resolve(root,'../../../validation/visual-vd01/motion-recording.json'),JSON.stringify({method:'offline Chrome WebCodecs VP8 / exact timestamp WebM / original canvas mockups; not game capture',reports,errors},null,2));
 console.log(JSON.stringify(reports));
})().catch(e=>{console.error(e);process.exitCode=1});
