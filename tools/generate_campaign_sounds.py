#!/usr/bin/env python3
"""Original deterministic synth effects; no recordings, third-party samples or dependencies."""
import math, random, wave, struct, hashlib, json
from pathlib import Path
RATE=22050
ROOT=Path(__file__).resolve().parent.parent

def tone(t, frequency):
    return math.sin(2*math.pi*frequency*t)+0.18*math.sin(2*math.pi*frequency*2.01*t)

def render(name, duration):
    rng=random.Random(name)
    count=round(duration*RATE)
    values=[]; low=0.0
    for i in range(count):
        t=i/RATE; u=i/(count-1)
        noise=rng.uniform(-1,1); low=0.72*low+0.28*noise
        if name.startswith('slash'):
            step=int(name[-1]); centre=[0,.39,.3,.43][step]
            envelope=math.exp(-((u-centre)/.23)**2)*math.sin(math.pi*u)**.5
            v=envelope*((noise-low)*.8+tone(t,150+step*40)*.08)
        elif name in ['hit','heavy','hurt']:
            base={'hit':180,'heavy':95,'hurt':125}[name]
            v=(tone(t,base)*.55+tone(t,base*3.71)*.15+noise*.35)*math.exp(-u*7)
        elif name=='dash':
            v=(noise-low+tone(t,230+420*u)*.12)*math.sin(math.pi*u)*math.exp(-u*2)
        elif name in ['pickup','pay','chest','recruit','build','seal','victory']:
            notes={'pickup':[1046,1568],'pay':[880,660],'chest':[523,659,784,1046], 'recruit':[523,659,784], 'build':[262,392,523], 'seal':[392,523,784,1046], 'victory':[392,523,659,784,1046]}[name]
            note=min(len(notes)-1,int(u*len(notes)))
            local=(u*len(notes))%1
            v=tone(t,notes[note])*(1-math.exp(-local*30))*math.exp(-local*3)
            v+=tone(t,notes[0]/2)*.1*(1-u)
        else:
            base=110 if name=='night' else 146.83
            v=(tone(t,base)+tone(t,base*1.498)*.5)*math.sin(math.pi*u)*.5
        # Short edge fades prevent waveform discontinuities; bounded PCM prevents clipping.
        fade=min(1,t/.004,(duration-t)/.018)
        values.append(v*max(0,fade))
    peak=max(abs(x) for x in values)
    pcm=[round(x/peak*.30*32767) for x in values]
    pcm[0]=pcm[-1]=0
    return pcm

def main():
    target=ROOT/'art/audio/campaign-v001';target.mkdir(parents=True,exist_ok=True)
    durations={'slash1':.19,'slash2':.17,'slash3':.24,'hit':.13,'heavy':.21,'hurt':.20,'dash':.22,'pickup':.14,'pay':.13,'chest':.48,'recruit':.42,'build':.48,'night':.75,'seal':.60,'victory':.90,'defeat':.85}
    records={}
    for name,duration in durations.items():
        pcm=render(name,duration);path=target/(name+'.wav')
        with wave.open(str(path),'wb') as w:
            w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE)
            w.writeframes(struct.pack('<'+'h'*len(pcm),*pcm))
        records[path.name]={'seconds':len(pcm)/RATE,'peak':max(abs(x) for x in pcm)/32767,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
    (target/'provenance.json').write_text(json.dumps({'origin':'Original mathematical synthesis for Cyber Kingdom; no sampled recordings','generator':'tools/generate_campaign_sounds.py','sample_rate':RATE,'channels':1,'bits':16,'assets':records},indent=2)+'\n')
    print('Generated',len(records),'original PCM effects')
if __name__=='__main__':main()
