"""Load the verified public tables for figure reproduction."""
import sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from verify import load_pairs,read_csv as rows
def load_gaps(tag,name='gaps_grid192_ds1024.csv'):
    filename='gaps-finer-trace.csv' if '256' in name else 'gaps-primary.csv'
    p=ROOT/'runs'/tag/filename;values=load_pairs(p)
    times=sorted({float(r['time']) for r in rows(p) if r['convention']=='fixed'})
    data=np.asarray([[values[i,s] for s in range(25)] for i in range(51)])
    return np.asarray(times),data
