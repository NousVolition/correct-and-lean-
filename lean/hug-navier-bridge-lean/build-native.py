import os,subprocess,sys,time
from pathlib import Path
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
root=Path(__file__).resolve().parent.parent
pkg=root/'hug-navier-bridge-lean'
lib=pkg/'.lake/build/lib/lean';lib.mkdir(parents=True,exist_ok=True)
deps=root/'work/NavierStokesAndEuler-audit/.lake/packages'
imports=[lib,root/'hug-existence-lean/.lake/build/lib/lean']
imports.extend(p/'.lake/build/lib/lean' for p in deps.iterdir() if (p/'.lake/build/lib/lean').is_dir())
env=os.environ.copy();env['LEAN_PATH']=';'.join(map(str,imports));env['LEAN_NUM_THREADS']='4'
lean=root/'work/toolchains/lean-4.34.0-rc2-windows/bin/lean.exe'
label=sys.argv[1]
log=pkg/f'native-{label}.log'
if log.exists():raise FileExistsError(log)
with log.open('w',encoding='utf-8') as handle:
 for name in (sys.argv[2:] or ('BridgeModel','BridgeSolution')):
  print('Checking '+name,flush=True)
  started=time.monotonic()
  result=subprocess.run([str(lean),'-o',str(lib/(name+'.olean')),name+'.lean'],cwd=pkg,env=env,
      stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,encoding='utf-8',errors='replace',timeout=120)
  handle.write(result.stdout);handle.flush()
  print(result.stdout,flush=True)
  print(f'{name}: exit={result.returncode}, elapsed={time.monotonic()-started:.1f}s',flush=True)
  if result.returncode:
   (pkg/f'native-{label}.exit').write_text(str(result.returncode)+'\n')
   sys.exit(result.returncode)
(pkg/f'native-{label}.exit').write_text('0\n')
