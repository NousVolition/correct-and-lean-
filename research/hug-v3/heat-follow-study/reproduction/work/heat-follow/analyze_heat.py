"""Recount saved heat arrays and compare the two actual time steps."""
import csv,hashlib,json
from pathlib import Path
import numpy as np
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1];OUT=ROOT/'outputs/heat-follow'
TAGS=['n16_dt0p002','n16_dt0p001'];NAMES=['initial_warmth','net_viscous_heat','structural_release','write_0','write_1','write_2']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def rows(p):
    with p.open(newline='',encoding='utf-8') as f:return list(csv.DictReader(f))
def number(r,k):return float(r[k])
def dump(p,x):p.write_text(json.dumps(x,indent=2,allow_nan=False)+'\n',encoding='utf-8')
def key(r):return (round(float(r['time']),10),r['side'])
def main():
    allrows=[];arrays=[];summaries=[];verification=[]
    for tag in TAGS:
        folder=OUT/tag;receipt=load(folder/'receipt.json');assert receipt['status']=='completed' and receipt['source_unchanged']
        for p,digest in receipt['files_sha256'].items():assert sha(folder/p)==digest
        rr=rows(folder/'history.csv');index={key(r):r for r in rr};assert len(index)==len(rr)
        z=np.load(folder/'fields.npz',allow_pickle=False);q=z['components'];g=z['native_g'];names=z['component_names'].tolist();assert names==NAMES
        assert q.shape==g.shape[:-1]+(6,) and len(rr)==round(1.6/receipt['actual_step'])+4
        defect=float(abs(q.sum(axis=-1)-g[...,4]).max());assert defect<1e-12
        snapshot_errors=[];negative_errors=[];squares=[];outside_errors=[]
        for j,(t,side) in enumerate(zip(z['time'],z['side'])):
            row=index[(round(float(t),10),str(side))]
            assert abs(float(g[j,...,4].mean())-number(row,'thermal_mean'))<1e-17
            for i,name in enumerate(names):
                f=q[j,...,i];mean=float(f.mean());neg=float(-f[f<0].sum()/f.size)
                snapshot_errors.append(abs(mean-number(row,name+'_mean')))
                negative_errors.append(abs(neg-number(row,name+'_negative_integral')))
                square=float(np.einsum('ijk,ijk->',f,f)/f.size);volume=mean*mean/square if square else 0.
                squares.append(abs(volume-number(row,name+'_effective_volume')))
                if i>=3:
                    x=np.arange(receipt['grid'])/receipt['grid']-.5;xyz=np.stack(np.meshgrid(x,x,x,indexing='ij'),-1)
                    dist=np.sqrt(np.sum(((xyz-z['birth_centers'][i-3]+.5)%1-.5)**2,axis=-1))
                    outside=float(f[dist>.25].sum()/f.size);outside_errors.append(abs(outside-number(row,name+'_outside025_integral')))
        assert max(snapshot_errors)<1e-17 and max(negative_errors)<1e-17 and max(squares)<1e-12 and max(outside_errors)<1e-17
        budgets=[];component_sums=[];tag_errors=[]
        initial=float(rr[0]['thermal_mean'])
        for row in rr:
            thermal=number(row,'thermal_mean');means=[number(row,n+'_mean') for n in names]
            budgets.append(abs(thermal-initial-number(row,'continuous_ledger')-number(row,'write_total')))
            component_sums.append(abs(thermal-sum(means)))
            for n in names:tag_errors.append(abs(number(row,n+'_mean')-number(row,n+'_expected_mean')))
        assert max(budgets)<1e-12 and max(component_sums)<1e-12 and max(tag_errors)<1e-14
        final=rr[-1];assert key(final)==(1.6,'at');writedata=[]
        for i,t in enumerate([.4,.8,1.2]):
            n='write_'+str(i);birth=index[(t,'after_write')];before=index[(t,'before_write')]
            assert number(before,n+'_mean')==0 and number(birth,n+'_mean')>0
            active=[r for r in rr if number(r,n+'_expected_mean')>0]
            h=number(birth,n+'_expected_mean');other_before=sum(number(before,'write_'+str(k)+'_mean') for k in range(i))
            writedata.append({'event_id':i,'write_time':t,'deposited_heat':h,'earlier_write_heat_at_this_write':other_before,'final_integral':number(final,n+'_mean'),'maximum_integral_drift':max(abs(number(r,n+'_mean')-h) for r in active),'birth_effective_volume':number(birth,n+'_effective_volume'),'final_effective_volume':number(final,n+'_effective_volume'),'birth_peak':number(birth,n+'_peak'),'final_peak':number(final,n+'_peak'),'birth_outside025_share':number(birth,n+'_outside025_share'),'final_outside025_share':number(final,n+'_outside025_share'),'birth_negative_to_net_ratio':number(birth,n+'_negative_integral')/h,'maximum_negative_to_net_ratio':max(number(r,n+'_negative_integral')/h for r in active),'final_negative_to_net_ratio':number(final,n+'_negative_integral')/h,'birth_centroid':[number(birth,n+'_centroid_'+c) for c in ['x','y','z']],'final_centroid':[number(final,n+'_centroid_'+c) for c in ['x','y','z']],'effective_volume_increases':number(final,n+'_effective_volume')>number(birth,n+'_effective_volume'),'peak_decreases':number(final,n+'_peak')<number(birth,n+'_peak')})
        final_parts={n:number(final,n+'_mean') for n in names};total=number(final,'thermal_mean');write_total=sum(final_parts[n] for n in names[3:])
        summary={'run':tag,'grid':16,'dt':receipt['actual_step'],'rows':len(rr),'snapshots':len(q),'writes':writedata,'final_temperature_mean_excess':total,'initial_temperature_mean_excess':initial,'final_components':final_parts,'final_write_share_of_excess':write_total/total,'final_write_total':write_total,'total_increase_from_initial':total-initial,'write_share_of_thermal_increase':write_total/(total-initial),'minimum_absolute_temperature':min(number(r,'temperature_min') for r in rr),'minimum_unfiltered_net_viscous':receipt['minimum_unfiltered_net_viscous'],'maximum_extraction_fraction_of_viscous_heating':receipt['maximum_extraction_fraction_of_viscous_heating'],'baseline_checkpoints':len(receipt['baseline_checks']),'baseline_max_array_error':max((v['maximum_array_error'] for v in receipt['baseline_checks']),default=None)}
        verification.append({'run':tag,'saved_grid_values_recounted':int(q.size+g.size),'snapshot_integral_max_difference':max(snapshot_errors),'negative_integral_max_difference':max(negative_errors),'effective_volume_max_difference':max(squares),'outside_sphere_integral_max_difference':max(outside_errors),'full_snapshot_reconstruction_max':defect,'dense_global_budget_max_residual':max(budgets),'dense_component_sum_max_residual':max(component_sums),'dense_tag_integral_max_residual':max(tag_errors),'source_receipt_sha256':sha(folder/'receipt.json')})
        allrows.append(rr);arrays.append({k:z[k].copy() for k in z.files});summaries.append(summary);z.close()
    coarse,fine=arrays;assert np.array_equal(coarse['time'],fine['time']) and np.array_equal(coarse['side'],fine['side'])
    comparisons=[]
    for i in range(3):
        idx=3+i;h0=summaries[0]['writes'][i]['deposited_heat'];h1=summaries[1]['writes'][i]['deposited_heat']
        active=np.array([t>[.4,.8,1.2][i] or (t==[.4,.8,1.2][i] and side=='after_write') for t,side in zip(coarse['time'],coarse['side'])])
        c=coarse['components'][active,...,idx]/h0;f=fine['components'][active,...,idx]/h1
        l1=np.mean(abs(c-f),axis=(1,2,3));shares=[abs(summaries[0]['writes'][i][p]-summaries[1]['writes'][i][p]) for p in ['birth_outside025_share','final_outside025_share']]
        own_masks=[]
        for j in range(2):
            x=np.arange(16)/16-.5;xyz=np.stack(np.meshgrid(x,x,x,indexing='ij'),-1);own_masks.append(np.linalg.norm((xyz-arrays[j]['birth_centers'][i]+.5)%1-.5,axis=-1)>.25)
        shape_shares=np.mean(np.where(own_masks[0],c,0),axis=(1,2,3))-np.mean(np.where(own_masks[1],f,0),axis=(1,2,3))
        relative=abs(h0-h1)/abs(h0);field=float(l1.max());share=float(abs(shape_shares).max())
        comparisons.append({'event_id':i,'relative_deposited_heat_change':relative,'normalized_field_L1_max_at_common_snapshots':field,'normalized_field_L1_at_end':float(l1[-1]),'outside025_share_max_change':share,'maximum_field_difference_time':float(coarse['time'][active][np.argmax(l1)]),'amount_within_1_percent':relative<=.01,'normalized_shape_within_1_percent':field<=.01,'outside_share_within_half_percentage_point':share<=.005,'both_crc':[load(OUT/tag/'receipt.json')['writes'][i]['account']['crc'] for tag in TAGS]})
    result={'status':'completed','runs':summaries,'independent_recounts':verification,'time_step_comparison':comparisons,'time_step_all_criteria_pass':all(all(v[k] for k in ['amount_within_1_percent','normalized_shape_within_1_percent','outside_share_within_half_percentage_point']) for v in comparisons),'source_account':'Signed additive contributions on each actual coupled trajectory; not a no-write counterfactual. The net viscous source already subtracts the model extraction term.','boundary':'Periodic unit cube, no wall loss or cooling term in this equation. Wrapping a plotting boundary is not leaving the domain.','negative_values':'Retained and measured; Fourier-filtered tags are signed numerical contributions, not positive particle inventories.','scope':'Historical threshold-1 breathing-on model, 16 cubed, original interval 0 to 1.2 plus new continuation to 1.6; no fourth write. Step refinement only; no grid/continuum convergence claim.','provenance':'AI-generated analysis and diagram; dictated and directed by NousVolition.'}
    dump(OUT/'analysis.json',result)
    print(json.dumps({'runs':summaries,'time_step_comparison':comparisons,'time_step_all_criteria_pass':result['time_step_all_criteria_pass']},indent=2))
if __name__=='__main__':main()
