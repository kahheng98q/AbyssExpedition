"""Freeze real controlled frame sequences and an offline, one-shot human test page."""
import argparse
import hashlib
import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--capture', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--build-manifest', type=Path, required=True)
    args = parser.parse_args()
    source = args.capture.resolve()
    target = args.output.resolve()
    if target.exists():
        parser.error('output exists; preserve prior evidence')
    data = json.loads((source / 'source.json').read_text(encoding='utf-8'))
    identity = json.loads(args.build_manifest.read_text(encoding='utf-8-sig'))
    assert all(sha(ROOT / row['path']) == row['sha256'] for row in identity['source_files'])
    assert sha(ROOT / 'tools/godot-4.5/Godot_v4.5-stable_win64_console.exe') == identity['engine_sha256']
    assert not data['failures'] and len(data['dense']) == 10
    branches = [clip for clip in data['clips'] if clip['profession'] != 'swordsman']
    assert len(branches) == 12
    assert len({(tuple(c['window']), c['profession'], c['attack']) for c in branches}) == 12
    hashes = {}
    for clip in data['clips']:
        assert len(clip['frames']) == 60 and clip['duration_seconds'] == 1
        assert [f['tick'] for f in clip['frames']] == list(range(clip['frames'][0]['tick'], clip['frames'][0]['tick'] + 60))
        for frame in clip['frames']:
            for kind in ('raw', 'clean', 'gray'):
                hashes[frame[kind]] = sha(source / frame[kind])
    for item in data['dense']:
        hashes[item['file']] = sha(source / item['file'])
    target.mkdir(parents=True)
    # Paths are public; answers and scoring keys are only in the separate private manifest.
    import os
    prefix = Path(os.path.relpath(source, target)).as_posix()
    public = {'clips': {c['id']: [prefix + '/' + f['gray'] for f in c['frames']] for c in branches},
              'dense': {c['id']: prefix + '/' + c['file'] for c in data['dense']}, 'orders': {}}
    for index in range(1, 6):
        rng = random.Random(20261021 + index)
        clips = list(public['clips'])
        dense = list(public['dense'])
        rng.shuffle(clips)
        rng.shuffle(dense)
        public['orders'][f'P{index:02}'] = {'clips': clips, 'dense': dense}
    manifest = {'format': 'sword-human-stimuli-v1', 'source_directory': prefix,
                'engine': identity['engine'], 'engine_sha256': identity['engine_sha256'],
                'build_hash': identity['build_hash'], 'source_files': identity['source_files'],
                'fixture_sha256': sha(ROOT / 'tests/sword_identity_stimuli.gd'),
                'source_manifest_sha256': sha(source / 'source.json'), 'files_sha256': hashes,
                'clips': data['clips'], 'dense': data['dense'], 'orders': public['orders'],
                'treatment': data['treatment'], 'human_responses_generated': 0,
                'scoring': {'gray': 'At least 4/5 each >=10/12 AND ordinary>=5/6 AND fifth>=5/6; first answer only, uncertain wrong.',
                            'dense': 'Same five players; at least4/5 each>=8/10 BOTH hero and nearest warning; accept documented ties.',
                            'understanding': 'Same hero15/no companions/seed, previews then anonymous clean clips and both3-active-minute branches; record real verbatim answers separately.'}}
    (target / 'stimuli.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
    page = PAGE.replace('PUBLIC_DATA', json.dumps(public, ensure_ascii=False))
    (target / 'readability.html').write_text(page, encoding='utf-8')
    (target / 'README.md').write_text('''# 真人材料（未验收）

离线打开[首答页面](readability.html)，每人选择自己的P01–P05。只显示一次1秒，不提示、不重播；失焦／丢帧标记无效，不补挑成功回答。页面不读取答案清单。每人完成后下载其原答JSON，操作者另核验身份、观看条件与原始失败。

[私有刺激清单](stimuli.json)含hash、原图、灰度规则、标准答案与固定随机序；勿给参与者查看。色彩无名片段是每条clean-00…59帧序列，以60fps播放1秒；灰度用同序列gray帧。全屏原图保留，裁切和统一隐藏CombatFeedback文字／粒子均已披露，不生成假图。SC001先看真实转职演示，再看无名片段、各分支3主动分钟，独立记录原话／偏好／死亡／疲劳／重试意愿。当前没有玩家答案，材料存在不代表SC001／003通过。
''', encoding='utf-8')
    print(f'STIMULI frozen: {len(data["clips"])} color sequences;12 gray;10 dense;{len(hashes)} hashes;0 human answers')


PAGE = r'''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>剑系辨识 · 首答</title>
<style>body{margin:24px auto;max-width:820px;background:#0b141c;color:#d4e5e6;font:16px system-ui}button,select{font:inherit;padding:9px;background:#19303a;color:inherit;border:1px solid #6f9198;margin:5px}canvas{width:640px;max-width:100%;height:auto;background:#070c10;image-rendering:pixelated;border:1px solid #44606b}p{line-height:1.6}</style>
<h1>剑系辨识 · 首答</h1><p>先由操作者说明流程。同组五名真实玩家；每题仅看一次1秒，结束后作答。不确定可直接选择。页面不提供反馈或答案。</p>
<select id="person"><option>P01</option><option>P02</option><option>P03</option><option>P04</option><option>P05</option></select><button id="begin">开始</button><p id="status">尚未开始</p><canvas id="screen" width="640" height="360" aria-label="一秒辨识画面与密集图回答坐标"></canvas><div id="actions"></div><button id="save" hidden>下载原答</button>
<script>const data=PUBLIC_DATA;
const canvas=document.querySelector('#screen'),ctx=canvas.getContext('2d'),status=document.querySelector('#status'),actions=document.querySelector('#actions');let participant,index=0,phase='clips',answers=[],failures=[],active=false,hero=null,warnings=[],invalid=false;
function clear(){ctx.fillStyle='#070c10';ctx.fillRect(0,0,640,360)}
function button(label,callback){let b=document.createElement('button');b.textContent=label;b.onclick=callback;actions.append(b)}
async function image(src){return await new Promise((resolve,reject)=>{let im=new Image;im.onload=()=>resolve(im);im.onerror=reject;im.src=src})}
document.querySelector('#begin').onclick=()=>{participant=document.querySelector('#person').value;document.querySelector('#save').hidden=false;document.querySelector('#begin').disabled=true;document.querySelector('#person').disabled=true;next()};
document.addEventListener('visibilitychange',()=>{if(active&&document.hidden)invalid=true});window.addEventListener('blur',()=>{if(active)invalid=true});
async function next(){actions.innerHTML='';hero=null;warnings=[];invalid=false;let ids=data.orders[participant][phase];if(index>=ids.length){if(phase==='clips'){phase='dense';index=0;next();return}status.textContent='已结束。请下载原答交给操作者。';document.querySelector('#save').hidden=false;return}
 let id=ids[index];status.textContent=`${phase==='clips'?'灰度':'密集'} ${index+1}/${ids.length} · 加载中`;
 try{let frames=await Promise.all((phase==='clips'?data.clips[id]:[data.dense[id]]).map(image));status.textContent='观察 · 1秒';active=true;let start=null,last=null,maxGap=0;await new Promise(resolve=>{function draw(now){if(start===null)start=now;if(last!==null)maxGap=Math.max(maxGap,now-last);last=now;let elapsed=now-start;if(elapsed>=1000){clear();resolve();return}clear();let im=frames[Math.min(frames.length-1,Math.floor(elapsed*frames.length/1000))];if(phase==='clips')ctx.drawImage(im,96,4,448,352);else ctx.drawImage(im,0,0,640,360);requestAnimationFrame(draw)}requestAnimationFrame(draw)});active=false;
 if(maxGap>100)invalid=true;status.textContent=phase==='clips'?'首次判断':'在空白框先点主角位置，再点最近敌方预警中心；不确定可选按钮';
 function answer(value){answers.push({phase,id,answer:value,invalid_presentation:invalid,max_frame_gap_ms:maxGap,answered_at:new Date().toISOString()});index++;canvas.onclick=null;next()}
 if(phase==='clips'){button('双刃',()=>answer('swordmaster'));button('长刃',()=>answer('abyss_swordsman'));button('不确定',()=>answer('uncertain'))}
 else{canvas.onclick=e=>{let r=canvas.getBoundingClientRect(),point=[(e.clientX-r.left)*640/r.width,(e.clientY-r.top)*360/r.height];if(hero===null){hero=point;status.textContent='再点最近敌方预警中心'}else answer({hero,nearest_warning:point})};button('不确定',()=>answer('uncertain'))}
 }catch(error){active=false;failures.push({phase,id,error:String(error)});status.textContent='素材加载失败；停止并保留失败。'+error}}
document.querySelector('#save').onclick=()=>{let a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify({participant,protocol:'one-shot-1s-v1',answers,failures,completed:phase==='dense'&&index===10,human_identity_verified_by_operator:false},null,2)],{type:'application/json'}));a.download=participant+'-answers.json';a.click();URL.revokeObjectURL(a.href)};
</script></html>'''


if __name__ == '__main__':
    main()
