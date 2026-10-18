"use strict";
(()=>{
const q=id=>document.getElementById(id),data=window.VD_WALLCLOCK;let pending=0,playing=false;
for(const [id,entry]of Object.entries(data)){const option=new Option(entry.label,id);q("build").add(option)}
q("build").value="release";
function current(){return data[q("build").value]}
function frames(){return current().records.filter(row=>row.segment===q("segment").value)}
function show(row){q("frame").src=current().folder+row.image;q("frame").alt="REAL："+q("segment").value+"，运行tick "+row.tick;q("status").textContent=`${q("segment").value} · tick ${row.tick} · ${(row.elapsed_usec/1000000).toFixed(3)} s`;q("metadata").textContent=JSON.stringify({context:current().context,frame:row},null,2)}
function prepare(){pending++;playing=false;q("play").disabled=false;const list=frames();if(list.length)show(list[0])}
function build(){q("segment").replaceChildren(...current().segments.map(s=>new Option(s.name,s.name)));prepare()}
q("build").onchange=build;q("segment").onchange=prepare;q("scale").onchange=()=>q("board").style.width=(640*Number(q("scale").value))+"px";
q("play").onclick=async()=>{if(playing)return;playing=true;q("play").disabled=true;const token=++pending,list=frames(),entry=current();try{await Promise.all(list.map(row=>{const im=new Image();im.src=entry.folder+row.image;return im.decode()}));if(token!==pending)return;const start=performance.now(),origin=list[0].elapsed_usec;function step(){if(token!==pending)return;const elapsed=(performance.now()-start)*1000;let index=0;while(index+1<list.length&&list[index+1].elapsed_usec-origin<=elapsed)index++;show(list[index]);if(index+1<list.length)requestAnimationFrame(step);else{playing=false;q("play").disabled=false;q("status").textContent+=" · 结束"}}step()}catch{playing=false;q("play").disabled=false;q("status").textContent="本地帧缺失；不能计为验证通过。"}};
build();
})();
