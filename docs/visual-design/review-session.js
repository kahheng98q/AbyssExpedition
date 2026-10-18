"use strict";
(()=>{
 const $=id=>document.getElementById(id),data=window.VD_REVIEW_DATA;
 const items=[['hero','描述主角的位置'],['thrall','描述 Saltbound Thrall 的外形与位置'],['brinejaw','描述 Skittering Brinejaw 的外形与位置'],['direction','剑击朝哪个方向？'],['friendly_magic','法术属于哪一方、哪个角色？'],['danger','危险区域在哪里、边界是什么形状？']];
 // Labels identify the questions, never the expected visual answer.
 const prompts={hp:'定位当前 HP 与最大 HP',levels:'区分永久角色等级与本局等级',focus:'指出当前获得焦点的升级选项'};
 let session=null,trials=[],at=0,images=[],loading=false,showing=false,started=0,timer=0,raf=0,current=null;
 function shuffle(values){for(let i=values.length-1;i>0;i--){const n=new Uint32Array(1);crypto.getRandomValues(n);const j=n[0]%(i+1);[values[i],values[j]]=[values[j],values[i]]}return values}
 function sizeFor(t){return [640*t.scale,360*t.scale]}
 function fits(t){const [w,h]=sizeFor(t);return innerWidth>=w&&innerHeight>=h&&Math.abs(devicePixelRatio-1)<.001}
 function ready(){
  $('answers').hidden=true;$('trial').hidden=at>=trials.length;$('done').hidden=at<trials.length;
  $('download').disabled=false;$('csv').disabled=false;
  if(at>=trials.length){session.finished_at=new Date().toISOString();$('status').textContent='原始答案待独立评分；缺测和无效轮次仍保留。';return}
  const t=trials[at],s=sizeFor(t);$('progress').textContent=`${at+1} / ${trials.length} · ${s[0]} × ${s[1]}`;
  $('prompt').textContent=t.kind==='recognition'?'辨识画面':prompts[t.task];
  $('instruction').textContent=t.kind==='recognition'?'观看 2 秒，然后回答六个问题。':'找到答案后，在 5 秒内按空格；画面隐藏后填写答案。';
  $('fit').textContent=fits(t)?'可完整显示。':'当前屏幕或系统缩放不适合本轮。请全屏、使用 100% 系统缩放，或记录缺测；不要缩小图片。';
  $('show').disabled=!fits(t);$('show').textContent='显示画面';$('status').textContent='尚未显示测试画面。';
 }
 function fields(){
  $('fields').replaceChildren();const list=trials[at].kind==='recognition'?items:[['answer','你的答案']];
  for(const [id,title] of list){const label=document.createElement('label');label.htmlFor='answer-'+id;label.textContent=title;const input=document.createElement('textarea');input.id='answer-'+id;input.name=id;input.required=true;label.append(input);$('fields').append(label)}
 }
 function stop(reason){
  if(!showing)return;const elapsed=performance.now()-started;showing=false;clearTimeout(timer);cancelAnimationFrame(raf);document.body.classList.remove('exposing');
  current.exposure_ms=elapsed;current.stop_reason=reason;current.invalid=reason==='visibility-change'||reason==='window-change';
  current.response_signal_ms=trials[at].kind==='ui'&&reason==='response'?elapsed:null;
  current.within_five_seconds=current.response_signal_ms!==null&&elapsed<=5000;
  current.timing_valid=!current.invalid&&elapsed<=(trials[at].kind==='ui'?5100:2100);
  $('trial').hidden=true;$('answers').hidden=false;fields();
  $('exposure').textContent=`曝光 ${(elapsed/1000).toFixed(2)} 秒 · ${current.invalid?'本轮无效，仍保留记录':current.timing_valid?'计时记录有效':'计时超限，需复核'}。`;
  document.querySelector('#fields textarea').focus();
 }
 async function show(){
  if(loading||showing||!fits(trials[at]))return;loading=true;$('show').disabled=true;$('show').textContent='正在准备本地画面…';const t=trials[at];
  try{
   const files=t.kind==='recognition'?data.frames[t.condition].frames.map(r=>r.file):[data.ui[t.task].file];
   images=await Promise.all(files.map(async file=>{const im=new Image();im.src=data.folder+file;await im.decode();if(im.naturalWidth!==640||im.naturalHeight!==360)throw Error('Unexpected native dimensions');return im}));
   if(!fits(t))throw Error('Window no longer fits');
   current={...t,started_at:new Date().toISOString(),requested_size:sizeFor(t),viewport:[innerWidth,innerHeight],device_pixel_ratio:devicePixelRatio,
    material_sha256:t.kind==='recognition'?data.frames[t.condition].sha256:data.ui[t.task].sha256};
   $('frame').style.width=640*t.scale+'px';$('frame').style.height=360*t.scale+'px';$('frame').src=images[0].src;
   document.body.classList.add('exposing');showing=true;started=performance.now();
   timer=setTimeout(()=>stop('timeout'),t.kind==='recognition'?2000:5000);
   function draw(){if(!showing)return;const index=Math.min(images.length-1,Math.floor((performance.now()-started)*30/1000));$('frame').src=images[index].src;raf=requestAnimationFrame(draw)}draw();
  }catch(error){$('status').textContent='未显示有效画面：'+error.message;$('show').disabled=!fits(t);$('show').textContent='重新准备'}finally{loading=false}
 }
 $('fullscreen').onclick=async()=>{try{await document.documentElement.requestFullscreen()}catch{$('status').textContent='全屏不可用，可使用浏览器全屏功能。'}};
 $('begin').onclick=()=>{const participant=$('participant').value.trim();if(!participant){$('participant').focus();return}
  trials=shuffle([2,3].flatMap(scale=>[...['normal','dense','max-corruption'].map(condition=>({kind:'recognition',condition,scale})),...Object.keys(prompts).map(task=>({kind:'ui',task,scale}))]));
  session={schema:'VD01-human-review-1',participant,created_at:new Date().toISOString(),candidate_sha256:data.candidate_sha256,
   material_sha256:data.material_sha256,protocol_sha256:data.protocol_sha256,order:trials,records:[],origin:'Unverified browser responses; reviewer must confirm actual participant identity and conduct.',
   timing_limit:'Browser exposure and response signal only; not physical display latency.'};
  $('setup').hidden=true;ready();};
 $('show').onclick=show;
 $('missing').onclick=()=>{session.records.push({...trials[at],missing:true,reason:'screen/equipment/participant unavailable',answers:{}});at++;ready()};
 $('answers').onsubmit=event=>{event.preventDefault();current.answers=Object.fromEntries(new FormData($('answers')).entries());current.recorded_at=new Date().toISOString();session.records.push(current);at++;ready()};
 document.addEventListener('keydown',event=>{if(showing&&event.code==='Space'){event.preventDefault();if(trials[at].kind==='ui')stop('response')}});
 document.addEventListener('visibilitychange',()=>{if(document.hidden)stop('visibility-change')});
 window.addEventListener('resize',()=>{if(showing)stop('window-change');else if(session&&at<trials.length&&!loading&&$('answers').hidden)ready()});
 function download(text,type,name){$('raw-export').hidden=false;$('raw-data').value=text;const url=URL.createObjectURL(new Blob([text],{type}));const a=document.createElement('a');a.href=url;a.download=name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),30000)}
 $('copy').onclick=async()=>{const field=$('raw-data');field.focus();field.select();try{await navigator.clipboard.writeText(field.value);$('status').textContent='已复制原始记录。'}catch{$('status').textContent='原始记录已选中，请按 Ctrl+C 复制。'}};
 $('download').onclick=()=>download(JSON.stringify(session,null,2),'application/json','visual-review-'+session.participant.replace(/[^a-z0-9_-]/gi,'_')+'.json');
 $('csv').onclick=()=>{const quote=v=>'"'+String(v??'').replaceAll('"','""')+'"';const rows=[['participant','kind','condition_or_task','size','item','response','response_signal_ms','correct','valid','clip_sha256','notes']];
  for(const r of session.records)for(const [item,response] of Object.entries(r.answers||{}))rows.push([session.participant,r.kind,r.condition||r.task,sizeFor(r).join('x'),item,response,r.response_signal_ms,'',!r.invalid&&r.timing_valid&&(r.kind!=='ui'||r.within_five_seconds),r.material_sha256,'Requires independent human scoring']);
  download('\ufeff'+rows.map(row=>row.map(quote).join(',')).join('\r\n'),'text/csv;charset=utf-8','visual-review-unscored.csv');};
})();
